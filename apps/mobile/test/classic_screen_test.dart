import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:kombelo/main.dart';
import 'package:kombelo/storage/game_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  testWidgets('Classic route opens and supports tap select then placement', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      KombeloApp(
        openStore: () => GameStore.open(
          databaseFactory: databaseFactoryFfi,
          path: inMemoryDatabasePath,
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump(const Duration(seconds: 1));

    final visibleText = find
        .byType(Text)
        .evaluate()
        .map((element) => (element.widget as Text).data)
        .toList();
    expect(find.text('Kombelo'), findsOneWidget, reason: '$visibleText');
    expect(find.text('XAL'), findsOneWidget);
    expect(
      find.text('Fiquru seç və lövhədə uyğun xanaya toxun.'),
      findsOneWidget,
    );

    await tester.tap(find.bySemanticsLabel('Fiqur 1'));
    await tester.pump(const Duration(milliseconds: 150));
    final firstCell = find
        .descendant(
          of: find.byType(GameBoard),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    await tester.tap(firstCell);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.textContaining('+'), findsOneWidget);
    expect(find.text('XAL'), findsOneWidget);

    final tray = find.bySemanticsLabel('Fiqur 2');
    final boardRect = tester.getRect(find.byType(GameBoard));
    final from = tester.getCenter(tray);
    final to =
        boardRect.topLeft +
        Offset(boardRect.width * .42, boardRect.height * .42);
    final gesture = await tester.startGesture(from);
    await gesture.moveTo(to, timeStamp: const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.up();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(seconds: 2)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('+'), findsOneWidget);
  });
}
