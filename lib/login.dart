import 'package:flutter/material.dart';
import 'register.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_database/firebase_database.dart';

class MyLoginPage extends StatefulWidget {
  const MyLoginPage({super.key});

  @override
  State<MyLoginPage> createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  bool _passwordVisible = false;

  final _userEmailController = TextEditingController();
  final _userPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  @override
  void dispose() {
    _userEmailController.dispose();
    _userPasswordController.dispose();
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
      title: 'Login',
      theme: ThemeData(
          primarySwatch: Colors.red,
          fontFamily: 'Open_Sans'
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
            margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Login Akun",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                SizedBox(height: 40,),
                TextField(
                  keyboardType: TextInputType.text,
                  controller: _userEmailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  keyboardType: TextInputType.text,
                  controller: _userPasswordController,
                  obscureText: !_passwordVisible,//This will obscure text dynamically
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    // Here is key idea
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Theme.of(context).primaryColorDark,
                      ),
                      onPressed: () {
                        // Update the state i.e. toogle the state of passwordVisible variable
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Belum Punya Akun?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyRegisterPage()),
                        );
                      },
                      child: Text("Register"),
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFF7272),
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      var login = 0;
                      var email_terdaftar = 0;
                      var userKey = '';

                      final email_login = _userEmailController.text.trim();
                      if (email_login.contains('@') != true || email_login == "") {
                        _showMyDialog("Error", "Masukkan Email yang Valid!");
                      } else if (_userPasswordController.text.length < 8) {
                        _showMyDialog("Error", "Password Tidak Valid!");
                      } else {
                        final ref = FirebaseDatabase.instance.ref();
                        await ref.child('iot_dictionary/users/').get().then((snapshot) {
                          for (final user in snapshot.children) {
                            if (user.child("email").value == email_login) {
                              setState(() { email_terdaftar = 1; });
                              if (user.child("password").value == _userPasswordController.text) {
                                setState(() {
                                  login = 1;
                                  userKey = user.child("userKey").value.toString();
                                });
                              } else {
                                _showMyDialog("Error", "Password salah!");
                              }
                            }
                          }
                        }, onError: (error) {
                          print("164" + error.toString());
                        });

                        if (login == 1) {
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setInt('login', 1);
                          await prefs.setString('userKey', userKey);
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        } else {
                          if (email_terdaftar == 0) {
                            _showMyDialog("Error", "Email tidak terdaftar!");
                          } else {
                            _showMyDialog("Error", "Gagal login!");
                          }
                        }
                      }
                    },
                    child: Text(
                      "Login",
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          backgroundColor: Color(0xFFFF7272),
          child: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      ),
    );
  }
}