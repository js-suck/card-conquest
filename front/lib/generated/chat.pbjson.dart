//
//  Generated code. Do not modify.
//  source: chat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userDescriptor instead')
const User$json = {
  '1': 'User',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'username', '3': 2, '4': 1, '5': 9, '10': 'username'},
    {'1': 'mediaUrl', '3': 3, '4': 1, '5': 9, '10': 'mediaUrl'},
  ],
};

/// Descriptor for `User`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List userDescriptor = $convert.base64Decode(
    'CgRVc2VyEg4KAmlkGAEgASgFUgJpZBIaCgh1c2VybmFtZRgCIAEoCVIIdXNlcm5hbWUSGgoIbW'
    'VkaWFVcmwYAyABKAlSCG1lZGlhVXJs');

@$core.Deprecated('Use chatMessageDescriptor instead')
const ChatMessage$json = {
  '1': 'ChatMessage',
  '2': [
    {'1': 'guildId', '3': 1, '4': 1, '5': 5, '10': 'guildId'},
    {'1': 'userId', '3': 2, '4': 1, '5': 5, '10': 'userId'},
    {'1': 'username', '3': 3, '4': 1, '5': 9, '10': 'username'},
    {'1': 'content', '3': 4, '4': 1, '5': 9, '10': 'content'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `ChatMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatMessageDescriptor = $convert.base64Decode(
    'CgtDaGF0TWVzc2FnZRIYCgdndWlsZElkGAEgASgFUgdndWlsZElkEhYKBnVzZXJJZBgCIAEoBV'
    'IGdXNlcklkEhoKCHVzZXJuYW1lGAMgASgJUgh1c2VybmFtZRIYCgdjb250ZW50GAQgASgJUgdj'
    'b250ZW50EhwKCXRpbWVzdGFtcBgFIAEoA1IJdGltZXN0YW1w');

@$core.Deprecated('Use chatHistoryMessageDescriptor instead')
const ChatHistoryMessage$json = {
  '1': 'ChatHistoryMessage',
  '2': [
    {'1': 'user', '3': 1, '4': 1, '5': 11, '6': '.protos.User', '10': 'user'},
    {'1': 'content', '3': 2, '4': 1, '5': 9, '10': 'content'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 3, '10': 'timestamp'},
  ],
};

/// Descriptor for `ChatHistoryMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatHistoryMessageDescriptor = $convert.base64Decode(
    'ChJDaGF0SGlzdG9yeU1lc3NhZ2USIAoEdXNlchgBIAEoCzIMLnByb3Rvcy5Vc2VyUgR1c2VyEh'
    'gKB2NvbnRlbnQYAiABKAlSB2NvbnRlbnQSHAoJdGltZXN0YW1wGAMgASgDUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use joinRequestDescriptor instead')
const JoinRequest$json = {
  '1': 'JoinRequest',
  '2': [
    {'1': 'guildId', '3': 1, '4': 1, '5': 5, '10': 'guildId'},
    {'1': 'userId', '3': 2, '4': 1, '5': 5, '10': 'userId'},
  ],
};

/// Descriptor for `JoinRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List joinRequestDescriptor = $convert.base64Decode(
    'CgtKb2luUmVxdWVzdBIYCgdndWlsZElkGAEgASgFUgdndWlsZElkEhYKBnVzZXJJZBgCIAEoBV'
    'IGdXNlcklk');

@$core.Deprecated('Use historyRequestDescriptor instead')
const HistoryRequest$json = {
  '1': 'HistoryRequest',
  '2': [
    {'1': 'guildId', '3': 1, '4': 1, '5': 5, '10': 'guildId'},
  ],
};

/// Descriptor for `HistoryRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyRequestDescriptor = $convert.base64Decode(
    'Cg5IaXN0b3J5UmVxdWVzdBIYCgdndWlsZElkGAEgASgFUgdndWlsZElk');

@$core.Deprecated('Use historyResponseDescriptor instead')
const HistoryResponse$json = {
  '1': 'HistoryResponse',
  '2': [
    {'1': 'messages', '3': 1, '4': 3, '5': 11, '6': '.protos.ChatHistoryMessage', '10': 'messages'},
  ],
};

/// Descriptor for `HistoryResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List historyResponseDescriptor = $convert.base64Decode(
    'Cg9IaXN0b3J5UmVzcG9uc2USNgoIbWVzc2FnZXMYASADKAsyGi5wcm90b3MuQ2hhdEhpc3Rvcn'
    'lNZXNzYWdlUghtZXNzYWdlcw==');

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode(
    'CgVFbXB0eQ==');

