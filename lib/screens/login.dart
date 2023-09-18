import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:medicare/screens/home.dart';

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  bool isRegister = false;
  var selectedUserForRegister;
  @override
  void dispose() {
    // _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'TimeSync',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),

                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  // validator: (text) validatePassword(nameController.text),
                  controller: nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'User Name',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextFormField(
                  obscureText: true,
                  controller: passwordController,
                  validator: (text) {if (!(passwordController.value.toString().length > 5) && passwordController.value.toString().isNotEmpty) {
    return "Password should contain more than 5 characters";
    }
    return "";
  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              isRegister ? Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextFormField(
                  obscureText: true,
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'EmailId',
                  ),
                ),
              ) : Container(),
              isRegister ? Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: const Text('Doctor'),
                      leading: Radio(
                        value: 1,
                        groupValue: selectedUserForRegister,
                        onChanged: (value) {
                          setState(() {
                            selectedUserForRegister = value!;
                          });
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('Patient'),
                      leading: Radio(
                        value: 2,
                        groupValue: selectedUserForRegister,
                        onChanged: (value) {
                          setState(() {
                            selectedUserForRegister = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ) : Container(),
              TextButton(
                onPressed: () {
                  //forgot password screen
                },
                child: const Text('Forgot Password',),
              ),
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child:  isRegister ? Text('Register') : Text('Login'),
                    onPressed: () {
                      isRegister? register(nameController.value.text.toString(),passwordController.value.text.toString(),emailController.value.text.toString(),selectedUserForRegister): login(nameController.value.text.toString(),passwordController.value.text.toString());
                    },
                  )
              ),
              Row(
                children: <Widget>[
                  isRegister ? Text('Already user?') : Text('Does not have account?'),
                  TextButton(
                    child: isRegister ? Text(
                      'Log In',
                      style: TextStyle(fontSize: 20),
                    ) :Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        isRegister = !isRegister;
                      });

                    },
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
            ],
          )),
    );
  }
  Future<void> login(String userName,String password) async {
    print("userName $userName");
    print("password $password");
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/login'),
        // Use the correct cancel endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "username": "$userName",
          "password": "$password"
        }
        ), // Send the updated status
      );

      if (response.statusCode == 200) {
        // If the cancellation is successful, update the local status
        Navigator.push(context,MaterialPageRoute(builder: (context) =>Home()));

        print("Successfully logged In $response");
      } else {
        print("Error ${response.body}");

        throw Exception('Failed to login');
      }
    } catch (error) {
      print("Catch $error");
    }
  }

  Future<void> register(String userName,String password, String emailId, var role) async {
    print("userName $userName");
    print("password $password");
    print("emailId $emailId");
    print("role $role");
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/register'),
        // Use the correct cancel endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "username": "$userName",
          "password": "$password",
          "email": "$emailId",
          "role": role == 1 ? "doctor" : "patient",
        }
        ), // Send the updated status
      );

      if (response.statusCode == 201) {
        setState(() {
         isRegister = false;
        });
        print("Successfully Created user $response");
        nameController.clear();
        passwordController.clear();
      } else {
        print("Error ${response.body}");

        throw Exception('Failed to register');
      }
    } catch (error) {
      print("Catch $error");
    }
  }
}