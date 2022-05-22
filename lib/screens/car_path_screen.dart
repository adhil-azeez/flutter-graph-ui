import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter_svg/svg.dart';

class CarPathScreen extends StatefulWidget {
  const CarPathScreen({Key? key}) : super(key: key);

  @override
  State<CarPathScreen> createState() => _CarPathScreenState();
}

class _CarPathScreenState extends State<CarPathScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  final _keyCar = GlobalKey();
  final _keyStop1 = GlobalKey();
  final _keyStop2 = GlobalKey();
  final _keyStop3 = GlobalKey();
  final _keyStop4 = GlobalKey();

  Animation<Offset>? _carMoveAnimation;
  Animation<double>? _carRotationAnimation;

  final Size _stopSize = const Size(100, 102);
  final Size _carSize = const Size(50, 55);

  Offset _initialCarPosition = Offset.zero;
  Offset _carPosition = Offset.zero;
  Offset _stopPosition = Offset.zero;
  Offset _currentDirection = const Offset(0.0, 1.0);
  double _centerDx = 0;

  @override
  void initState() {
    _animationController =
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _centerDx = (MediaQuery.of(context).size.width + _carSize.width) * 0.5;

    return Scaffold(
      backgroundColor: const Color(0xFF011b2e),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              "assets/car_path/road.svg",
              width: _stopSize.width,
            ),
          ),
          Positioned(
            top: 350,
            left: 0,
            right: 0,
            child: Center(
              child: SvgPicture.asset(
                "assets/car_path/road.svg",
                width: _stopSize.width,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SvgPicture.asset(
              "assets/car_path/junction.svg",
              width: _stopSize.width * 2.40,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SvgPicture.asset(
              "assets/car_path/junction.svg",
              width: _stopSize.width * 2.40,
            ),
          ),
          Positioned.fill(
            top: 65,
            bottom: 68,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildStopWidget(_keyStop1),
                    const Spacer(),
                    _buildStopWidget(_keyStop2),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    _buildStopWidget(_keyStop3),
                    const Spacer(),
                    _buildStopWidget(_keyStop4),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 100,
            top: 100,
            child: _buildCarWidget(_keyCar),
          ),
        ],
      ),
    );
  }

  Widget _buildCarWidget(GlobalKey key) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) => Transform(
        transform: Matrix4.identity()
          ..translate(_carMoveAnimation?.value.dx ?? 0.0,
              _carMoveAnimation?.value.dy ?? 0.0)
          ..rotateZ(_carRotationAnimation?.value ?? 0.0),
        alignment: Alignment.center,
        child: child,
      ),
      child: Draggable(
        data: "car",
        feedback: Container(
          width: _carSize.width,
          height: _carSize.height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white,
                Colors.white,
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
        ),
        child: Transform.rotate(
          angle: math.pi,
          child: SizedBox(
            width: _carSize.width,
            height: _carSize.height,
            child: SvgPicture.asset(
              "assets/car_path/car.svg",
              key: key,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStopWidget(GlobalKey key) {
    return DragTarget(
      onAcceptWithDetails: (details) {
        _stopPosition = (key.currentContext!.findRenderObject() as RenderBox)
                .localToGlobal(Offset.zero) +
            Offset(_stopSize.width, _stopSize.height);
        _initAnimations();
        _playAnimation();
      },
      onWillAccept: (data) => true,
      builder: (context, candidateData, rejectedData) => SizedBox(
        key: key,
        width: _stopSize.width,
        height: _stopSize.height,
        child: SvgPicture.asset(
          "assets/car_path/parking.svg",
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  void _initAnimations() {
    if (_initialCarPosition == Offset.zero) {
      _carMoveAnimation = const AlwaysStoppedAnimation(Offset.zero);
      _carRotationAnimation = const AlwaysStoppedAnimation(0.0);
      return;
    }

    final diffStopOffset = _stopPosition -
        _initialCarPosition +
        Offset(-_carSize.width * 0.5, -_carSize.height * 0.5);
    final diffCarOffset = _carPosition -
        _initialCarPosition +
        Offset(-_carSize.width * 0.5, -_carSize.height * 0.5);

    var movementItems = <TweenSequenceItem<Offset>>[];
    var rotationItems = <TweenSequenceItem<double>>[];

    // Car path animation logic for [Transform]
    bool hasReached = false;
    int step = 1;
    double previousWeight = 0.0;
    Offset carPosition = diffCarOffset;

    while (!hasReached) {
      double levelWeight = 0.0;
      Offset nextDirection = Offset.zero;
      Offset endOffset = Offset.zero;
      switch (step) {
        // Move the car to center
        case 1:
          final directionDiff = (_centerDx - _carSize.width) - carPosition.dx;
          nextDirection = Offset(directionDiff.sign, 0.0);
          endOffset = carPosition;
          if (_currentDirection != nextDirection) {
            levelWeight = 0.10;
          }
          break;

        case 2:
          nextDirection = _currentDirection;
          levelWeight = 0.20 - previousWeight;
          endOffset =
              Offset(_centerDx - _initialCarPosition.dx, diffCarOffset.dy);
          break;

        case 3:
          if (diffStopOffset.dy >= carPosition.dy - (_carSize.height * 0.5)) {
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
          final directionDiff = _centerDx - _stopPosition.dx;
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
      }

      if (hasReached) break;

      if (levelWeight != 0) {
        double begin = _getRotationFromOffset(_currentDirection);
        double end = _getRotationFromOffset(nextDirection);

        if (begin - end > math.pi) {
          begin *= -1;
        }

        if (end - begin > math.pi) {
          end *= -1;
        }

        rotationItems.add(TweenSequenceItem<double>(
            tween: Tween<double>(begin: begin, end: end), weight: levelWeight));

        movementItems.add(
          TweenSequenceItem<Offset>(
            tween: Tween<Offset>(begin: carPosition, end: endOffset),
            weight: levelWeight,
          ),
        );
      }
      carPosition = endOffset;
      previousWeight = levelWeight;
      _currentDirection = nextDirection;
      step++;
    }

    _carMoveAnimation =
        TweenSequence<Offset>(movementItems).animate(_animationController);

    _carRotationAnimation =
        TweenSequence<double>(rotationItems).animate(_animationController);

    _carPosition = _stopPosition;
  }

  void _playAnimation() => _animationController
    ..reset()
    ..forward().orCancel;

  double _getRotationFromOffset(Offset offset) {
    double rotation = 0;
    if (offset == const Offset(0.0, -1.0)) {
      rotation = math.pi * 0.0;
    } else if (offset == const Offset(1.0, 0.0)) {
      rotation = math.pi * -0.5;
    } else if (offset == const Offset(0.0, 1.0)) {
      rotation = math.pi * 1.0;
    } else if (offset == const Offset(-1.0, 0.0)) {
      rotation = math.pi * 0.5;
    }
    return rotation;
  }
}
