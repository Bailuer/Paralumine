import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analysis_provider.dart';
import '../models/photo_analysis.dart';
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
                // Show comparison photos if available, otherwise single photo
                if (analysis.targetImagePath != null) ...[
                  _buildComparisonImages(analysis.referenceImagePath, analysis.targetImagePath!),
                  const SizedBox(height: 24),
                ] else ...[
                  _buildReferenceImage(analysis.referenceImagePath),
                  const SizedBox(height: 24),
                ],
                
                // Show comparison analysis if available
                if (analysis.comparison != null) ...[
                  _buildComparisonAnalysis(analysis.comparison!),
                  const SizedBox(height: 24),
                ],
                
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
                _buildMarkdownText(
                  tip,
                  TextStyle(
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

  Widget _buildComparisonImages(String environmentPath, String targetPath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Photo Comparison'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 Current Environment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: File(environmentPath).existsSync()
                          ? Image.file(
                              File(environmentPath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎯 Target Effect',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade300, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: File(targetPath).existsSync()
                          ? Image.file(
                              File(targetPath),
                              fit: BoxFit.cover,
                              width: double.infinity,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonAnalysis(ComparisonAnalysis comparison) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Transformation Guide'),
        const SizedBox(height: 16),
        
        // Key differences
        _buildComparisonCard(
          title: '🔍 Key Differences',
          icon: Icons.compare,
          color: Colors.orange,
          items: comparison.keyDifferences,
        ),
        const SizedBox(height: 16),
        
        // Step by step guide
        _buildComparisonCard(
          title: '📋 Step-by-Step Guide',
          icon: Icons.list_alt,
          color: Colors.blue,
          items: comparison.stepByStepGuide,
        ),
        const SizedBox(height: 16),
        
        // Equipment and adjustments
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                title: '💡 Lighting Changes',
                content: comparison.lightingChanges,
                color: Colors.amber,
                icon: Icons.wb_incandescent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                title: '📐 Position Adjustments',
                content: comparison.positionAdjustments,
                color: Colors.green,
                icon: Icons.camera_alt,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildInfoCard(
          title: '🛠️ Equipment Needed',
          content: comparison.equipmentNeeded,
          color: Colors.purple,
          icon: Icons.build,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMarkdownText(
                      item,
                      const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required Color color,
    required IconData icon,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
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
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
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

  Widget _buildMarkdownText(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final RegExp boldPattern = RegExp(r'\*\*(.*?)\*\*');
    
    int currentIndex = 0;
    final matches = boldPattern.allMatches(text).toList();
    
    if (matches.isEmpty) {
      // No bold text found, return normal text
      return Text(text, style: baseStyle);
    }
    
    for (final Match match in matches) {
      // Add text before the bold part
      if (match.start > currentIndex) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, match.start),
          style: baseStyle,
        ));
      }
      
      // Add the bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      
      currentIndex = match.end;
    }
    
    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: baseStyle,
      ));
    }
    
    // If no spans were created, fallback to normal text
    if (spans.isEmpty) {
      return Text(text, style: baseStyle);
    }
    
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}