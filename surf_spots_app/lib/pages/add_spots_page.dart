// import 'package:flutter/material.dart';
// //import 'package:surf_spots_app/widgets/containerForms.dart';
// import 'package:surf_spots_app/widgets/container_forms.dart';
// import 'package:surf_spots_app/widgets/navbar.dart';

// class AddSpotPage extends StatelessWidget {
//   AddSpotPage({super.key});

//   final TextEditingController _gpsController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage("assets/images/background.png"),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               children: [
//                 ContainerForms(
//                   gpsController: _gpsController,
//                   onPickLocation: () {
//                     // Ici tu peux gérer ce qui se passe quand on clique sur l'icône GPS
//                     print("Mode sélection GPS activé !");
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
