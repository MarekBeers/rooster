import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:rooster/classes.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:week_of_year/week_of_year.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class RoosterOverview extends StatefulWidget {
  @override
  _RoosterOverviewState createState() => _RoosterOverviewState();
}



class _RoosterOverviewState extends State<RoosterOverview> with WidgetsBindingObserver {

  WebViewController _controllerRooster;

  int thisWeekButton = 0;

  var htmlRooster = "";

  var script = "<script>function checkOverFlow(element) {"
      "return element.scrollWidth > element.clientWidth;"
      "}"
      "var procent = 100;"
      "function doSomething(){"
      "if(checkOverFlow(document.body)){"
      "procent--;"
      "console.log(procent);"
      "document.body.style.zoom = procent+'%';"
      "doSomething();"
      "}"
      "}"
      "doSomething();</script>";

  var thisWeek = "";

  var nextWeek = "";

  var weekThree = "";

  var weekFour = "";

  var className = "Rooster";

  @override
  void initState() {
    super.initState();
    // loadRooster();
  }



  @override
  void dispose() {

    super.dispose();
  }

  void loadRooster() async {

    final storage = new FlutterSecureStorage();
    var class_index = await storage.read(key: "class_index");
    var weekNumber = (DateTime.now().weekOfYear + 0).toString();
    var cache_rooster = await storage.read(key: "cache_rooster$weekNumber");

    var tempClassName = await storage.read(key: "class_name");
    setState(() {
      className = tempClassName;
    });

    if(cache_rooster != null && cache_rooster != ""){
      _controllerRooster.loadUrl(Uri.dataFromString(
          cache_rooster,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8')
      ).toString());
    }
    // print("https://roosters.rocmondriaan.nl/TIN/ICT/$weekNumber/c/$class_index.htm");


    var response = await http.get(Uri.parse('https://roosters.rocmondriaan.nl/TIN/ICT/$weekNumber/c/$class_index.htm'));




    thisWeek = response.body+script;

    if(cache_rooster != thisWeek){

      await storage.write(key: "cache_rooster$weekNumber", value: thisWeek);

      _controllerRooster.loadUrl(Uri.dataFromString(
          thisWeek,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8')
      ).toString());

    }


    setState(() {
      htmlRooster = "_";
    });

    // _controllerRooster.loadUrl("https://roosters.rocmondriaan.nl/TIN/ICT/$weekNumber/c/$class_index.htm");

  }


  switchWeek(int thisWeekSub) async {

    _controllerRooster.loadUrl(Uri.dataFromString(
        """""",
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());

    final storage = new FlutterSecureStorage();
    var class_index = await storage.read(key: "class_index");

    var tempWeekNumber = DateTime.now().weekOfYear + thisWeekSub + 0;


    setState(() {
      thisWeekButton = thisWeekSub;
      htmlRooster = "";
    });

    var weekNumber = tempWeekNumber.toString();

    print(weekNumber);

    var cached = "";

    if(nextWeek != "" && thisWeekSub == 1){
      cached = nextWeek;
    }else if(thisWeek != "" && thisWeekSub == 0){
      cached = thisWeek;
    }else if(weekThree != "" && thisWeekSub == 2){
      cached = weekThree;
    }else if(weekFour != "" && thisWeekSub == 3){
      cached = weekFour;
    }

    if(cached == ""){
      var response = await http.get(Uri.parse('https://roosters.rocmondriaan.nl/TIN/ICT/$weekNumber/c/$class_index.htm'));
      cached = response.body+script;
    }else{
      await new Future.delayed(const Duration(milliseconds: 100));
    }



    if(nextWeek == "" && thisWeekSub == 1){
      nextWeek = cached;
    }else if(thisWeek == "" && thisWeekSub == 0){
      thisWeek = cached;
      await storage.write(key: "cache_rooster$weekNumber", value: thisWeek);
    }else if(weekThree == "" && thisWeekSub == 2){
      weekThree = cached;
    }else if(weekFour == "" && thisWeekSub == 3){
      weekFour = cached;
    }


    _controllerRooster.loadUrl(Uri.dataFromString(
        cached,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());

    setState(() {
      htmlRooster = "_";
    });
    // _controllerRooster.loadUrl("https://roosters.rocmondriaan.nl/TIN/ICT/$weekNumber/c/$class_index.htm");

  }

  resetClass() async {

    final storage = new FlutterSecureStorage();
    await storage.deleteAll();

    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
        builder: (BuildContext context) => ClassesOverview()), (Route<dynamic> route) => false);

  }

