import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SOSButton extends StatefulWidget {
  final VoidCallback onTapSOS;     
  final VoidCallback onLongPressSOS; 

  const SOSButton({
    super.key,
    required this.onTapSOS,
    required this.onLongPressSOS,
  });

  @override
  _SOSButtonState createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 0.1,
    );

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _vibrate() {
    HapticFeedback.vibrate();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
        _vibrate();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTapSOS();
      },
      onTapCancel: () {
        _controller.reverse();
      },

      onLongPress: () {
        _vibrate();
        widget.onLongPressSOS();
      },

      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },

        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFD6003D),
                Color(0xFF8B002C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 40),
              SizedBox(height: 5),
              Text(
                "SOS",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
