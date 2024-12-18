import 'package:flashmaster/Screens/flashcardScreen.dart';
import 'package:flashmaster/classess/Flashcard.dart';
import 'package:flashmaster/database/flash.dart';
import 'package:flashmaster/widgets/Textfields.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  String question = "";
  String answer = "";
  final db = FlashCardDatabase.instance;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  late Future<List<Flashcard>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer for lifecycle
    loadcards();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadcards(); // Refresh data on returning to app
    }
  }

  void saveflashcard() async {
    final isValid = formkey.currentState!.validate();
    if (!isValid) {
      return;
    }
    formkey.currentState!.save();
    try {
      int? maxId = await db.getMaxId();
      int newId = (maxId ?? 0) + 1;
      await db
          .insertCard(Flashcard(id: newId, Question: question, Answer: answer));
      setState(() {
        loadcards();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Flashcard added successfully"),
        duration: Duration(seconds: 2),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Flashcard add failed"),
        duration: Duration(seconds: 2),
      ));
    }
    Navigator.of(context).pop();
  }

  void addflashcard() {
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
                  hintText: "Enter the question",
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
                  hintText: "Enter the answer",
                  onSaved: (value) {
                    answer = value!;
                  },
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
                  onPressed: saveflashcard,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void loadcards() {
    setState(() {
      _cardsFuture = db.getCards();
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.cyan],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Center(
        child: FutureBuilder<List<Flashcard>>(
          future: _cardsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return const Text("Something went wrong. Please try again.");
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    "No flashcards available!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap the + button to add your first flashcard.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final card = snapshot.data![index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                      card.Question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      card.Answer,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        db.deleteCard(card.id);
                        setState(() {
                          loadcards();
                        });
                      },
                    ),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) =>
                                  Flashcardscreen(id: card.id)))
                          .then((_) {
                        loadcards();
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addflashcard,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
