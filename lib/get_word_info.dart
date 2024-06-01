import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;

import 'word.dart';

void main() async {
  int start = 31511;
  int end = 83296;
  int added = 0;
  int error = 0;
  Stopwatch stopwatch = Stopwatch()..start();
  print("Starting storing from $start to $end");

  // getting current json file
  String fileString = await File("dictionary.json").readAsString();
  var jsonObject = jsonDecode(fileString);
  
  // jsonObject["test udapte"] = "test update value";

  for(int i = start; i <= end; i++){
    print("Starting iteration number $i");
    try{
      WordForExctract current = await getWord("https://www.larousse.fr/dictionnaires/francais/mot/$i");

      jsonObject[current.word] = current.toJson();
      added++;
    } catch(e){
      print("Error with iteration $i, continuing...");
      error++;
    }
	
	// update file every 300 iteration
	if(i % 300 == 0){
		File("dictionary.json").writeAsString(jsonEncode(jsonObject));
		print("\n============ UPDATED FILE ============\n${stopwatch.elapsed} elapsed\n");
	}
  }

  File("dictionary.json").writeAsString(jsonEncode(jsonObject));

  stopwatch.stop();
  print("Finished program in ${stopwatch.elapsed} resulting with $added words scraped and $error errors");
}

Future<WordForExctract> getWord(String url) async{
  final response = await http.get(Uri.parse(url));
  
  if (response.statusCode == 200) {
    final document = html.parse(response.body);
    
    final List<String> divisionDefinitions = [];
    
    // Extract <li> tags with class 'DivisionDefinition'
    final elements = document.querySelectorAll('li.DivisionDefinition');
    final String word = document.querySelector("h2.AdresseDefinition")!.nodes[3].text.toString();

    elements.forEach((element) {
      divisionDefinitions.add(element.text);
    });

    return parseList(divisionDefinitions, word);
  } else {
    print('Failed to load webpage: ${response.statusCode}');
    throw Error();
  }
}

WordForExctract parseList(List<String> lines, String word){
  // print("lines = $lines");
  List<String> definitions = [];
  List<String> synonymous = [];
  List<String> opposites = [];

  // to know if next line is synonymous or oppostes line
  bool nextIsSynonymous = false;
  bool nextIsOpposite = false;
  for(String line in lines){
    List<String> subLines = line.split("\n");
    for(String subLine in subLines){
      // print("subline = $subLine");
      // print("First charcater = ${(subLine[0].codeUnits)}");
      if(subLine[0].codeUnits[0] != 9){ // this is a definition
        definitions.add(subLine);
        continue;
      }
      else{
        // this is either 'Synonymes' or 'Contraires' label or in fact synonymous or opposites

        // check if current line is synonymous or opposite
        if(nextIsSynonymous){
          synonymous.addAll(subLine.trim().split(" - "));
          nextIsSynonymous = false;
          continue;
        }
        else if(nextIsOpposite){
          opposites.addAll(subLine.trim().split(" - "));
          nextIsOpposite = false;
          continue;
        }

        // now check if this is the label
        String lineTrim = subLine.trim();
        if(lineTrim == "Synonymes :" || lineTrim == "Synonyme :"){
          nextIsSynonymous = true;
          continue;
        }
        else if(lineTrim == "Contraires :" || lineTrim == "Contraire :"){
          nextIsOpposite = true;
          continue;
        }
      }
    }
  }

  return WordForExctract(word: word, definitions: definitions, synonymous: synonymous, opposites: opposites);
}

/*List<String> getDefinitions (Document document){
  List<String> result = [];
  // Extract <li> tags with class 'DivisionDefinition'
    final elements = document.querySelectorAll('li.DivisionDefinition');
    elements.forEach((element) {
      // Get only the text directly within the <li> tag
      String text = element.firstChild!.text!;

      if(text.length > 5){
        result.add(text);
      }
      else{
        result.add(element.nodes[1].text!);
      }
    });

    // Print the division definitions
    return result.map((e) => e.trim()).toList();
}

List<String> getSynonymouses (Document document){
  List<String> result = [];
  // Extract <li> tags with class 'DivisionDefinition'
    final elements = document.querySelectorAll('p.Synonymes');
    elements.forEach((element) {
        result.add(element.text);
    });

    // Print the division definitions
    result = result.map((e) => e.trim()).toList();

    List<String> splitResult = [];
    for(int i = 0; i < result.length; i++){
      String el = result[i];
      List<String> subList = el.split(" - ");

      splitResult.addAll(subList);
    }

    return splitResult;
}

List<String> getOpposites (Document document){
  List<String> result = [];
  // Extract <li> tags with class 'DivisionDefinition'
    final elements = document.querySelectorAll('p.LibelleSynonyme');
    elements.forEach((element) {
        result.add(element.text);
    });

    // Print the division definitions
    result = result.map((e) => e.trim()).toList();

    List<String> splitResult = [];
    for(int i = 0; i < result.length; i++){
      String el = result[i];
      List<String> subList = el.split(" - ");

      splitResult.addAll(subList);
    }

    return splitResult;
}*/
