import 'package:flutter/material.dart';
import 'package:techxcel11/pages/reuse.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBarUser(),
      appBar: buildAppBar('Welcome to TechXcel'),
      body: Container(),
    );
  }
}
