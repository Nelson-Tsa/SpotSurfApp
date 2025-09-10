import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:surf_spots_app/models/surf_spot.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:surf_spots_app/providers/user_provider.dart';
import 'package:surf_spots_app/providers/spots_provider.dart';
import 'package:surf_spots_app/widgets/container_forms.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surf_spots_app/services/auth_service.dart';
import 'package:surf_spots_app/services/spot_service.dart';

class SpotDetailPage extends StatefulWidget {
  final SurfSpot spot;

  const SpotDetailPage({super.key, required this.spot});

  @override
  State<SpotDetailPage> createState() => _SpotDetailPageState();
}

class _SpotDetailPageState extends State<SpotDetailPage> {
  late SurfSpot _spot;
  String _backgroundImageUrl = '';

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _gpsController;
  late TextEditingController _villeController;
  late TextEditingController _spotController;
  late TextEditingController _descriptionController;
  int? _selectedNiveau;
  int? _selectedDifficulte;
  List<XFile> _images = [];
  List<String> _existingImagesBase64 = [];
  bool _isSubmitting = false;
  bool _showPhotoError = false;

  @override
  void initState() {
    super.initState();
    _spot = widget.spot;
    _backgroundImageUrl = _spot.imageBase64.isNotEmpty
        ? _spot.imageBase64.first
        : '';
    _gpsController = TextEditingController(text: _spot.gps);
    _villeController = TextEditingController(text: _spot.city);
    _spotController = TextEditingController(text: _spot.name);
    _descriptionController = TextEditingController(text: _spot.description);
    _selectedNiveau = _spot.level;
    _selectedDifficulte = _spot.difficulty;
    _images = [];
    _existingImagesBase64 = List<String>.from(_spot.imageBase64);
    _loadLikeData();
  }

