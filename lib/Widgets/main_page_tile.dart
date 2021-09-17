import 'package:flutter/material.dart';

class MainPageTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function onTap;
  const MainPageTile({
    Key key,
    this.text,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 110,
          width: MediaQuery.of(context).size.width * 0.95,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.orange[300], Colors.orange[100]],
              ),
              borderRadius: BorderRadius.circular(45)),
          child: Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              SizedBox(
                width: 30,
              ),
              Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 20),
              )
            ],
          ),
        ),
      ),
    );
  }
}
