import 'package:flashmaster/widgets/Textfields.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String question = "";
  String answer = "";
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  void addflashcard() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Center(
            child: Form(
                child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                QuestionTextField(
                  hintText: "Question",
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
                  hintText: "Answer",
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
              ],
            )),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FlashMaster"),
        actions: [
          IconButton(
              onPressed: () {
                addflashcard();
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Center(
        child: Container(
          child: Text("shanmukha"),
        ),
      ),
    );
  }
}
