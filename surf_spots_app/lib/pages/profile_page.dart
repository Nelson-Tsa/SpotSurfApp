import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_spots_app/widgets/user_spots_carousel.dart';
import 'package:surf_spots_app/constants/colors.dart';
import 'package:surf_spots_app/models/user.dart';
import 'package:surf_spots_app/main.dart';
import 'package:surf_spots_app/pages/update_profile_page.dart';
import 'package:surf_spots_app/pages/change_password_page.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../providers/spots_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Key _futureKey = UniqueKey();

  void _navigateToUpdateProfile(User user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateProfilePage(user: user)),
    );

    // Si l'utilisateur a mis à jour ses infos, on rafraîchit la page
    if (result == true && mounted) {
      setState(() {
        _futureKey = UniqueKey();
      });
    }
  }

  void _navigateToChangePassword() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );

    // Pas besoin de rafraîchir car le changement de mot de passe n'affecte pas l'affichage
    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mot de passe modifié avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        key: _futureKey,
        future: AuthService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Erreur lors du chargement du profil'),
            );
          }

          final user = snapshot.data!;
          return _buildProfileContent(user);
        },
      ),
    );
  }

  Widget _buildProfileContent(User user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 50),
          _buildProfileInfo(user),
          const SizedBox(height: 30),
          _buildProfileSettings(user),
          const SizedBox(height: 20),
          const UserSpotsCarousel(),
          const SizedBox(height: 30),
          _buildLogoutSection(context),
          const SizedBox(height: 20),
          _buildFooterLinks(),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   // Simplement afficher le profil - la logique isLoggedIn est gérée dans main.dart
  //   return Scaffold(
  //     body: SingleChildScrollView(
  //       child: Column(
  //         children: [
  //           _buildHeader(),
  //           const SizedBox(height: 50),
  //           _buildProfileInfo(),
  //           const SizedBox(height: 30),
  //           _buildProfileSettings(),
  //           const SizedBox(height: 20),
  //           const Carroussel(),
  //           const SizedBox(height: 30),
  //           _buildLogoutSection(context),
  //           const SizedBox(height: 20),
  //           _buildFooterLinks(),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHeader() {
    return Container(
      color: AppColors.primary,
      width: double.infinity,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo/wave.png', width: 40),
            const SizedBox(width: 16),
            const Text(
              "Surf App",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(User user) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 60, color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          user.name, // Utilise le nom de l'utilisateur depuis la DB
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          user.email, // Affiche aussi l'email
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildProfileSettings(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // Bouton Personal Information
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => _navigateToUpdateProfile(user),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.supervised_user_circle, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Personal Information",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),

          // Bouton Change Password
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _navigateToChangePassword,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Changer le mot de passe",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profile Settings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () async {
                // Sauvegarder le context avant les opérations async
                final navigator = Navigator.of(context);
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                final spotsProvider = Provider.of<SpotsProvider>(context, listen: false);
                
                // Nettoyer tous les providers et caches
                userProvider.clearUser();
                spotsProvider.clearCache();

                // Ensuite déconnecter
                await AuthService.logout();

                // Retourner à la page d'accueil (index 0) avec nettoyage complet
                if (mounted) {
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) =>
                          const HomeScreen(title: 'Surf Spots App'),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text("Log Out", style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _footerLink("Mentions Légales"),
          _footerLink("Nous contacter"),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return TextButton(
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.black54)),
    );
  }
}
