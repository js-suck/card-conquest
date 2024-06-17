//
//  Generated code. Do not modify.
//  source: match.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use matchRequestDescriptor instead')
const MatchRequest$json = {
  '1': 'MatchRequest',
  '2': [
    {'1': 'match_id', '3': 1, '4': 1, '5': 5, '10': 'matchId'},
  ],
};

/// Descriptor for `MatchRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchRequestDescriptor = $convert.base64Decode(
    'CgxNYXRjaFJlcXVlc3QSGQoIbWF0Y2hfaWQYASABKAVSB21hdGNoSWQ=');

@$core.Deprecated('Use playerMatchDescriptor instead')
const PlayerMatch$json = {
  '1': 'PlayerMatch',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'mediaUrl', '3': 3, '4': 1, '5': 9, '10': 'mediaUrl'},
    {'1': 'rank', '3': 4, '4': 1, '5': 5, '10': 'rank'},
    {'1': 'score', '3': 5, '4': 1, '5': 5, '10': 'score'},
  ],
};

/// Descriptor for `PlayerMatch`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List playerMatchDescriptor = $convert.base64Decode(
    'CgtQbGF5ZXJNYXRjaBIOCgJpZBgBIAEoBVICaWQSGgoIdXNlcm5hbWUYAiABKAlSCHVzZXJuYW'
    '1lEhoKCG1lZGlhVXJsGAMgASgJUghtZWRpYVVybBISCgRyYW5rGAQgASgFUgRyYW5rEhQKBXNj'
    'b3JlGAUgASgFUgVzY29yZQ==');

@$core.Deprecated('Use matchResponseDescriptor instead')
const MatchResponse$json = {
  '1': 'MatchResponse',
  '2': [
    {'1': 'match_id', '3': 1, '4': 1, '5': 5, '10': 'matchId'},
    {'1': 'status', '3': 2, '4': 1, '5': 9, '10': 'status'},
    {'1': 'playerOne', '3': 3, '4': 1, '5': 11, '6': '.protos.PlayerMatch', '10': 'playerOne'},
    {'1': 'playerTwo', '3': 4, '4': 1, '5': 11, '6': '.protos.PlayerMatch', '10': 'playerTwo'},
    {'1': 'winnerId', '3': 5, '4': 1, '5': 5, '10': 'winnerId'},
  ],
};

/// Descriptor for `MatchResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List matchResponseDescriptor = $convert.base64Decode(
    'Cg1NYXRjaFJlc3BvbnNlEhkKCG1hdGNoX2lkGAEgASgFUgdtYXRjaElkEhYKBnN0YXR1cxgCIA'
    'EoCVIGc3RhdHVzEjEKCXBsYXllck9uZRgDIAEoCzITLnByb3Rvcy5QbGF5ZXJNYXRjaFIJcGxh'
    'eWVyT25lEjEKCXBsYXllclR3bxgEIAEoCzITLnByb3Rvcy5QbGF5ZXJNYXRjaFIJcGxheWVyVH'
    'dvEhoKCHdpbm5lcklkGAUgASgFUgh3aW5uZXJJZA==');

