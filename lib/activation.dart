import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

import 'package:firebase_database/firebase_database.dart';

import 'login.dart';

class MyActivationPage extends StatefulWidget {
  const MyActivationPage({super.key});

  @override
  State<MyActivationPage> createState() => _MyActivationPageState();
}

class _MyActivationPageState extends State<MyActivationPage> {
  final _userActivationCodeController = TextEditingController();
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;

  @override
  void dispose() {
    _userActivationCodeController.dispose();
    super.dispose();
  }

  Future<void> _showMyDialog(title, desc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$title'),
          content: Text('$desc'),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register LexicDict',
      theme: ThemeData(
        primarySwatch: Colors.red,
        fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Aktivasi",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 20,),
                Wrap(
                  children: [
                    const Text("Mohon cek email anda untuk mendapatkan kode aktivasi"),
                    CountdownTimer(
                      endTime: endTime,
                    ),
                  ],
                ),
                const SizedBox(height: 20,),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _userActivationCodeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '******',
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Email Tidak Terkirim?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Register Ulang"),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF7272),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                      final int? actCode = prefs.getInt('actCode');
                      final String? init_time = prefs.getString('init_time');
                      final String? userKey = prefs.getString('userKey');

                      if (actCode != null && init_time != null && userKey != null) {
                        DateTime initTime = DateTime.parse(init_time).add(const Duration(minutes: 3));

                        if (_userActivationCodeController.text.trim() == "") {
                          _showMyDialog("Error", "Kode Aktifasi Harus Diisi!");
                        } else if (actCode.toString() != _userActivationCodeController.text.trim()) {
                          _showMyDialog("Error", "Kode Aktifasi Salah!");
                        } else if (initTime.compareTo(DateTime.now()) < 0) {
                          _showMyDialog("Error", "Waktu Habis, Register Ulang!");
                          FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey").remove();
                        } else {
                          FirebaseDatabase.instance.ref("iot_dictionary/users/$userKey").update({
                            "active": 1,
                            "type": "member",
                            "member_since": "${DateTime.now()}",
                            "kontribusi":  0,
                            "pengunjung": 0,
                            "kamus": 0,
                          });
                          _showMyDialog("Berhasil", "Anda Telah Berhasil Terdaftar, Silahkan Login!");

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MyLoginPage()),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Aktifkan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}