class Flashcard {
  Flashcard({required this.id, required this.Question, required this.Answer});
  final int id;
  final String Question;
  final String Answer;
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Question': Question,
      'Answer': Answer,
    };
  }

  static Flashcard fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      Question: map['Question'],
      Answer: map['Answer'],
    );
  }
}
