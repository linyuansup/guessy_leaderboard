// This is a generated file - do not edit.
//
// Generated from proto/leaderboard.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use leaderboardUpdatedDescriptor instead')
const LeaderboardUpdated$json = {
  '1': 'LeaderboardUpdated',
  '2': [
    {'1': 'leaderboard', '3': 1, '4': 1, '5': 9, '10': 'leaderboard'},
  ],
};

/// Descriptor for `LeaderboardUpdated`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaderboardUpdatedDescriptor = $convert.base64Decode(
    'ChJMZWFkZXJib2FyZFVwZGF0ZWQSIAoLbGVhZGVyYm9hcmQYASABKAlSC2xlYWRlcmJvYXJk');

@$core.Deprecated('Use questionDescriptor instead')
const Question$json = {
  '1': 'Question',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 9, '10': 'content'},
    {'1': 'hints', '3': 2, '4': 3, '5': 9, '10': 'hints'},
  ],
};

/// Descriptor for `Question`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List questionDescriptor = $convert.base64Decode(
    'CghRdWVzdGlvbhIYCgdjb250ZW50GAEgASgJUgdjb250ZW50EhQKBWhpbnRzGAIgAygJUgVoaW'
    '50cw==');

@$core.Deprecated('Use gameStoppedDescriptor instead')
const GameStopped$json = {
  '1': 'GameStopped',
  '2': [
    {
      '1': 'scores',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.leaderboard.ScoreItem',
      '10': 'scores'
    },
  ],
};

/// Descriptor for `GameStopped`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List gameStoppedDescriptor = $convert.base64Decode(
    'CgtHYW1lU3RvcHBlZBIuCgZzY29yZXMYASADKAsyFi5sZWFkZXJib2FyZC5TY29yZUl0ZW1SBn'
    'Njb3Jlcw==');

@$core.Deprecated('Use scoreItemDescriptor instead')
const ScoreItem$json = {
  '1': 'ScoreItem',
  '2': [
    {'1': 'player', '3': 1, '4': 1, '5': 9, '10': 'player'},
    {'1': 'score', '3': 2, '4': 1, '5': 5, '10': 'score'},
  ],
};

/// Descriptor for `ScoreItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scoreItemDescriptor = $convert.base64Decode(
    'CglTY29yZUl0ZW0SFgoGcGxheWVyGAEgASgJUgZwbGF5ZXISFAoFc2NvcmUYAiABKAVSBXNjb3'
    'Jl');

@$core.Deprecated('Use timeConfigChangedDescriptor instead')
const TimeConfigChanged$json = {
  '1': 'TimeConfigChanged',
  '2': [
    {'1': 'round_time', '3': 1, '4': 1, '5': 5, '10': 'roundTime'},
  ],
};

/// Descriptor for `TimeConfigChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timeConfigChangedDescriptor = $convert.base64Decode(
    'ChFUaW1lQ29uZmlnQ2hhbmdlZBIdCgpyb3VuZF90aW1lGAEgASgFUglyb3VuZFRpbWU=');

@$core.Deprecated('Use leaderboardConfigChangedDescriptor instead')
const LeaderboardConfigChanged$json = {
  '1': 'LeaderboardConfigChanged',
  '2': [
    {'1': 'show_first_rank', '3': 1, '4': 1, '5': 5, '10': 'showFirstRank'},
  ],
};

/// Descriptor for `LeaderboardConfigChanged`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List leaderboardConfigChangedDescriptor =
    $convert.base64Decode(
        'ChhMZWFkZXJib2FyZENvbmZpZ0NoYW5nZWQSJgoPc2hvd19maXJzdF9yYW5rGAEgASgFUg1zaG'
        '93Rmlyc3RSYW5r');

@$core.Deprecated('Use addAnswerDescriptor instead')
const AddAnswer$json = {
  '1': 'AddAnswer',
  '2': [
    {'1': 'player', '3': 1, '4': 1, '5': 9, '10': 'player'},
    {'1': 'answer', '3': 2, '4': 1, '5': 9, '10': 'answer'},
  ],
};

/// Descriptor for `AddAnswer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List addAnswerDescriptor = $convert.base64Decode(
    'CglBZGRBbnN3ZXISFgoGcGxheWVyGAEgASgJUgZwbGF5ZXISFgoGYW5zd2VyGAIgASgJUgZhbn'
    'N3ZXI=');
