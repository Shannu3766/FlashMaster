import 'package:flashmaster/classess/Flashcard.dart';
import 'package:flashmaster/database/flash.dart';
import 'package:flashmaster/widgets/Textfields.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Flashcardscreen extends StatefulWidget {
  const Flashcardscreen({
    super.key,
    required this.id,
  });
  final int id;

  @override
  State<Flashcardscreen> createState() => _FlashcardscreenState();
}

class _FlashcardscreenState extends State<Flashcardscreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool isFront = true;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  String question = "";
  String answer = "";
  final db = FlashCardDatabase.instance;

  void getdata() async {
    Flashcard? card = await db.getCardById(widget.id);
    setState(() {
      question = card?.Question ?? "No Question Found!";
      answer = card?.Answer ?? "No Answer Found!";
    });
  }

  @override
  void initState() {
    getdata();
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void update() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              top: 16,
              left: 16,
              right: 16),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QuestionTextField(
                  initialValue: question,
                  onSaved: (value) => question = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the question";
                    }
                    return null;
                  },
                ),
                QuestionTextField(
                  initialValue: answer,
                  onSaved: (value) => answer = value!,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the answer";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    if (formkey.currentState!.validate()) {
                      formkey.currentState!.save();
                      await db.updateCard(Flashcard(
                          id: widget.id, Question: question, Answer: answer));
                      setState(() {
                        getdata();
                      });
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
        title: const Text(
          "FlashMaster",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 4,
      ),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * pi; // Use π for rotation
              final isFrontVisible = angle < pi / 2;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(angle),
                child: isFrontVisible
                    ? _buildCard(question, Colors.blue, Colors.white)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: _buildCard(answer, Colors.green, Colors.white),
                      ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: update,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }

  Widget _buildCard(String text, Color backgroundColor, Color textColor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
