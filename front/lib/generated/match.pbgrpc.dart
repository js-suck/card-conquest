//
//  Generated code. Do not modify.
//  source: match.proto
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

import 'match.pb.dart' as $0;

export 'match.pb.dart';

class MatchServiceClient extends $grpc.Client {
  static final _$subscribeMatchUpdates =
      $grpc.ClientMethod<$0.MatchRequest, $0.MatchResponse>(
          '/protos.MatchService/SubscribeMatchUpdates',
          ($0.MatchRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.MatchResponse.fromBuffer(value));

  MatchServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseStream<$0.MatchResponse> subscribeMatchUpdates(
      $0.MatchRequest request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$subscribeMatchUpdates, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class MatchServiceBase extends $grpc.Service {
  $core.String get $name => 'protos.MatchService';

  MatchServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.MatchRequest, $0.MatchResponse>(
        'SubscribeMatchUpdates',
        subscribeMatchUpdates_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.MatchRequest.fromBuffer(value),
        ($0.MatchResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.MatchResponse> subscribeMatchUpdates_Pre(
      $grpc.ServiceCall call, $async.Future<$0.MatchRequest> request) async* {
    yield* subscribeMatchUpdates(call, await request);
  }

  $async.Stream<$0.MatchResponse> subscribeMatchUpdates(
      $grpc.ServiceCall call, $0.MatchRequest request);
}
