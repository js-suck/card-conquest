// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.34.2
// 	protoc        v5.27.1
// source: tournament.proto

package authentication_api

import (
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

type Player struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Username string `protobuf:"bytes,1,opt,name=username,proto3" json:"username,omitempty"`
	UserId   string `protobuf:"bytes,2,opt,name=userId,proto3" json:"userId,omitempty"`
	Score    int32  `protobuf:"varint,3,opt,name=score,proto3" json:"score,omitempty"`
}

func (x *Player) Reset() {
	*x = Player{}
	if protoimpl.UnsafeEnabled {
		mi := &file_tournament_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Player) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Player) ProtoMessage() {}

func (x *Player) ProtoReflect() protoreflect.Message {
	mi := &file_tournament_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Player.ProtoReflect.Descriptor instead.
func (*Player) Descriptor() ([]byte, []int) {
	return file_tournament_proto_rawDescGZIP(), []int{0}
}

func (x *Player) GetUsername() string {
	if x != nil {
		return x.Username
	}
	return ""
}

func (x *Player) GetUserId() string {
	if x != nil {
		return x.UserId
	}
	return ""
}

func (x *Player) GetScore() int32 {
	if x != nil {
		return x.Score
	}
	return 0
}

type Match struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Position  int32   `protobuf:"varint,1,opt,name=position,proto3" json:"position,omitempty"`
	PlayerOne *Player `protobuf:"bytes,2,opt,name=player_one,json=playerOne,proto3" json:"player_one,omitempty"`
	PlayerTwo *Player `protobuf:"bytes,3,opt,name=player_two,json=playerTwo,proto3" json:"player_two,omitempty"`
	Status    string  `protobuf:"bytes,4,opt,name=status,proto3" json:"status,omitempty"`
	WinnerId  int32   `protobuf:"varint,5,opt,name=winner_id,json=winnerId,proto3" json:"winner_id,omitempty"`
	MatchId   int32   `protobuf:"varint,6,opt,name=match_id,json=matchId,proto3" json:"match_id,omitempty"`
	Location  string  `protobuf:"bytes,7,opt,name=location,proto3" json:"location,omitempty"`
	StartTime string  `protobuf:"bytes,8,opt,name=startTime,proto3" json:"startTime,omitempty"`
}

func (x *Match) Reset() {
	*x = Match{}
	if protoimpl.UnsafeEnabled {
		mi := &file_tournament_proto_msgTypes[1]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *Match) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*Match) ProtoMessage() {}

func (x *Match) ProtoReflect() protoreflect.Message {
	mi := &file_tournament_proto_msgTypes[1]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use Match.ProtoReflect.Descriptor instead.
func (*Match) Descriptor() ([]byte, []int) {
	return file_tournament_proto_rawDescGZIP(), []int{1}
}

func (x *Match) GetPosition() int32 {
	if x != nil {
		return x.Position
	}
	return 0
}

func (x *Match) GetPlayerOne() *Player {
	if x != nil {
		return x.PlayerOne
	}
	return nil
}

func (x *Match) GetPlayerTwo() *Player {
	if x != nil {
		return x.PlayerTwo
	}
	return nil
}

func (x *Match) GetStatus() string {
	if x != nil {
		return x.Status
	}
	return ""
}

func (x *Match) GetWinnerId() int32 {
	if x != nil {
		return x.WinnerId
	}
	return 0
}

func (x *Match) GetMatchId() int32 {
	if x != nil {
		return x.MatchId
	}
	return 0
}

func (x *Match) GetLocation() string {
	if x != nil {
		return x.Location
	}
	return ""
}

func (x *Match) GetStartTime() string {
	if x != nil {
		return x.StartTime
	}
	return ""
}

type TournamentStep struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	Step    int32    `protobuf:"varint,1,opt,name=step,proto3" json:"step,omitempty"`
	Matches []*Match `protobuf:"bytes,2,rep,name=matches,proto3" json:"matches,omitempty"`
}

func (x *TournamentStep) Reset() {
	*x = TournamentStep{}
	if protoimpl.UnsafeEnabled {
		mi := &file_tournament_proto_msgTypes[2]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *TournamentStep) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*TournamentStep) ProtoMessage() {}

