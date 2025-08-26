import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/containerForms.dart';
import 'package:surf_spots_app/widgets/navbar.dart';

class AddSpotPage extends StatelessWidget {
  const AddSpotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                ContainerForms(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
