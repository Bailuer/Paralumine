import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../widgets/camera_settings_card.dart';
import '../widgets/lighting_setup_card.dart';
import '../widgets/camera_position_card.dart';
import '../widgets/pro_mode_panel.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Analysis Results'),
        actions: [
          Consumer<AnalysisProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: Icon(
                  provider.isBeginnerMode ? Icons.school : Icons.engineering,
                  color: Colors.blue,
                ),
                onPressed: () {
                  provider.toggleMode();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isBeginnerMode 
                          ? 'Switched to Beginner Mode' 
                          : 'Switched to Pro Mode',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                tooltip: provider.isBeginnerMode ? 'Switch to Pro Mode' : 'Switch to Beginner Mode',
              );
            },
          ),
        ],
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          if (provider.isAnalyzing) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider.error!);
          }

          if (provider.currentAnalysis == null) {
            return _buildEmptyState(context);
          }

          final analysis = provider.currentAnalysis!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReferenceImage(analysis.referenceImagePath),
                const SizedBox(height: 24),
                
                if (provider.isBeginnerMode) ...[
                  _buildBeginnerTip(analysis.beginnerTip),
                  const SizedBox(height: 24),
                ],

                _buildSectionTitle('Camera Settings'),
                const SizedBox(height: 12),
                ...analysis.cameraSettingsOptions.map(
                  (settings) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CameraSettingsCard(settings: settings),
                  ),
                ),

                const SizedBox(height: 24),
                _buildSectionTitle('Lighting Setup'),
                const SizedBox(height: 12),
                LightingSetupCard(lightingSetup: analysis.lightingSetup),

                const SizedBox(height: 24),
                _buildSectionTitle('Camera Position'),
                const SizedBox(height: 12),
                CameraPositionCard(cameraPosition: analysis.cameraPosition),

                if (!provider.isBeginnerMode) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Pro Mode'),
                  const SizedBox(height: 12),
                  ProModePanel(proModeData: analysis.proModeData),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Analyzing your photo...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few seconds',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Analysis Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Provider.of<AnalysisProvider>(context, listen: false)
                    .clearError();
                Navigator.pop(context);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Analysis Selected',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select a photo to analyze',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceImage(String imagePath) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: File(imagePath).existsSync()
            ? Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.image,
                  size: 64,
                  color: Colors.grey[500],
                ),
              ),
      ),
    );
  }

  Widget _buildBeginnerTip(String tip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.green.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}