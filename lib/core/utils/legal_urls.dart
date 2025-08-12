class LegalUrls {
  // Terms of Service URLs by language
  static const Map<String, String> termsOfServiceUrls = {
    'en': 'https://sites.google.com/view/quiztastic-legal/home/terms-of-service-en',
    'de': 'https://sites.google.com/view/quiztastic-legal/home/terms-of-service-de',
    'fr': 'https://sites.google.com/view/quiztastic-legal/home/terms-of-service-fr',
    'es': 'https://sites.google.com/view/quiztastic-legal/home/terms-of-service-es',
    'ja': 'https://sites.google.com/view/quiztastic-legal/home/terms-of-service-ja',
    'zh': 'https://sites.google.com/view/quiztastic-legal/home/terms-of-service-zh',
  };

  // Privacy Policy URLs by language
  static const Map<String, String> privacyPolicyUrls = {
    'en': 'https://sites.google.com/view/quiztastic-legal/home/privacy-policy-en',
    'de': 'https://sites.google.com/view/quiztastic-legal/home/privacy-policy-de',
    'fr': 'https://sites.google.com/view/quiztastic-legal/home/privacy-policy-fr',
    'es': 'https://sites.google.com/view/quiztastic-legal/home/privacy-policy-es',
    'ja': 'https://sites.google.com/view/quiztastic-legal/home/privacy-policy-ja',
    // Note: Chinese privacy policy URL was not provided, will fallback to English
  };

  // Get Terms of Service URL for a specific language
  static String getTermsOfServiceUrl(String languageCode) {
    return termsOfServiceUrls[languageCode] ?? termsOfServiceUrls['en']!;
  }

  // Get Privacy Policy URL for a specific language
  static String getPrivacyPolicyUrl(String languageCode) {
    return privacyPolicyUrls[languageCode] ?? privacyPolicyUrls['en']!;
  }
}