import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:firebase_database/firebase_database.dart';

class MyVocabDetailPage extends StatefulWidget {
  const MyVocabDetailPage({super.key});

  @override
  State<MyVocabDetailPage> createState() => _MyVocabDetailPageState();
}

class _MyVocabDetailPageState extends State<MyVocabDetailPage> {
  late final Future mygetVocabDetails;

  @override
  void initState() {
    mygetVocabDetails = getVocabDetails();
  }

  Future<dynamic> getVocabDetails() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? vocabKey = prefs.getString('vocabKey');
    var vocabDetails = [];

    final ref = FirebaseDatabase.instance.ref();
    await ref.child('iot_dictionary/vocabs/').get().then((snapshot) {
      for (final category in snapshot.children) {
        for (final vocab in category.children) {
          if (vocab.key.toString() == vocabKey.toString()) {
            setState(() {
              vocabDetails.add({
                "title": vocab.child("title").value,
                "author": vocab.child("author").value,
                "desc": vocab.child("desc").value,
                "en_term": vocab.child("en_term").value,
                "img": vocab.child("img").value,
                "key": vocab.child("key").value,
                "source": vocab.child("source").value,
              });
            });
          }
        }
      }
    }, onError: (error) {
      print("164" + error.toString());
    });

    // print(vocabDetails);
    return vocabDetails;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocab Details',
      theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 10),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/bg4.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: mygetVocabDetails,
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          // print(snapshot.data[0]["img"]);
                          if (snapshot.hasData) {
                            if (snapshot.data != "") {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            snapshot.data[0]["title"],
                                            style: TextStyle(
                                              fontSize: 40,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data[0]["en_term"],
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          FlutterTts ftts = FlutterTts();
                                          var result = await ftts.speak(snapshot.data[0]["en_term"]);
                                          if(result == 1){
                                            print("Bicara");
                                          }else{
                                            print("Tidak Bicara");
                                          }

                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            Icons.volume_up,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30,),
                                  Center(
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            // image: (snapshot.data[0]["img"].toString() != null) ? NetworkImage('https://googleflutter.com/sample_image.jpg') : NetworkImage(snapshot.data[0]["img"].toString()),
                                            image: NetworkImage(snapshot.data[0]["img"].toString()),
                                            fit: BoxFit.cover
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                    child: Text("Data Not Found"),
                                  ),
                                  Divider(
                                      color: Colors.black
                                  ),
                                ],
                              );
                            }
                          } else {
                            return Transform.scale(
                              scale: 0.1,
                              child: LoadingIndicator(
                                  indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                                  colors: const [Colors.black],       /// Optional, The color collections
                                  strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                                  backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                                  pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: FutureBuilder(
                    future: mygetVocabDetails,
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data != "") {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 30,),
                              Text(
                                snapshot.data[0]["desc"],
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(height: 30,),
                              Text(
                                "Referensi:",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "- Image by " + snapshot.data[0]["img"],
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                "- Description by " + snapshot.data[0]["source"],
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                child: Text("Data Not Found"),
                              ),
                              Divider(
                                  color: Colors.black
                              ),
                            ],
                          );
                        }
                      } else {
                        return Transform.scale(
                          scale: 0.1,
                          child: LoadingIndicator(
                              indicatorType: Indicator.ballPulse, /// Required, The loading type of the widget
                              colors: const [Colors.black],       /// Optional, The color collections
                              strokeWidth: 2,                     /// Optional, The stroke of the line, only applicable to widget which contains line
                              backgroundColor: Colors.transparent,      /// Optional, Background of the widget
                              pathBackgroundColor: Colors.transparent   /// Optional, the stroke backgroundColor
                          ),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.remove('vocabKey');
            Navigator.pop(context);
          },
          backgroundColor: Color(0xFFFF7272),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}