import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../widgets/widgets.dart';

enum _DrawTool { pen2, pen3, pen5, eraser }

class DryRunScreen extends StatefulWidget {
  const DryRunScreen({super.key});

  @override
  State<DryRunScreen> createState() => _DryRunScreenState();
}

class _DryRunScreenState extends State<DryRunScreen> {
  static const _canvasColor = Color(0xFFFFFEF7);
  static const _inkColor = Color(0xFF1A1A2E);

  final _strokes = <_DrawStroke>[];
  _DrawStroke? _activeStroke;
  _DrawTool _tool = _DrawTool.pen3;

  double get _strokeWidth => switch (_tool) {
        _DrawTool.pen2 => 2,
        _DrawTool.pen3 => 3,
        _DrawTool.pen5 => 5,
        _DrawTool.eraser => 24,
      };

  Color get _strokeColor => _tool == _DrawTool.eraser ? _canvasColor : _inkColor;

  void _startStroke(Offset point) {
    setState(() {
      _activeStroke = _DrawStroke(
        points: [point],
        width: _strokeWidth,
        color: _strokeColor,
        isEraser: _tool == _DrawTool.eraser,
      );
    });
  }

  void _extendStroke(Offset point) {
    setState(() => _activeStroke?.points.add(point));
  }

  void _endStroke() {
    if (_activeStroke == null) return;
    setState(() {
      _strokes.add(_activeStroke!);
      _activeStroke = null;
    });
  }

  void _clearBoard() {
    setState(() {
      _strokes.clear();
      _activeStroke = null;
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dry Run'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _strokes.isEmpty ? null : _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear board',
            onPressed: _strokes.isEmpty && _activeStroke == null ? null : _clearBoard,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  _toolChip(_DrawTool.pen2, '2'),
                  const SizedBox(width: 6),
                  _toolChip(_DrawTool.pen3, '3'),
                  const SizedBox(width: 6),
                  _toolChip(_DrawTool.pen5, '5'),
                  const SizedBox(width: 12),
                  _toolChip(_DrawTool.eraser, 'Erase', icon: Icons.auto_fix_off),
                  const Spacer(),
                  Text(
                    'Pen size 2 · 3 · 5',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _canvasColor,
                    border: Border.all(color: AppColors.divider, width: 1.5),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        onPanStart: (d) => _startStroke(d.localPosition),
                        onPanUpdate: (d) => _extendStroke(d.localPosition),
                        onPanEnd: (_) => _endStroke(),
                        onPanCancel: () => _endStroke(),
                        child: CustomPaint(
                          size: Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _BoardPainter(
                            canvasColor: _canvasColor,
                            strokes: _strokes,
                            activeStroke: _activeStroke,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
            child: Text(
              'Write arrays, dry run steps, logic — finger se draw karo',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toolChip(_DrawTool tool, String label, {IconData? icon}) {
    final selected = _tool == tool;
    return FilterChip(
      selected: selected,
      showCheckmark: false,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: selected ? AppColors.textPrimary : AppColors.textSecondary),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      onSelected: (_) => setState(() => _tool = tool),
      selectedColor: AppColors.primary.withValues(alpha: 0.35),
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.primaryLight : AppColors.divider),
    );
  }
}

class _DrawStroke {
  _DrawStroke({
    required this.points,
    required this.width,
    required this.color,
    required this.isEraser,
  });

  final List<Offset> points;
  final double width;
  final Color color;
  final bool isEraser;
}

class _BoardPainter extends CustomPainter {
  _BoardPainter({
    required this.canvasColor,
    required this.strokes,
    required this.activeStroke,
  });

  final Color canvasColor;
  final List<_DrawStroke> strokes;
  final _DrawStroke? activeStroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = canvasColor);

    for (final stroke in [...strokes, if (activeStroke != null) activeStroke!]) {
      _paintStroke(canvas, stroke);
    }
  }

  void _paintStroke(Canvas canvas, _DrawStroke stroke) {
    if (stroke.points.isEmpty) return;

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, stroke.width / 2, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (var i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) =>
      oldDelegate.strokes != strokes || oldDelegate.activeStroke != activeStroke;
}
