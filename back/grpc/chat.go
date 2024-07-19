package grpc

import (
	"authentication-api/db"
	"authentication-api/models"
	authentication_api "authentication-api/pb/github.com/lailacha/authentication-api"
	service "authentication-api/services"
	"context"
	"strconv"
	"sync"
)

type chatServer struct {
	authentication_api.UnimplementedChatServiceServer
	mu     sync.Mutex
	guilds map[string][]chan *authentication_api.ChatHistoryMessage
}

func NewChatServer() *chatServer {
	return &chatServer{
		guilds: make(map[string][]chan *authentication_api.ChatHistoryMessage),
	}
}

func (s *chatServer) SendMessage(ctx context.Context, msg *authentication_api.ChatMessage) (*authentication_api.Empty, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	user := models.User{}
	userService := service.NewUserService(db.DB)
	err := userService.Get(&user, uint(msg.UserId), "Media")

	if err != nil {
		return nil, err
	}

	// Store the message in the database
	chatMessage := models.ChatMessage{
		Content:   msg.Content,
		Timestamp: msg.Timestamp,
		Username:  msg.Username,
		UserId:    int(msg.UserId),
		GuildId:   int(msg.GuildId),
	}
	db.DB.Create(&chatMessage)

	chatHMessage := authentication_api.ChatHistoryMessage{
		Content:   msg.Content,
		Timestamp: msg.Timestamp,
		User: &authentication_api.User{
			Id:       msg.UserId,
			Username: user.Username,
		},
	}

	if user.Media != nil {
		chatHMessage.User.MediaUrl = user.Media.FileName
	}

	if channels, ok := s.guilds[string(msg.GuildId)]; ok {
		for _, ch := range channels {
			ch <- &chatHMessage
		}
	}

	return &authentication_api.Empty{}, nil
}

func (s *chatServer) Join(req *authentication_api.JoinRequest, stream authentication_api.ChatService_JoinServer) error {
	ch := make(chan *authentication_api.ChatHistoryMessage, 100)

	s.mu.Lock()
	s.guilds[string(req.GuildId)] = append(s.guilds[string(req.GuildId)], ch)
	s.mu.Unlock()

	defer func() {
		s.mu.Lock()
		defer s.mu.Unlock()

		channels := s.guilds[string(req.GuildId)]
		for i, c := range channels {
			if c == ch {
				s.guilds[string(req.GuildId)] = append(channels[:i], channels[i+1:]...)
				break
			}
		}
	}()

	for msg := range ch {
		if err := stream.Send(msg); err != nil {
			return err
		}
	}

	return nil
}

func (s *chatServer) GetChatHistory(ctx context.Context, req *authentication_api.HistoryRequest) (*authentication_api.HistoryResponse, error) {
	var messages []authentication_api.ChatMessage
	if err := db.DB.Where("guild_id = ?", strconv.Itoa(int(req.GuildId))).Order("timestamp").Find(&messages).Error; err != nil {
		return nil, err
	}

	var chatMessages []*authentication_api.ChatHistoryMessage
	for _, msg := range messages {
		user := models.User{}
		userService := service.NewUserService(db.DB)
		err := userService.Get(&user, uint(msg.UserId), "Media")

		// Skip the message if the user is not found
		if err != nil {
			continue
		}

		chatMessages = append(chatMessages, &authentication_api.ChatHistoryMessage{
			Content:   msg.Content,
			Timestamp: msg.Timestamp,
			User: &authentication_api.User{
				Id:       msg.UserId,
				Username: user.Username,
			},
		})

		if user.Media != nil {
			chatMessages[len(chatMessages)-1].User.MediaUrl = user.Media.FileName
		}
	}

	return &authentication_api.HistoryResponse{Messages: chatMessages}, nil
}