  refreshRooster(){

    _controllerRooster.loadUrl(Uri.dataFromString(
        """""",
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());

    if(thisWeekButton == 0){
      thisWeek = "";
    }else if(thisWeekButton == 1){
      nextWeek = "";
    }else if(thisWeekButton == 2){
      weekThree = "";
    }else if(thisWeekButton == 3){
      weekFour = "";
    }

    switchWeek(thisWeekButton);

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
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                resetClass();
              }
          ),
        ],
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        backgroundColor: Colors.black,
        title: Text(
          className,
        ),

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
            children: <Widget>[

              Container(
                width: MediaQuery.of(context).size.width / 1.15,
                margin: EdgeInsets.only(
                  top: 10.0,
                  bottom: 10.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 10,
                          child:

                          TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                              backgroundColor: thisWeekButton == 0 ? Colors.blue : Colors.grey,
                              padding: EdgeInsets.all(15.0),
                            ),
                            onPressed: () {
                              switchWeek(0);
                            },
                            child: AutoSizeText(
                              'Deze Week',
                              maxLines: 1,
                              minFontSize: 1,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.white,
                              ),
                            ),

                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: SizedBox.shrink(),
                        ),
                        Expanded(
                          flex: 10,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                              backgroundColor: thisWeekButton == 1 ? Colors.blue : Colors.grey,
                              padding: EdgeInsets.all(15.0),
                            ),
                            onPressed: () {
                              switchWeek(1);
                            },
                            child: AutoSizeText(
                                'Volgende Week',
                                maxLines: 1,
                                minFontSize: 1,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)
                            ),

                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 10,
                    //       child:
                    //
                    //       TextButton(
                    //         style: TextButton.styleFrom(
                    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                    //           backgroundColor: thisWeekButton == 2 ? Colors.blue : Colors.grey,
                    //           padding: EdgeInsets.all(15.0),
                    //         ),
                    //         onPressed: () {
                    //           switchWeek(2);
                    //         },
                    //         child: AutoSizeText(
                    //           'Over 3 Weken',
                    //           maxLines: 1,
                    //           minFontSize: 1,
                    //           style: TextStyle(
                    //             fontSize: 20.0,
                    //             color: Colors.white,
                    //           ),
                    //         ),
                    //
                    //       ),
                    //     ),
                    //     Expanded(
                    //       flex: 1,
                    //       child: SizedBox.shrink(),
                    //     ),
                    //     Expanded(
                    //       flex: 10,
                    //       child: TextButton(
                    //         style: TextButton.styleFrom(
                    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
                    //           backgroundColor: thisWeekButton == 3 ? Colors.blue : Colors.grey,
                    //           padding: EdgeInsets.all(15.0),
                    //         ),
                    //         onPressed: () {
                    //           switchWeek(3);
                    //         },
                    //         child: AutoSizeText(
                    //             'Over 4 Weken',
                    //             maxLines: 1,
                    //             minFontSize: 1,
                    //             style: TextStyle(
                    //                 fontSize: 20.0,
                    //                 color: Colors.white,
                    //                 fontWeight: FontWeight.bold)
                    //         ),
                    //
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),

              Expanded(
                child: Stack(
                  children: [
                    WebView(
                      javascriptMode: JavascriptMode.unrestricted,
                      initialUrl: '',
                      onWebViewCreated: (WebViewController webViewController) {
                        _controllerRooster = webViewController;
                        loadRooster();
                      },
                      initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                      gestureNavigationEnabled: false,
                      // onPageFinished: (String url) {
                      //   _controllerRooster.evaluateJavascript(
                      //       "function checkOverFlow(element) {"
                      //           "return element.scrollWidth > element.clientWidth;"
                      //           "}"
                      //           "var procent = 100;"
                      //           "function doSomething(){"
                      //           "if(checkOverFlow(document.body)){"
                      //           "procent--;"
                      //           "console.log(procent);"
                      //           "document.body.style.zoom = procent+'%';"
                      //           "doSomething();"
                      //           "}"
                      //           "}"
                      //           "doSomething();"
                      //   );
                      // },

                    ),
                    AnimatedSwitcher(
                      duration: Duration(
                        milliseconds: 200,
                      ),
                      child: htmlRooster == "" ? Center(
                        child: SizedBox(
                          height: 200,
                          width: 200,
                          child: LoadingIndicator(
                            indicatorType: Indicator.pacman,
                            color: Colors.grey,
                          ),
                        ),
                      ) : SizedBox.shrink(),
                    ),

                  ],
                ),

              ),



            ],
          ),
        ),



      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          refreshRooster();
        },
        child: const Icon(Icons.refresh, color: Colors.white,),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
