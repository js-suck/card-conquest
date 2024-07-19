//
//  Generated code. Do not modify.
//  source: tournament.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Player extends $pb.GeneratedMessage {
  factory Player({
    $core.String? username,
    $core.String? userId,
    $core.int? score,
  }) {
    final $result = create();
    if (username != null) {
      $result.username = username;
    }
    if (userId != null) {
      $result.userId = userId;
    }
    if (score != null) {
      $result.score = score;
    }
    return $result;
  }
  Player._() : super();
  factory Player.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Player.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Player',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'username')
    ..aOS(2, _omitFieldNames ? '' : 'userId', protoName: 'userId')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'score', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Player clone() => Player()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Player copyWith(void Function(Player) updates) =>
      super.copyWith((message) => updates(message as Player)) as Player;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Player create() => Player._();
  Player createEmptyInstance() => create();
  static $pb.PbList<Player> createRepeated() => $pb.PbList<Player>();
  @$core.pragma('dart2js:noInline')
  static Player getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Player>(create);
  static Player? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get username => $_getSZ(0);
  @$pb.TagNumber(1)
  set username($core.String v) {
    $_setString(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasUsername() => $_has(0);
  @$pb.TagNumber(1)
  void clearUsername() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get userId => $_getSZ(1);
  @$pb.TagNumber(2)
  set userId($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasUserId() => $_has(1);
  @$pb.TagNumber(2)
  void clearUserId() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get score => $_getIZ(2);
  @$pb.TagNumber(3)
  set score($core.int v) {
    $_setSignedInt32(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasScore() => $_has(2);
  @$pb.TagNumber(3)
  void clearScore() => clearField(3);
}

class Match extends $pb.GeneratedMessage {
  factory Match({
    $core.int? position,
    Player? playerOne,
    Player? playerTwo,
    $core.String? status,
    $core.int? winnerId,
    $core.int? matchId,
    $core.String? location,
    $core.String? startTime,
  }) {
    final $result = create();
    if (position != null) {
      $result.position = position;
    }
    if (playerOne != null) {
      $result.playerOne = playerOne;
    }
    if (playerTwo != null) {
      $result.playerTwo = playerTwo;
    }
    if (status != null) {
      $result.status = status;
    }
    if (winnerId != null) {
      $result.winnerId = winnerId;
    }
    if (matchId != null) {
      $result.matchId = matchId;
    }
    if (location != null) {
      $result.location = location;
    }
    if (startTime != null) {
      $result.startTime = startTime;
    }
    return $result;
  }
  Match._() : super();
  factory Match.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory Match.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Match',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'position', $pb.PbFieldType.O3)
    ..aOM<Player>(2, _omitFieldNames ? '' : 'playerOne',
        subBuilder: Player.create)
    ..aOM<Player>(3, _omitFieldNames ? '' : 'playerTwo',
        subBuilder: Player.create)
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'winnerId', $pb.PbFieldType.O3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'matchId', $pb.PbFieldType.O3)
    ..aOS(7, _omitFieldNames ? '' : 'location')
    ..aOS(8, _omitFieldNames ? '' : 'startTime', protoName: 'startTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  Match clone() => Match()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  Match copyWith(void Function(Match) updates) =>
      super.copyWith((message) => updates(message as Match)) as Match;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Match create() => Match._();
  Match createEmptyInstance() => create();
  static $pb.PbList<Match> createRepeated() => $pb.PbList<Match>();
  @$core.pragma('dart2js:noInline')
  static Match getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Match>(create);
  static Match? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get position => $_getIZ(0);
  @$pb.TagNumber(1)
  set position($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasPosition() => $_has(0);
  @$pb.TagNumber(1)
  void clearPosition() => clearField(1);

  @$pb.TagNumber(2)
  Player get playerOne => $_getN(1);
  @$pb.TagNumber(2)
  set playerOne(Player v) {
    setField(2, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasPlayerOne() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlayerOne() => clearField(2);
  @$pb.TagNumber(2)
  Player ensurePlayerOne() => $_ensure(1);

  @$pb.TagNumber(3)
  Player get playerTwo => $_getN(2);
  @$pb.TagNumber(3)
  set playerTwo(Player v) {
    setField(3, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasPlayerTwo() => $_has(2);
  @$pb.TagNumber(3)
  void clearPlayerTwo() => clearField(3);
  @$pb.TagNumber(3)
  Player ensurePlayerTwo() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String v) {
    $_setString(3, v);
  }

  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get winnerId => $_getIZ(4);
  @$pb.TagNumber(5)
  set winnerId($core.int v) {
    $_setSignedInt32(4, v);
  }

  @$pb.TagNumber(5)
  $core.bool hasWinnerId() => $_has(4);
  @$pb.TagNumber(5)
  void clearWinnerId() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get matchId => $_getIZ(5);
  @$pb.TagNumber(6)
  set matchId($core.int v) {
    $_setSignedInt32(5, v);
  }

  @$pb.TagNumber(6)
  $core.bool hasMatchId() => $_has(5);
  @$pb.TagNumber(6)
  void clearMatchId() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get location => $_getSZ(6);
  @$pb.TagNumber(7)
  set location($core.String v) {
    $_setString(6, v);
  }

  @$pb.TagNumber(7)
  $core.bool hasLocation() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocation() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get startTime => $_getSZ(7);
  @$pb.TagNumber(8)
  set startTime($core.String v) {
    $_setString(7, v);
  }

  @$pb.TagNumber(8)
  $core.bool hasStartTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearStartTime() => clearField(8);
}

class TournamentStep extends $pb.GeneratedMessage {
  factory TournamentStep({
    $core.int? step,
    $core.Iterable<Match>? matches,
  }) {
    final $result = create();
    if (step != null) {
      $result.step = step;
    }
    if (matches != null) {
      $result.matches.addAll(matches);
    }
    return $result;
  }
  TournamentStep._() : super();
  factory TournamentStep.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TournamentStep.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TournamentStep',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'step', $pb.PbFieldType.O3)
    ..pc<Match>(2, _omitFieldNames ? '' : 'matches', $pb.PbFieldType.PM,
        subBuilder: Match.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TournamentStep clone() => TournamentStep()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TournamentStep copyWith(void Function(TournamentStep) updates) =>
      super.copyWith((message) => updates(message as TournamentStep))
          as TournamentStep;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TournamentStep create() => TournamentStep._();
  TournamentStep createEmptyInstance() => create();
  static $pb.PbList<TournamentStep> createRepeated() =>
      $pb.PbList<TournamentStep>();
  @$core.pragma('dart2js:noInline')
  static TournamentStep getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TournamentStep>(create);
  static TournamentStep? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get step => $_getIZ(0);
  @$pb.TagNumber(1)
  set step($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasStep() => $_has(0);
  @$pb.TagNumber(1)
  void clearStep() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Match> get matches => $_getList(1);
}

class TournamentResponse extends $pb.GeneratedMessage {
  factory TournamentResponse({
    $core.int? tournamentId,
    $core.String? tournamentName,
    $core.String? tournamentStatus,
    $core.Iterable<TournamentStep>? tournamentSteps,
  }) {
    final $result = create();
    if (tournamentId != null) {
      $result.tournamentId = tournamentId;
    }
    if (tournamentName != null) {
      $result.tournamentName = tournamentName;
    }
    if (tournamentStatus != null) {
      $result.tournamentStatus = tournamentStatus;
    }
    if (tournamentSteps != null) {
      $result.tournamentSteps.addAll(tournamentSteps);
    }
    return $result;
  }
  TournamentResponse._() : super();
  factory TournamentResponse.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TournamentResponse.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TournamentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'tournamentId', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'tournamentName')
    ..aOS(3, _omitFieldNames ? '' : 'tournamentStatus')
    ..pc<TournamentStep>(
        4, _omitFieldNames ? '' : 'tournamentSteps', $pb.PbFieldType.PM,
        subBuilder: TournamentStep.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TournamentResponse clone() => TournamentResponse()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TournamentResponse copyWith(void Function(TournamentResponse) updates) =>
      super.copyWith((message) => updates(message as TournamentResponse))
          as TournamentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TournamentResponse create() => TournamentResponse._();
  TournamentResponse createEmptyInstance() => create();
  static $pb.PbList<TournamentResponse> createRepeated() =>
      $pb.PbList<TournamentResponse>();
  @$core.pragma('dart2js:noInline')
  static TournamentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TournamentResponse>(create);
  static TournamentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get tournamentId => $_getIZ(0);
  @$pb.TagNumber(1)
  set tournamentId($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTournamentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTournamentId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get tournamentName => $_getSZ(1);
  @$pb.TagNumber(2)
  set tournamentName($core.String v) {
    $_setString(1, v);
  }

  @$pb.TagNumber(2)
  $core.bool hasTournamentName() => $_has(1);
  @$pb.TagNumber(2)
  void clearTournamentName() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tournamentStatus => $_getSZ(2);
  @$pb.TagNumber(3)
  set tournamentStatus($core.String v) {
    $_setString(2, v);
  }

  @$pb.TagNumber(3)
  $core.bool hasTournamentStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearTournamentStatus() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<TournamentStep> get tournamentSteps => $_getList(3);
}

class TournamentRequest extends $pb.GeneratedMessage {
  factory TournamentRequest({
    $core.int? tournamentId,
  }) {
    final $result = create();
    if (tournamentId != null) {
      $result.tournamentId = tournamentId;
    }
    return $result;
  }
  TournamentRequest._() : super();
  factory TournamentRequest.fromBuffer($core.List<$core.int> i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(i, r);
  factory TournamentRequest.fromJson($core.String i,
          [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TournamentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'protos'),
      createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'tournamentId', $pb.PbFieldType.O3)
    ..hasRequiredFields = false;

  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
      'Will be removed in next major version')
  TournamentRequest clone() => TournamentRequest()..mergeFromMessage(this);
  @$core.Deprecated('Using this can add significant overhead to your binary. '
      'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
      'Will be removed in next major version')
  TournamentRequest copyWith(void Function(TournamentRequest) updates) =>
      super.copyWith((message) => updates(message as TournamentRequest))
          as TournamentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TournamentRequest create() => TournamentRequest._();
  TournamentRequest createEmptyInstance() => create();
  static $pb.PbList<TournamentRequest> createRepeated() =>
      $pb.PbList<TournamentRequest>();
  @$core.pragma('dart2js:noInline')
  static TournamentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TournamentRequest>(create);
  static TournamentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get tournamentId => $_getIZ(0);
  @$pb.TagNumber(1)
  set tournamentId($core.int v) {
    $_setSignedInt32(0, v);
  }

  @$pb.TagNumber(1)
  $core.bool hasTournamentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearTournamentId() => clearField(1);
}

const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
