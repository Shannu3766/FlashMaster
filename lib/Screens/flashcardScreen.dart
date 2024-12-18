import 'package:flutter/material.dart';

class Flashcardscreen extends StatefulWidget {
  const Flashcardscreen({
    super.key,
    required this.Question,
    required this.Answer,
    required this.id,
  });
  final int id;
  final String Question;
  final String Answer;

  @override
  State<Flashcardscreen> createState() => _FlashcardscreenState();
}

class _FlashcardscreenState extends State<Flashcardscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool isFront = true;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isFront = !isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flashmaster"),
      ),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard, // Trigger flip animation on tap
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle =
                  _flipAnimation.value * 3.14159265359; // π (180 degrees)
              final isFrontVisible = angle < 3.14159265359 / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(angle),
                child: isFrontVisible
                    ? _buildCard(widget.Question, Colors.blue, Colors.white)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159265359),
                        child: _buildCard(
                            widget.Answer, Colors.green, Colors.white),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String text, Color backgroundColor, Color textColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
