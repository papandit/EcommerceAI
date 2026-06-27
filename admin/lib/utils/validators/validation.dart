/// VALIDATION CLASS
class TValidator {
  /// Empty Text Validation
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

//==============================================================================
  final RegExp facebookRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?facebook\.com\/[a-zA-Z0-9(.?)?]',
    caseSensitive: false,
  );
  final RegExp twitterRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?twitter\.com\/[a-zA-Z0-9_]{1,15}$',
    caseSensitive: false,
  );
  final RegExp instagramRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?instagram\.com\/[a-zA-Z0-9_.]+$',
    caseSensitive: false,
  );
  // YouTube URL validation regex
  final RegExp youtubeRegExp = RegExp(
    r'^(https?:\/\/)?(www\.)?(youtube\.com\/(channel\/|user\/|c\/|watch\?v=|playlist\?list=)|youtu\.be\/)[a-zA-Z0-9_\-]{1,}$',
    caseSensitive: false,
  );
  String? validateSocialMediaUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
// X (Twitter rebranded) URL validation regex
    final RegExp xRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?x\.com\/[a-zA-Z0-9_]{1,15}\/status\/\d+\?s=\d+$',
      caseSensitive: false,
    );
    if (facebookRegExp.hasMatch(value) ||
        twitterRegExp.hasMatch(value) ||
        instagramRegExp.hasMatch(value) ||
        youtubeRegExp.hasMatch(value) ||
        xRegExp.hasMatch(value)) {
      return null; // Valid URL for Facebook, Twitter, or Instagram
    } else {
      return 'Please enter a valid Facebook, Twitter, Instagram, or YouTube URL';
    }
  }

//==============================================================================
  /// Username Validation
  static String? validateUsername(String? username) {
    if (username == null || username.isEmpty) {
      return 'Username is required.';
    }

    // Define a regular expression pattern for the username.
    const pattern = r"^[a-zA-Z0-9_-]{3,20}$";

    // Create a RegExp instance from the pattern.
    final regex = RegExp(pattern);

    // Use the hasMatch method to check if the username matches the pattern.
    bool isValid = regex.hasMatch(username);

    // Check if the username doesn't start or end with an underscore or hyphen.
    if (isValid) {
      isValid = !username.startsWith('_') &&
          !username.startsWith('-') &&
          !username.endsWith('_') &&
          !username.endsWith('-');
    }

    if (!isValid) {
      return 'Username is not valid.';
    }

    return null;
  }

  ///Digit Validation
  static String? validateDigit(String? value) {
    if (value == null || value.isEmpty) {
      return 'Percentage is required.';
    }

    final numberRegExp = RegExp(r'^\d+\.?\d{0,2}$');
    // final numberRegExp = RegExp(r'^\d\?\d{0,3}$');

    if (!numberRegExp.hasMatch(value)) {
      return 'Invalid Percentage format (00.00 digits are required).';
    }

    return null;
  }

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }

    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check for uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }

    // Check for numbers
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number.';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  /// Phone Number Validation
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required.';
    }

    // Regular expression for phone number validation (assuming a 10-digit US phone number format)
    final phoneRegExp = RegExp(r'^\d{12}$');

    if (!phoneRegExp.hasMatch(value)) {
      return 'Invalid phone number format (12 digits required).';
    }

    return null;
  }

// Add more custom validators as needed for your specific requirements.
}
