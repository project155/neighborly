import 'package:flutter/material.dart';
import 'package:neighborly/VolunteerLoginPage.dart';
import 'package:neighborly/loginuser.dart';

class Choosescreen extends StatelessWidget {
  const Choosescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body:  
        Center( 
          child:
           Column(
            children: [Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomRight: Radius.circular(-180)),
              image: DecorationImage(image: AssetImage('upperimage.png'),
               //alignment: Alignment.bottomCenter,
              fit: BoxFit.fill,
              
             ),
              
              ),
              width: double.infinity,
              height: 450,
              
             ),

             SizedBox(height: 50,),
          
          
               Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginUser(),));
                    },
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                      
                          color: const Color.fromARGB(255, 248, 248, 248),  
                        borderRadius: BorderRadius.circular(70),
                      image: DecorationImage(image: AssetImage('userimage.png',),
                      fit: BoxFit.fitHeight,),
                      boxShadow: [
                                      BoxShadow(
                                      color: Colors.black.withOpacity(0.2),  // Shadow color
                                     spreadRadius: 2,                       // Spread distance
                                    blurRadius: 10,                        // Blur amount
                                    offset: Offset(5, 9),                  // Shadow position (x, y)
                                     ),]
                     ),
                        alignment: Alignment.topCenter,
                    child: Text("USER"),
                    ),
                  ),
                  Spacer(),
                  
                    
                       GestureDetector(
                        onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) =>VolunteerLoginPage (),));
                    },
                         child: Container(
                            width: 190,
                            height: 190,
                          
                           decoration: BoxDecoration(
                             color: const Color.fromARGB(255, 249, 249, 249),
                              borderRadius: BorderRadius.circular(70)
                            ),
                            
                          ),
                       ),
                      Spacer(),
                      
                      
                      
                   
                   
                   
                   ],
                   ),

                   SizedBox(height: 70,),

                         Container(
                          width: 200,
                          height: 100,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                                      BoxShadow(
                                      color: Colors.black.withOpacity(0.2),  // Shadow color
                                     spreadRadius: 2,                       // Spread distance
                                    blurRadius: 10,                        // Blur amount
                                    offset: Offset(5, 9),                  // Shadow position (x, y)
                                     ),
  ],
                          
                          
                          color: const Color.fromARGB(255, 96, 134, 255)),
                          alignment: Alignment.center,
                          
                          child: Text('submit', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,fontFamily:'sans serif'),),
                         ),
                         
             ],
             
           
        
        ),
      ),
    );
  }
}