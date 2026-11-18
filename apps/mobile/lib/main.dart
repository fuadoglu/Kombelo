import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:game_rules/game_rules.dart';

import 'storage/game_store.dart';

void main() => runApp(const KombeloApp());

const colors = <Color>[
  Color(0xFF2DE1D2),
  Color(0xFFFFE05A),
  Color(0xFFFF69B5),
  Color(0xFFFF926B),
  Color(0xFFA68CFF),
];

Future<String>? _rulesAssetSource;
Future<String>? _lifecycleAssetSource;

Future<String> _loadRulesAsset() =>
    _rulesAssetSource ??= rootBundle.loadString('assets/game-v1.json');

Future<String> _loadLifecycleAsset() => _lifecycleAssetSource ??= rootBundle
    .loadString('assets/classic-lifecycle-v1.json');

class KombeloApp extends StatelessWidget {
  const KombeloApp({
    super.key,
    this.openStore,
    this.fixture,
    this.rulesJson,
    this.lifecycleJson,
  });
  final Future<GameStore> Function()? openStore;
  @visibleForTesting
  final String? fixture;
  @visibleForTesting
  final String? rulesJson;
  @visibleForTesting
  final String? lifecycleJson;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kombelo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121634),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFFFE05A),
        surface: Color(0xFF20264A),
      ),
      useMaterial3: true,
    ),
    home: ClassicScreen(
      openStore: openStore,
      fixture: fixture,
      rulesJson: rulesJson,
      lifecycleJson: lifecycleJson,
    ),
  );
}

class ClassicScreen extends StatefulWidget {
  const ClassicScreen({
    super.key,
    this.openStore,
    this.fixture,
    this.rulesJson,
    this.lifecycleJson,
  });
  final Future<GameStore> Function()? openStore;
  @visibleForTesting
  final String? fixture;
  @visibleForTesting
  final String? rulesJson;
  @visibleForTesting
  final String? lifecycleJson;

  @override
  State<ClassicScreen> createState() => _ClassicScreenState();
}

class _ClassicScreenState extends State<ClassicScreen> {
  GameStore? _store;
  ShapeCatalog? _catalog;
  GameState? _state;
  int? _selected;
  int? _hover;
  int? _draggingSlot;
  bool _loading = true;
  bool _committing = false;
  String _feedback = 'Fiquru seç və lövhədə uyğun xanaya toxun.';

