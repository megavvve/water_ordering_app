import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vodovoz/presentation/screens/driver/driver_profile_screen/widgets/photo_section_widget.dart';

class PhotoSection extends StatelessWidget {
  final File? carPhoto;
  final File? sorPhoto;
  final File? licensePhoto;
  final Future<void> Function(ImageSource source, String type) onPickImage;

  const PhotoSection({
    super.key,
    this.carPhoto,
    this.sorPhoto,
    this.licensePhoto,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PhotoSectionWidget(
          title: 'Фото автомобиля',
          photo: carPhoto,
          onPickImage: () => onPickImage(ImageSource.gallery, 'car'),
        ),
        PhotoSectionWidget(
          title: 'Фото СОР',
          photo: sorPhoto,
          onPickImage: () => onPickImage(ImageSource.gallery, 'sor'),
        ),
        PhotoSectionWidget(
          title: 'Фото ВУ',
          photo: licensePhoto,
          onPickImage: () => onPickImage(ImageSource.gallery, 'license'),
        ),
      ],
    );
  }
}
