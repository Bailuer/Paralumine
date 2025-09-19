import 'package:flutter/material.dart';
import '../models/photo_analysis.dart';

class CameraPositionCard extends StatelessWidget {
  final CameraPosition cameraPosition;

  const CameraPositionCard({
    super.key,
    required this.cameraPosition,
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
                Icons.videocam,
                color: Colors.indigo,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Camera Position',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPositionDiagram(),
          const SizedBox(height: 16),
          _buildPositionDetails(),
          const SizedBox(height: 16),
          _buildDescription(),
        ],
      ),
    );
  }

  Widget _buildPositionDiagram() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 20,
            child: _buildSubjectIcon(),
          ),
          Positioned(
            right: 30,
            bottom: 30 + (cameraPosition.height * 20),
            child: _buildCameraIcon(),
          ),
          Positioned(
            right: 50,
            bottom: 10,
            child: Text(
              '${cameraPosition.distance.toStringAsFixed(1)}m',
              style: TextStyle(
                fontSize: 10,
                color: Colors.indigo.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (cameraPosition.angle != 0)
            Positioned(
              right: 20,
              top: 20,
              child: Text(
                '${cameraPosition.angle.toStringAsFixed(0)}°',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.indigo.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSubjectIcon() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.indigo.shade100,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.indigo.shade300, width: 2),
      ),
      child: Icon(
        Icons.person,
        size: 16,
        color: Colors.indigo.shade600,
      ),
    );
  }

  Widget _buildCameraIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.camera_alt,
        size: 12,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPositionDetails() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            'Height',
            '${cameraPosition.height.toStringAsFixed(1)}m',
            Icons.height,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailItem(
            'Distance',
            '${cameraPosition.distance.toStringAsFixed(1)}m',
            Icons.straighten,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildDetailItem(
            'Angle',
            '${cameraPosition.angle.toStringAsFixed(0)}°',
            Icons.rotate_right,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description,
                color: Colors.grey.shade600,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Positioning Guide',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            cameraPosition.description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}