func (x *TournamentStep) ProtoReflect() protoreflect.Message {
	mi := &file_tournament_proto_msgTypes[2]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use TournamentStep.ProtoReflect.Descriptor instead.
func (*TournamentStep) Descriptor() ([]byte, []int) {
	return file_tournament_proto_rawDescGZIP(), []int{2}
}

func (x *TournamentStep) GetStep() int32 {
	if x != nil {
		return x.Step
	}
	return 0
}

func (x *TournamentStep) GetMatches() []*Match {
	if x != nil {
		return x.Matches
	}
	return nil
}

type TournamentResponse struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	TournamentId     int32             `protobuf:"varint,1,opt,name=tournament_id,json=tournamentId,proto3" json:"tournament_id,omitempty"`
	TournamentName   string            `protobuf:"bytes,2,opt,name=tournament_name,json=tournamentName,proto3" json:"tournament_name,omitempty"`
	TournamentStatus string            `protobuf:"bytes,3,opt,name=tournament_status,json=tournamentStatus,proto3" json:"tournament_status,omitempty"`
	TournamentSteps  []*TournamentStep `protobuf:"bytes,4,rep,name=tournament_steps,json=tournamentSteps,proto3" json:"tournament_steps,omitempty"`
}

func (x *TournamentResponse) Reset() {
	*x = TournamentResponse{}
	if protoimpl.UnsafeEnabled {
		mi := &file_tournament_proto_msgTypes[3]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *TournamentResponse) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*TournamentResponse) ProtoMessage() {}

func (x *TournamentResponse) ProtoReflect() protoreflect.Message {
	mi := &file_tournament_proto_msgTypes[3]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use TournamentResponse.ProtoReflect.Descriptor instead.
func (*TournamentResponse) Descriptor() ([]byte, []int) {
	return file_tournament_proto_rawDescGZIP(), []int{3}
}

func (x *TournamentResponse) GetTournamentId() int32 {
	if x != nil {
		return x.TournamentId
	}
	return 0
}

func (x *TournamentResponse) GetTournamentName() string {
	if x != nil {
		return x.TournamentName
	}
	return ""
}

func (x *TournamentResponse) GetTournamentStatus() string {
	if x != nil {
		return x.TournamentStatus
	}
	return ""
}

func (x *TournamentResponse) GetTournamentSteps() []*TournamentStep {
	if x != nil {
		return x.TournamentSteps
	}
	return nil
}

type TournamentRequest struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	TournamentId int32 `protobuf:"varint,1,opt,name=tournament_id,json=tournamentId,proto3" json:"tournament_id,omitempty"`
}

func (x *TournamentRequest) Reset() {
	*x = TournamentRequest{}
	if protoimpl.UnsafeEnabled {
		mi := &file_tournament_proto_msgTypes[4]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *TournamentRequest) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*TournamentRequest) ProtoMessage() {}

