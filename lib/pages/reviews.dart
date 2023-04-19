import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import '../loading & splashscreen/loading.dart';

class SteamUsername extends StatefulWidget {
  final String steamID;

  SteamUsername({required this.steamID});


  @override
  _SteamUsernameState createState() => _SteamUsernameState();
}

class _SteamUsernameState extends State<SteamUsername> {
  String _username = '';

  Future<void> _getUsername(String steamId) async {
    final response = await http.get(
        Uri.parse('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/'
            '?key=B7ABBB155FF3A1AE5A0EFB9D78A7FCDE&steamids=$steamId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      setState(() {
        _username = jsonResponse['response']['players'][0]['personaname'];
      });
    } else {
      throw Exception('Failed to load username');
    }
  }

  @override
  void initState() {
    super.initState();
    _getUsername(widget.steamID);
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_username', style: TextStyle(
      fontSize: 18,
      color: Colors.white,
      decoration: TextDecoration.underline,
      decorationColor: Colors.white,
      decorationThickness: 1,
      decorationStyle: TextDecorationStyle.solid,
    ));

  }
}
class GameReviews extends StatefulWidget {
  final int appID;

  GameReviews({required this.appID});

  @override
  _GameReviewsState createState() => _GameReviewsState();
}

class _GameReviewsState extends State<GameReviews> {
  List<dynamic> _reviews = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchReviews(widget.appID);
  }

  Future<void> fetchReviews(int appId) async {
    final response = await http.get(Uri.parse(
        'https://store.steampowered.com/appreviews/$appId?json=1&key=B7ABBB155FF3A1AE5A0EFB9D78A7FCDE'));
//&language=french&num_per_page=1&key=B7ABBB155FF3A1AE5A0EFB9D78A7FCDE
    if (response.statusCode == 200) {
      Map<String, dynamic> reviewsData = jsonDecode(response.body);
      setState(() {
        _reviews = reviewsData['reviews'];
        loading = false;
      });
    } else {
      throw Exception('Failed to fetch game reviews from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : _reviews.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 70),
                    const Text(
                      "Il n'y a pas encore d'avis pour ce jeu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
          )
        : Container(
              height: 400,
              child: ListView.builder(
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final review = _reviews[index];
                  return Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: Color.fromARGB(255, 37, 46, 54),
                        ),
                        child: ListTile(
                          title: Row(
                            children: [
                              SteamUsername(steamID: review['author']['steamid']),
                              SizedBox(height: 50),
                            ],
                          ),
                          subtitle: Text(review['review'], style: TextStyle(color: Colors.white)),
                          trailing: review['voted_up'] == true ?
                          Container(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset(
                              'images/thumbs_up.svg',
                            ),
                          ) :
                          Container(
                            width: 24,
                            height: 24,
                            child: SvgPicture.asset(
                              'images/thumbs_down.svg',
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
    );
  }
}
