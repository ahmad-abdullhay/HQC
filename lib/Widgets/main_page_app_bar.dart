import 'package:flutter/material.dart';

class MainPageAppBar extends StatelessWidget {
  final double height;
  final List<Widget> columnWidgets;
  const MainPageAppBar({
    Key key,
    this.columnWidgets, this.height,
  }) : super(key: key);
  
  Widget build2(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.orangeAccent[100],
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60))),
        child: Column(
          children: columnWidgets,
        ),
      ),
    );}
  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.orangeAccent[100],
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60),
                bottomRight: Radius.circular(60))),
        child: Column(
          children: columnWidgets,
        ),
      ),
    );
  }
}
