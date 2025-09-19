import 'package:flutter/material.dart';
import '../models/photo_analysis.dart';

class CameraSettingsCard extends StatelessWidget {
  final CameraSettings settings;

  const CameraSettingsCard({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Camera Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSettingsGrid(),
        ],
      ),
    );
  }

  Widget _buildSettingsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSettingItem(
                'ISO',
                settings.iso.toString(),
                Icons.iso,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSettingItem(
                'Aperture',
                'f/${settings.aperture}',
                Icons.camera_enhance,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSettingItem(
                'Shutter Speed',
                settings.shutterSpeed,
                Icons.shutter_speed,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSettingItem(
                'Focus',
                settings.focusMode,
                Icons.center_focus_strong,
                Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildSettingItem(
          'White Balance',
          settings.whiteBalance,
          Icons.wb_sunny,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildSettingItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}