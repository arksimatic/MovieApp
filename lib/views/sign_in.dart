import 'package:flutter/material.dart';
import 'package:mim2_2/services/auth.dart';
import 'package:mim2_2/shared/constants.dart';
import 'package:mim2_2/shared/loading.dart';

class SignIn extends StatefulWidget {

  final Function toggleView;
  SignIn({ this.toggleView });

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  //text field state
  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 102, 204),
        elevation: 0.0,
        title: Text("Sign in"),
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.person),
            label: Text("Register"),
            onPressed: () {
              widget.toggleView();
            },
          )
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              SizedBox(height: 20.0),
              TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Email'),
                  validator: (val) => val.isEmpty ? 'Enter valid email' : null,
                  onChanged: (val) {
                  setState(() => email = val);
                }
              ),
              SizedBox(height: 20.0),
              TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Password'),
                obscureText: true,
                  validator: (val) => val.length < 6 ? 'Password must be at least 6 chars' : null,
                  onChanged: (val) {
                  setState(() => password = val);
                }
              ),
              SizedBox(height: 20.0),
              RaisedButton(
                color: Color.fromARGB(255, 0, 102, 204),
                child: Text(
                  'Sign in',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    setState(() => loading = true);
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if(result == null) {
                      setState() {
                        error = 'Wrong login or password';
                        loading = false;
                      }
                    }
                  }
                }
              ),
              SizedBox(height: 12.0),
              Text(
                error,
                style: TextStyle(color: Colors.red, fontSize: 14.0),
              ),
            ],
          ),
        ),

        //anonymous login
        // child: RaisedButton(
        //   child: Text("Sign in anonymously"),
        //   onPressed: () async {
        //     dynamic result = await _auth.signInAnon();
        //     if(result == null) {
        //         print('sign in error');
        //       } else {
        //       print('signed in');
        //       print(result);
        //       print(result.uid);
        //     }
        //   },
        // )
      ),
    );
  }
}
