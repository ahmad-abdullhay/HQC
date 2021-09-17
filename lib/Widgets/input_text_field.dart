import 'package:flutter/material.dart';

class InputTextField extends StatelessWidget {
  final Function onChanged;
  final Function validator;
  final String hintText;
  final bool isObscure;
  final Icon icon;
  final TextInputType textInputType;
  const InputTextField({
    Key key,
    this.onChanged,
    this.icon,
    this.hintText,
    this.isObscure,
    this.validator,
    this.textInputType,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6),
      width: MediaQuery.of(context).size.width,
      child: TextFormField(
        style: TextStyle(fontFamily: 'Scholar', fontSize: 16.0),
        validator: validator,
        obscureText: isObscure ?? false,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        keyboardType: textInputType,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: hintText, icon: icon),
      ),
    );
  }
}
