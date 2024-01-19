import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:provider/provider.dart';
import 'firebase_options.dart';
//import 'home_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
}

class FavoriteScreen extends StatefulWidget {
  final String title;
  final int def;
  final int atk;
  final int hp;
  final String itemName;
  final String imageUrl;
  final int baseExperience;
  final int Satk;
  final int SDef;
  final int speed;
  final List<Map<String, dynamic>> pokemonList;

  const FavoriteScreen({
    Key? key,
    required this.title,
    required this.pokemonList,
    required this.def,
    required this.atk,
    required this.hp,
    required this.itemName,
    required this.imageUrl,
    required this.baseExperience,
    required this.Satk,
    required this.SDef,
    required this.speed,
  }) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Map<String, dynamic>>> _favoritesData;
  ThemeData themeData = ThemeData.light();
  
   //IconData _currentIcon = Icons.wb_sunny;

  @override
  void initState() {
    super.initState();
    _favoritesData = fetchFavoritesData();
  }

  Future<List<Map<String, dynamic>>> fetchFavoritesData() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('favorites').get();
      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (error) {
      print("Error fetching data from Firestore: $error");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: themeData,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "favorites",
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          backgroundColor: Color.fromARGB(255, 239, 154, 154),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Color.fromARGB(255, 0, 0, 0),
            onPressed: () {
              // Pop the current screen
              Navigator.of(context).pop();
            },
          ),
          actions: [
            IconButton(
             icon: Icon( Icons.wb_sunny),
              onPressed: () {
                // Toggle theme
                setState(() {
                  themeData =
                      themeData.brightness == Brightness.dark ? ThemeData.light() : ThemeData.dark();
                });
              },
            ),
          ],
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _favoritesData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Map<String, dynamic>> favoritesList = snapshot.data ?? [];

              return favoritesList.isEmpty
                  ? Center(
                      child: Text('You have no favorites yet.'),
                    )
                  : ListView.builder(
                      itemCount: favoritesList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Item Name: ${favoritesList[index]['itemName']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Base Experience: ${favoritesList[index]['baseExperience']}'),
                              Text('HP: ${favoritesList[index]['hp']}'),
                              Text('Attack: ${favoritesList[index]['atk']}'),
                              Text('Defence: ${favoritesList[index]['def']}'),
                              Text('specialAttack:${favoritesList[index]['Satk']}'),
                              Text('specialDefence:${favoritesList[index]['SDef']}'),
                              Text('speed:${favoritesList[index]['speed']}'),
                            ],
                          ),
                        );
                      },
                    );
            }
          },
        ),
      ),
    );
  }
}
