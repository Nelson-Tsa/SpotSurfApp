import 'package:flutter/material.dart';
import 'package:surf_spots_app/widgets/carroussel.dart';
import 'package:surf_spots_app/constants/colors.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Key _futureKey = UniqueKey();

  // void _refreshProfile() {
  //   setState(() {
  //     _futureKey = UniqueKey();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      key: _futureKey,
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final isLoggedIn = snapshot.data ?? false;

        if (isLoggedIn) {
          // Utilisateur connecté - afficher le profil complet
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 50),
                  _buildProfileInfo(),
                  const SizedBox(height: 30),
                  _buildProfileSettings(),
                  const SizedBox(height: 20),
                  const Carroussel(),
                  const SizedBox(height: 30),
                  _buildLogoutSection(context),
                  const SizedBox(height: 20),
                  _buildFooterLinks(),
                ],
              ),
            ),
          );
        } else {
          // Utilisateur non connecté - afficher les boutons login/register
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.black,
                    maximumSize: const Size(350, 60),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.black,
                    minimumSize: const Size(170, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text(
                    'S\'inscrire',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

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

  Widget _buildProfileInfo() {
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
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Kristin Hennessy",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildProfileSettings() {
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
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {},
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
              onPressed: null,
              // () async {
              //   await AuthService.logout();
              //   _refreshProfile();
              // },
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
          _footerLink("Instructeur Léo"),
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
