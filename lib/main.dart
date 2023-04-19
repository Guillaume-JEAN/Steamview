import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:steamview/Connexion/Login.dart';
import 'package:steamview/Database/database.dart';
import 'package:steamview/loading & splashscreen/loading.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "SteamView",
    options: const FirebaseOptions(
      apiKey: "AIzaSyDFSu8wbgYGaODFueMk9Mj89hu3vUNrSfA",
      appId: "1:974097826947:web:9a2e5fe1bedd2bfe4b07b6",
      messagingSenderId: "974097826947",
      projectId: "steamview-5e98b",
    )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<AppUser?>.value(
      value: LoginService().user,
      initialData: null,
      child: MaterialApp(
        title: 'SteamView',
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}

