//
//  Generated code. Do not modify.
//  source: tournament.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use playerDescriptor instead')
const Player$json = {
  '1': 'Player',
  '2': [
    {'1': 'username', '3': 1, '4': 1, '5': 9, '10': 'username'},
    {'1': 'userId', '3': 2, '4': 1, '5': 9, '10': 'userId'},
    {'1': 'score', '3': 3, '4': 1, '5': 5, '10': 'score'},
  ],
};

/// Descriptor for `Player`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List playerDescriptor = $convert.base64Decode(
    'CgZQbGF5ZXISGgoIdXNlcm5hbWUYASABKAlSCHVzZXJuYW1lEhYKBnVzZXJJZBgCIAEoCVIGdX'
    'NlcklkEhQKBXNjb3JlGAMgASgFUgVzY29yZQ==');

@$core.Deprecated('Use matchDescriptor instead')
const Match$json = {
  '1': 'Match',
  '2': [
    {'1': 'position', '3': 1, '4': 1, '5': 5, '10': 'position'},
    {'1': 'player_one', '3': 2, '4': 1, '5': 11, '6': '.protos.Player', '10': 'playerOne'},
    {'1': 'player_two', '3': 3, '4': 1, '5': 11, '6': '.protos.Player', '10': 'playerTwo'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'winner_id', '3': 5, '4': 1, '5': 5, '10': 'winnerId'},
    {'1': 'match_id', '3': 6, '4': 1, '5': 5, '10': 'matchId'},
  ],
};

/// Descriptor for `Match`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchDescriptor = $convert.base64Decode(
    'CgVNYXRjaBIaCghwb3NpdGlvbhgBIAEoBVIIcG9zaXRpb24SLQoKcGxheWVyX29uZRgCIAEoCz'
    'IOLnByb3Rvcy5QbGF5ZXJSCXBsYXllck9uZRItCgpwbGF5ZXJfdHdvGAMgASgLMg4ucHJvdG9z'
    'LlBsYXllclIJcGxheWVyVHdvEhYKBnN0YXR1cxgEIAEoCVIGc3RhdHVzEhsKCXdpbm5lcl9pZB'
    'gFIAEoBVIId2lubmVySWQSGQoIbWF0Y2hfaWQYBiABKAVSB21hdGNoSWQ=');

@$core.Deprecated('Use tournamentStepDescriptor instead')
const TournamentStep$json = {
  '1': 'TournamentStep',
  '2': [
    {'1': 'step', '3': 1, '4': 1, '5': 5, '10': 'step'},
    {'1': 'matches', '3': 2, '4': 3, '5': 11, '6': '.protos.Match', '10': 'matches'},
  ],
};

/// Descriptor for `TournamentStep`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tournamentStepDescriptor = $convert.base64Decode(
    'Cg5Ub3VybmFtZW50U3RlcBISCgRzdGVwGAEgASgFUgRzdGVwEicKB21hdGNoZXMYAiADKAsyDS'
    '5wcm90b3MuTWF0Y2hSB21hdGNoZXM=');

@$core.Deprecated('Use tournamentResponseDescriptor instead')
const TournamentResponse$json = {
  '1': 'TournamentResponse',
  '2': [
    {'1': 'tournament_id', '3': 1, '4': 1, '5': 5, '10': 'tournamentId'},
    {'1': 'tournament_name', '3': 2, '4': 1, '5': 9, '10': 'tournamentName'},
    {'1': 'tournament_status', '3': 3, '4': 1, '5': 9, '10': 'tournamentStatus'},
    {'1': 'tournament_steps', '3': 4, '4': 3, '5': 11, '6': '.protos.TournamentStep', '10': 'tournamentSteps'},
  ],
};

/// Descriptor for `TournamentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tournamentResponseDescriptor = $convert.base64Decode(
    'ChJUb3VybmFtZW50UmVzcG9uc2USIwoNdG91cm5hbWVudF9pZBgBIAEoBVIMdG91cm5hbWVudE'
    'lkEicKD3RvdXJuYW1lbnRfbmFtZRgCIAEoCVIOdG91cm5hbWVudE5hbWUSKwoRdG91cm5hbWVu'
    'dF9zdGF0dXMYAyABKAlSEHRvdXJuYW1lbnRTdGF0dXMSQQoQdG91cm5hbWVudF9zdGVwcxgEIA'
    'MoCzIWLnByb3Rvcy5Ub3VybmFtZW50U3RlcFIPdG91cm5hbWVudFN0ZXBz');

@$core.Deprecated('Use tournamentRequestDescriptor instead')
const TournamentRequest$json = {
  '1': 'TournamentRequest',
  '2': [
    {'1': 'tournament_id', '3': 1, '4': 1, '5': 5, '10': 'tournamentId'},
  ],
};

/// Descriptor for `TournamentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List tournamentRequestDescriptor = $convert.base64Decode(
    'ChFUb3VybmFtZW50UmVxdWVzdBIjCg10b3VybmFtZW50X2lkGAEgASgFUgx0b3VybmFtZW50SW'
    'Q=');

