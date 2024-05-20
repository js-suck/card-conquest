//
//  Generated code. Do not modify.
//  source: tournament.proto
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

import 'tournament.pb.dart' as $0;

export 'tournament.pb.dart';

@$pb.GrpcServiceName('protos.TournamentService')
class TournamentServiceClient extends $grpc.Client {
  static final _$suscribeTournamentUpdate = $grpc.ClientMethod<$0.TournamentRequest, $0.TournamentResponse>(
      '/protos.TournamentService/SuscribeTournamentUpdate',
      ($0.TournamentRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TournamentResponse.fromBuffer(value));

  TournamentServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseStream<$0.TournamentResponse> suscribeTournamentUpdate($0.TournamentRequest request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$suscribeTournamentUpdate, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('protos.TournamentService')
abstract class TournamentServiceBase extends $grpc.Service {
  $core.String get $name => 'protos.TournamentService';

  TournamentServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.TournamentRequest, $0.TournamentResponse>(
        'SuscribeTournamentUpdate',
        suscribeTournamentUpdate_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.TournamentRequest.fromBuffer(value),
        ($0.TournamentResponse value) => value.writeToBuffer()));
  }

  $async.Stream<$0.TournamentResponse> suscribeTournamentUpdate_Pre($grpc.ServiceCall call, $async.Future<$0.TournamentRequest> request) async* {
    yield* suscribeTournamentUpdate(call, await request);
  }

  $async.Stream<$0.TournamentResponse> suscribeTournamentUpdate($grpc.ServiceCall call, $0.TournamentRequest request);
}
