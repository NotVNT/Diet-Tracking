import 'package:flutter/material.dart';
import 'responsive.dart';

/// Demo screen showcasing responsive design features
/// 
/// This screen demonstrates various responsive widgets and patterns
/// that can be used throughout the Diet Tracking app.
class ResponsiveDemo extends StatefulWidget {
  const ResponsiveDemo({super.key});

  @override
  State<ResponsiveDemo> createState() => _ResponsiveDemoState();
}

class _ResponsiveDemoState extends State<ResponsiveDemo> with ResponsiveMixin {
  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      basePadding: 16,
      appBar: AppBar(
        title: const Text('Responsive Demo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Device Info Section
            _buildDeviceInfoCard(),
            
            rVerticalSpace(24),
            
            // Typography Demo
            _buildTypographySection(),
            
            rVerticalSpace(24),
            
            // Spacing Demo
            _buildSpacingSection(),
            
            rVerticalSpace(24),
            
            // Button Demo
            _buildButtonSection(),
            
            rVerticalSpace(24),
            
            // Grid Demo
            _buildGridSection(),
            
            rVerticalSpace(24),
            
            // Icon Demo
            _buildIconSection(),
            
            rVerticalSpace(40),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return ResponsiveCard(
      baseRadius: 12,
      basePadding: 16,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Device Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          rVerticalSpace(12),
          _buildInfoRow('Device Type', deviceType.toString().split('.').last),
          rVerticalSpace(8),
          _buildInfoRow('Screen Width', '${responsive.screenWidth.toStringAsFixed(1)} dp'),
          rVerticalSpace(8),
          _buildInfoRow('Screen Height', '${responsive.screenHeight.toStringAsFixed(1)} dp'),
          rVerticalSpace(8),
          _buildInfoRow('Orientation', isPortrait ? 'Portrait' : 'Landscape'),
          rVerticalSpace(8),
          _buildInfoRow('Scale Factor', '${responsive.scale.toStringAsFixed(2)}x'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ResponsiveText(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
          ),
        ),
        ResponsiveText(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildTypographySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Typography',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        rVerticalSpace(12),
        ResponsiveCard(
          basePadding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveText(
                'Display (32sp)',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              rVerticalSpace(8),
              ResponsiveText(
                'Title (24sp)',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              rVerticalSpace(8),
              ResponsiveText(
                'Heading (20sp)',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              rVerticalSpace(8),
              ResponsiveText(
                'Body Large (16sp)',
                style: const TextStyle(fontSize: 16),
              ),
              rVerticalSpace(8),
              ResponsiveText(
                'Body (14sp)',
                style: const TextStyle(fontSize: 14),
              ),
              rVerticalSpace(8),
              ResponsiveText(
                'Caption (12sp)',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Spacing',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        rVerticalSpace(12),
        ResponsiveCard(
          basePadding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpacingDemo('XS (4dp)', 4),
              _buildSpacingDemo('S (8dp)', 8),
              _buildSpacingDemo('M (16dp)', 16),
              _buildSpacingDemo('L (24dp)', 24),
              _buildSpacingDemo('XL (32dp)', 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingDemo(String label, double size) {
    return Padding(
      padding: rPadding(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: ResponsiveText(
              label,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Container(
            width: rSpacing(size),
            height: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Buttons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        rVerticalSpace(12),
        ResponsiveButton(
          baseHeight: 56,
          basePadding: 16,
          baseRadius: 12,
          backgroundColor: Theme.of(context).colorScheme.primary,
          onPressed: () {},
          child: ResponsiveText(
            'Large Button (56dp)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        rVerticalSpace(12),
        ResponsiveButton(
          baseHeight: 48,
          basePadding: 16,
          baseRadius: 12,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {},
          child: ResponsiveText(
            'Medium Button (48dp)',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        rVerticalSpace(12),
        ResponsiveButton(
          baseHeight: 40,
          basePadding: 12,
          baseRadius: 10,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          onPressed: () {},
          child: ResponsiveText(
            'Small Button (40dp)',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Grid Layout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        rVerticalSpace(12),
        ResponsiveText(
          'Auto-adjusts columns based on device type',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        rVerticalSpace(12),
        ResponsiveGridView(
          baseSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            6,
            (index) => ResponsiveCard(
              basePadding: 16,
              baseRadius: 12,
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Center(
                child: ResponsiveText(
                  'Item ${index + 1}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Icons',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        rVerticalSpace(12),
        ResponsiveCard(
          basePadding: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  ResponsiveIcon(
                    Icons.home,
                    baseSize: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  rVerticalSpace(4),
                  ResponsiveText(
                    'Small\n(16dp)',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  ResponsiveIcon(
                    Icons.favorite,
                    baseSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  rVerticalSpace(4),
                  ResponsiveText(
                    'Medium\n(24dp)',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  ResponsiveIcon(
                    Icons.star,
                    baseSize: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  rVerticalSpace(4),
                  ResponsiveText(
                    'Large\n(32dp)',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  ResponsiveIcon(
                    Icons.emoji_emotions,
                    baseSize: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  rVerticalSpace(4),
                  ResponsiveText(
                    'XLarge\n(48dp)',
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
