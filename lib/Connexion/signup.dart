import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:steamview/pages/home.dart';

import 'Login.dart';
import '../loading & splashscreen/loading.dart';

class InscriptionPage extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}


class _InscriptionPageState extends State<InscriptionPage> {
  final LoginService _auth = LoginService();
  final _formKey = GlobalKey<FormState>();
  String error = '';
  bool loading = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return loading ? Loading() :
      Scaffold(
        backgroundColor: Color.fromARGB(250, 30, 38, 44),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(250, 30, 38, 44),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 50,
                  horizontal: 80,
                ),
                child: Column(
                  children: const [
                    SizedBox(height: 100),
                    Text(
                      "Inscription",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 22),
                    Text(
                      "Veuillez saisir ces différentes informations, afin que vos listes soient sauvegardées.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              //TextFormField(),
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
                        controller: nameController,
                        validator: (value) => value?.isEmpty ?? true ? "Entrer un nom d'utilisateur" : null,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "Nom d'utilisateur",
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 33, 42 ,48),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailController,
                        validator: (value) => value?.isEmpty ?? true ? "Entrer un email" : null,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: "E-mail",
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 33, 42 ,48),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
                        validator: (value) => value != null && value.length < 6 ? "Entrer un mot de passe d'au moins 6 caractères" : null,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Mot de passe',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 33, 42 ,48),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),

                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        validator: (value) => value != passwordController.value.text ? "Mots de passes différents" : null,
                        obscureText: true,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          hintText: 'Vérification du mot de passe',
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color.fromARGB(255, 33, 42 ,48),
                          hintStyle: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              ),
              const SizedBox(height: 70),
              Column(
                children: [
                  TextButton (
                    style: (
                        TextButton.styleFrom(
                          fixedSize: const Size.fromWidth(300),
                          foregroundColor: Colors.white,
                          backgroundColor: const Color.fromARGB(255, 99, 106, 246),
                          elevation: 0,
                        )
                    ),
                    child: const Text("S'inscrire"),
                    onPressed: () async {

                      if (_formKey.currentState!.validate()) {
                        setState(() => loading = true );
                        var password = passwordController.value.text;
                        var email = emailController.value.text;
                        var name = nameController.value.text;

                        //TODO call firebase auth
                        dynamic result = await _auth.registerWithEmailAndPassword(name, email, password);
                        if (result == null) {
                          setState(() {
                            loading = false;
                            error = 'Entrer une adresse valide';
                          });
                        }else{
                          setState(() {
                            loading = false;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Accueil()));
                        }
                      }
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
