import 'package:flashmaster/classess/Flashcard.dart';
import 'package:flashmaster/database/flash.dart';
import 'package:flashmaster/widgets/Textfields.dart';
import 'package:flutter/material.dart';

class Flashcardscreen extends StatefulWidget {
  const Flashcardscreen({
    super.key,
    // required this.Question,
    // required this.Answer,
    required this.id,
  });
  final int id;
  // final String Question;
  // final String Answer;
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
    question = card!.Question;
    answer = card.Answer;
    setState(() {});
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
        builder: (context) {
          return Center(
            child: Form(
                key: formkey,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    QuestionTextField(
                      // hintText: "Question",
                      initialValue: question,
                      onSaved: (value) {
                        question = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the question";
                        }
                        return null;
                      },
                    ),
                    QuestionTextField(
                      initialValue: answer,
                      // hintText: "Answer",
                      onSaved: (value) {
                        answer = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the Answer";
                        }
                        return null;
                      },
                    ),
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          elevation: 3,
                          iconColor: Colors.white,
                          backgroundColor:
                              const Color.fromARGB(255, 18, 134, 0),
                          // textStyle: TextStyle(color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 30),
                        ),
                        onPressed: () async {
                          if (formkey.currentState!.validate()) {
                            formkey.currentState!.save();
                            try {
                              await db.updateCard(Flashcard(
                                  id: widget.id,
                                  Question: question,
                                  Answer: answer));
                            } catch (e) {
                              print(e);
                              print(
                                  "......................................................");
                            }
                          }
                          setState(() {
                            getdata();
                          });
                          Navigator.pop(context);
                        },
                        label: const Text(
                          "Update",
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(Icons.save))
                  ],
                )),
          );
        });
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: update,
              icon: const Icon(Icons.edit),
            ),
          )
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard,
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
                    ? _buildCard(question, Colors.blue, Colors.white)
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.14159265359),
                        child: _buildCard(answer, Colors.green, Colors.white),
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
      height: MediaQuery.of(context).size.height * 0.5,
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
