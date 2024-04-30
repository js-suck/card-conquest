//
//  Generated code. Do not modify.
//  source: match.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// La demande pour recevoir des mises à jour
class MatchRequest extends $pb.GeneratedMessage {
  factory MatchRequest({
    $core.int? matchId,
  }) {
    final $result = create();
    if (matchId != null) {
      $result.matchId = matchId;
    }
    return $result;
  }
  MatchRequest._() : super();
  factory MatchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'matchId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatchRequest clone() => MatchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatchRequest copyWith(void Function(MatchRequest) updates) => super.copyWith((message) => updates(message as MatchRequest)) as MatchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatchRequest create() => MatchRequest._();
  MatchRequest createEmptyInstance() => create();
  static $pb.PbList<MatchRequest> createRepeated() => $pb.PbList<MatchRequest>();
  @$core.pragma('dart2js:noInline')
  static MatchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatchRequest>(create);
  static MatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get matchId => $_getIZ(0);
  @$pb.TagNumber(1)
  set matchId($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMatchId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchId() => clearField(1);
}

/// La réponse qui contient l'état du match
class MatchResponse extends $pb.GeneratedMessage {
  factory MatchResponse({
    $core.int? matchId,
    $core.String? status,
    $core.String? detail,
  }) {
    final $result = create();
    if (matchId != null) {
      $result.matchId = matchId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (detail != null) {
      $result.detail = detail;
    }
    return $result;
  }
  MatchResponse._() : super();
  factory MatchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'matchId', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOS(3, _omitFieldNames ? '' : 'detail')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MatchResponse clone() => MatchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MatchResponse copyWith(void Function(MatchResponse) updates) => super.copyWith((message) => updates(message as MatchResponse)) as MatchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MatchResponse create() => MatchResponse._();
  MatchResponse createEmptyInstance() => create();
  static $pb.PbList<MatchResponse> createRepeated() => $pb.PbList<MatchResponse>();
  @$core.pragma('dart2js:noInline')
  static MatchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MatchResponse>(create);
  static MatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get matchId => $_getIZ(0);
  @$pb.TagNumber(1)
  set matchId($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMatchId() => $_has(0);
  @$pb.TagNumber(1)
  void clearMatchId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get status => $_getSZ(1);
  @$pb.TagNumber(2)
  set status($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get detail => $_getSZ(2);
  @$pb.TagNumber(3)
  set detail($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDetail() => $_has(2);
  @$pb.TagNumber(3)
  void clearDetail() => clearField(3);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
