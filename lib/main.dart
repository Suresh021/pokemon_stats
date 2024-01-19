import 'package:flutter/material.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(
  MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // You can display a loading indicator here
          }
          
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in
            return MultiProvider(
              providers: [
                ChangeNotifierProvider(
                  create: (context) => favoriteProvider(),
                ),
              ],
              child: MyApps(),
            );
          } else {
            // User is not logged in
            return MyHomePage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    ),
  );
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
  bool isLogin =true;

//home: user!=null ?MyApps() :const MyHomePage(),
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
              Text('Login',style: TextStyle(color: Colors.black,fontSize: 26,fontWeight: FontWeight.bold),textAlign: TextAlign.center),
               SizedBox(height: 16),
              Padding(
                 padding: EdgeInsets.only(left:35, bottom: 10, right: 35, top:10),
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
                padding: EdgeInsets.only(left:35, bottom: 20, right: 35, top:10),
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
              SizedBox(height: 16),
            ElevatedButton(
                  onPressed: () {
                    _login();// Add login logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    foregroundColor: Colors.white,
                     padding: EdgeInsets.only(left:145, bottom: 20, right: 145, top:20),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(5.0),
                      ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  child: Text('Login',textAlign: TextAlign.center),
                ),
              
             SizedBox(height: 10),
     Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    const Text(
      "Haven't started the journey? ",
      style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
    ),
    SizedBox(width: 8), // Add space after the text
    TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignupScreen()),
        );
      },
      child: Row(
        children: [
          Text(
            'Sign Up',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 26), 
        ],
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
      ),
    );
  }
 Future<void> _login() async {
  try {
    // Check if the user is already signed in
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      // User is already signed in, redirect to MyApps
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApps(),
        ),
      );
      return;
    }

    // User is not signed in, proceed with login
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final User? user = userCredential.user;
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User logged in successfully'),
          duration: Duration(seconds: 3),
        ),
      );

      // Redirect to MyApps
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyApps(),
        ),
      );
    } else {
      print('An error occurred');
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
             Text('Sign up',style: TextStyle(color: Colors.black,fontSize: 26,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              SizedBox(height: 16),
            Padding(
            padding: EdgeInsets.only(left:35, bottom: 10, right: 35, top:10),
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
            padding: EdgeInsets.only(left:35, bottom: 10, right: 35, top:10),
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
            padding: EdgeInsets.only(left:35, bottom: 10, right: 35, top:10),
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
            padding: EdgeInsets.only(left:35, bottom: 10, right: 35, top:10),
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
             SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () async {
                  CollectionReference collref = FirebaseFirestore.instance.collection('details');
                // ignore: unused_local_variable
                DocumentReference docRef = await collref.add({
                'username': _usernameController.text,
                'email':_signupEmailController.text,
               });
               if (_formKey.currentState!.validate()) {
                ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
                  _signup();
                  }// Add signup logic here
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.only(left:140, bottom: 20, right: 140, top:20),
                  shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(5.0),
                    ),
                  textStyle: const TextStyle(fontSize: 18, fontStyle: FontStyle.normal,fontWeight: FontWeight.w700),
                ),
                child: Text('Sign Up',textAlign: TextAlign.center,),
              ),
            ),
            Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Already on the way? ",
          style: TextStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.w400),
        ),
         TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
          child: Row(
            children:[
          Text(
            'Sign In',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 24),
            ],
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
      saveUsernameToSharedPreferences(_usernameController.text);
      UserCredential signInCredential = await _auth.signInWithEmailAndPassword(
        email: _signupEmailController.text.trim(),
        password: _signupPasswordController.text.trim(),
      );
      if (signInCredential.user != null) {
        print('Signup successful: ${user.email}');
      } else {
        print('Sign-in after signup failed.');
      }
    } else {
      print('Signup failed.');
    }
  } catch (e) {
    print('Error: $e');
  }
}
Future<void> saveUsernameToSharedPreferences(String username) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('username', username);
}

  void dispose() {
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
  }
}