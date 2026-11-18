import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kombelo/main.dart';
import 'package:kombelo/storage/game_store.dart';
import 'package:game_rules/game_rules.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late String rulesJson;
late String lifecycleJson;

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    rulesJson = await rootBundle.loadString('assets/game-v1.json');
    lifecycleJson = await rootBundle.loadString(
      'assets/classic-lifecycle-v1.json',
    );
  });

  testWidgets('Classic opens and accepts tap placement', (tester) async {
    await _mount(tester, fixture: 'gesture');
    expect(find.text('Kombelo'), findsOneWidget);
    expect(find.text('XAL'), findsOneWidget);
    expect(
      find.text('Fiquru seç və lövhədə uyğun xanaya toxun.'),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Fiqur 1'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(_cell(tester, 0, 0));
    await _settleCommit(tester);

    final state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(state.moveCount, 1);
    expect(state.board.first, 0);
    expect(state.tray.first, isNull);
  });

  testWidgets('A01 tray slots reach three corners and bottom center', (
    tester,
  ) async {
    await _mount(tester, fixture: 'gesture');
    await _drag(tester, 0, 0, 0);
    await _settleCommit(tester);
    await _drag(tester, 1, 0, 7);
    await _settleCommit(tester);
    await _drag(tester, 2, 7, 3);
    await _settleCommit(tester);

    var state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(state.board[0], 0);
    expect(state.board[7], 1);
    expect(state.board[59], 2);
    expect(state.moveCount, 3);
  });

  testWidgets('A01 lower-right corner remains reachable', (tester) async {
    await _mount(tester, fixture: 'gesture');
    await _drag(tester, 0, 7, 7);
    await _settleCommit(tester);
    final state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(state.board[63], 0);
  });

  testWidgets(
    'A02 cancel, occupied target, and second pointer preserve state',
    (tester) async {
      await _mount(tester, fixture: 'gesture');
      final beforeCancel = _snapshot(tester);
      final trayOne = tester.getCenter(find.bySemanticsLabel('Fiqur 1'));
      final boardRect = tester.getRect(find.byType(GameBoard));
      final cancelled = await tester.startGesture(trayOne);
      await cancelled.moveTo(boardRect.center);
      await tester.pump(const Duration(milliseconds: 400));
      await cancelled.cancel();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_snapshot(tester), beforeCancel);

      await _drag(tester, 0, 0, 0);
      await _settleCommit(tester);
      final beforeOccupied = _snapshot(tester);
      await _drag(tester, 1, 0, 0);
      await _settleCommit(tester);
      expect(_snapshot(tester), beforeOccupied);
      expect(find.text('Bu fiqur həmin yerə yerləşmir.'), findsOneWidget);

      // A second pointer cannot replace the tray item currently being dragged.
      final primary = await tester.startGesture(
        tester.getCenter(find.bySemanticsLabel('Fiqur 2')),
        pointer: 1,
      );
      final firstTarget = _cellCenter(tester, 0, 1);
      await primary.moveTo(
        firstTarget,
        timeStamp: const Duration(milliseconds: 400),
      );
      await tester.pump(const Duration(milliseconds: 400));
      final secondary = await tester.startGesture(
        tester.getCenter(find.bySemanticsLabel('Fiqur 3')),
        pointer: 2,
      );
      await secondary.moveTo(
        _cellCenter(tester, 0, 2),
        timeStamp: const Duration(milliseconds: 800),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await secondary.up();
      await tester.pump();
      await primary.up();
      await _settleCommit(tester);
      final afterPointers = tester
          .widget<GameBoard>(find.byType(GameBoard))
          .state;
      expect(afterPointers.moveCount, 2);
      expect(afterPointers.board[0], 0);
      expect(afterPointers.board[1], 1);
      expect(afterPointers.board[2], -1);
      expect(afterPointers.tray[2], isNotNull);
    },
  );

  testWidgets('A03 allows the next drag while clear animation runs', (
    tester,
  ) async {
    await _mount(tester, fixture: 'intersection');
    final first = await _beginDrag(tester, 2, 0, 0);
    await first.up();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 80)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('3 kombo · +37 xal'), findsOneWidget);
    var state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(state.board.where((cell) => cell < 0).length, 64);
    expect(state.moveCount, 1);

    final nextDrag = await _beginDrag(
      tester,
      0,
      0,
      0,
      duration: const Duration(milliseconds: 80),
    );
    await nextDrag.up();
    await _settleCommit(tester);
    state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(state.moveCount, 2);
    expect(state.board[0], greaterThanOrEqualTo(0));
  });

  testWidgets('A05 terminal fixture refills and shows result', (tester) async {
    await _mount(tester, fixture: 'terminal');
    await _drag(tester, 2, 0, 1);
    await _settleCommit(tester);
    await tester.pumpAndSettle();

    final state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(find.text('Raund bitdi'), findsOneWidget);
    expect(state.score, 100);
    expect(state.tray.whereType<Piece>().length, 3);
    expect(state.rng, 962054837);
    expect(state.hasLegalMove, isFalse);
  });

  testWidgets('A05 alternate lifecycle placement keeps the round playable', (
    tester,
  ) async {
    await _mount(tester, fixture: 'alternate');
    await _drag(tester, 2, 2, 0);
    await _settleCommit(tester);

    expect(find.text('Raund bitdi'), findsNothing);
    final state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
    expect(state.score, 100);
    expect(state.tray.whereType<Piece>().length, 3);
    expect(state.rng, 962054837);
    expect(state.hasLegalMove, isTrue);
  });
}

