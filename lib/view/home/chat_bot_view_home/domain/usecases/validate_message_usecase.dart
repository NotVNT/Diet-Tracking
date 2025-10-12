/// Use case for validating message input
class ValidateMessageUseCase {
  /// Execute validation
  ValidationResult execute(String message) {
    final trimmed = message.trim();
    
    if (trimmed.isEmpty) {
      return ValidationResult.failure("Tin nhắn không được để trống");
    }
    
    if (_hasLineBreak(trimmed)) {
      return ValidationResult.failure("Tin nhắn không được chứa xuống dòng");
    }
    
    return ValidationResult.success(trimmed);
  }
  
  /// Checks if the input contains any line break characters
  bool _hasLineBreak(String value) {
    return value.contains('\n') || value.contains('\r');
  }
}

/// Result class for message validation
class ValidationResult {
  final bool isValid;
  final String? validMessage;
  final String? error;

  ValidationResult._({
    required this.isValid,
    this.validMessage,
    this.error,
  });

  factory ValidationResult.success(String validMessage) {
    return ValidationResult._(
      isValid: true,
      validMessage: validMessage,
    );
  }

  factory ValidationResult.failure(String error) {
    return ValidationResult._(
      isValid: false,
      error: error,
    );
  }
}
