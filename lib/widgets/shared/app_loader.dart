import 'package:flutter/material.dart';
import '../../theme/theme.dart';

class AppLoader extends StatelessWidget {
  final String? mensaje;

  const AppLoader({this.mensaje, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: kBrandPurple,
            strokeWidth: 3.5,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
