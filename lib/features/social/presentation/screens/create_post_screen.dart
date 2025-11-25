import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:good_news/core/constants/theme_tokens.dart';
import 'package:good_news/core/services/social_api_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;
  bool _isUploadingImage = false;
  String _visibility = 'Public';
  File? _selectedImageFile;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_updateButtonState);
    _titleController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _textController.removeListener(_updateButtonState);
    _titleController.removeListener(_updateButtonState);
    _textController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _canPost => _textController.text.trim().isNotEmpty && !_isPosting && !_isUploadingImage;

  Color get _buttonBackgroundColor {
    if (_isPosting || _isUploadingImage) return ThemeTokens.buttonDisabled;
    return _canPost ? ThemeTokens.buttonEnabled : ThemeTokens.buttonDisabled;
  }

  Future<void> _createPost() async {
    if (!_canPost) return;

    final content = _textController.text.trim();
    final title = _titleController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Content is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    try {
      print('📝 CREATE POST: Starting post creation...');
      print('📝 CREATE POST: Title: "$title"');
      print('📝 CREATE POST: Content: "$content"');
      print('📝 CREATE POST: Visibility (UI): "$_visibility"');
      print('📝 CREATE POST: Uploaded Image URL: ${_uploadedImageUrl ?? 'None'}');

      // Map visibility to API format
      String visibilityFormatted;
      switch (_visibility) {
        case 'Public':
          visibilityFormatted = 'public';
          break;
        case 'Friends Only':
          visibilityFormatted = 'friends';
          break;
        case 'Private':
          visibilityFormatted = 'private';
          break;
        default:
          visibilityFormatted = 'public';
      }

      print('📝 CREATE POST: Visibility (API): "$visibilityFormatted"');

      // Create post with uploaded image URL
      final response = await SocialApiService.createPost(
        content,
        visibilityFormatted,
        title: title.isNotEmpty ? title : null,
        imageUrl: _uploadedImageUrl,
      );

      print('📝 CREATE POST: Response status: ${response['status']}');
      print('📝 CREATE POST: Response data: $response');

      if (response['status'] == 'success') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Good news shared! 🌟'),
              backgroundColor: ThemeTokens.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception(response['error'] ?? 'Failed to create post');
      }
    } catch (e) {
      print('❌ CREATE POST: Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share post: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  void _selectImage() async {
    // Check camera permission
    var cameraStatus = await Permission.camera.status;

    // Check gallery permission (works for both Android 13+ and older versions)
    var galleryStatus = await Permission.photos.status;

    // Fallback to storage permission for older Android versions
    if (!galleryStatus.isGranted && Platform.isAndroid) {
      galleryStatus = await Permission.storage.status;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: ThemeTokens.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Photo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromCamera();
                    },
                    icon: const Icon(Icons.camera_alt, color: ThemeTokens.primaryGreen),
                    label: const Text(
                      'Camera',
                      style: TextStyle(color: ThemeTokens.primaryGreen),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ThemeTokens.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImageFromGallery();
                    },
                    icon: const Icon(Icons.photo_library, color: ThemeTokens.primaryGreen),
                    label: const Text(
                      'Gallery',
                      style: TextStyle(color: ThemeTokens.primaryGreen),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: ThemeTokens.primaryGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Maximum file size: 5MB',
              style: TextStyle(
                color: ThemeTokens.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();

      if (cameraPermission.isGranted) {
        final XFile? image = await _picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          await _handleImageSelection(File(image.path));
        }
      } else if (cameraPermission.isPermanentlyDenied) {
        _showPermissionDeniedDialog('Camera');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera permission is required to take photos'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('📷 Camera error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📷 Camera error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      // Try photos permission first (for Android 13+)
      PermissionStatus galleryPermission = await Permission.photos.request();

      // If photos permission is not available or denied, try storage permission (for older Android)
      if (galleryPermission.isDenied && Platform.isAndroid) {
        galleryPermission = await Permission.storage.request();
      }

      print('📂 Gallery permission status: $galleryPermission');

      // Allow access if permission is granted OR permanently denied (in case user already granted it in settings)
      if (galleryPermission.isGranted ||
          galleryPermission.isLimited ||
          galleryPermission.isPermanentlyDenied) {

        final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image != null) {
          await _handleImageSelection(File(image.path));
        }
      } else {
        _showPermissionDeniedDialog('Gallery');
      }
    } catch (e) {
      print('📂 Gallery error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📂 Gallery error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleImageSelection(File imageFile) async {
    final fileSizeInBytes = await imageFile.length();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);

    if (fileSizeInMB > 5) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image size must be less than 5MB'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _selectedImageFile = imageFile;
      _isUploadingImage = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Uploading image...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: ThemeTokens.primaryGreen,
        ),
      );
    }

    try {
      print('📤 Uploading image: ${imageFile.path}');
      final uploadResponse = await SocialApiService.uploadPostImage(imageFile);

      print('📤 Upload response: $uploadResponse');

      if (uploadResponse['status'] == 'success') {
        setState(() {
          _uploadedImageUrl = uploadResponse['image_url'];
          _isUploadingImage = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Image uploaded successfully!'),
              backgroundColor: ThemeTokens.primaryGreen,
              duration: Duration(seconds: 2),
            ),
          );
        }

        print('✅ Image uploaded successfully: $_uploadedImageUrl');
      } else {
        throw Exception(uploadResponse['error'] ?? 'Upload failed');
      }
    } catch (e) {
      print('❌ Image upload failed: $e');

      setState(() {
        _selectedImageFile = null;
        _uploadedImageUrl = null;
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Upload failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Required'),
        content: Text('Please grant $permission access in Settings to select photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _uploadedImageUrl = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Image removed'),
        backgroundColor: Colors.grey,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Create Post'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: ElevatedButton(
              onPressed: _canPost ? _createPost : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPosting || _isUploadingImage
                    ? colorScheme.secondary
                    : (_canPost ? colorScheme.primary : colorScheme.secondary.withOpacity(0.5)),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isPosting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Text(
                'Post',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  child: Text(
                    'ME',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You',
                        style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
                      ),
                      DropdownButton<String>(
                        value: _visibility,
                        dropdownColor: theme.cardTheme.color ?? colorScheme.surfaceVariant,
                        underline: Container(),
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        items: ['Public', 'Friends Only', 'Private'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Public'
                                      ? Icons.public
                                      : value == 'Friends Only'
                                      ? Icons.people
                                      : Icons.lock,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _visibility = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Title Field (Commented out - uncomment if needed)
            // Card(
            //   child: Padding(
            //     padding: const EdgeInsets.all(16),
            //     child: TextField(
            //       controller: _titleController,
            //       style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface),
            //       decoration: InputDecoration(
            //         hintText: 'Add a title (optional)...',
            //         hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            //         border: InputBorder.none,
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _textController,
                  maxLines: 8,
                  minLines: 8,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Share something positive that happened today... (Required)',
                    hintStyle: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedImageFile != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.file(
                              _selectedImageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Icon(
                                  _isUploadingImage ? Icons.cloud_upload : Icons.check_circle,
                                  color: _isUploadingImage ? colorScheme.secondary : Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isUploadingImage ? 'Uploading...' : 'Image uploaded',
                                    style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                                  ),
                                ),
                                if (!_isUploadingImage)
                                  IconButton(
                                    onPressed: _removeImage,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    tooltip: 'Remove image',
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isUploadingImage ? null : _selectImage,
                icon: Icon(
                  Icons.photo_camera_outlined,
                  color: _isUploadingImage ? Colors.grey : colorScheme.primary,
                ),
                label: Text(
                  _selectedImageFile == null ? 'Add Photo (Optional)' : 'Change Photo',
                  style: textTheme.labelLarge?.copyWith(
                    color: _isUploadingImage ? Colors.grey : colorScheme.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _isUploadingImage ? Colors.grey : colorScheme.primary,
                    width: 1,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}