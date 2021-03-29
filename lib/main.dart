import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rooster/rooster.dart';

import 'package:rooster/classes.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext contextP) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
//        debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.grey,
        backgroundColor: Colors.white,
      ),
      home: FutureBuilder<String>(
        future: _checkScreen(),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {  // AsyncSnapshot<Your object type>
          if(snapshot.connectionState == ConnectionState.waiting){
            return SizedBox.shrink();
          }else{
            if (snapshot.hasError) {
              return SizedBox.shrink();
            } else {
              if(snapshot.data == "rooster"){
                return RoosterOverview();
              }else{
                return ClassesOverview();
              }
            }
          }
        },
      )
    );
  }

  Future<String> _checkScreen() async {

    final storage = new FlutterSecureStorage();
    var index = await storage.read(key: "class_index");

    if(index != null){
      return "rooster";
    }else{
      return "class_picker";
    }

  }

}