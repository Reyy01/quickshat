import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quickchat_ui/core/router/segment.dart';
import 'package:quickchat_ui/features/authentication/data/bloc/segment/segment_bloc.dart';

import 'segment.bloc_test.mocks.dart';

class MockBuildContext extends Mock implements BuildContext {}

@GenerateMocks(<Type>[Segment])
void main() {
  late MockSegment mockSegment;
  late MockBuildContext mockBuildContext;
  late SegmentBloc segmentBloc;

  setUp(() {
    mockSegment = MockSegment();
    mockBuildContext = MockBuildContext();
    segmentBloc = SegmentBloc(mockSegment);
  });

  group('_ListenSegmentStream', () {
    test('should listen to segment stream', () {
      final SegmentState state = SegmentState.initial();

      // arrange
      when(mockSegment.listenSegmentStream(any)).thenAnswer((_) async* {
        yield 'test';
      });

      final List<SegmentState> expected = <SegmentState>[
        state.copyWith(segment: 'test'),
      ];

      // act
      expectLater(segmentBloc.stream, emitsInOrder(expected));

      // assert
      segmentBloc
          .add(SegmentEvent.listenSegmentStream(context: mockBuildContext));
    });
  });

  group('_UpdateSegment', () {
    test('should update segment', () {
      final SegmentState state = SegmentState.initial();

      // arrange
      final List<SegmentState> expected = <SegmentState>[
        state.copyWith(segment: 'test'),
      ];

      // act
      expectLater(segmentBloc.stream, emitsInOrder(expected));

      // assert
      segmentBloc.add(const SegmentEvent.updateSegment(segment: 'test'));
    });
  });
}
