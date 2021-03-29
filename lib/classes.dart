import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:async/async.dart';
import 'package:rooster/rooster.dart';

class ClassesOverview extends StatefulWidget {
  @override
  _ClassesOverviewState createState() => _ClassesOverviewState();
}



class _ClassesOverviewState extends State<ClassesOverview> with WidgetsBindingObserver {

  var _getClasses = AsyncMemoizer();

  String className = "Rooster";

  @override
  void initState() {
    super.initState();
  }



  @override
  void dispose() {

    super.dispose();
  }

  loadClasses(){
    return this._getClasses.runOnce(() async {
      try {

        var response = await http.get(Uri.parse('https://roosters.rocmondriaan.nl/TIN/ICT/frames/navbar.htm'));

        return response.body.split("var classes = [")[1].split("];")[0].replaceAll('"', '').split(",");


      } on Exception catch (e) {
        var emptyArray = [
          "empty"
        ];
        return emptyArray;
      }
    });
  }

  Future<Null> _refreshClasses() async {
    setState(() {
      this._getClasses = AsyncMemoizer();
    });
    return null;
  }

  _chooseClass(String index, String className) async {

    final storage = new FlutterSecureStorage();

    var temp_index = "c00000";

    temp_index = temp_index.substring(0, temp_index.length - index.length) + index;

    print(temp_index);

    await storage.write(key: "class_index", value: temp_index);
    await storage.write(key: "class_name", value: className);

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (BuildContext context) => RoosterOverview()), (Route<dynamic> route) => false);

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar:  AppBar(
        actions: <Widget>[
        ],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.black,
        title: Text(className),

      ),
      backgroundColor: Colors.white,
      body: Container(
        // decoration: BoxDecoration(
        //   // image: DecorationImage(
        //   //   image: AssetImage("assets/images/SimpleTicket_bg.jpg"),
        //   //   fit: BoxFit.cover,
        //   // ),
        //   color: Colors.black,
        // ),
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[

              Expanded(
                flex: 1,
                child: FutureBuilder<dynamic>(
                    future: loadClasses(),
                    // ignore: missing_return
                    builder:
                    // ignore: missing_return
                        (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Text('Error!');
                        case ConnectionState.waiting:
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 200,
                                  width: 200,
                                  child: LoadingIndicator(
                                    indicatorType: Indicator.pacman,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        case ConnectionState.active:
                          return Text('Connecting...');
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return Text(
                              'Error!',
                              style: TextStyle(color: Colors.red),
                            );
                          } else if (snapshot.data[0] == "empty") {
                            return Center(
                              child: FadeInUp(
                                delay: Duration(
                                    milliseconds: 300),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ButtonTheme(
                                      minWidth: MediaQuery.of(context).size.width / 1.15,
                                      child:
                                      TextButton(

                                        onPressed: _refreshClasses,

                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                                          padding: EdgeInsets.all(20),

                                        ),

                                        child: AutoSizeText(
                                            "Probeer Opnieuw",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white)),
                                      ),

                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return AnimationLimiter(
                              child: ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  // print(snapshot.data.length);
                                  // print(index);
                                  return AnimationConfiguration.staggeredList(
                                    position: index+1,
                                    duration: const Duration(milliseconds: 300),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: Center(
                                          child: Container(
                                            width: MediaQuery.of(context).size.width / 1.15,
                                            margin: EdgeInsets.only(
                                                top: 10.0,
                                                bottom: snapshot.data.length == index+1 ? 10.0 : 0,
                                            ),
                                            child: TextButton(

                                              onPressed: () => _chooseClass(
                                                  (index+1).toString(), snapshot.data[index].toString()
                                              ),

                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                                                padding: EdgeInsets.all(20),

                                              ),

                                              child: AutoSizeText(
                                                  snapshot.data[index].toString(),
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                      }
                    }),
              ),


            ],
          ),
        ),



      ),
    );
  }
}
