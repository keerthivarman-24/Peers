class Validators {
  static String? requiredText(String v, {String message = 'Required'}) {
    if (v.trim().isEmpty) return message;
    return null;
  }

  static bool isValidUrl(String input) {
    final s = input.trim();
    if (s.isEmpty) return true;
    final uri = Uri.tryParse(s);
    return uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}

