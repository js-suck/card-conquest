// firebase.go
package firebase

import (
	"context"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
)

type FirebaseClient struct {
	App       *firebase.App
	Messaging *messaging.Client
}

func NewFirebaseClient(serviceAccountKeyPath string) (*FirebaseClient, error) {
	ctx := context.Background()
	sa := option.WithCredentialsFile(serviceAccountKeyPath)
	app, err := firebase.NewApp(ctx, nil, sa)
	if err != nil {
		return nil, err
	}

	messagingClient, err := app.Messaging(ctx)
	if err != nil {
		return nil, err
	}

	return &FirebaseClient{App: app, Messaging: messagingClient}, nil
}

func (f *FirebaseClient) SendNotification(token, title, body string) (string, error) {
	message := &messaging.Message{
		Notification: &messaging.Notification{
			Title: title,
			Body:  body,
		},
		Token: token,
	}

	response, err := f.Messaging.Send(context.Background(), message)
	if err != nil {
		return "", err
	}

	return response, nil
}
