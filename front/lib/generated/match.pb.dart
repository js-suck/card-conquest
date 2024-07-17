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

class PlayerMatch extends $pb.GeneratedMessage {
  factory PlayerMatch({
    $core.int? id,
    $core.String? username,
    $core.String? mediaUrl,
    $core.int? rank,
    $core.int? score,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (username != null) {
      $result.username = username;
    }
    if (mediaUrl != null) {
      $result.mediaUrl = mediaUrl;
    }
    if (rank != null) {
      $result.rank = rank;
    }
    if (score != null) {
      $result.score = score;
    }
    return $result;
  }
  PlayerMatch._() : super();
  factory PlayerMatch.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PlayerMatch.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PlayerMatch', package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'username')
    ..aOS(3, _omitFieldNames ? '' : 'mediaUrl', protoName: 'mediaUrl')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'rank', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'score', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PlayerMatch clone() => PlayerMatch()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PlayerMatch copyWith(void Function(PlayerMatch) updates) => super.copyWith((message) => updates(message as PlayerMatch)) as PlayerMatch;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PlayerMatch create() => PlayerMatch._();
  PlayerMatch createEmptyInstance() => create();
  static $pb.PbList<PlayerMatch> createRepeated() => $pb.PbList<PlayerMatch>();
  @$core.pragma('dart2js:noInline')
  static PlayerMatch getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PlayerMatch>(create);
  static PlayerMatch? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get username => $_getSZ(1);
  @$pb.TagNumber(2)
  set username($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUsername() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsername() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get mediaUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set mediaUrl($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMediaUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearMediaUrl() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get rank => $_getIZ(3);
  @$pb.TagNumber(4)
  set rank($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRank() => $_has(3);
  @$pb.TagNumber(4)
  void clearRank() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get score => $_getIZ(4);
  @$pb.TagNumber(5)
  set score($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasScore() => $_has(4);
  @$pb.TagNumber(5)
  void clearScore() => clearField(5);
}

class MatchResponse extends $pb.GeneratedMessage {
  factory MatchResponse({
    $core.int? matchId,
    $core.String? status,
    PlayerMatch? playerOne,
    PlayerMatch? playerTwo,
    $core.int? winnerId,
    $core.String? location,
    $core.String? startDate,
  }) {
    final $result = create();
    if (matchId != null) {
      $result.matchId = matchId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (playerOne != null) {
      $result.playerOne = playerOne;
    }
    if (playerTwo != null) {
      $result.playerTwo = playerTwo;
    }
    if (winnerId != null) {
      $result.winnerId = winnerId;
    }
    if (location != null) {
      $result.location = location;
    }
    if (startDate != null) {
      $result.startDate = startDate;
    }
    return $result;
  }
  MatchResponse._() : super();
  factory MatchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MatchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MatchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'matchId', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'status')
    ..aOM<PlayerMatch>(3, _omitFieldNames ? '' : 'playerOne', protoName: 'playerOne', subBuilder: PlayerMatch.create)
    ..aOM<PlayerMatch>(4, _omitFieldNames ? '' : 'playerTwo', protoName: 'playerTwo', subBuilder: PlayerMatch.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'winnerId', $pb.PbFieldType.O3, protoName: 'winnerId')
    ..aOS(6, _omitFieldNames ? '' : 'location')
    ..aOS(7, _omitFieldNames ? '' : 'startDate', protoName: 'startDate')
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
  PlayerMatch get playerOne => $_getN(2);
  @$pb.TagNumber(3)
  set playerOne(PlayerMatch v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPlayerOne() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlayerOne() => clearField(3);
  @$pb.TagNumber(3)
  PlayerMatch ensurePlayerOne() => $_ensure(2);

  @$pb.TagNumber(4)
  PlayerMatch get playerTwo => $_getN(3);
  @$pb.TagNumber(4)
  set playerTwo(PlayerMatch v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasPlayerTwo() => $_has(3);
  @$pb.TagNumber(4)
  void clearPlayerTwo() => clearField(4);
  @$pb.TagNumber(4)
  PlayerMatch ensurePlayerTwo() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get winnerId => $_getIZ(4);
  @$pb.TagNumber(5)
  set winnerId($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWinnerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearWinnerId() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get location => $_getSZ(5);
  @$pb.TagNumber(6)
  set location($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocation() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocation() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get startDate => $_getSZ(6);
  @$pb.TagNumber(7)
  set startDate($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStartDate() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartDate() => clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
