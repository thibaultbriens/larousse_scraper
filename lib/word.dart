//import 'package:flutter/material.dart';
class WordForExctract{
  String word;
  List<String> definitions;
  List<String> synonymous;
  List<String> opposites;

  WordForExctract({
    required this.word,
    required this.definitions,
    required this.synonymous,
    required this.opposites
  });

  @override
  String toString() {
    // TODO: implement toString
    return this.word + "\n" + this.definitions.toString() + "\n" + "${this.synonymous ?? "[]"}" + "\n" + "${this.opposites ?? "[]"}";
  }

  String toJson(){
    String jsonString = '''
{
  "definitions": ${definitions.map((e) => '''"$e"''').toList()},
  "synonymous": ${synonymous.map((e) => '''"$e"''').toList()},
  "opposites": ${opposites.map((e) => '''"$e"''').toList()}
}''';

    return jsonString;
  }
}