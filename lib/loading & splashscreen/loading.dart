import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:steamview/pages/home.dart';
import 'package:steamview/Connexion/connexion.dart';
import 'package:steamview/Database/database.dart';



class Loading extends StatelessWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(250, 30, 38, 44),
      child: Center(
        child: SpinKitDualRing(
          color: Colors.white,
          size: 40.0,
        ),
      )
    );
  }
}


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    if (user == null) {
      return ConnexionPage();
    } else {
      return Accueil();
    }
  }
}
