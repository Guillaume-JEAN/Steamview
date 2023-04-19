import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:steamview/pages/reviews.dart';
import 'package:steamview/Database/database.dart';
import '../loading & splashscreen/loading.dart';


class Details extends StatefulWidget {
  final int appID;

  Details({required this.appID});

  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  bool isLiked = false;
  bool isWished = false;
  bool isDesc = true;
  Map<String, dynamic>? _mpGame;


  Future<void> checkIfLiked() async {
    final user = Provider.of<AppUser?>(context);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        List<dynamic> likes = snapshot.data()!['likes'];
        if (likes.contains(widget.appID)) {
          setState(() {
            isLiked = true;
          });
        }
        else{
          setState(() {
            isLiked = false;
          });
        }
      }
    });
  }
  Future<void> checkIfWished() async {
    final user = Provider.of<AppUser?>(context);
    FirebaseFirestore.instance
        .collection('users')
        .doc(user?.uid)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        List<dynamic> likes = snapshot.data()!['wishlist'];
        if (likes.contains(widget.appID)) {
          setState(() {
            isWished = true;
          });
        }
        else{
          setState(() {
            isWished = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchGameDetails(widget.appID);
    checkIfLiked().then((value) {
      setState(() {
        isLiked = isLiked;
      });
    });
    checkIfWished().then((value) {
      setState(() {
        isWished = isWished;
      });
    });
  }

  Future<void> fetchGameDetails(int appId) async {
    final response = await http.get(Uri.parse(
        //'https://cors-anywhere.herokuapp.com/'
            'https://store.steampowered.com/api/appdetails?appids=$appId'
            '&cc=FR&l=fr&key=B7ABBB155FF3A1AE5A0EFB9D78A7FCDE'));

    if (response.statusCode == 200) {
      Map<String, dynamic> gameData = jsonDecode(response.body);
      if (gameData[appId.toString()]?["success"] == true) {
        setState(() {
          _mpGame = gameData[appId.toString()]?["data"];
        });
      }
    } else {
      throw Exception('Failed to fetch game details from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    checkIfLiked();
    checkIfWished();
    return _mpGame == null ? Loading() :  Scaffold(
      backgroundColor: Color.fromARGB(250, 30, 38, 44),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(250, 30, 38, 44),
        title: const Text('Détail du jeu'),
        actions: [

          IconButton(
            onPressed: () {
              setState(() {
                //On inverse l'état de isLiked
                isLiked = !isLiked;
              });
              if (isLiked) {
                //On ajoute l'appID du jeu à la liste des likes
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .update({
                  'likes': FieldValue.arrayUnion([widget.appID])
                });
              } else {
                //On remove l'appID du jeu de la liste des likes
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .update({
                  'likes': FieldValue.arrayRemove([widget.appID])
                });
              }

            },
            icon: SvgPicture.asset( isLiked ?
              'images/like_full.svg' : 'images/like.svg',
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                //On inverse l'état de isWished
                isWished = !isWished;
              });
              if (isWished) {
                //On ajoute l'appID du jeu à la liste des wish
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .update({
                  'wishlist': FieldValue.arrayUnion([widget.appID])
                });
              } else {
                //On remove l'appID du jeu de la liste des wish
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user?.uid)
                    .update({
                  'wishlist': FieldValue.arrayRemove([widget.appID])
                });
              }
            },
            icon: SvgPicture.asset( isWished ?
              'images/whishlist_full.svg' : 'images/whishlist.svg',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Image en arrière-plan
            Image.network(
              _mpGame!['screenshots'][1]['path_full'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: 270,
            ),
            Column(
              children: [
                SizedBox(height: 230),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    image: DecorationImage(
                      image: NetworkImage(
                          "https:\/\/cdn.akamai.steamstatic.com\/steam\/apps\/${widget.appID}\/header.jpg?t=1655250428"
                      ),
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
                          "https:\/\/cdn.akamai.steamstatic.com\/steam\/apps\/${widget.appID}\/header.jpg?t=1655250428",
                        ),
                      ],
                    ),
                    title: Text(
                        _mpGame != null ? _mpGame!['name'] : '',
                        style: TextStyle(color: Colors.white)
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _mpGame != null && _mpGame!['publishers'] != null ?
                            '${_mpGame!['publishers']}'
                                : '',
                            style: TextStyle(color: Colors.white)
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isDesc = true;
                            });
                          },
                          child: Text('DESCRIPTION'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDesc ? Color.fromARGB(255, 100, 107, 248) : Color.fromARGB(250, 30, 38, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                              ),
                              side: BorderSide(color: Color.fromARGB(255, 100, 107, 248), width: 2),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 50,
                        width: 180,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isDesc = false;
                            });
                          },
                          child: Text('AVIS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDesc ? Color.fromARGB(250, 30, 38, 44) : Color.fromARGB(255, 100, 107, 248),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              side: BorderSide(color: Color.fromARGB(255, 100, 107, 248), width: 2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: isDesc ?
                    Column(
                      children: [
                        Text(
                            _mpGame != null && _mpGame!['short_description'] != null ?
                            '${_mpGame!['short_description']}'
                                : 'Aucune description disponible',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                            )
                        ),
                      ],
                    ) :
                  GameReviews(appID: widget.appID),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
