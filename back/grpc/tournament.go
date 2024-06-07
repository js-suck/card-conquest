package grpc

import (
	"authentication-api/db"
	"log"
	"strconv"
	"sync"

	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	"authentication-api/services"
	"github.com/google/uuid"
)

type server struct {
	authentication_api.UnimplementedMatchServiceServer
	authentication_api.UnimplementedTournamentServiceServer
	streams map[string]map[string]chan *authentication_api.TournamentResponse
	mu      sync.RWMutex // Use RWMutex for more granular locking
}

func NewServer() *server {
	s := &server{
		streams: make(map[string]map[string]chan *authentication_api.TournamentResponse),
	}

	// Start the goroutine to broadcast updates for all tournaments
	go s.broadcastUpdates()
	return s
}

func (s *server) broadcastUpdates() {
	for update := range services.TournamentUpdates {
		tournamentID := strconv.Itoa(int(update.TournamentId))
		s.mu.RLock()
		streams, exists := s.streams[tournamentID]
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
		}
	}
}

func (s *server) SuscribeTournamentUpdate(req *authentication_api.TournamentRequest, stream authentication_api.TournamentService_SuscribeTournamentUpdateServer) error {
	subscribedTournamentID := strconv.Itoa(int(req.TournamentId))
	clientID := uuid.New().String()
	db := db.DB
	tournamentService := services.NewTournamentService(db)

	s.mu.Lock()
	if _, ok := s.streams[subscribedTournamentID]; !ok {
		s.streams[subscribedTournamentID] = make(map[string]chan *authentication_api.TournamentResponse)
	}
	updateChan := make(chan *authentication_api.TournamentResponse, 200)
	s.streams[subscribedTournamentID][clientID] = updateChan
	s.mu.Unlock()

	tournamentService.SendTournamentUpdatesForGRPC(uint(req.TournamentId))

	log.Printf("Client %s subscribed to tournament %s", clientID, subscribedTournamentID)

	defer func() {
		s.mu.Lock()
		close(s.streams[subscribedTournamentID][clientID])
		delete(s.streams[subscribedTournamentID], clientID)
		if len(s.streams[subscribedTournamentID]) == 0 {
			delete(s.streams, subscribedTournamentID)
		}
		s.mu.Unlock()
		log.Printf("Client %s unsubscribed from tournament %s", clientID, subscribedTournamentID)
	}()

	go func() {
		for update := range updateChan {
			if err := stream.Send(update); err != nil {
				log.Printf("Error sending update to client %s: %v", clientID, err)
				return
			}
			log.Printf("Update sent to client %s for tournament %s", clientID, subscribedTournamentID)
		}
	}()

	<-stream.Context().Done()
	return stream.Context().Err()
}
