import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedMascot extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const AnimatedMascot({
    super.key,
    required this.imagePath,
    this.width = 100,
    this.height = 100,
  });

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot> with TickerProviderStateMixin {
  // 캐릭터 움직임 컨트롤러
  late final AnimationController _moveController;
  late final Animation<double> _positionAnimation;
  late final Animation<double> _rotationAnimation;

  // 하트 관리 리스트
  final List<Widget> _hearts = [];

  @override
  void initState() {
    super.initState();

    // 1. 캐릭터 둥둥 떠다니는 애니메이션 설정
    _moveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _positionAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOutQuad),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  // 2. 하트 추가 함수
  void _addHeart() {
    // 고유한 키 생성
    final Key heartKey = UniqueKey();

    setState(() {
      _hearts.add(
        _HeartAnimation(
          key: heartKey,
          onComplete: () {
            // 애니메이션 끝나면 리스트에서 제거 (메모리 관리)
            setState(() {
              _hearts.removeWhere((element) => element.key == heartKey);
            });
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height + 50, // 하트가 올라갈 공간 확보
      child: Stack(
        alignment: Alignment.center, // 중앙 정렬
        clipBehavior: Clip.none,     // 영역 밖으로 나가도 보이게
        children: [
          // (1) 캐릭터 (터치 감지)
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                _addHeart(); // 터치하면 하트 추가!
              },
              child: AnimatedBuilder(
                animation: _moveController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _positionAnimation.value),
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Image.asset(
                  widget.imagePath,
                  width: widget.width,
                  height: widget.height,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // (2) 생성된 하트들 (캐릭터 위에 겹쳐서 표시)
          ..._hearts,
        ],
      ),
    );
  }
}

// ==========================================
// ★ 하트 애니메이션 위젯 (작은 하트가 위로 올라가며 사라짐)
// ==========================================
class _HeartAnimation extends StatefulWidget {
  final VoidCallback onComplete;

  const _HeartAnimation({super.key, required this.onComplete});

  @override
  State<_HeartAnimation> createState() => _HeartAnimationState();
}

class _HeartAnimationState extends State<_HeartAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _position;
  late final Animation<double> _scale;

  // 랜덤 각도 (하트가 살짝 왼쪽이나 오른쪽으로 휘어지게)
  final double randomAngle = (math.Random().nextDouble() - 0.5) * 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), // 0.8초 동안 생존
      vsync: this,
    );

    // 점점 투명해짐
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    // 위로 100px 올라감
    _position = Tween<double>(begin: 0, end: -100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 크기가 커졌다 작아짐 (팝!)
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(_controller);

    // 시작!
    _controller.forward().whenComplete(() {
      widget.onComplete(); // 끝나면 부모에게 알려서 삭제
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 50 + _position.value, // 캐릭터 머리 위쯤에서 시작해서 위로 올라감
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Transform.rotate(
                angle: randomAngle, // 랜덤하게 기울어짐
                child: const Icon(
                  Icons.favorite_rounded,
                  color: Colors.pinkAccent,
                  size: 30, // 하트 크기
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}