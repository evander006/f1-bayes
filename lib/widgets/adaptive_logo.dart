import 'package:flutter/material.dart';

class AdaptiveLogo extends StatelessWidget{
  const AdaptiveLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final w=MediaQuery.sizeOf(context).width;
    final size=(w * 0.06).clamp(28.0, 56.0);
    return Image.asset('assets/logo/f1logo.png', width: size,height: size,fit: BoxFit.contain,);
  }

}