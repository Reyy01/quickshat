// Mocks generated by Mockito 5.4.4 from annotations
// in quickchat_ui/test/features/authentication/data/bloc/segment/segment.bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:flutter/material.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i4;
import 'package:quickchat_ui/core/router/segment.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [Segment].
///
/// See the documentation for Mockito's code generation for more information.
class MockSegment extends _i1.Mock implements _i2.Segment {
  MockSegment() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String getCurrent(_i3.BuildContext? context) => (super.noSuchMethod(
        Invocation.method(
          #getCurrent,
          [context],
        ),
        returnValue: _i4.dummyValue<String>(
          this,
          Invocation.method(
            #getCurrent,
            [context],
          ),
        ),
      ) as String);

  @override
  _i5.Stream<String> listenSegmentStream(_i3.BuildContext? context) =>
      (super.noSuchMethod(
        Invocation.method(
          #listenSegmentStream,
          [context],
        ),
        returnValue: _i5.Stream<String>.empty(),
      ) as _i5.Stream<String>);

  @override
  void disposeSegmentListener() => super.noSuchMethod(
        Invocation.method(
          #disposeSegmentListener,
          [],
        ),
        returnValueForMissingStub: null,
      );
}
