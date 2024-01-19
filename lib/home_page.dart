import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokemon/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorite_page.dart';
import 'package:provider/provider.dart';

void main(){
  runApp( ChangeNotifierProvider(
      create: (context) => favoriteProvider(),
      child: MyApps(),
      ),
  );
}

class favoriteProvider with ChangeNotifier {
  bool favoritevalue = false;
   List<String> favoriteItems = [];

   void toggleFavorite(String item) {
    if (favoriteItems.contains(item)) {
      favoriteItems.remove(item);
    } else {
      favoriteItems.add(item);
    }
    notifyListeners();
  }

  bool isFavorite(String item) {
    return favoriteItems.contains(item);
  }

  void setfavoriteValue(bool value) {
    favoritevalue = value;
    notifyListeners();
  }
}

class MyAppThemes {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
  );
}

// ignore: must_be_immutable
class MyApps extends StatefulWidget {
    String itemName = "";

  MyApps({super.key}); 
   //late final String itemName;

  @override
  _MyAppStates createState() => _MyAppStates();
}

class _MyAppStates extends State<MyApps> {
  int _selectedIndex = 0;
  final url = "https://pokeapi.co/api/v2/pokemon?limit=100&offset=0";
  final ValueNotifier<ThemeMode>_notifier=ValueNotifier(ThemeMode.light);
   IconData _currentIcon = Icons.wb_sunny;
  
  late Future<Map<String, dynamic>> _data;
   Map<String, dynamic> selectedPokemonDetails = {};
   Set<String> favoritePokemon = Set();


  Future<Map<String, dynamic>> fetchPosts() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (err) {
      throw err;
    }
  }

  

void _toggleTheme(ThemeMode themeMode) {
  setState(() {
    _currentIcon =
        (_currentIcon == Icons.wb_sunny) ? Icons.nightlight_round : Icons.wb_sunny;
    _notifier.value = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  });
}

void _onListItemTap(BuildContext context, String itemName) async {
  final details = await fetchPokemonDetails(itemName);
  setState(() {
    selectedPokemonDetails = details;
  });
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BlankScreen(itemName: itemName, currentIcon: _currentIcon,),
    ),
  );
}


