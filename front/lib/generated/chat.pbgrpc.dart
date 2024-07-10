//
//  Generated code. Do not modify.
//  source: chat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'chat.pb.dart' as $0;

export 'chat.pb.dart';

class ChatServiceClient extends $grpc.Client {
  static final _$sendMessage = $grpc.ClientMethod<$0.ChatMessage, $0.Empty>(
      '/protos.ChatService/SendMessage',
      ($0.ChatMessage value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$join = $grpc.ClientMethod<$0.JoinRequest, $0.ChatHistoryMessage>(
      '/protos.ChatService/Join',
      ($0.JoinRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ChatHistoryMessage.fromBuffer(value));
  static final _$getChatHistory = $grpc.ClientMethod<$0.HistoryRequest, $0.HistoryResponse>(
      '/protos.ChatService/GetChatHistory',
      ($0.HistoryRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.HistoryResponse.fromBuffer(value));

  ChatServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.Empty> sendMessage($0.ChatMessage request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  $grpc.ResponseStream<$0.ChatHistoryMessage> join($0.JoinRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$join, $async.Stream.fromIterable([request]), options: options);
  }

  $grpc.ResponseFuture<$0.HistoryResponse> getChatHistory($0.HistoryRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getChatHistory, request, options: options);
  }
}

abstract class ChatServiceBase extends $grpc.Service {
  $core.String get $name => 'protos.ChatService';

  ChatServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ChatMessage, $0.Empty>(
        'SendMessage',
        sendMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ChatMessage.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.JoinRequest, $0.ChatHistoryMessage>(
        'Join',
        join_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.JoinRequest.fromBuffer(value),
        ($0.ChatHistoryMessage value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HistoryRequest, $0.HistoryResponse>(
        'GetChatHistory',
        getChatHistory_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HistoryRequest.fromBuffer(value),
        ($0.HistoryResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> sendMessage_Pre($grpc.ServiceCall call, $async.Future<$0.ChatMessage> request) async {
    return sendMessage(call, await request);
  }

  $async.Stream<$0.ChatHistoryMessage> join_Pre($grpc.ServiceCall call, $async.Future<$0.JoinRequest> request) async* {
    yield* join(call, await request);
  }

  $async.Future<$0.HistoryResponse> getChatHistory_Pre($grpc.ServiceCall call, $async.Future<$0.HistoryRequest> request) async {
    return getChatHistory(call, await request);
  }

  $async.Future<$0.Empty> sendMessage($grpc.ServiceCall call, $0.ChatMessage request);
  $async.Stream<$0.ChatHistoryMessage> join($grpc.ServiceCall call, $0.JoinRequest request);
  $async.Future<$0.HistoryResponse> getChatHistory($grpc.ServiceCall call, $0.HistoryRequest request);
}
