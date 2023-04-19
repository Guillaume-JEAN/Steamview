import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:steamview/pages/home.dart';
import 'package:steamview/Connexion/Login.dart';
import 'signup.dart';
import '../loading & splashscreen/loading.dart';
import 'mdp.dart';

class ConnexionPage extends StatefulWidget {
  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}


class _ConnexionPageState extends State<ConnexionPage> {
  final LoginService _log = LoginService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return loading ? Loading() :
    Scaffold(
      backgroundColor: Color.fromARGB(250, 30, 38, 44),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 90,
              ),
              child: Column(
                children: const [
                  SizedBox(height: 100),
                  Text("Bienvenue !",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white,
                    ),),
                  SizedBox(height: 20),
                  Text("Veuillez vous connecter ou créer un nouveau"
                      " compte pour utiliser l'application.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                  ),),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      //onChanged: (value) => setState(() => _email = value ),
                      controller: emailController,
                      validator: (value) => value?.isEmpty ?? true ? "Entrer un email" : null,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          //labelText: 'E-mail',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 33, 42 ,48),
                          hintText: "E-mail",
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: passwordController,
                      validator: (value) => value != null && value.length < 6 ? "Entrer un mot de passe d'au moins 6 caractères" : null,
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 33, 42 ,48),
                          hintText: 'Mot de passe',
                          hintStyle: TextStyle(
                            color: Colors.white,
                          )
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            Column(
              children: [
                TextButton (
                  style: (
                      TextButton.styleFrom(
                        fixedSize: const Size.fromWidth(350),
                        foregroundColor: Colors.white,
                        backgroundColor: const Color.fromARGB(255, 99, 106, 246),
                        elevation: 0,
                      )
                  ),
                  child: const Text("Se connecter"),
                  onPressed: () async {

                    if (_formKey.currentState!.validate()) {
                      setState(() => loading = true );
                      var password = passwordController.value.text;
                      var email = emailController.value.text;

                      dynamic result = await _log.signInWithEmailAndPassword(email, password);
                      if (result == null) {
                        setState(() {
                          loading = false;
                          error = 'Entrer une adresse valide';
                        });
                      }
                      else{
                        setState(() {
                          loading = false;
                        });
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Accueil()));
                      }
                    }
                  },
                ),
                const SizedBox(height: 5),
                Text(
                  error,
                  style: const TextStyle(color: Colors.red, fontSize: 15.0),
                ),
                TextButton (
                  style: (
                    TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      fixedSize: const Size.fromWidth(350),
                      shape: const RoundedRectangleBorder(side: BorderSide(
                        color: Color.fromARGB(255, 99, 106, 246),
                        width: 1,
                      ),),
                    )
                  ),
                  child: const Text("Créer un nouveau compte"),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => InscriptionPage(),));
                  },
                ),
                const SizedBox(height: 100),
                TextButton (
                  style: (
                      TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      )
                  ),
                  child: const Text("Mot de passe oublié",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MotDePasseOublie(),));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
