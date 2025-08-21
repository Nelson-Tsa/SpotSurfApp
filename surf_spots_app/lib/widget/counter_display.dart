import 'package:flutter/material.dart';

// Un widget simple et réutilisable qui ne fait qu'afficher un nombre.
class CounterDisplay extends StatelessWidget {
  final int count;

  const CounterDisplay({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Vous avez appuyé sur le bouton ce nombre de fois :'),
          Text(
            '$count', // On utilise la valeur reçue
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}
