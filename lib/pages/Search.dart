import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home.dart';
import 'details.dart';
import '../loading & splashscreen/loading.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
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

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  String searchText = "";

  List<dynamic> data = [];
  List<dynamic> filteredData = [];

  List<dynamic> _mpGamesID = [];
  Map<int, dynamic> _mpGame = {};

  bool loading = true;

  final String url = //"https://cors-anywhere.herokuapp.com/"
      "https://api.steampowered.com/ISteamApps/GetAppList/v2/"
      "?key=B7ABBB155FF3A1AE5A0EFB9D78A7FCDE";

  Future<void> fetchSteamGames() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> gamesList = json.decode(response.body)["applist"]["apps"];
      setState(() {
        _mpGamesID = gamesList.where((game) => game["name"] != '').toList();
        data = List<String>.from(_mpGamesID.map((game) => game["name"]));
        filteredData = data;
        loading = false;
      });
      for (final gameID in _mpGamesID) {
        await fetchGameDetails(gameID['appid']);
      }
    } else {
      throw Exception('Erreur de chargement des jeux');
    }
  }

  Future<void> fetchGameDetails(int appId) async {
    final response = await http.get(Uri.parse(//'https://cors-anywhere.herokuapp.com/'
        'https://store.steampowered.com/api/appdetails?appids=$appId'
        '&cc=FR&l=fr&key=B7ABBB155FF3A1AE5A0EFB9D78A7FCDE'));
    if (response.statusCode == 200) {
      Map<String, dynamic> gameData = jsonDecode(response.body) as Map<String, dynamic>;
      if (gameData[appId.toString()]?["success"] == true) {
        setState(() {
          _mpGame[appId] = gameData[appId.toString()]?["data"];
        });
      }
    }
    else {
      throw Exception('Failed to fetch game details from API');
    }
  }


  @override
  void initState() {
    super.initState();
    fetchSteamGames();
  }

  void filterSearchResults(String query) {
    List<String> searchResult = [];
    if (query.isNotEmpty) {
      data.forEach((game) {
        if (game.toLowerCase().contains(query.toLowerCase())) {
          searchResult.add(game);
        }
      });
      setState(() {
        filteredData = searchResult;
      });
    } else {
      setState(() {
        filteredData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(250, 30, 38, 44),
      appBar: AppBar(
        leading: IconButton(
          icon: SvgPicture.asset(
            'images/close.svg',
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Accueil(),));
          },
        ),
        backgroundColor: Color.fromARGB(250, 30, 38, 44),
        title: Text('Recherche'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  )
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Color.fromARGB(255, 30, 38, 44),
                hintText: 'Rechercher un jeu...',
                hintStyle: TextStyle(
                  color: Colors.white,
                ),
                suffixIcon: Icon(Icons.search, color: Color.fromARGB(255, 100, 107, 248)),
              ),
              controller: searchController,
              onSubmitted: (value) {
                searchText = value;
                loading = false;
                filterSearchResults(searchText);
              },
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "Résultats de recherche = ${filteredData.length}",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: 1,
                      decorationStyle: TextDecorationStyle.solid,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                // Autres widgets ici...
              ],
            ),
          ),
          Expanded(
            child: filteredData.isEmpty
                ? loading ? Loading()
                          : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text('Aucun résultat pour la recherche : $searchText', style: TextStyle(color: Colors.white)),
                                        )
                                      ],
                                    )
                : ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (BuildContext context, int index) {
                        final gameID = _mpGamesID
                            .firstWhere((gameID) => gameID['name'] == filteredData[index]);
                        final game = _mpGame[gameID['appid']];
                        //TODO Crerer une nouvelle liste qui remove les éléments sans details
                        return game != null && game.isNotEmpty ? Column(
                          children: [
                            SizedBox(height: 10),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: NetworkImage(game?['header_image'] ?? ''),
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
                                      game?['header_image'] ?? '',
                                    ),
                                  ],
                                ),
                                title: Text(game?['name'] ?? '', style: TextStyle(color: Colors.white)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        game != null && game['publishers'] != null ?
                                        '${game['publishers']}'
                                            : '',
                                        style: TextStyle(color: Colors.white)
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                        game != null && game['price_overview'] != null ?
                                        'Prix : ${game['price_overview']['final_formatted']}'
                                            : 'Prix : Gratuit',
                                        style: TextStyle(color: Colors.white)
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  height: 200,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => Details(appID: gameID['appid'])));
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
                            ),
                          ],
                        ) : Column(
                              children: [
                                SizedBox(height: 10.0),
                                Container(
                                  child: FutureBuilder<GameDetails>(
                                    future: fetchDetails(gameID['appid']),
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
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Details(appID: gameID['appid'])));
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
                                      } else if (snapshot.hasError) {
                                        return Container(
                                          margin: EdgeInsets.symmetric(horizontal: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5.0),
                                            image: DecorationImage(
                                              image: NetworkImage('https://cdn.akamai.steamstatic.com//steam//apps//1085660//header_french.jpg'),
                                              fit: BoxFit.cover,
                                              colorFilter: ColorFilter.mode(
                                                Colors.black.withOpacity(0.8),
                                                BlendMode.darken,
                                              ),
                                            ),
                                          ),
                                          child: ListTile(
                                            title: Text('Nom = ${gameID['name']}', style: TextStyle(color: Colors.white)),
                                            subtitle: Text('Steam_appid = ${gameID['appid'].toString()}', style: TextStyle(color: Colors.white)),
                                            isThreeLine: true,
                                          ),
                                        );
                                      } else {
                                        return Loading();
                                      }
                                    },
                                  ),
                                ),
                              ]
                        );
                      },
                ),
          ),
        ],
      ),
    );
  }
}
