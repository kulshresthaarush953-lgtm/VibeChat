import 'package:flutter/material.dart';
import 'package:vibe_chat/services/auth_services.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthServices _authServices = AuthServices();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
       child: Padding(
        padding: EdgeInsets.fromLTRB(50,150,50,100),
        child: Column(
          mainAxisAlignment : MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/Final-IMAGE.png',
              width:200,
              height:200,
            ),
            SizedBox(
              height:20,
            ),
            Text(
              'Welcome To Vibe Chat!',
              style: TextStyle(
                color: Colors.amberAccent,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: 'RedHatDisplay',
              ),
            ),
            SizedBox(
              height:50,
            ),
            TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            style: TextStyle(
              color: Colors.amberAccent,
            ),
            ),
            SizedBox(
              height: 40,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your Password',
                prefixIcon: Icon(Icons.password),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              style: TextStyle(
                color: Colors.amberAccent,
              ),
            ),
            SizedBox(
              height:20,
            ),
            ElevatedButton(
              onPressed: () async{
                if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please fill all the fields"),
                    ),
                  );
                  return;
                }
                String? result;
                result = await _authServices.signIn(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                );
                if (result == "success"){
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(),)
                  );
                }
                if(result == 'user-not-found'){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("The user does not Exist. Create an account."),),
                  );
                  return;
                }
                if(result == 'invalid-email'){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("The email is not valid."),),
                  );
                  return;
                }
                if (result == 'invalid-credential'){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Incorrect Email or Password."),)
                  );
                  return;
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.blue,
                backgroundColor: Colors.amberAccent,
                minimumSize : Size(250,50),
              ),
              child: Text('Login',
              style: TextStyle(
                fontSize: 20,
                ),
              ),
              
            ),
            SizedBox(
              height:100,
            ),
            Text(
              'New to Vibe Chat?',
              style: TextStyle(
                fontFamily: 'RedHatDisplay',
                fontSize: 20,
                color: Colors.amberAccent,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpScreen()
                  ),
                );
              },
              child: const Text(
                'Sign Up'
              ),
              
            ),
          ],
        ),
       ),
      ),
      
    );
  }
}
