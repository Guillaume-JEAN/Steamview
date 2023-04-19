import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class MotDePasseOublie extends StatelessWidget {
  const MotDePasseOublie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(250, 30, 38, 44),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(250, 30, 38, 44),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(
                vertical: 30,
                horizontal: 20,
              ),
              child: Column(
                children: const [
                  SizedBox(height: 100),
                  Text(
                    "Mot de passe oublié",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 70,
              ),
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Veuillez saisir votre email afin de réinitialiser votre mot de passe.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  TextField(
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Color.fromARGB(255, 33, 42 ,48),
                      hintText: "E-mail",
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 70),
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
                  child: const Text("Renvoyer mon mot de passe"),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
