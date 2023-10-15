import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';


class CalenderPage extends StatefulWidget{
  const CalenderPage({Key? key}) : super(key: key);

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}
 
class _CalenderPageState extends State<CalenderPage>{
  @override
  Widget build (BuildContext context){
     return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 241, 243, 1),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: const Color.fromRGBO(248, 241, 243, 1),
        color: const Color.fromARGB(255, 237, 212, 242),
        animationDuration: const Duration (milliseconds: 300),
        onTap: (index){
          //use it to navigate to different pages

        },
        items: const [
        Icon(Icons.home),
        Icon(Icons.work),
        Icon(Icons.book),
        Icon(Icons.chat_bubble),

      ],
      ) ,
    );
  }
}