  Future<void> _loadLikeData() async {
    try {
      final spotId = int.parse(_spot.id);
      final futures = await Future.wait([
        LikeService.getLikesCount(spotId),
        LikeService.isLiked(spotId),
      ]);

      final count = futures[0] as int;
      final isLiked = futures[1] as bool;

      if (mounted) {
        setState(() {
          _spot.likesCount = count;
          _spot.isLiked = isLiked;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _spot.isLiked = false;
          _spot.likesCount = 0;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    try {
      // Utiliser directement le Provider qui gère la synchronisation backend
      final spotsProvider = Provider.of<SpotsProvider>(context, listen: false);
      await spotsProvider.toggleFavorite(_spot);

      // Recharger les données locales depuis le backend pour être sûr
      await _loadLikeData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous devez être connecté pour liker un spot'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Widget _buildLevelIndicator(int level) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            index < level
                ? 'assets/logo/SurfPlancheGOOD.png'
                : 'assets/logo/plancheGrise.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.surfing,
                color: index < level ? Colors.blue : Colors.grey[300],
                size: 24,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDifficultyIndicator(int difficulty) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Image.asset(
            index < difficulty
                ? 'assets/logo/vague.png'
                : 'assets/logo/GriseVague.png',
            width: 30,
            height: 30,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.waves,
                color: index < difficulty ? Colors.orange : Colors.grey[300],
                size: 24,
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildPhotoGallery() {
    final validImages = _spot.imageBase64
        .where((url) => url.isNotEmpty)
        .toList();

    if (validImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          validImages.length == 1 ? "Photo :" : "Photos :",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: validImages.length,
            itemBuilder: (context, index) {
              final imgBase64 = validImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _backgroundImageUrl = imgBase64;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _backgroundImageUrl == imgBase64
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(
                      base64Decode(imgBase64),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[600],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundImage() {
    if (_backgroundImageUrl.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: MemoryImage(base64Decode(_backgroundImageUrl)),
          fit: BoxFit.contain,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  Future<void> deleteSpot(String spotId) async {
    try {
      final response = await AuthService.authenticatedDio.delete(
        'http://10.0.2.2:4000/api/spot/delete/$spotId',
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de la suppression: ${response.data['error']}',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de connexion: $e')));
    }
  }

  Future<void> _openEditForm() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Barre grise pour indiquer qu'on peut glisser
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 16.0),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Titre du formulaire
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.blue,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Fermer',
                        ),
                        const SizedBox(width: 55),
                        Text(
                          'Modifier le spot',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contenu du formulaire
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StatefulBuilder(
                        builder: (context, setModalState) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                // Message d'erreur pour les photos
                                if (_showPhotoError)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      border: Border.all(color: Colors.orange),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.orange.shade700,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Merci d\'ajouter au moins une photo',
                                            style: TextStyle(
                                              color: Colors.orange.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ContainerForms(
                                  formKey: _formKey,
                                  gpsController: _gpsController,
                                  villeController: _villeController,
                                  spotController: _spotController,
                                  descriptionController: _descriptionController,
                                  onPickLocation: () {},
                                  selectedNiveau: _selectedNiveau,
                                  selectedDifficulte: _selectedDifficulte,
                                  onNiveauChanged: (val) {
                                    setModalState(() => _selectedNiveau = val);
                                  },
                                  onDifficulteChanged: (val) {
                                    setModalState(
                                      () => _selectedDifficulte = val,
                                    );
                                  },
                                  isGpsEditable: false,
                                  onValidate: () async {
                                    if (!_formKey.currentState!.validate() ||
                                        _selectedNiveau == null ||
                                        _selectedDifficulte == null) {
                                      return;
                                    }

                                    // Capturer le contexte AVANT l'opération asynchrone
                                    final navigatorContext = Navigator.of(
                                      context,
                                    );
                                    final scaffoldMessengerContext =
                                        ScaffoldMessenger.of(context);

                                    // Ajoute les nouvelles images à la liste finale
                                    List<String> allImagesBase64 = [
                                      ..._existingImagesBase64,
                                      ...await Future.wait(
                                        _images.map((img) async {
                                          final bytes = await img.readAsBytes();
                                          return base64Encode(bytes);
                                        }),
                                      ),
                                    ];

                                    // Vérification qu'au moins une photo est présente
                                    if (allImagesBase64.isEmpty) {
                                      setModalState(
                                        () => _showPhotoError = true,
                                      );
                                      return;
                                    } else {
                                      setModalState(
                                        () => _showPhotoError = false,
                                      );
                                    }

                                    setModalState(() => _isSubmitting = true);

                                    try {
                                      final response = await AuthService
                                          .authenticatedDio
                                          .put(
                                            'http://10.0.2.2:4000/api/spot/update/${_spot.id}',
                                            data: jsonEncode({
                                              'name': _spotController.text,
                                              'city': _villeController.text,
                                              'description':
                                                  _descriptionController.text,
                                              'gps': _gpsController.text,
                                              'level': _selectedNiveau,
                                              'difficulty': _selectedDifficulte,
                                              'images': allImagesBase64,
                                            }),
                                          );
                                      setModalState(
                                        () => _isSubmitting = false,
                                      );

                                      if (!mounted) return;

                                      if (response.statusCode == 200) {
                                        final updatedSpot = SurfSpot.fromJson(
                                          response.data['spot'],
                                        );
                                        setState(() {
                                          _spot = updatedSpot;
                                          _existingImagesBase64 =
                                              List<String>.from(
                                                _spot.imageBase64,
                                              );
                                          _images.clear();
                                        });

                                        // Utiliser les contextes capturés
                                        navigatorContext.pop();
                                        navigatorContext.pop(updatedSpot);
                                      } else {
                                        scaffoldMessengerContext.showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Erreur lors de la modification',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setModalState(
                                        () => _isSubmitting = false,
                                      );

                                      if (!mounted) return;

                                      scaffoldMessengerContext.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Erreur de connexion: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  existingImagesBase64: _existingImagesBase64,
                                  images: _images,
                                  onAddImage: () async {
                                    final picker = ImagePicker();
                                    final picked = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (picked != null) {
                                      setModalState(() => _images.add(picked));
                                    }
                                  },
                                  onRemoveImage: (img) {
                                    setModalState(() => _images.remove(img));
                                  },
                                  onRemoveExistingImage: (imgBase64) {
                                    setModalState(() {
                                      _existingImagesBase64.remove(imgBase64);
                                    });
                                  },
                                  isSubmitting: _isSubmitting,
                                  formTitle: 'Modifier le spot',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      body: SlidingUpPanel(
        panel: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 16.0)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.blue),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 50.0),
                        child: Text(
                          "Détails du spot",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _spot.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me_rounded,
                            size: 18,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _spot.city,
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _spot.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      _buildPhotoGallery(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Text(
                            "Niveau : ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildLevelIndicator(_spot.level),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "Difficulté : ",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          _buildDifficultyIndicator(_spot.difficulty),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _spot.isLiked ?? false
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.blue,
                            ),
                            onPressed: () async {
                              await _toggleLike();
                            },
                          ),
                          Text(
                            "${_spot.likesCount} like${_spot.likesCount == 1 ? '' : 's'}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          if (currentUser != null &&
                              (currentUser.role == 'admin' ||
                                  currentUser.id == _spot.userId)) ...[
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.orange,
                              ),
                              tooltip: 'Modifier ce spot',
                              onPressed: _openEditForm,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                      'Confirmer la suppression',
                                    ),
                                    content: const Text(
                                      'Voulez-vous vraiment supprimer ce spot ?',
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text('Annuler'),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await deleteSpot(_spot.id);
                                }
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.3,
              child: _buildBackgroundImage(),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.1,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(30),
                      Colors.black.withAlpha(10),
                      Colors.transparent,
                      Colors.black.withAlpha(40),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Container(color: Colors.white),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Container(color: Colors.white),
            ),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        minHeight: MediaQuery.of(context).size.height * 0.6,
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
    );
  }
}