void _onItemTapped(int index) {
  if (index == 0) {
    if (selectedPokemonDetails.isNotEmpty) {
      var imageUrl = selectedPokemonDetails['imageUrl'] ?? '';
      var baseExperience = selectedPokemonDetails['baseExperience'] ?? 0;
      var hp = selectedPokemonDetails['hp'] ?? 0;
      var atk = selectedPokemonDetails['atk'] ?? 0;
      var def = selectedPokemonDetails['def'] ?? 0;
      var Satk= selectedPokemonDetails['Satk'] ?? 0;
      var SDef=selectedPokemonDetails['SDef'] ?? 0;
      var speed=selectedPokemonDetails['speed'] ?? 0;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FavoriteScreen(
            title: 'Favorites App',
            itemName: widget.itemName,
            imageUrl: imageUrl,
            baseExperience: baseExperience,
            hp: hp,
            atk: atk,
            def: def, 
            pokemonList: const [],
             //themeData: ThemeData(), 
             Satk: 0, 
             SDef: 0, 
             speed: 0,
          ),
        ),
      );
    } else {
      // Handle the case when selectedPokemonDetails is empty
      print('Error: Selected Pokemon details are empty.');
    }
  } else if (index == 1) {
    // Always navigate to the FavoritesScreen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FavoriteScreen(
          title: 'Favorites App',
          itemName: widget.itemName,
          imageUrl: '',
          baseExperience: 0,
          hp: 0,
          atk: 0,
          def: 0, 
          pokemonList: const [], 
          //themeData: ThemeData(), 
          Satk: 0, 
          SDef: 0, 
          speed: 0,
        ),
      ),
    );
    Text("there is no  favorites here",textAlign: TextAlign.center,);
  }
}


  void logout() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('username');

    await FirebaseAuth.instance.signOut();
    Navigator.pop(context); // Pop the current screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()), // Navigate to MyHomePage
    );
  } catch (e) {
    print('Error during logout: $e');
  }
}
Future<Map<String, dynamic>> fetchPokemonDetails(String itemName) async {
    final apiUrl = "https://pokeapi.co/api/v2/pokemon";
    try {
      final response =
          await http.get(Uri.parse('$apiUrl/${itemName.toLowerCase()}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        final int pokemonId = jsonData['id'];
        final imageUrl =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png";

        // Fetching stats values
        final List<dynamic> stats = jsonData['stats'];
        final int baseExperience = jsonData['base_experience'];
        final int hp = stats[0]['base_stat'];
        final int atk = stats[1]['base_stat'];
        final int def = stats[2]['base_stat'];
        final int Satk=stats[3]['base_stat'];
        final int SDef=stats[4]['base_stat'];
        final int speed=stats[5]['base_stat'];

        return {
          'imageUrl': imageUrl,
          'baseExperience': baseExperience,
          'hp': hp,
          'atk': atk,
          'def': def,
          'satk':Satk,
          'SDef':SDef,
          'speed':speed,
        };
      } else {
        throw Exception('Failed to fetch Pokemon details');
      }
    } catch (err) {
      throw err;
    }
  }


 @override
  void initState() {
    super.initState();
    _data = fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => favoriteProvider(),
      child: ValueListenableBuilder<ThemeMode>(
      valueListenable: _notifier,
      builder: (_,mode,__){
    return MaterialApp(
         themeMode: mode,
        theme: ThemeData.light(),
        darkTheme: ThemeData.dark(),
    debugShowCheckedModeBanner: false,
      home:Scaffold(
        appBar: AppBar(
          title: Center(child: const Text("pokemon",style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontWeight: FontWeight.bold))),
          backgroundColor:  Color.fromARGB(255, 239, 154, 154),
           actions: <Widget>[
   Builder(
     builder: (context) => IconButton(
                icon: Icon(_currentIcon, color: Color.fromARGB(255, 0, 0, 0)),
                    onPressed: (){
                     _toggleTheme(_notifier.value);
                    }
    ),
  ),
],
           leading: Transform.rotate(
            angle: 3.14, 
            child: IconButton(
              icon: Icon(Icons.logout),
              color: const Color.fromARGB(255, 0, 0, 0),
              onPressed: () { 
                logout();
              },
            ),
          ),
        
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              Map<String, dynamic> jsonData = snapshot.data!;
              List<dynamic> results = jsonData['results'];

              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, i) {
                  final post = results[i];
                  


                  return Column(
                    children: [
                      ListTile(
                        title: Text("  ${post["name"]}"),
                         trailing: Icon(Icons.arrow_forward),
                          onTap: () {
            _onListItemTap(context, post["name"]);
          },
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
              bottomNavigationBar: BottomNavigationBar(
                backgroundColor:   Color.fromARGB(255, 239, 154, 154),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: 'All', 
            ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: 'Favorites',  
           ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
        unselectedItemColor:  const Color.fromARGB(255, 0, 0, 0),
          selectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
        onTap: _onItemTapped,
      ),
      ),
    );
  }
      ),
    );
  }
}

class BlankScreen extends StatefulWidget {
  final String itemName;
  final IconData currentIcon; 

  BlankScreen({required this.itemName, required this.currentIcon});

  @override
  _BlankScreenState createState() => _BlankScreenState();
}

class _BlankScreenState extends State<BlankScreen> {
  final String apiUrl = "https://pokeapi.co/api/v2/pokemon";
  String imageUrl = "";
  int baseExperience = 0;
  int hp = 0;
  int atk = 0;
  int Def = 0;
   int specialAttack=0;
   int specialDefence=0;
   int speed=0;
  bool favoritevalue = false;

   final CollectionReference favoriteCollection =
      FirebaseFirestore.instance.collection('favorites');
  
 @override
  void initState() {
    super.initState();
    fetchPokemonId();
  }

   Future<void> fetchPokemonId() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/${widget.itemName}'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

           baseExperience = jsonData['base_experience'];

      // Fetching stats values
      final List<dynamic> stats = jsonData['stats'];
      if (stats.length >= 4) {
        hp = stats[0]['base_stat'];
        atk = stats[1]['base_stat'];
        Def = stats[2]['base_stat'];
        specialAttack=stats[3]['base_stat'];
        specialDefence=stats[4]['base_stat'];
        speed=stats[5]['base_stat'];
      }

        final int pokemonId = jsonData['id'];
        imageUrl =
            "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$pokemonId.png";
      } else {
        throw Exception('Failed to fetch Pokemon ID');
      }
    } catch (err) {
      throw err;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        ThemeData themeData = Theme.of(context);

        return ChangeNotifierProvider.value(
          value: Provider.of<favoriteProvider>(context),
          child: MaterialApp(
             theme: themeData,
             darkTheme: ThemeData.dark(),
            debugShowCheckedModeBanner: false,
      home: Scaffold(
      appBar: AppBar(
         leading:  IconButton(
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).brightness == Brightness.dark
               ? Colors.white
               : Colors.black, 
              onPressed: () { 
                Navigator.of(context).pop();
          }
        ),
      ),
      body: FutureBuilder<void>(
        future: fetchPokemonId(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
                children: [
                  Image.network(
                    imageUrl,
                    height: 393,
                    width: 393,
                  ),
                  Text(
         "${widget.itemName}",
          style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color.fromARGB(255, 15, 15, 15),
    fontSize: 26,
    fontWeight: FontWeight.bold,
  ),
),
                  Text("xp:$baseExperience",style: TextStyle(fontSize: 14),),
                   SizedBox(height: 18.0),
SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      _buildStatContainer("HP", hp, const Color.fromARGB(255, 165, 214, 167)),
       SizedBox(width: 18.0),
      _buildStatContainer("Atk", atk, const Color.fromARGB(255, 239, 154, 154)),
       SizedBox(width: 18.0),
      _buildStatContainer("Def", Def, const Color.fromARGB(255, 129, 212, 250)),
       SizedBox(width: 18.0),
      _buildStatContainer("Satk", specialAttack, const Color.fromARGB(255, 129, 212, 250)),
        SizedBox(width: 18.0),
      _buildStatContainer("SDef", specialDefence, const Color.fromARGB(255, 129, 212, 250)),
      SizedBox(width: 18.0),
      _buildStatContainer("Speed", speed, const Color.fromARGB(255, 129, 212, 250)),
    ],
  ),
),
                ],
              );
          }
        },
      ),
            floatingActionButton: Consumer<favoriteProvider>(
  builder: (context, favoriteProvider, child) {
    return Stack(
      children: [
        FloatingActionButton(
          onPressed: () async {
            favoriteProvider.toggleFavorite(widget.itemName);

            if (favoriteProvider.isFavorite(widget.itemName)) {
              // Store data in Firestore
              storeFavoriteData(
                itemName: widget.itemName,
                baseExperience: baseExperience,
                hp: hp,
                atk: atk,
                def: Def,
                specialAttack:specialAttack,
                specialDefence:specialDefence,
                speed:speed
              );
            } else {
              // Remove data from Firestore
              await removeFavoriteData(widget.itemName);
            }
            SharedPreferences prefs = await SharedPreferences.getInstance();
            String? username = prefs.getString('username') ?? 'Unknown User';

            final snackBar = SnackBar(
              content: Text(
                '${widget.itemName} ${favoriteProvider.isFavorite(widget.itemName) ? 'added to' : 'removed from'} $username\'s favorites',
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          },
          backgroundColor: const Color.fromARGB(255, 239, 154, 154),
          shape: const CircleBorder(),
          child: Icon(
            favoriteProvider.isFavorite(widget.itemName)
                ? Icons.favorite_sharp
                : Icons.favorite_border,
            color: favoriteProvider.isFavorite(widget.itemName)
                ? Colors.red
                : null,
          ),
        ),
      ],
    );
  },
),
      ),
   ),
    );
      },
    );
  }
  void storeFavoriteData({
  required String itemName,
  required int baseExperience,
  required int hp,
  required int atk,
  required int def, 
  required int specialAttack, 
  required int specialDefence, 
  required int speed, 
}) async {
  try {
    // Check if the item already exists in Firestore
    final QuerySnapshot querySnapshot = await favoriteCollection
        .where('itemName', isEqualTo: itemName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Item already exists, don't add it again
      print("Item already exists in Firestore.");
    } else {
      // Item does not exist, add it to Firestore
      favoriteCollection.add({
        'itemName': itemName,
        'baseExperience': baseExperience,
        'hp': hp,
        'atk': atk,
        'def': def,
        'Satk':specialAttack,
        'SDef':specialDefence,
        'speed':speed
        // Add other fields you want to store
      }).then((value) {
        print("Favorite added to Firestore!");
      }).catchError((error) {
        print("Error adding favorite to Firestore: $error");
      });
    }
  } catch (error) {
    print("Error checking Firestore: $error");
  }
}

Future<void> removeFavoriteData(String itemName) async {
  try {
    // Find the document with the item name and delete it
    final QuerySnapshot querySnapshot = await favoriteCollection
        .where('itemName', isEqualTo: itemName)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final String documentId = querySnapshot.docs.first.id;
      await favoriteCollection.doc(documentId).delete();
      print("Favorite removed from Firestore!");
    } else {
      // Item not found in Firestore
      print("Item not found in Firestore.");
    }
  } catch (error) {
    print("Error removing favorite from Firestore: $error");
  }
}


Widget _buildStatContainer(String statName, int statValue, Color color) {
  return Container(
    padding: EdgeInsets.all(40.0),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      children: [
        Text("$statValue", style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontSize: 40,fontWeight: FontWeight.bold)),
        Text(statName, style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0),fontSize: 25)),
      ],
    ),
  );
}
}
