import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import 'image_details_dialog.dart';
import '../../../domain/entities/scanned_food_entity.dart';

/// Bottom sheet menu showing more options for the scanned food detail
class MoreOptionsMenu extends StatelessWidget {
  final ScannedFoodEntity scannedFood;
  final ResponsiveHelper responsive;

  const MoreOptionsMenu({
    super.key,
    required this.scannedFood,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Save to device'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Image details'),
            onTap: () {
              Navigator.pop(context);
              _showImageDetails(context);
            },
          ),
        ],
      ),
    );
  }

  void _showImageDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ImageDetailsDialog(scannedFood: scannedFood),
    );
  }
}

