import 'package:flutter/material.dart';
import 'AdminPage.dart';

class LoginPage extends StatefulWidget {
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == 'admin' && password == '123456') {
      Navigator.pushNamed(context, '/admin');
    } else if (username == 'user' && password == '123456') {
      Navigator.pushNamed(context, '/user');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials')),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Container(
          height: 400,
          width: 333,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
  Widget build(BuildContext context){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(title: Text('Login'),),
      body: SingleChildScrollView(
        child:Center(child: 
        Container(
          alignment:Alignment.center,
          width: width * 0.4, // 80% of screen width
        height: height * 0.9,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
                child: Container(
                    width: 200,
                    height: 150,
                    /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
              ),
            ),
            ),
           
              //padding: const EdgeInsets.only(left:16.0,right: 24.0,top:16,bottom: 24),
              Padding(
                padding: const EdgeInsets.only(left:24.0,right: 24.0,top:16,bottom: 16.0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username or Email'),
                    //hintText: 'Enter valid email id as abc@gmail.com'),
              ),
              ),
            
            
            Padding(
              padding: const EdgeInsets.only(
                  left: 24.0, right: 24.0, top: 16.0 ,bottom: 16.0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(

                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password'),
                   // hintText: 'Enter secure password'),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            
             
            
          ],
        
    ),
        ),
    ),
    ),
    );
  }
}*/