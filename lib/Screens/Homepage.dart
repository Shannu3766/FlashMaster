import 'package:flashmaster/classess/Flashcard.dart';
import 'package:flashmaster/database/flash.dart';
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
  final db = FlashCardDatabase.instance;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  late Future<List<Flashcard>> _cardsFuture;
  void saveflashcard() async {
    final isValid = formkey.currentState!.validate();
    if (!isValid) {
      return;
    }
    formkey.currentState!.save();
    print(
        ".......................................................................");
    print("Question is $question");
    print("Answer is $answer");
    try {
      int? maxId = await db.getMaxId();
      int newId = (maxId ?? 0) + 1;
      await db
          .insertCard(Flashcard(id: newId, Question: question, Answer: answer));
      print("success");
      setState(() {
        loadcards();
      });
    } catch (e) {
      print("failed");
      print(e.toString());
    }
    Navigator.of(context).pop();
  }

  void addflashcard() {
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
                        answer = value!;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the question";
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
                        onPressed: saveflashcard,
                        label: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        icon: Icon(Icons.save))
                  ],
                )),
          );
        });
  }

  void loadcards() {
    _cardsFuture = db.getCards();
  }

  @override
  void initState() {
    super.initState();
    loadcards();
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
          child: FutureBuilder<List<Flashcard>>(
              future: _cardsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  print(
                      ".........................................................");
                  return const Text(
                      "Something went wrong...............................");
                }
                if (!snapshot.hasData || snapshot.data!.length == 0) {
                  return const Text("No data found");
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(snapshot.data![index].Question),
                        subtitle: Text(snapshot.data![index].Answer),
                      );
                    });
              }),
        ),
      ),
    );
  }
}
