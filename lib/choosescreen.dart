import 'package:flutter/material.dart';
import 'package:neighborly/VolunteerLoginPage.dart';
import 'package:neighborly/loginuser.dart';
import 'package:neighborly/samplepage.dart';

class Choosescreen extends StatelessWidget {
  const Choosescreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
     
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image

            Positioned(
              left: 0,
              right: 0,
              child: Container(
                height: screenHeight * 0.44,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/upperimage.png'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ),

            // USER Button
            Positioned(
              top: 420,
              left: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginUser()),
                  );
                },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 248, 248, 248),
                    borderRadius: BorderRadius.circular(70),
                    image: DecorationImage(
                      image: AssetImage('assets/userimage.png'),
                      fit: BoxFit.fitHeight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(5, 9),
                      ),
                    ],
                  ),
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              top: 610,
              left: 90,
              child: Container(
                child: Text(
                  'USER',
                  style: TextStyle(
                    fontSize: 20,color:Colors.white
                  ),
                ),
              ),
            ),

            // VOLUNTEER Button
            Positioned(
              top: 420,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VolunteerLoginPage()),
                  );
                },
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 249, 249, 249),
                    borderRadius: BorderRadius.circular(70),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(5, 9),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                ),
              ),
            ),
            Positioned(
              top: 610,
              right: 57,
              child: Container(
                child: Text(
                  'VOLUNTEER',
                  style: TextStyle(fontSize: 20,color:Colors.white ),
                ),
              ),
            ),

           
          ]   
        ),
      ),
    );
  }
}
