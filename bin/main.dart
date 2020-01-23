import 'dart:io';
import 'package:csv/csv.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart';
import 'dart:convert';

main(List<String> arguments) async {

  File file = File('../assets/toy-shows-company.csv');
  void _fetchUrl(List<dynamic> row) async {

    try {
      http.Response response = await http.get(
        row[0])//.timeout(Duration(seconds: 5), onTimeout: () => Future.value());
        ;

      if (response.statusCode != 200 && response.statusCode != 201) {      
        Map<String, dynamic> resData = {
          'company': row[1]??'',
          'country': row[2]??'',
          'domain': row[0], 
          'title': 'status code != 200, 201',
          'desc': ''
          };
        List<List> fList = [[resData['domain'],resData['company'],resData['country'],resData['title'],resData['desc']]];
        final res = const ListToCsvConverter(fieldDelimiter: ';').convert(fList);
        file.writeAsStringSync('$res\n', mode: FileMode.append);   
      } else {

        //print(response.statusCode); 
        //print(response.body); 
        var document = parse(response.body);
        Element title = document.querySelector('head > title');
        Element meta = document.querySelector("head > meta[name='description']");
        
      // print(title.text);
      // print(meta.attributes['content']);
        String desc = 'NO';
        if(meta != null && meta.attributes.containsKey('content')){
          desc = meta.attributes['content'];  
        } 

        final Map<String, dynamic> resData = {
          'company': row[1]??'',
          'country': row[2]??'',
          'domain': row[0],
          'title': title?.text?? 'no',
          'desc': desc
          };
        print(resData); 
        
        List<List> fList = [[resData['domain'],resData['company'],resData['country'],resData['title'],resData['desc']]];
        final res = const ListToCsvConverter(fieldDelimiter: ';').convert(fList);
        file.writeAsStringSync('$res\n', mode: FileMode.append); 
      }

    } catch (e)  {
      print('${row[2]} ${e.toString()}');
      final Map<String, dynamic> resData = {
          'company': row[1]??'',
          'country': row[2]??'',
          'domain': row[0],
        'title': e.toString(),
        'desc': 'NO'
        };
      print(resData); 

      List<List> fList = [[resData['domain'],resData['company'],resData['country'],resData['title'],resData['desc']]];
      final res = const ListToCsvConverter(fieldDelimiter: ';').convert(fList);
      file.writeAsStringSync('$res\n', mode: FileMode.append); 
      //return resData;
    }
  }

final input = File('../assets/import.csv').openRead();
final rows = await input.transform(utf8.decoder).transform(CsvToListConverter(eol: "\n", fieldDelimiter: ";", textDelimiter: '"')).toList();

int countProcess = 0;
for(var i = 0; i < rows.length; i++) {
    if(rows[i][2].toString().isEmpty) continue;
    _fetchUrl(rows[i]);
    countProcess++;
    if(countProcess > 6) {
      await Future.delayed(const Duration(seconds: 2), (){});
      countProcess = 0;
    }
  }

}

