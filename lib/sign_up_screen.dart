import 'package:flutter/material.dart';
import 'package:vibe_chat/services/auth_services.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreen();
}

class _SignUpScreen extends State<SignUpScreen> {
  final AuthServices _authServices = AuthServices();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SingleChildScrollView(
        child : Padding(
          padding: EdgeInsets.fromLTRB(50, 70, 50, 100),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children:[
              Image.asset(
                'assets/Final-IMAGE.png',
                width: 250,
                height:250,
              ),
              SizedBox(
                height:0,
              ),
              Text(
                'Create An Account!',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 35,
                  fontFamily: 'RedHatDisplay',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name here',
                  prefixIcon: Icon(Icons.person),
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
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your Email Address',
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
                height:40,
              ),

              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Set your Password',
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
                height:40,
              ),
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Enter the password to confirm.',
                  prefixIcon: Icon(Icons.security),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                style: TextStyle(
                  color: Colors.amberAccent,
                ),
              ),  
              SizedBox(
                height: 50,
              ),

              ElevatedButton(
                onPressed: () async{
                  if(_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty ||
                   _confirmPasswordController.text.trim().isEmpty)
                  { 
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fill all the fields"),
                      )
                    );
                    print("Please fill all the fields");
                    return; 
                  }
                  if(_passwordController.text.trim() != _confirmPasswordController.text.trim()){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("The Passwords does not match!"),  
                      ),
                    );
                    return;
                  }
                  String? result;
              
                  if (_passwordController.text.trim() == _confirmPasswordController.text.trim()){
                    result = await _authServices.signUp(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  
                  if (result == "Success") {
                    Navigator.pushReplacement(
                       context,
                       MaterialPageRoute(
                         builder: (context) => HomeScreen(),
                       ),
                    );
                  }
                }
                  if (result == 'email-already-in-use'){
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("This email is already registered. Please log in instead.")
                        ),
                    );
                    return;
                  }
                  if(result == 'weak-password'){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('The password is too weak. Make a stronger one')),
                    );
                    return;
                  }
                  if(result == 'invalid-email'){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Email format is wrong. Try again.')),
                    );
                    return;
                  }
                  if (result == 'name-already-in-use') {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('This name is already taken. Choose another one.')),
                  );
                  return;
}
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: Colors.blue,
                ),
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                    fontSize: 20,
                  ),               
                ),

              ),         
            ],
          ),
        ),
      ),
    );
  }
}