func (x *TournamentRequest) ProtoReflect() protoreflect.Message {
	mi := &file_tournament_proto_msgTypes[4]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use TournamentRequest.ProtoReflect.Descriptor instead.
func (*TournamentRequest) Descriptor() ([]byte, []int) {
	return file_tournament_proto_rawDescGZIP(), []int{4}
}

func (x *TournamentRequest) GetTournamentId() int32 {
	if x != nil {
		return x.TournamentId
	}
	return 0
}

var File_tournament_proto protoreflect.FileDescriptor

var file_tournament_proto_rawDesc = []byte{
	0x0a, 0x10, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x2e, 0x70, 0x72, 0x6f,
	0x74, 0x6f, 0x12, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x73, 0x22, 0x52, 0x0a, 0x06, 0x50, 0x6c,
	0x61, 0x79, 0x65, 0x72, 0x12, 0x1a, 0x0a, 0x08, 0x75, 0x73, 0x65, 0x72, 0x6e, 0x61, 0x6d, 0x65,
	0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x08, 0x75, 0x73, 0x65, 0x72, 0x6e, 0x61, 0x6d, 0x65,
	0x12, 0x16, 0x0a, 0x06, 0x75, 0x73, 0x65, 0x72, 0x49, 0x64, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09,
	0x52, 0x06, 0x75, 0x73, 0x65, 0x72, 0x49, 0x64, 0x12, 0x14, 0x0a, 0x05, 0x73, 0x63, 0x6f, 0x72,
	0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x05, 0x52, 0x05, 0x73, 0x63, 0x6f, 0x72, 0x65, 0x22, 0x8b,
	0x02, 0x0a, 0x05, 0x4d, 0x61, 0x74, 0x63, 0x68, 0x12, 0x1a, 0x0a, 0x08, 0x70, 0x6f, 0x73, 0x69,
	0x74, 0x69, 0x6f, 0x6e, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52, 0x08, 0x70, 0x6f, 0x73, 0x69,
	0x74, 0x69, 0x6f, 0x6e, 0x12, 0x2d, 0x0a, 0x0a, 0x70, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x5f, 0x6f,
	0x6e, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x0e, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f,
	0x73, 0x2e, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x52, 0x09, 0x70, 0x6c, 0x61, 0x79, 0x65, 0x72,
	0x4f, 0x6e, 0x65, 0x12, 0x2d, 0x0a, 0x0a, 0x70, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x5f, 0x74, 0x77,
	0x6f, 0x18, 0x03, 0x20, 0x01, 0x28, 0x0b, 0x32, 0x0e, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x73,
	0x2e, 0x50, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x52, 0x09, 0x70, 0x6c, 0x61, 0x79, 0x65, 0x72, 0x54,
	0x77, 0x6f, 0x12, 0x16, 0x0a, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x18, 0x04, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x06, 0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x12, 0x1b, 0x0a, 0x09, 0x77, 0x69,
	0x6e, 0x6e, 0x65, 0x72, 0x5f, 0x69, 0x64, 0x18, 0x05, 0x20, 0x01, 0x28, 0x05, 0x52, 0x08, 0x77,
	0x69, 0x6e, 0x6e, 0x65, 0x72, 0x49, 0x64, 0x12, 0x19, 0x0a, 0x08, 0x6d, 0x61, 0x74, 0x63, 0x68,
	0x5f, 0x69, 0x64, 0x18, 0x06, 0x20, 0x01, 0x28, 0x05, 0x52, 0x07, 0x6d, 0x61, 0x74, 0x63, 0x68,
	0x49, 0x64, 0x12, 0x1a, 0x0a, 0x08, 0x6c, 0x6f, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x18, 0x07,
	0x20, 0x01, 0x28, 0x09, 0x52, 0x08, 0x6c, 0x6f, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x12, 0x1c,
	0x0a, 0x09, 0x73, 0x74, 0x61, 0x72, 0x74, 0x54, 0x69, 0x6d, 0x65, 0x18, 0x08, 0x20, 0x01, 0x28,
	0x09, 0x52, 0x09, 0x73, 0x74, 0x61, 0x72, 0x74, 0x54, 0x69, 0x6d, 0x65, 0x22, 0x4d, 0x0a, 0x0e,
	0x54, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x53, 0x74, 0x65, 0x70, 0x12, 0x12,
	0x0a, 0x04, 0x73, 0x74, 0x65, 0x70, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52, 0x04, 0x73, 0x74,
	0x65, 0x70, 0x12, 0x27, 0x0a, 0x07, 0x6d, 0x61, 0x74, 0x63, 0x68, 0x65, 0x73, 0x18, 0x02, 0x20,
	0x03, 0x28, 0x0b, 0x32, 0x0d, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x73, 0x2e, 0x4d, 0x61, 0x74,
	0x63, 0x68, 0x52, 0x07, 0x6d, 0x61, 0x74, 0x63, 0x68, 0x65, 0x73, 0x22, 0xd2, 0x01, 0x0a, 0x12,
	0x54, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e,
	0x73, 0x65, 0x12, 0x23, 0x0a, 0x0d, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74,
	0x5f, 0x69, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52, 0x0c, 0x74, 0x6f, 0x75, 0x72, 0x6e,
	0x61, 0x6d, 0x65, 0x6e, 0x74, 0x49, 0x64, 0x12, 0x27, 0x0a, 0x0f, 0x74, 0x6f, 0x75, 0x72, 0x6e,
	0x61, 0x6d, 0x65, 0x6e, 0x74, 0x5f, 0x6e, 0x61, 0x6d, 0x65, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09,
	0x52, 0x0e, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x4e, 0x61, 0x6d, 0x65,
	0x12, 0x2b, 0x0a, 0x11, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x5f, 0x73,
	0x74, 0x61, 0x74, 0x75, 0x73, 0x18, 0x03, 0x20, 0x01, 0x28, 0x09, 0x52, 0x10, 0x74, 0x6f, 0x75,
	0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x53, 0x74, 0x61, 0x74, 0x75, 0x73, 0x12, 0x41, 0x0a,
	0x10, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x5f, 0x73, 0x74, 0x65, 0x70,
	0x73, 0x18, 0x04, 0x20, 0x03, 0x28, 0x0b, 0x32, 0x16, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x73,
	0x2e, 0x54, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x53, 0x74, 0x65, 0x70, 0x52,
	0x0f, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x53, 0x74, 0x65, 0x70, 0x73,
	0x22, 0x38, 0x0a, 0x11, 0x54, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x52, 0x65,
	0x71, 0x75, 0x65, 0x73, 0x74, 0x12, 0x23, 0x0a, 0x0d, 0x74, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d,
	0x65, 0x6e, 0x74, 0x5f, 0x69, 0x64, 0x18, 0x01, 0x20, 0x01, 0x28, 0x05, 0x52, 0x0c, 0x74, 0x6f,
	0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x49, 0x64, 0x32, 0x68, 0x0a, 0x11, 0x54, 0x6f,
	0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x53, 0x65, 0x72, 0x76, 0x69, 0x63, 0x65, 0x12,
	0x53, 0x0a, 0x18, 0x53, 0x75, 0x73, 0x63, 0x72, 0x69, 0x62, 0x65, 0x54, 0x6f, 0x75, 0x72, 0x6e,
	0x61, 0x6d, 0x65, 0x6e, 0x74, 0x55, 0x70, 0x64, 0x61, 0x74, 0x65, 0x12, 0x19, 0x2e, 0x70, 0x72,
	0x6f, 0x74, 0x6f, 0x73, 0x2e, 0x54, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x52,
	0x65, 0x71, 0x75, 0x65, 0x73, 0x74, 0x1a, 0x1a, 0x2e, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x73, 0x2e,
	0x54, 0x6f, 0x75, 0x72, 0x6e, 0x61, 0x6d, 0x65, 0x6e, 0x74, 0x52, 0x65, 0x73, 0x70, 0x6f, 0x6e,
	0x73, 0x65, 0x30, 0x01, 0x42, 0x28, 0x5a, 0x26, 0x67, 0x69, 0x74, 0x68, 0x75, 0x62, 0x2e, 0x63,
	0x6f, 0x6d, 0x2f, 0x6c, 0x61, 0x69, 0x6c, 0x61, 0x63, 0x68, 0x61, 0x2f, 0x61, 0x75, 0x74, 0x68,
	0x65, 0x6e, 0x74, 0x69, 0x63, 0x61, 0x74, 0x69, 0x6f, 0x6e, 0x2d, 0x61, 0x70, 0x69, 0x62, 0x06,
	0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_tournament_proto_rawDescOnce sync.Once
	file_tournament_proto_rawDescData = file_tournament_proto_rawDesc
)

func file_tournament_proto_rawDescGZIP() []byte {
	file_tournament_proto_rawDescOnce.Do(func() {
		file_tournament_proto_rawDescData = protoimpl.X.CompressGZIP(file_tournament_proto_rawDescData)
	})
	return file_tournament_proto_rawDescData
}

var file_tournament_proto_msgTypes = make([]protoimpl.MessageInfo, 5)
var file_tournament_proto_goTypes = []any{
	(*Player)(nil),             // 0: protos.Player
	(*Match)(nil),              // 1: protos.Match
	(*TournamentStep)(nil),     // 2: protos.TournamentStep
	(*TournamentResponse)(nil), // 3: protos.TournamentResponse
	(*TournamentRequest)(nil),  // 4: protos.TournamentRequest
}
var file_tournament_proto_depIdxs = []int32{
	0, // 0: protos.Match.player_one:type_name -> protos.Player
	0, // 1: protos.Match.player_two:type_name -> protos.Player
	1, // 2: protos.TournamentStep.matches:type_name -> protos.Match
	2, // 3: protos.TournamentResponse.tournament_steps:type_name -> protos.TournamentStep
	4, // 4: protos.TournamentService.SuscribeTournamentUpdate:input_type -> protos.TournamentRequest
	3, // 5: protos.TournamentService.SuscribeTournamentUpdate:output_type -> protos.TournamentResponse
	5, // [5:6] is the sub-list for method output_type
	4, // [4:5] is the sub-list for method input_type
	4, // [4:4] is the sub-list for extension type_name
	4, // [4:4] is the sub-list for extension extendee
	0, // [0:4] is the sub-list for field type_name
}

func init() { file_tournament_proto_init() }
func file_tournament_proto_init() {
	if File_tournament_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_tournament_proto_msgTypes[0].Exporter = func(v any, i int) any {
			switch v := v.(*Player); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_tournament_proto_msgTypes[1].Exporter = func(v any, i int) any {
			switch v := v.(*Match); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_tournament_proto_msgTypes[2].Exporter = func(v any, i int) any {
			switch v := v.(*TournamentStep); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_tournament_proto_msgTypes[3].Exporter = func(v any, i int) any {
			switch v := v.(*TournamentResponse); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
		file_tournament_proto_msgTypes[4].Exporter = func(v any, i int) any {
			switch v := v.(*TournamentRequest); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_tournament_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   5,
			NumExtensions: 0,
			NumServices:   1,
		},
		GoTypes:           file_tournament_proto_goTypes,
		DependencyIndexes: file_tournament_proto_depIdxs,
		MessageInfos:      file_tournament_proto_msgTypes,
	}.Build()
	File_tournament_proto = out.File
	file_tournament_proto_rawDesc = nil
	file_tournament_proto_goTypes = nil
	file_tournament_proto_depIdxs = nil
}
