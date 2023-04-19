import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:steamview/pages/home.dart';
import 'package:steamview/Database/database.dart';
import 'package:http/http.dart' as http;

import 'details.dart';
import '../loading & splashscreen/loading.dart';

class MesLikes extends StatefulWidget {
  @override
  _MesLikesState createState() => _MesLikesState();
}
class GameDetails {
  final String name;
  final String imageUrl;
  final String publisher;
  final String price;

  GameDetails({
    required this.name,
    required this.imageUrl,
    required this.publisher,
    required this.price,
  });
}
Future<GameDetails> fetchDetails(int appId) async {
  final response = await http.get(Uri.parse(//'https://cors-anywhere.herokuapp.com/'
      'https://store.steampowered.com/api/appdetails?appids=$appId&cc=FR&l=fr'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> gameData = jsonDecode(response.body)['$appId']['data'];

    String name = gameData['name'];
    String imageUrl = gameData['header_image'];
    String publisher = gameData['publishers'] != null ? gameData['publishers'][0] : '';
    String price = gameData['price_overview'] != null ? gameData['price_overview']['final_formatted'] : 'Gratuit';

    return GameDetails(
      name: name,
      imageUrl: imageUrl,
      publisher: publisher,
      price: price,
    );
  } else {
    throw Exception('Failed to load game detailszz');
  }
}

class _MesLikesState extends State<MesLikes> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) throw Exception("utilisateur introuvable");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(250, 30, 38, 44),
        leading: IconButton(
          icon: SvgPicture.asset(
            'images/close.svg',
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Accueil()));
          },
        ),
        title: const Text('Mes likes'),
      ),
      backgroundColor: Color.fromARGB(250, 30, 38, 44),
      body: StreamProvider<AppUserData>.value(
        initialData: AppUserData(
          uid: "",
          name: "",
          likes: [],
          wishlist: [],
        ),
        value: DatabaseService(user.uid).user,
        child: Consumer<AppUserData>(
          builder: (context, userData, child) {
            return userData.likes.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'images/empty_likes.svg',
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    "Vous n'avez encore pas liké de contenu.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Cliquez sur le coeur pour en rajouter",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: userData.likes.length,
              itemBuilder: (BuildContext context, int index) {
                //TODO Crerer une nouvelle liste qui remove les éléments sans details
                return Column(
                    children: [
                      SizedBox(height: 10.0),
                      Container(
                        child: FutureBuilder<GameDetails>(
                          future: fetchDetails(userData.likes[index]),
                          builder: (BuildContext context, AsyncSnapshot<GameDetails> snapshot) {
                            if (snapshot.hasData) {
                              GameDetails gameDetails = snapshot.data!;
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  image: DecorationImage(
                                    image: NetworkImage(gameDetails.imageUrl),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.8),
                                      BlendMode.darken,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Stack(
                                    children: [
                                      Image.network(
                                        gameDetails.imageUrl,
                                      ),
                                    ],
                                  ),
                                  title: Text(gameDetails.name, style: TextStyle(color: Colors.white)),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          gameDetails.publisher != null ?
                                          '${gameDetails.publisher}'
                                              : '',
                                          style: TextStyle(color: Colors.white)
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                          gameDetails.price != null ?
                                          'Prix : ${gameDetails.price}'
                                              : 'Prix : Gratuit',
                                          style: TextStyle(color: Colors.white)
                                      ),
                                    ],
                                  ),
                                  trailing: SizedBox(
                                    height: 200,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Details(appID: userData.likes[index])));
                                      },
                                      child: Column(
                                        children: [
                                          Text('En savoir plus',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        fixedSize: Size(100, 100),
                                        backgroundColor: const Color.fromARGB(255, 99, 106, 246),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            }else {
                              return Loading();
                            }
                          },
                        ),
                      ),
                    ]
                );
              },
            );
          },
        ),
      ),
    );
  }
}
