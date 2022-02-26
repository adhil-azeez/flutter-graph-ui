import 'package:flutter/material.dart';
import 'package:flutter_graph_ui/models/graph_model.dart';
import 'package:flutter_graph_ui/utils/colors.dart';

class GraphWidget extends StatefulWidget {
  const GraphWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  Animation<double>? _anim;
  bool _isForward = true;
  final _list = [
    GrpahModel(x: 10, y: -10),
    GrpahModel(x: 25, y: 60),
    GrpahModel(x: 45, y: -30),
    GrpahModel(x: 70, y: 120),
    GrpahModel(x: 90, y: -30),
    GrpahModel(x: 110, y: 69),
  ];

  late final List<GrpahModel> _highPoints;

  @override
  void initState() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1000,
      ),
    );

    super.initState();

    _initHighPoints();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _anim = CurvedAnimation(
      parent: _animController,
      curve: Curves.decelerate,
    );
    return AnimatedBuilder(
        animation: _anim!,
        builder: (context, _) {
          return InkWell(
            onTap: () {
              if (_isForward) {
                _animController.reverse().orCancel;
              } else {
                _animController.forward().orCancel;
              }
              _isForward = !_isForward;
            },
            child: CustomPaint(
              painter: _ThisCustomPainter(
                animVal: _anim!.value,
                list: _list,
                highPoints: _highPoints,
              ),
              size: Size.fromHeight(30 + (320 * _anim!.value)),
            ),
          );
        });
  }

  void _initHighPoints() {
    final list = List<GrpahModel>.from(_list);
    list.sort((a, b) => b.y.compareTo(a.y));
    _highPoints = list.where((e) => e.x < 100).take(2).toList();
  }
}

class _ThisCustomPainter extends CustomPainter {
  final double animVal;
  final List<GrpahModel> list;
  final List<GrpahModel> highPoints;

  final _bgPaint = Paint()..color = color21DCB6;
  final _paintCurveOne = Paint()
    ..color = colorFFB5D8
    ..style = PaintingStyle.fill;
  final _paintCurveTwo = Paint()
    ..color = colorFFE9B6
    ..style = PaintingStyle.fill;

  _ThisCustomPainter({
    required this.animVal,
    required this.list,
    required this.highPoints,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.drawRect(
      Offset.zero & Size(size.width, size.height * 0.8),
      _bgPaint,
    );

    _drawAllCurves(canvas, size);

    _drawHighPointCircles(canvas, size);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  void _drawAllCurves(Canvas canvas, Size size) {
    double heightShift = 0.9752;
    Path path = _getCurvePath(size.height * heightShift, 0.2, list, size);

    canvas.clipPath(Path.combine(PathOperation.reverseDifference, path,
        Path()..addRect(Offset.zero & size)));
    heightShift = 0.7;

    path = _getCurvePath(size.height * heightShift, 1.0, list, size);

    canvas.drawPath(path, _paintCurveOne);

    heightShift = 0.8;
    path = _getCurvePath(size.height * heightShift, 0.4, list, size);

    canvas.drawPath(path, _paintCurveTwo);
  }

  Path _getCurvePath(
      double height, double heightRatio, List<GrpahModel> list, Size size) {
    final path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(0.0, height);
    final pointWidthRatio = size.width * 0.01;
    final pointHeightRatio = height * 0.01;

    for (int i = 1; i < list.length; i++) {
      final model = list[i];
      final previousModel = list[i - 1];
      final points = _getCurvePoints(previousModel, model);
      path.quadraticBezierTo(
        points[0] * pointWidthRatio,
        height + (points[1] * pointHeightRatio * (heightRatio)),
        points[2] * pointWidthRatio,
        height + (points[3] * pointHeightRatio * (heightRatio)),
      );
    }

    final points = _getCurvePoints(
        list[list.length - 1], GrpahModel(x: size.width, y: size.height));
    path.quadraticBezierTo(
      points[0] * pointWidthRatio,
      height + (points[1] * pointHeightRatio),
      points[2] * pointWidthRatio,
      height + (points[3] * pointHeightRatio),
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  List<double> _getCurvePoints(GrpahModel previousModel, GrpahModel model) {
    double x1, y1, x2, y2;

    final double midX1 = previousModel.x + ((model.x - previousModel.x) * 0.5);
    final double midY1 = previousModel.y + ((model.y - previousModel.y) * 0.5);

    x1 = previousModel.x;
    y1 = 1 - (previousModel.y);

    x2 = midX1;
    y2 = 1 - (midY1);

    // print([x1, y1, x2, y2]);
    return [x1, y1, x2, y2];
  }

  void _drawHighPointCircles(Canvas canvas, Size size) {
    const double radius = 20.0;
    // double animVal = 0.1;

    double heightScale = (animVal / 0.5) - 1.0;
    double scale = 1.0 - heightScale.abs();

    // scale = 0.1;

    final height = size.height * 0.7;
    canvas.save();
    canvas.translate(0.0, height * 0.324);

    for (final point in highPoints) {
      final double w = point.x * size.width * 0.01;
      final double h = ((height - (point.y * (height) * 0.01)) * 0.5);
      final Offset c =
          Offset(w, (h * 1.425) + (-40 * heightScale.clamp(-0.25, 1.5)));

      canvas.drawCircle(c, radius * (scale), _paintCurveOne);
    }

    canvas.restore();
  }
}
