import 'package:flutter/material.dart';

class Choosescreen extends StatelessWidget {
  const Choosescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

     
      body: Column(
      
        
        children: [
          Spacer(),
          Row(
            
            children: [
              SizedBox(width: 30,),
              Expanded(
                child: SizedBox(
                  height: 170,
                  child: Card(
                    child: Center(child: Text('user')),
                    
                  ),
                ),
              ),
               SizedBox(width: 20,),
            
              Expanded(
                child: SizedBox(
                  height:170,
                  child: Card(
                    child: Center(child: Text('volunteer')),
                  ),
                ),
              ),
              SizedBox(width: 30,),
              
              ],
          ),

          Spacer(),
      Expanded(child: SizedBox(
      
        width: 450,
        child: Card(
          child: Center(child: Text('hello')),
        ),
      ))
       
       
             
       
       
      
        
        ],
      ),
      
    );
  }
}