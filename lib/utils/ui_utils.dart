import 'package:flutter/material.dart';

class BeamPainter extends CustomPainter {
  final Color color;

  BeamPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              color.withOpacity(0.5), // Centre opaque
              color.withOpacity(0.0), // Extérieur transparent
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2,
            ),
          );

    // On définit un arc de cercle (le cône)
    // Ici on dessine un angle de 90° (pi/2) orienté vers le haut
    final Path path = Path()
      ..moveTo(size.width / 2, size.height / 2) // Centre
      ..arcTo(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width,
          height: size.height,
        ),
        -3.14 / 2 - (3.14 / 4), // Angle de départ (Haut - 45°)
        3.14 / 2, // Ouverture du cône (90°)
        false,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