Future<void> _mount(WidgetTester tester, {required String fixture}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
  });
  await tester.binding.setSurfaceSize(const Size(360, 800));
  await tester.pumpWidget(
    KombeloApp(
      fixture: fixture,
      rulesJson: rulesJson,
      lifecycleJson: lifecycleJson,
      openStore: () => GameStore.open(
        databaseFactory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      ),
    ),
  );
  for (
    var attempt = 0;
    attempt < 40 && find.byType(GameBoard).evaluate().isEmpty;
    attempt++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 250)),
    );
    await tester.pump();
  }
  if (find.byType(GameBoard).evaluate().isEmpty) {
    throw TestFailure(
      'Failed to load $fixture fixture: ${tester.widgetList<Text>(find.byType(Text)).map((widget) => widget.data).toList()}',
    );
  }
  expect(
    find.byType(GameBoard),
    findsOneWidget,
    reason: find
        .byType(Text)
        .evaluate()
        .map((element) => (element.widget as Text).data)
        .join(' | '),
  );
}

Finder _cell(WidgetTester tester, int row, int col) => find
    .descendant(
      of: find.byType(GameBoard),
      matching: find.byType(AnimatedContainer),
    )
    .at(row * 8 + col);

Offset _cellCenter(WidgetTester tester, int row, int col) {
  final board = tester.getRect(find.byType(GameBoard));
  final cellSize = (board.width - 24) / 8;
  final pitch = cellSize + 2;
  return Offset(
    board.left + 5 + col * pitch + cellSize / 2,
    board.top + 5 + row * pitch + cellSize / 2,
  );
}

Future<TestGesture> _beginDrag(
  WidgetTester tester,
  int slot,
  int row,
  int col, {
  Duration duration = const Duration(milliseconds: 400),
}) async {
  final gesture = await tester.startGesture(
    tester.getCenter(find.bySemanticsLabel('Fiqur ${slot + 1}')),
  );
  await gesture.moveTo(_cellCenter(tester, row, col), timeStamp: duration);
  await tester.pump(duration);
  return gesture;
}

Future<void> _drag(WidgetTester tester, int slot, int row, int col) async {
  final gesture = await _beginDrag(tester, slot, row, col);
  await gesture.up();
  await tester.pump();
}

Future<void> _settleCommit(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 150)),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Map<String, Object?> _snapshot(WidgetTester tester) {
  final state = tester.widget<GameBoard>(find.byType(GameBoard)).state;
  return {
    'board': state.board,
    'tray': state.tray.map((piece) => piece?.toJson()).toList(),
    'score': state.score,
    'chain': state.chain,
    'best': state.best,
    'rng': state.rng,
    'moveCount': state.moveCount,
  };
}
