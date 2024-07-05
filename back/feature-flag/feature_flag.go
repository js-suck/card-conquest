package feature_flag

import (
	"gopkg.in/yaml.v2"
	"io/ioutil"
)

var Configs *Config

type Features struct {
	SendNotification bool `yaml:"send_notification"`
	Grpc             bool `yaml:"grpc"`
}

type Config struct {
	Features Features `yaml:"features"`
}

func LoadConfig(filename string) (*Config, error) {
	data, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}
