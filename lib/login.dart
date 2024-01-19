import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FocusNode _userFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Login',style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                 controller: _emailController,
                focusNode: _userFocus,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _passwordController,
                 obscureText: true,
                focusNode: _passwordFocus,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ),
          ElevatedButton(
                onPressed: () {
                  _login();// Add login logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                   padding: EdgeInsets.symmetric(vertical: 15, horizontal: 150),
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(5.0),
                    ),
                  textStyle: const TextStyle(fontSize: 25, fontStyle: FontStyle.normal),
                ),
                child: Text('Login'),
              ),
            
           SizedBox(height: 10), // Add some space between the buttons
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Haven't started the journey? ",
          style: TextStyle(color: Colors.black),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignupScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
    Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
           ),
         ),
        ],
       ),
      ),
    );
  }
  Future<void> _login() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        print('Login successful: ${user.email}');
      } else {
        print('Login failed.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _userFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }
}

// ignore: must_be_immutable
class SignupScreen extends StatelessWidget {
   final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
final FocusNode _confirmFocus = FocusNode();

  final _formKey = GlobalKey<FormState>();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:Center(
       child:ListView(
      shrinkWrap: true,
        children: [
         Form(
          key: _formKey,
          child:SingleChildScrollView(
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Text('Sign up',style: TextStyle(color: Colors.black,fontSize: 25,fontWeight: FontWeight.bold)),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                 controller:  _usernameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  hintText: "Username",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                 validator:  (value){
                   if (value == null || value.length < 3 ||  RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
                   return 'Username must have at least 3 characters and  must not contain special characters';
                     }
                    return null;
                 }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _signupEmailController,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                 validator: (value){
                   if (value == null || !value.endsWith('@gmail.com')) {
                   return 'Invalid email. Please use a Gmail account.';
                   }
                 return null;
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _signupPasswordController,
                  obscureText: true,
                focusNode: _passwordFocus,
                decoration: InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                 validator: (value){
                  if (value == null || value.length < 6 || !RegExp(r'(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[\W_])').hasMatch(value)) {
                  return 'Invalid password.please enter a valid password';
                  }
                  return null; 
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: _confirmController,
                  obscureText: true,
                focusNode: _confirmFocus,
                decoration: InputDecoration(
                  hintText: "confirm Password",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                ),
                  validator: (value){
                  if (value == null || value.length < 6 || !RegExp(r'(?=.*\d)(?=.*[A-Z])(?=.*[a-z])(?=.*[\W_])').hasMatch(value)) {
                  return 'Invalid password.please enter a valid password';
                  }
                  if(value != _signupPasswordController.text){
                    return 'password do not match';
                  }
                  return null; 
                }
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () {
                   if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
                  _signup();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 140),
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(5.0),
                    ),
                  textStyle: const TextStyle(fontSize: 25, fontStyle: FontStyle.normal),
                ),
                child: Text('Sign Up'),
              ),
            ),
            Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Already on the way? ",
          style: TextStyle(color: Colors.black),
        ),
         TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
          child: Text(
            'Sign In',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
    Container(
      padding: const EdgeInsets.all(16.0),
      width: double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
          ),
         ),
        ],
       ),
      ),
      ),
        ],
    ),
    ),
    
      );
  }
Future<void> _signup() async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
      );

      final User? user = userCredential.user;
      if (user != null) {
        // Signup successful, navigate to the next screen or perform other actions
        print('Signup successful: ${user.email}');
      } else {
        // Handle the case where user is null
        print('Signup failed.');
      }
    } catch (e) {
      // Handle authentication errors
      print('Error: $e');
    }
  }

  void dispose() {
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    //super.dispose();
  }
}