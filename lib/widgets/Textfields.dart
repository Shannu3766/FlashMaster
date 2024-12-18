import 'package:flutter/material.dart';

class QuestionTextField extends StatelessWidget {
  final String? initialValue;
  final FormFieldSetter<String>? onSaved;
  final String? Function(String?)? validator;
  final String? hintText;

  const QuestionTextField(
      {super.key,
      this.initialValue,
      this.onSaved,
      this.validator,
      this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 20),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        initialValue: initialValue,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
