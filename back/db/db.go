package db

import (
	"authentication-api/models"
	"cloud.google.com/go/cloudsqlconn"
	"context"
	"database/sql"
	"fmt"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/stdlib"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
	"log"
	"net"
	"os"
	"time"
)

var DB *gorm.DB

func InitDB() (*gorm.DB, error) {
	mustGetenv := func(k string) string {
		v := os.Getenv(k)
		if v == "" {
			log.Fatalf("Fatal Error in connect_connector.go: %s environment variable not set.", k)
		}
		return v
	}

	var (
		dbUser                 = mustGetenv("DATABASE_USERNAME")
		dbPwd                  = mustGetenv("DATABASE_PASSWORD")
		dbName                 = mustGetenv("DATABASE_NAME")
		dbHost                 = os.Getenv("DATABASE_HOST") // e.g. 'localhost' for local, empty for GCP
		dbPort                 = mustGetenv("DATABASE_PORT")
		instanceConnectionName = os.Getenv("INSTANCE_CONNECTION_NAME") // Only needed for GCP
		usePrivate             = os.Getenv("PRIVATE_IP")
	)

	var dsn string
	var sqlDB *sql.DB
	var err error

	if dbHost != "" { // Local connection
		dsn = fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable", dbHost, dbUser, dbPwd, dbName, dbPort)
		sqlDB, err = sql.Open("pgx", dsn)
		if err != nil {
			return nil, fmt.Errorf("sql.Open: %w", err)
		}
	} else { // GCP connection
		dsn = fmt.Sprintf("user=%s password=%s dbname=%s port=%s sslmode=disable", dbUser, dbPwd, dbName, dbPort)
		config, err := pgx.ParseConfig(dsn)
		if err != nil {
			return nil, fmt.Errorf("pgx.ParseConfig: %w", err)
		}

		var opts []cloudsqlconn.Option
		if usePrivate != "" {
			opts = append(opts, cloudsqlconn.WithDefaultDialOptions(cloudsqlconn.WithPrivateIP()))
		}

		d, err := cloudsqlconn.NewDialer(context.Background(), opts...)
		if err != nil {
			return nil, fmt.Errorf("cloudsqlconn.NewDialer: %w", err)
		}

		config.DialFunc = func(ctx context.Context, network, instance string) (net.Conn, error) {
			return d.Dial(ctx, instanceConnectionName)
		}

		dbURI := stdlib.RegisterConnConfig(config)
		sqlDB, err = sql.Open("pgx", dbURI)
		if err != nil {
			return nil, fmt.Errorf("sql.Open: %w", err)
		}
	}

	// Configurer GORM avec sqlDB
	newLogger := logger.New(
		log.New(os.Stdout, "\r\n", log.LstdFlags),
		logger.Config{
			SlowThreshold: time.Second,
			LogLevel:      logger.Info,
			Colorful:      true,
		},
	)

	gormDB, err := gorm.Open(postgres.New(postgres.Config{
		Conn: sqlDB,
	}), &gorm.Config{
		Logger: newLogger,
	})
	if err != nil {
		return nil, fmt.Errorf("gorm.Open: %w", err)
	}

	// Migrer les modèles
	if err := gormDB.AutoMigrate(&models.User{}); err != nil {
		return nil, fmt.Errorf("AutoMigrate: %w", err)
	}

	DB = gormDB
	return gormDB, nil
}
