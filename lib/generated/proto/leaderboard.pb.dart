// This is a generated file - do not edit.
//
// Generated from proto/leaderboard.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class LeaderboardUpdated extends $pb.GeneratedMessage {
  factory LeaderboardUpdated({
    $core.String? leaderboard,
  }) {
    final result = create();
    if (leaderboard != null) result.leaderboard = leaderboard;
    return result;
  }

  LeaderboardUpdated._();

  factory LeaderboardUpdated.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaderboardUpdated.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaderboardUpdated',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'leaderboard')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaderboardUpdated clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaderboardUpdated copyWith(void Function(LeaderboardUpdated) updates) =>
      super.copyWith((message) => updates(message as LeaderboardUpdated))
          as LeaderboardUpdated;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaderboardUpdated create() => LeaderboardUpdated._();
  @$core.override
  LeaderboardUpdated createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaderboardUpdated getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaderboardUpdated>(create);
  static LeaderboardUpdated? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get leaderboard => $_getSZ(0);
  @$pb.TagNumber(1)
  set leaderboard($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLeaderboard() => $_has(0);
  @$pb.TagNumber(1)
  void clearLeaderboard() => $_clearField(1);
}

class Question extends $pb.GeneratedMessage {
  factory Question({
    $core.String? content,
    $core.Iterable<$core.String>? hints,
  }) {
    final result = create();
    if (content != null) result.content = content;
    if (hints != null) result.hints.addAll(hints);
    return result;
  }

  Question._();

  factory Question.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Question.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Question',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..pPS(2, _omitFieldNames ? '' : 'hints')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Question clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Question copyWith(void Function(Question) updates) =>
      super.copyWith((message) => updates(message as Question)) as Question;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Question create() => Question._();
  @$core.override
  Question createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Question getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Question>(create);
  static Question? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<$core.String> get hints => $_getList(1);
}

class GameStopped extends $pb.GeneratedMessage {
  factory GameStopped({
    $core.Iterable<ScoreItem>? scores,
  }) {
    final result = create();
    if (scores != null) result.scores.addAll(scores);
    return result;
  }

  GameStopped._();

  factory GameStopped.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GameStopped.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GameStopped',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..pPM<ScoreItem>(1, _omitFieldNames ? '' : 'scores',
        subBuilder: ScoreItem.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameStopped clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GameStopped copyWith(void Function(GameStopped) updates) =>
      super.copyWith((message) => updates(message as GameStopped))
          as GameStopped;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GameStopped create() => GameStopped._();
  @$core.override
  GameStopped createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static GameStopped getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GameStopped>(create);
  static GameStopped? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ScoreItem> get scores => $_getList(0);
}

class ScoreItem extends $pb.GeneratedMessage {
  factory ScoreItem({
    $core.String? player,
    $core.int? score,
  }) {
    final result = create();
    if (player != null) result.player = player;
    if (score != null) result.score = score;
    return result;
  }

  ScoreItem._();

  factory ScoreItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ScoreItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ScoreItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'player')
    ..aI(2, _omitFieldNames ? '' : 'score')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoreItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScoreItem copyWith(void Function(ScoreItem) updates) =>
      super.copyWith((message) => updates(message as ScoreItem)) as ScoreItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScoreItem create() => ScoreItem._();
  @$core.override
  ScoreItem createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ScoreItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScoreItem>(create);
  static ScoreItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get player => $_getSZ(0);
  @$pb.TagNumber(1)
  set player($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlayer() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayer() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get score => $_getIZ(1);
  @$pb.TagNumber(2)
  set score($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScore() => $_has(1);
  @$pb.TagNumber(2)
  void clearScore() => $_clearField(2);
}

class TimeConfigChanged extends $pb.GeneratedMessage {
  factory TimeConfigChanged({
    $core.int? roundTime,
  }) {
    final result = create();
    if (roundTime != null) result.roundTime = roundTime;
    return result;
  }

  TimeConfigChanged._();

  factory TimeConfigChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TimeConfigChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TimeConfigChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'roundTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeConfigChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimeConfigChanged copyWith(void Function(TimeConfigChanged) updates) =>
      super.copyWith((message) => updates(message as TimeConfigChanged))
          as TimeConfigChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimeConfigChanged create() => TimeConfigChanged._();
  @$core.override
  TimeConfigChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TimeConfigChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimeConfigChanged>(create);
  static TimeConfigChanged? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get roundTime => $_getIZ(0);
  @$pb.TagNumber(1)
  set roundTime($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRoundTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearRoundTime() => $_clearField(1);
}

class LeaderboardConfigChanged extends $pb.GeneratedMessage {
  factory LeaderboardConfigChanged({
    $core.int? showFirstRank,
  }) {
    final result = create();
    if (showFirstRank != null) result.showFirstRank = showFirstRank;
    return result;
  }

  LeaderboardConfigChanged._();

  factory LeaderboardConfigChanged.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory LeaderboardConfigChanged.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'LeaderboardConfigChanged',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'showFirstRank')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaderboardConfigChanged clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LeaderboardConfigChanged copyWith(
          void Function(LeaderboardConfigChanged) updates) =>
      super.copyWith((message) => updates(message as LeaderboardConfigChanged))
          as LeaderboardConfigChanged;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static LeaderboardConfigChanged create() => LeaderboardConfigChanged._();
  @$core.override
  LeaderboardConfigChanged createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static LeaderboardConfigChanged getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<LeaderboardConfigChanged>(create);
  static LeaderboardConfigChanged? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get showFirstRank => $_getIZ(0);
  @$pb.TagNumber(1)
  set showFirstRank($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasShowFirstRank() => $_has(0);
  @$pb.TagNumber(1)
  void clearShowFirstRank() => $_clearField(1);
}

class AddAnswer extends $pb.GeneratedMessage {
  factory AddAnswer({
    $core.String? player,
    $core.String? answer,
  }) {
    final result = create();
    if (player != null) result.player = player;
    if (answer != null) result.answer = answer;
    return result;
  }

  AddAnswer._();

  factory AddAnswer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory AddAnswer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'AddAnswer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'leaderboard'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'player')
    ..aOS(2, _omitFieldNames ? '' : 'answer')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddAnswer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddAnswer copyWith(void Function(AddAnswer) updates) =>
      super.copyWith((message) => updates(message as AddAnswer)) as AddAnswer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddAnswer create() => AddAnswer._();
  @$core.override
  AddAnswer createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static AddAnswer getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddAnswer>(create);
  static AddAnswer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get player => $_getSZ(0);
  @$pb.TagNumber(1)
  set player($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPlayer() => $_has(0);
  @$pb.TagNumber(1)
  void clearPlayer() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get answer => $_getSZ(1);
  @$pb.TagNumber(2)
  set answer($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAnswer() => $_has(1);
  @$pb.TagNumber(2)
  void clearAnswer() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
