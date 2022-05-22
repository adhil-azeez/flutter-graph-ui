import 'package:flutter/material.dart';
import 'dart:math' as math;

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  final _keyCar = GlobalKey();
  final _keyStop1 = GlobalKey();
  final _keyStop2 = GlobalKey();
  final _keyStop3 = GlobalKey();
  final _keyStop4 = GlobalKey();

  late final AnimationController _animController;

  final carSize = const Size(25, 50);

  Offset? _initialCarPosition = Offset.zero;
  Offset? _carPosition = Offset.zero;
  Offset? _stopPosition = Offset.zero;
  Offset _currentDirection = const Offset(0.0, 1.0);

  Animation<Offset>? _carVerticalMoveAnimation;
  Animation<double>? _rotateAnimation;
  double centerDx = 0;

  @override
  void initState() {
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _initAnimations();

    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _carPosition = (_keyCar.currentContext!.findRenderObject() as RenderBox)
          .localToGlobal(Offset.zero);
      _initialCarPosition = _carPosition;
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    centerDx = MediaQuery.of(context).size.width * 0.5;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
                child: Column(
              children: [
                Row(
                  children: [
                    _buildDragTarget(context, _keyStop1),
                    const Spacer(),
                    _buildDragTarget(context, _keyStop2),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildDragTarget(context, _keyStop3),
                    const Spacer(),
                    _buildDragTarget(context, _keyStop4),
                  ],
                ),
              ],
            )),
            Positioned(
              top: 100,
              left: 100,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..translate(_carVerticalMoveAnimation!.value.dx,
                            _carVerticalMoveAnimation!.value.dy)
                        ..rotateZ(_rotateAnimation?.value ?? 0.0),
                      child: child!);
                },
                child: Draggable<int>(
                  dragAnchorStrategy: (draggable, context, position) {
                    return const Offset(12.5, 12.5);
                  },
                  feedbackOffset: const Offset(0.0, 0.0),
                  // onDragUpdate: (detail) {
                  // },
                  onDragStarted: () {},
                  onDragCompleted: () {},
                  onDragEnd: (details) {},
                  onDraggableCanceled: (_, __) {},
                  child: Container(
                    key: _keyCar,
                    width: carSize.width,
                    height: carSize.height,
                    color: Colors.blue,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 25,
                      height: 10,
                      color: Colors.orange,
                    ),
                  ),
                  feedback: Container(
                    width: 25,
                    height: 50,
                    color: Colors.orange,
                  ),
                  data: 121,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DragTarget<int> _buildDragTarget(BuildContext context, GlobalKey key) {
    return DragTarget<int>(
      key: key,
      onLeave: (data) {},
      onAcceptWithDetails: (details) {
        _stopPosition = (key.currentContext!.findRenderObject() as RenderBox)
                .localToGlobal(const Offset(0, 0)) +
            const Offset((100 - 25) * 0.5, 50);

        _initAnimations();
        _playAnimation();
      },
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {},
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.green,
        );
      },
    );
  }

  void _initAnimations() {
    if (_initialCarPosition == Offset.zero) {
      _carVerticalMoveAnimation = const AlwaysStoppedAnimation(Offset.zero);
      _rotateAnimation = const AlwaysStoppedAnimation(0.0);
      return;
    }
    final diffStopOffset = _stopPosition! -
        _initialCarPosition! +
        Offset(0, -carSize.height * 0.5);
    final diffCarOffset =
        _carPosition! - _initialCarPosition! + Offset(0, -carSize.height * 0.5);

    var movementItems = <TweenSequenceItem<Offset>>[];
    var rotationItems = <TweenSequenceItem<double>>[];
    bool hasReached = false;
    int step = 1;
    double previousWeight = 0.0;
    int direction = 1;

    Offset carPosition = diffCarOffset;
    while (!hasReached) {
      double levelWeight = 0.0;
      Offset nextDirection = Offset.zero;

      Offset endOffset = Offset.zero;

      switch (step) {
        // Step 1: Move the car to center position
        case 1:
          final directionDiff = centerDx - carPosition.dx;
          nextDirection = Offset(directionDiff.sign, 0.0);
          endOffset = carPosition;

          if (_currentDirection != nextDirection) {
            levelWeight = 0.10;
          }

          break;

        case 2:
          nextDirection = _currentDirection;
          levelWeight = 0.20 - previousWeight;
          endOffset = Offset(195 - _initialCarPosition!.dx, diffCarOffset.dy);
          break;

        case 3:
          if (diffStopOffset.dy >= carPosition.dy - 25) {
            nextDirection = const Offset(0.0, -1.0);
          } else {
            nextDirection = const Offset(0.0, 1.0);
          }

          endOffset = carPosition;
          if (_currentDirection != nextDirection) {
            levelWeight = 0.10;
          }
          break;

        case 4:
          nextDirection = _currentDirection;
          endOffset = Offset(carPosition.dx, diffStopOffset.dy);
          if (carPosition.dy != diffStopOffset.dy) {
            levelWeight = 0.35 - previousWeight;
          }
          break;

        case 5:
          final directionDiff = centerDx - _stopPosition!.dx;
          nextDirection = Offset(directionDiff.sign, 0.0);
          endOffset = carPosition;
          if (_currentDirection != nextDirection) {
            levelWeight = 0.10;
          }
          break;

        case 6:
          nextDirection = _currentDirection;
          levelWeight = 0.20 - previousWeight;
          endOffset = diffStopOffset;
          break;

        default:
          hasReached = true;
          break;
      }

      if (hasReached) break;

      if (levelWeight != 0) {
        var begin = _getRotationPiFrom(_currentDirection, direction);
        var end = _getRotationPiFrom(nextDirection, direction);

        if (begin - end > math.pi) {
          begin *= -1;
        }

        if (end - begin > math.pi) {
          end *= -1;
        }

       
        rotationItems.add(
          TweenSequenceItem<double>(
            tween: Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: Curves.easeOutSine)),
            weight: levelWeight,
          ),
        );
        movementItems.add(TweenSequenceItem(
          tween: Tween<Offset>(
            begin: carPosition,
            end: endOffset,
          ).chain(CurveTween(curve: Curves.easeOutSine)),
          weight: levelWeight,
        ));
      }

      carPosition = endOffset;
      previousWeight = levelWeight;
      _currentDirection = nextDirection;
      step++;
    }
    _carVerticalMoveAnimation =
        TweenSequence<Offset>(movementItems).animate(_animController);

    _rotateAnimation =
        TweenSequence<double>(rotationItems).animate(_animController);

    // _carVerticalMoveAnimation =
    //     ConstantTween<Offset>(Offset.zero).animate(_animController);
    _carPosition = _stopPosition;
  }

  void _playAnimation() {
    _animController.reset();
    _animController.forward().orCancel;
  }

  double _getRotationPiFrom(Offset nextOffset, int direction) {
    double rotation = 0;

    if (nextOffset == const Offset(0.0, -1.0)) {
      rotation = math.pi * 0.0;
    }

    if (nextOffset == const Offset(1.0, 0.0)) {
      rotation = math.pi * -0.5;
    }

    if (nextOffset == const Offset(0.0, 1.0)) {
      rotation = math.pi * 1.0;
    }

    if (nextOffset == const Offset(-1.0, 0.0)) {
      rotation = math.pi * 0.5;
    }

    return rotation;
  }
}
