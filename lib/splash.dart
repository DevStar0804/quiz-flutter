import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz/settings.dart';


class SplashScreen extends StatefulWidget{
  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds: 3), (){
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomePage()
      ));
    });
  }

  @override
  Widget build(BuildContext context){
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "Let's Enjoy\n to Quiz!!!",
              style: TextStyle(
                fontSize: 50.0,
                color: Colors.redAccent,
                fontFamily: "Satisfy",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Center(
            child: Image(
              image: AssetImage('assets/splash.png'),
              width: screenWidth * 0.5,
              height: screenWidth * 0.5 * 720 / 1280,
            ),
          )
        ],
      )
    );
  }
}