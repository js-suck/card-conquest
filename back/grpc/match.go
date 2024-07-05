package grpc

import (
	"authentication-api/db"
	"github.com/google/uuid"
	"log"
	"strconv"
	"sync"

	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	"authentication-api/services"
)

type matchServer struct {
	authentication_api.UnimplementedMatchServiceServer
	matchStreams map[string]map[string]chan *authentication_api.MatchResponse
	mu           sync.RWMutex
}

func NewMatchServer() *matchServer {
	s := &matchServer{
		matchStreams: make(map[string]map[string]chan *authentication_api.MatchResponse),
	}
	go s.broadcastMatchUpdates()
	return s
}

func (s *matchServer) broadcastMatchUpdates() {
	for update := range services.MatchUpdates {
		matchID := strconv.Itoa(int(update.MatchId))
		s.mu.RLock()
		streams, exists := s.matchStreams[matchID]
		s.mu.RUnlock()
		if exists {
			for clientID, clientChan := range streams {
				select {
				case clientChan <- update:
					log.Printf("Queued update for client %s in match %s", clientID, matchID)
				default:
					log.Printf("Client %s update channel full, skipping update for match %s", clientID, matchID)
				}
			}
		} else {
			log.Printf("No clients subscribed to match %s", matchID)
		}
	}
}

func (s *matchServer) SubscribeMatchUpdates(req *authentication_api.MatchRequest, stream authentication_api.MatchService_SubscribeMatchUpdatesServer) error {
	clientID := uuid.New().String()

	matchID := strconv.Itoa(int(req.MatchId))

	s.mu.Lock()
	if _, ok := s.matchStreams[matchID]; !ok {
		s.matchStreams[matchID] = make(map[string]chan *authentication_api.MatchResponse)
	}
	updateChan := make(chan *authentication_api.MatchResponse, 200)
	s.matchStreams[matchID][clientID] = updateChan
	s.mu.Unlock()

	matchService := services.NewMatchService(db.DB)
	go func() {
		log.Printf("Sending initial match update for match %s", matchID)
		matchService.SendMatchUpdatesForGRPC(uint(req.MatchId))
	}()

	log.Printf("Client %s subscribed to match %s", clientID, matchID)

	defer func() {
		s.mu.Lock()
		close(s.matchStreams[matchID][clientID])
		delete(s.matchStreams[matchID], clientID)
		if len(s.matchStreams[matchID]) == 0 {
			delete(s.matchStreams, matchID)
		}
		s.mu.Unlock()
		log.Printf("Client %s unsubscribed from match %s", clientID, matchID)
	}()

	go func() {
		for update := range updateChan {
			if err := stream.Send(update); err != nil {
				log.Printf("Error sending update to client %s: %v", clientID, err)
				return
			}
			log.Printf("Update sent to client %s for match %s", clientID, matchID)
		}
	}()

	<-stream.Context().Done()
	return stream.Context().Err()
}
