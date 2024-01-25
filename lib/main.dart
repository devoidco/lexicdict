import 'package:flutter/material.dart';
import "string_extension.dart";

import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_cached_pdfview/flutter_cached_pdfview.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// import 'login.dart';
import 'register.dart';
import 'manage_user.dart';
import 'search_result.dart';
import 'my_dictionary.dart';
import 'contribution.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Dictionary',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Open_Sans'
      ),
      home: const MyHomePage(title: 'IoT Dictionary'),
    );
  }
}

Route _routeToRegister() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MyRegisterPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
Route _routeToManageUser() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MyManageUserPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
Route _routeToMyDictionary() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MyDictionaryPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
Route _routeToContribution() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => const MyContributionPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _searchVocabController = TextEditingController();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  @override
  void initState() {
    _searchVocabController.text = "";
    super.initState();
    _initSpeech();
  }
  @override
  void dispose() {
    _searchVocabController.dispose();
    super.dispose();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }
  void _onSpeechResult(SpeechRecognitionResult result) async {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchVocabController.text = _lastWords;
    });

    if (_speechToText.isNotListening) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("searchVocab", _lastWords);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MySearchResultPage()),
      );
    }
  }

  Future getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? login = prefs.getInt('login');
    final String? userKey = prefs.getString('userKey');

    if (login == 1) {
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('iot_dictionary/users/$userKey').get();
      if (snapshot.exists) {
        return snapshot;
      } else {
        print('No data available.');
      }
      setState(() {});
    } else {
      setState(() {});
      return "";
    }
    setState(() {});
  }

  Future usernameChecker() async {
    var userData = await getUserData();
    if (userData != "") {
      setState(() {});
      return userData.child("username").value;
    } else {
      setState(() {});
      return "";
    }
  }
  Future nimAndTypeChecker() async {
    var userData = await getUserData();
    if (userData != "") {
      return userData;
    } else {
      return "";
    }
  }
  Future kontribusiChecker() async {
    var userData = await getUserData();
    if (userData != "") {
      var contrib_length = 0;
      if (userData.child("kontribusi").value != 0 && userData.child("kontribusi").value != null) {
        userData.child("kontribusi").value.forEach((key, value) {
          contrib_length++;
        });
      }
      return contrib_length;
    } else {
      return "";
    }
  }
  Future pengunjungChecker() async {
    var userData = await getUserData();
    if (userData != "") {
      return userData.child("pengunjung").value;
    } else {
      return "";
    }
  }
  Future kamusChecker() async {
    var userData = await getUserData();
    if (userData != "") {
      var dict_length = 0;
      if (userData.child("kamus").value != 0) {
        userData.child("kamus").value.forEach((key, value) {
          dict_length++;
        });
      }
      return dict_length;
    } else {
      return "";
    }
  }
  Future firstTextProfilChecker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? login = prefs.getInt('login');
    if(login == 1) {
      return "Profil";
    } else {
      return "Login";
    }
  }
  Future secondTextProfilChecker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? login = prefs.getInt('login');
    if(login == 1) {
      return "Anda";
    } else {
      return "";
    }
  }
  Future firstTextMyDictChecker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? login = prefs.getInt('login');
    if(login == 1) {
      return "Kamus";
    } else {
      return "Login";
    }
  }
  Future secondTextMyDictChecker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? login = prefs.getInt('login');
    if(login == 1) {
      return "Anda";
    } else {
      return "";
    }
  }
  Future contributionTextChecker() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? login = prefs.getInt('login');
    if(login == 1) {
      return "Kontribusi";
    } else {
      return "Login";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: <Widget>[
                const Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 10),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bg1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchVocabController,
                      onSubmitted: (searchVocab) async {
                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString("searchVocab", searchVocab);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MySearchResultPage()),
                        );
                        print(searchVocab);
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Cari Kosakata',
                        suffixIcon: IconButton(
                          onPressed: () async {
                            if (_speechToText.isNotListening) {
                              _startListening();
                            } else {
                              _stopListening();
                            }
                          },
                          icon: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: NetworkImage('https://googleflutter.com/sample_image.jpg'),
                                fit: BoxFit.fill
                            ),
                          ),
                        ),
                        const SizedBox(width: 25,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FutureBuilder(
                                future: usernameChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data != "") {
                                      return Text(
                                        snapshot.data.toString(),
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      );
                                    } else {
                                      return TextButton(
                                        style:  TextButton.styleFrom(backgroundColor: Colors.white),
                                        onPressed: () async {
                                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                                          final int? login = prefs.getInt('login');
                                          if (login == 1) {
                                            // Ke Halaman Manajemen Profil
                                            Navigator.of(context).push(_routeToManageUser());
                                          } else {
                                            // Ke Halaman Registrasi
                                            Navigator.of(context).push(_routeToRegister());
                                          }
                                        },
                                        child: const Text(
                                          "Login",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Color(0xffff7272),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                              FutureBuilder(
                                future: nimAndTypeChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    if (snapshot.data != "") {
                                      return Text(
                                        snapshot.data.child("nim").value.toString().capitalize() + " (" + snapshot.data.child("type").value.toString().capitalize() + ")",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      );
                                    } else {
                                      return const Text("");
                                    }
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10, top: 40, right: 10, bottom: 10),
                      constraints: const BoxConstraints(
                        minHeight: 100,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 25, 10, 25),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  "Kontribusi",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                FutureBuilder(
                                  future: kontribusiChecker(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data != "") {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: const TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      } else {
                                        return const Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      }
                                    } else {
                                      return const Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const Text("Kosakata"),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Pengunjung",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                FutureBuilder(
                                  future: pengunjungChecker(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data != "") {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: const TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      } else {
                                        return const Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      }
                                    } else {
                                      return const Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const Text("Orang"),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Kamus",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10,),
                                FutureBuilder(
                                  future: kamusChecker(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data != "") {
                                        return Text(
                                          snapshot.data.toString(),
                                          style: const TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      } else {
                                        return const Text(
                                          "-",
                                          style: TextStyle(
                                            fontSize: 50,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        );
                                      }
                                    } else {
                                      return const Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 50,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const Text("Buah"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            final int? login = prefs.getInt('login');

                            if (login == 1) {
                              // Ke Halaman Manajemen Profil
                              Navigator.of(context).push(_routeToManageUser());
                            } else {
                              // Ke Halaman Registrasi
                              Navigator.of(context).push(_routeToRegister());
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.account_circle),
                                ),
                              ),
                              FutureBuilder(
                                future: firstTextProfilChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data.toString());
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                              FutureBuilder(
                                future: secondTextProfilChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data.toString());
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString("searchVocab", "all_special");
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const MySearchResultPage()),
                            );
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.checklist_rtl_rounded),
                                ),
                              ),
                              const Text("List"),
                              const Text("Kosakata"),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            final int? login = prefs.getInt('login');

                            if (login == 1) {
                              // Ke Halaman Kamus Anda
                              Navigator.of(context).push(_routeToMyDictionary());
                            } else {
                              // Ke Halaman Registrasi
                              Navigator.of(context).push(_routeToRegister());
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.book),
                                ),
                              ),
                              FutureBuilder(
                                future: firstTextMyDictChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data.toString());
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                              FutureBuilder(
                                future: secondTextMyDictChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data.toString());
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            final int? login = prefs.getInt('login');

                            if (login == 1) {
                              // Ke Halaman Kamus Anda
                              Navigator.of(context).push(_routeToContribution());
                            } else {
                              // Ke Halaman Registrasi
                              Navigator.of(context).push(_routeToRegister());
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.account_tree_rounded),
                                ),
                              ),
                              FutureBuilder(
                                future: contributionTextChecker(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(snapshot.data.toString());
                                  } else {
                                    return const Text("Loading");
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            print("pdf");
                            final Uri url = Uri.parse('https://s.id/iot_dictionary_manual_book');
                            if (!await launchUrl(
                              url,
                              mode: LaunchMode.externalApplication,
                            )) {
                              throw Exception('Could not launch $url');
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 7,
                                        offset: const Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.warning_rounded),
                                ),
                              ),
                              const Text("Tutorial"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 30, 30, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      "About",
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Wrap(
                      children: const [
                        Text("Nikmati fitur MyDictionary yang memungkinkan anda memiliki kamus pribadi anda, dengan list kata yang dapat di kostumisasi. Kamus IoT Dictionary merupakan kamus yang dikembangkan untuk membantu para mahasiswa mengatur kosakata istilah-istilah teknis dengan berbagai fitur yang telah disediakan aplikasi."),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/images/bg1.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
                "IoT Dictionary",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.manage_accounts),
                  SizedBox(width: 20),
                  Expanded(child: ExpansionTile(
                    initiallyExpanded: false,
                    title: Text("Tim Pengembang UP3M PNUP"),
                    children: <Widget>[
                      ListTile(title: Text('Naely Muchtar, S.Pd. M.Pd.')),
                      ListTile(title: Text('Dr. Alimin, M.Pd.')),
                      ListTile(title: Text('Gusri Emiyati Ali, S.Pd. M.Pd.')),
                    ],
                  ),),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.feedback),
                  SizedBox(width: 20),
                  Text("Feedback")
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.share),
                  SizedBox(width: 20),
                  Text("Share")
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