  GameState get game => _state!;
  ShapeCatalog get catalog => _catalog!;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final source = widget.rulesJson ?? await _loadRulesAsset();
      final catalog = ShapeCatalog.decode(source);
      final store = await (widget.openStore?.call() ?? GameStore.open());
      final saved = await store.load();
      GameState? state;
      final fixture = _activeFixture;
      if (fixture == 'intersection') {
        state = _intersectionFixture(catalog);
      } else if (fixture == 'gesture') {
        state = _gestureFixture(catalog);
      } else if (fixture == 'terminal' || fixture == 'alternate') {
        final lifecycle = jsonDecode(
          widget.lifecycleJson ?? await _loadLifecycleAsset(),
        ) as Map<String, dynamic>;
        state = _lifecycleFixture(
          catalog,
          lifecycle['before'] as Map<String, dynamic>,
        );
      } else if (saved != null && saved['rulesVersion'] == 1) {
        state = GameState.fromJson(saved['state'] as Map<String, dynamic>);
      } else if (saved != null) {
        throw UnsupportedError(
          'Bu raund yeni oyun qayda versiyasındadır. Yenilənmə tələb olunur.',
        );
      }
      state ??= _newGame(catalog, best: saved?['best'] as int? ?? 0);
      await store.save({
        'state': state.toJson(),
        'best': state.best,
      }, rulesVersion: 1);
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
        _store = store;
        _state = state;
        _loading = false;
        _feedback = state!.moveCount == 0
            ? 'Fiquru seç və lövhədə uyğun xanaya toxun.'
            : 'Saxlanmış raund bərpa edildi.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _feedback = 'Oyun yaddaşı açıla bilmədi: $error';
      });
    }
  }

  GameState _newGame(ShapeCatalog catalog, {int best = 0}) {
    final seed = math.Random.secure().nextInt(0xffffffff);
    final tray = PieceGenerator(catalog).drawTray(seed);
    return GameState(
      board: List.filled(64, -1),
      tray: tray.pieces,
      score: 0,
      chain: 0,
      best: best,
      rng: tray.rng,
    );
  }

  String? get _activeFixture =>
      kDebugMode ? widget.fixture ?? Uri.base.queryParameters['fixture'] : null;

  GameState _intersectionFixture(ShapeCatalog catalog) {
    final rows = [
      '.#######',
      '#.......',
      '#.......',
      '#.......',
      '#.......',
      '#.......',
      '#.......',
      '#.......',
    ];
    final board = rows
        .join()
        .split('')
        .map((cell) => cell == '#' ? 0 : -1)
        .toList();
    final dot = catalog.pieceForIndex(catalog.ids.indexOf('dot'), color: 0);
    return GameState(
      board: board,
      tray: [null, null, dot],
      score: 0,
      chain: 2,
      best: 0,
      rng: 21,
    );
  }

  GameState _gestureFixture(ShapeCatalog catalog) {
    final dotIndex = catalog.ids.indexOf('dot');
    return GameState(
      board: List.filled(64, -1),
      tray: [
        for (var slot = 0; slot < 3; slot++)
          catalog.pieceForIndex(dotIndex, color: slot),
      ],
      score: 0,
      chain: 0,
      best: 0,
      rng: 21,
    );
  }

  GameState _lifecycleFixture(
    ShapeCatalog catalog,
    Map<String, dynamic> fixture,
  ) {
    final board = (fixture['board'] as List<dynamic>)
        .cast<String>()
        .join()
        .split('')
        .map((cell) => cell == '#' ? 0 : -1)
        .toList();
    final tray = (fixture['tray'] as List<dynamic>).map<Piece?>((raw) {
      if (raw == null) return null;
      final item = raw as Map<String, dynamic>;
      final index = catalog.ids.indexOf(item['shape'] as String);
      if (index < 0) {
        throw FormatException('Unknown fixture shape ${item['shape']}');
      }
      return catalog.pieceForIndex(index, color: item['color'] as int);
    }).toList();
    return GameState(
      board: board,
      tray: tray,
      score: fixture['score'] as int,
      chain: fixture['chain'] as int,
      best: fixture['personalBest'] as int,
      rng: fixture['rng'] as int,
    );
  }

  Future<void> _play(int slot, int row, int col) async {
    if (_committing || _state == null) return;
    final current = game;
    final piece = current.tray[slot];
    if (piece == null || !current.canPlace(piece, row, col)) {
      setState(() => _feedback = 'Bu fiqur həmin yerə yerləşmir.');
      return;
    }

    try {
      setState(() => _committing = true);
      final remainingPieces = current.tray.whereType<Piece>().length;
      final GeneratedTray? refill = remainingPieces == 1
          ? PieceGenerator(catalog).drawTray(current.rng)
          : null;
      final result = const RulesEngine().play(
        current,
        Placement(slot, row, col),
        refill: refill?.pieces,
        refillRng: refill?.rng,
      );
      final next = result.state.copyWith(
        best: math.max(current.best, result.state.score),
      );
      await _store!.save({
        'state': next.toJson(),
        'best': next.best,
      }, rulesVersion: 1);
      if (!mounted) return;
      setState(() {
        _state = next;
        _selected = null;
        _hover = null;
        _committing = false;
        _feedback = result.clearedLines > 0
            ? '${next.chain} kombo · +${next.score - current.score} xal'
            : '+${next.score - current.score} xal';
      });
      if (!next.hasLegalMove) _showResult();
    } on InvalidMove catch (error) {
      if (!mounted) return;
      setState(() {
        _committing = false;
        _feedback = 'Gediş qəbul edilmədi: ${error.reason}';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _committing = false;
        _feedback = 'Gediş yadda saxlanmadı. Yenidən cəhd et.';
      });
    }
  }

  Future<void> _restart() async {
    final next = _newGame(catalog, best: game.best);
    await _store!.save({
      'state': next.toJson(),
      'best': next.best,
    }, rulesVersion: 1);
    if (!mounted) return;
    setState(() {
      _state = next;
      _selected = null;
      _hover = null;
      _feedback = 'Yeni raund başladı.';
    });
  }

  void _playCell(int slot, int cell) => _play(slot, cell ~/ 8, cell % 8);

  void _showResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF292748),
          title: const Text('Raund bitdi'),
          content: Text('Xalın ${game.score} oldu.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _restart();
              },
              child: const Text('Yenidən oyna'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _store?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_state == null) {
      return Scaffold(
        body: Center(child: Text(_feedback, textAlign: TextAlign.center)),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = math
                .min(constraints.maxWidth - 32, constraints.maxHeight * .52)
                .clamp(240.0, 560.0);
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      const BrandMark(),
                      const SizedBox(width: 9),
                      const Text(
                        'Kombelo',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _draggingSlot == null ? _pause : null,
                        tooltip: 'Fasilə',
                        icon: const Icon(Icons.pause_rounded),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 4, 2, 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Metric(label: 'XAL', value: '${game.score}', size: 47),
                        const Spacer(),
                        Metric(
                          label: 'REKORD',
                          value: '${game.best}',
                          size: 25,
                          color: const Color(0xFFFFE05A),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _feedback,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFB8C0E3),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox.square(
                      dimension: boardSize,
                      child: GameBoard(
                        state: game,
                        selected: _selected,
                        hoverCell: _hover,
                        busy: _committing,
                        onHover: (index) => setState(() => _hover = index),
                        onTap: (index) {
                          if (_selected != null && _draggingSlot == null) {
                            _play(_selected!, index ~/ 8, index % 8);
                          }
                        },
                        onDrop: _playCell,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      3,
                      (slot) => Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: slot == 2 ? 0 : 8),
                          child: TraySlot(
                            slot: slot,
                            piece: game.tray[slot],
                            width: (constraints.maxWidth - 48) / 3,
                            selected: _selected == slot,
                            enabled:
                                !_committing &&
                                (_draggingSlot == null ||
                                    _draggingSlot == slot),
                            onTap: () {
                              if (_draggingSlot == null) {
                                setState(() => _selected = slot);
                              }
                            },
                            onDragStarted: () => setState(() {
                              _selected = slot;
                              _draggingSlot = slot;
                            }),
                            onDragEnded: (accepted) => setState(() {
                              _draggingSlot = null;
                              if (!accepted) _hover = null;
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _pause() => showModalBottomSheet<void>(
    context: context,
    backgroundColor: const Color(0xFF20264A),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fasilə',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Oyuna qayıt'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Yeni raund'),
              onTap: () {
                Navigator.pop(context);
                _restart();
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class Metric extends StatelessWidget {
  const Metric({
    super.key,
    required this.label,
    required this.value,
    required this.size,
    this.color = Colors.white,
  });
  final String label, value;
  final double size;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Color(0xFFB8C0E3),
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: size,
          height: 1,
          fontWeight: FontWeight.w800,
          fontFeatures: const [ui.FontFeature.tabularFigures()],
        ),
      ),
    ],
  );
}

class GameBoard extends StatefulWidget {
  const GameBoard({
    super.key,
    required this.state,
    required this.selected,
    required this.hoverCell,
    required this.busy,
    required this.onTap,
    required this.onHover,
    required this.onDrop,
  });
  final GameState state;
  final int? selected, hoverCell;
  final bool busy;
  final ValueChanged<int> onTap, onHover;
  final void Function(int slot, int cell) onDrop;
  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _key = GlobalKey();

  int? _cellAt(Offset global) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final local = box.globalToLocal(global);
    const inset = 5.0;
    const boundaryTolerance = 4.0;
    final gridExtent = box.size.width - inset * 2;
    final maxCoordinate = gridExtent + boundaryTolerance;
    final x = local.dx - inset;
    final y = local.dy - inset;
    if (x < -boundaryTolerance ||
        y < -boundaryTolerance ||
        x > maxCoordinate ||
        y > maxCoordinate) {
      return null;
    }
    final cell = (gridExtent - 14) / 8;
    final pitch = cell + 2;
    final col = (x.clamp(0.0, gridExtent - 1) / pitch).floor();
    final row = (y.clamp(0.0, gridExtent - 1) / pitch).floor();
    return row * 8 + col;
  }

  @override
  Widget build(BuildContext context) => DragTarget<int>(
    onWillAcceptWithDetails: (details) {
      return !widget.busy &&
          details.data >= 0 &&
          details.data < 3 &&
          widget.state.tray[details.data] != null;
    },
    onMove: (details) {
      final index = _cellAt(details.offset);
      if (index != null) {
        widget.onHover(index);
      }
    },
    onAcceptWithDetails: (details) {
      final index = _cellAt(details.offset);
      if (index != null) widget.onDrop(details.data, index);
    },
    builder: (context, candidates, rejected) => GestureDetector(
      onTapUp: (details) {
        if (widget.selected == null || widget.busy) {
          return;
        }
        final box = _key.currentContext?.findRenderObject() as RenderBox?;
        if (box == null) {
          return;
        }
        final index = _cellAt(details.globalPosition);
        if (index != null) widget.onTap(index);
      },
      child: Container(
        key: _key,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFF101226),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF454473)),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 64,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ 8;
            final col = index % 8;
            final existing = widget.state.board[index];
            final piece = widget.selected == null
                ? null
                : widget.state.tray[widget.selected!];
            final originRow = widget.hoverCell == null
                ? -100
                : widget.hoverCell! ~/ 8;
            final originCol = widget.hoverCell == null
                ? -100
                : widget.hoverCell! % 8;
            final isPieceCell =
                piece != null &&
                row >= originRow &&
                col >= originCol &&
                row < originRow + piece.height &&
                col < originCol + piece.width &&
                piece.hasCell(row - originRow, col - originCol);
            final isValid =
                isPieceCell &&
                widget.state.canPlace(piece, originRow, originCol);
            final baseColor = existing >= 0
                ? colors[existing]
                : isValid
                ? const Color(0xAA2DE1D2)
                : const Color(0xFF26294A);
            return GestureDetector(
              onTap: () => widget.onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(5),
                  border: isValid
                      ? Border.all(color: const Color(0xFF90FFF4), width: 1.5)
                      : null,
                  gradient: existing < 0
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: .35),
                            baseColor,
                            Colors.black.withValues(alpha: .12),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

class TraySlot extends StatelessWidget {
  const TraySlot({
    super.key,
    required this.slot,
    required this.piece,
    required this.width,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onDragStarted,
    required this.onDragEnded,
  });
  final int slot;
  final Piece? piece;
  final double width;
  final bool selected, enabled;
  final VoidCallback onTap, onDragStarted;
  final ValueChanged<bool> onDragEnded;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: 76,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2A3C52) : const Color(0xFF202243),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF72F2E8) : const Color(0xFF41456D),
          width: selected ? 2 : 1,
        ),
      ),
      child: Center(
        child: piece == null
            ? const SizedBox.shrink()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  piece!.height,
                  (row) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      piece!.width,
                      (col) => Container(
                        width: 16,
                        height: 16,
                        margin: const EdgeInsets.all(1),
                        decoration: piece!.hasCell(row, col)
                            ? BoxDecoration(
                                color: colors[piece!.color],
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: .38),
                                    colors[piece!.color],
                                    Colors.black.withValues(alpha: .13),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
    if (piece == null) return child;
    return Draggable<int>(
      data: slot,
      maxSimultaneousDrags: enabled ? 1 : 0,
      onDragStarted: onDragStarted,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      onDragEnd: (details) => onDragEnded(details.wasAccepted),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.15,
          child: Transform.translate(
            offset: Offset(-width / 2, -88),
            child: Opacity(opacity: .94, child: child),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: child),
      child: Semantics(
        button: true,
        label: 'Fiqur ${slot + 1}',
        child: GestureDetector(onTap: enabled ? onTap : null, child: child),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: const Color(0xFF282C55),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Stack(
      children: [
        _cell(5, 22, colors[0]),
        _cell(18, 22, colors[2]),
        _cell(18, 9, colors[1]),
      ],
    ),
  );
  Widget _cell(double left, double bottom, Color color) => Positioned(
    left: left,
    bottom: bottom,
    child: Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55FFFFFF),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
    ),
  );
}

Future<Map<String, dynamic>> loadRules() async =>
    jsonDecode(await rootBundle.loadString('assets/game-v1.json'))
        as Map<String, dynamic>;
