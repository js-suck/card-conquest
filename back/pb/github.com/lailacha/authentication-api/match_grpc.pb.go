// Code generated by protoc-gen-go-grpc. DO NOT EDIT.
// versions:
// - protoc-gen-go-grpc v1.3.0
// - protoc             v5.26.1
// source: match.proto

package authentication_api

import (
	context "context"
	grpc "google.golang.org/grpc"
	codes "google.golang.org/grpc/codes"
	status "google.golang.org/grpc/status"
)

// This is a compile-time assertion to ensure that this generated file
// is compatible with the grpc package it is being compiled against.
// Requires gRPC-Go v1.32.0 or later.
const _ = grpc.SupportPackageIsVersion7

const (
	MatchService_SubscribeMatchUpdates_FullMethodName = "/protos.MatchService/SubscribeMatchUpdates"
)

// MatchServiceClient is the client API for MatchService service.
//
// For semantics around ctx use and closing/ending streaming RPCs, please refer to https://pkg.go.dev/google.golang.org/grpc/?tab=doc#ClientConn.NewStream.
type MatchServiceClient interface {
	SubscribeMatchUpdates(ctx context.Context, in *MatchRequest, opts ...grpc.CallOption) (MatchService_SubscribeMatchUpdatesClient, error)
}

type matchServiceClient struct {
	cc grpc.ClientConnInterface
}

func NewMatchServiceClient(cc grpc.ClientConnInterface) MatchServiceClient {
	return &matchServiceClient{cc}
}

func (c *matchServiceClient) SubscribeMatchUpdates(ctx context.Context, in *MatchRequest, opts ...grpc.CallOption) (MatchService_SubscribeMatchUpdatesClient, error) {
	stream, err := c.cc.NewStream(ctx, &MatchService_ServiceDesc.Streams[0], MatchService_SubscribeMatchUpdates_FullMethodName, opts...)
	if err != nil {
		return nil, err
	}
	x := &matchServiceSubscribeMatchUpdatesClient{stream}
	if err := x.ClientStream.SendMsg(in); err != nil {
		return nil, err
	}
	if err := x.ClientStream.CloseSend(); err != nil {
		return nil, err
	}
	return x, nil
}

type MatchService_SubscribeMatchUpdatesClient interface {
	Recv() (*MatchResponse, error)
	grpc.ClientStream
}

type matchServiceSubscribeMatchUpdatesClient struct {
	grpc.ClientStream
}

func (x *matchServiceSubscribeMatchUpdatesClient) Recv() (*MatchResponse, error) {
	m := new(MatchResponse)
	if err := x.ClientStream.RecvMsg(m); err != nil {
		return nil, err
	}
	return m, nil
}

// MatchServiceServer is the server API for MatchService service.
// All implementations must embed UnimplementedMatchServiceServer
// for forward compatibility
type MatchServiceServer interface {
	SubscribeMatchUpdates(*MatchRequest, MatchService_SubscribeMatchUpdatesServer) error
	mustEmbedUnimplementedMatchServiceServer()
}

// UnimplementedMatchServiceServer must be embedded to have forward compatible implementations.
type UnimplementedMatchServiceServer struct {
}

func (UnimplementedMatchServiceServer) SubscribeMatchUpdates(*MatchRequest, MatchService_SubscribeMatchUpdatesServer) error {
	return status.Errorf(codes.Unimplemented, "method SubscribeMatchUpdates not implemented")
}
func (UnimplementedMatchServiceServer) mustEmbedUnimplementedMatchServiceServer() {}

// UnsafeMatchServiceServer may be embedded to opt out of forward compatibility for this service.
// Use of this interface is not recommended, as added methods to MatchServiceServer will
// result in compilation errors.
type UnsafeMatchServiceServer interface {
	mustEmbedUnimplementedMatchServiceServer()
}

func RegisterMatchServiceServer(s grpc.ServiceRegistrar, srv MatchServiceServer) {
	s.RegisterService(&MatchService_ServiceDesc, srv)
}

func _MatchService_SubscribeMatchUpdates_Handler(srv interface{}, stream grpc.ServerStream) error {
	m := new(MatchRequest)
	if err := stream.RecvMsg(m); err != nil {
		return err
	}
	return srv.(MatchServiceServer).SubscribeMatchUpdates(m, &matchServiceSubscribeMatchUpdatesServer{stream})
}

type MatchService_SubscribeMatchUpdatesServer interface {
	Send(*MatchResponse) error
	grpc.ServerStream
}

type matchServiceSubscribeMatchUpdatesServer struct {
	grpc.ServerStream
}

func (x *matchServiceSubscribeMatchUpdatesServer) Send(m *MatchResponse) error {
	return x.ServerStream.SendMsg(m)
}

// MatchService_ServiceDesc is the grpc.ServiceDesc for MatchService service.
// It's only intended for direct use with grpc.RegisterService,
// and not to be introspected or modified (even as a copy)
var MatchService_ServiceDesc = grpc.ServiceDesc{
	ServiceName: "protos.MatchService",
	HandlerType: (*MatchServiceServer)(nil),
	Methods:     []grpc.MethodDesc{},
	Streams: []grpc.StreamDesc{
		{
			StreamName:    "SubscribeMatchUpdates",
			Handler:       _MatchService_SubscribeMatchUpdates_Handler,
			ServerStreams: true,
		},
	},
	Metadata: "match.proto",
}
