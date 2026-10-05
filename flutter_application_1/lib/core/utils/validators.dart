/// Tiny validators. Each returns an error message, or null when the value is OK.
class Validators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  /// Indian mobile number: 10 digits, starting with 6, 7, 8 or 9.
  static String? phone(String? value) {
    final missing = required(value, field: 'Mobile number');
    if (missing != null) return missing;
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value!.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  /// Firebase Auth needs at least 6 characters, so we use 6 here too.
  static String? password(String? value) {
    final missing = required(value, field: 'Password');
    if (missing != null) return missing;
    if (value!.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    final missing = required(value, field: 'Confirm password');
    if (missing != null) return missing;
    if (value != original) return 'Passwords do not match';
    return null;
  }
}
