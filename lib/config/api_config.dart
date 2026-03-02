class ApiConfig {
  // Replace this with your actual Gemini API key
  // Get your API key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY_HERE';
  
  // Validate if API key is configured
  static bool get isConfigured => geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE';
}