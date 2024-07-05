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

type tournamentServer struct {
	authentication_api.UnimplementedTournamentServiceServer
	tournamentStreams map[string]map[string]chan *authentication_api.TournamentResponse
	mu                sync.RWMutex
}

func NewTournamentServer() *tournamentServer {
	s := &tournamentServer{
		tournamentStreams: make(map[string]map[string]chan *authentication_api.TournamentResponse),
	}
	go s.broadcastTournamentUpdates()
	return s
}

func (s *tournamentServer) broadcastTournamentUpdates() {
	for update := range services.TournamentUpdates {
		tournamentID := strconv.Itoa(int(update.TournamentId))
		s.mu.RLock()
		streams, exists := s.tournamentStreams[tournamentID]
		s.mu.RUnlock()
		if exists {
			for clientID, clientChan := range streams {
				select {
				case clientChan <- update:
					log.Printf("Queued update for client %s in tournament %s", clientID, tournamentID)
				default:
					log.Printf("Client %s update channel full, skipping update for tournament %s", clientID, tournamentID)
				}
			}
		} else {
			log.Printf("No clients subscribed to tournament %s", tournamentID)
		}
	}
}

func (s *tournamentServer) SuscribeTournamentUpdate(req *authentication_api.TournamentRequest, stream authentication_api.TournamentService_SuscribeTournamentUpdateServer) error {
	clientID := uuid.New().String()

	tournamentID := strconv.Itoa(int(req.TournamentId))

	s.mu.Lock()
	if _, ok := s.tournamentStreams[tournamentID]; !ok {
		s.tournamentStreams[tournamentID] = make(map[string]chan *authentication_api.TournamentResponse)
	}
	updateChan := make(chan *authentication_api.TournamentResponse, 200)
	s.tournamentStreams[tournamentID][clientID] = updateChan
	s.mu.Unlock()

	tournamentService := services.NewTournamentService(db.DB)
	go func() {
		log.Printf("Sending initial tournament update for tournament %s", tournamentID)
		tournamentService.SendTournamentUpdatesForGRPC(uint(req.TournamentId))
	}()

	log.Printf("Client %s subscribed to tournament %s", clientID, tournamentID)

	defer func() {
		s.mu.Lock()
		close(s.tournamentStreams[tournamentID][clientID])
		delete(s.tournamentStreams[tournamentID], clientID)
		if len(s.tournamentStreams[tournamentID]) == 0 {
			delete(s.tournamentStreams, tournamentID)
		}
		s.mu.Unlock()
		log.Printf("Client %s unsubscribed from tournament %s", clientID, tournamentID)
	}()

	go func() {
		for update := range updateChan {
			if err := stream.Send(update); err != nil {
				log.Printf("Error sending update to client %s: %v", clientID, err)
				return
			}
			log.Printf("Update sent to client %s for tournament %s", clientID, tournamentID)
		}
	}()

	<-stream.Context().Done()
	return stream.Context().Err()
}
