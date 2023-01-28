import 'package:flutter/material.dart';

class Clipper extends CustomClipper<Rect> {
  const Clipper(this.rect);

  final Rect rect;

  @override
  Rect getClip(Size size) => rect;

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => false;
}
