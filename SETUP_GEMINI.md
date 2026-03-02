# Gemini API Setup for Paralumine

Paralumine now uses Google's Gemini AI for advanced image analysis and photography guidance.

## Setup Instructions

### 1. Get Your Gemini API Key
1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Create a new API key
4. Copy the generated API key

### 2. Configure the API Key
1. Open `lib/config/api_config.dart`
2. Replace `YOUR_GEMINI_API_KEY_HERE` with your actual API key:

```dart
class ApiConfig {
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  static bool get isConfigured => geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';
}
```

### 3. Build and Run
```bash
flutter pub get
flutter run
```

## What's New with Gemini Integration

### Advanced Image Analysis
- **Intelligent Camera Settings**: Gemini analyzes lighting, composition, and technical aspects to suggest optimal camera settings
- **Lighting Setup Analysis**: Detailed breakdown of lighting patterns and professional setup recommendations
- **Camera Position Guidance**: Precise positioning advice with angles and distances
- **Beginner-Friendly Tips**: Contextual advice tailored to the skill level
- **Pro Mode Features**: Advanced analysis including color temperature, sharpness scores, and post-processing suggestions

### Features Powered by Gemini
1. **Smart Camera Settings Detection**: Multiple setting options for different equipment levels
2. **Professional Lighting Analysis**: Rembrandt, Loop, High Key, and other lighting pattern recognition
3. **Composition Analysis**: Camera height, distance, and angle recommendations
4. **Equipment Suggestions**: Lens recommendations based on the analyzed photo
5. **Post-Processing Guidance**: Editing suggestions specific to the image type

### API Usage
The app sends images to Gemini with a comprehensive prompt that analyzes:
- Lighting conditions (direction, quality, color temperature)
- Composition and camera angles
- Technical settings needed to recreate the look
- Depth of field and focus characteristics
- Color grading and mood
- Special techniques used

### Error Handling
- Graceful fallback to basic analysis if Gemini API is unavailable
- Clear error messages for API configuration issues
- Offline-capable with cached analysis when possible

## Important Notes
- Keep your API key secure and never commit it to version control
- Monitor your API usage at [Google Cloud Console](https://console.cloud.google.com/)
- Gemini API has usage quotas - check your limits in the console
- Images are processed securely and not stored by Google beyond the API call

## Troubleshooting
- **"API key not configured"**: Check that you've set your API key in `api_config.dart`
- **"API quota exceeded"**: Check your usage limits in Google Cloud Console
- **"Network error"**: Ensure you have internet connectivity for Gemini API calls