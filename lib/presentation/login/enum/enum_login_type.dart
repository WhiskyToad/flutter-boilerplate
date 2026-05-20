enum LoginType { EMAIL, PHONE, GOOGLE, APPLE }

extension ParseLoginType on LoginType {
  String toViewString() {
    if (this == .APPLE || this == .GOOGLE) {
      return '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
    } else {
      return name.toLowerCase();
    }
  }

  String toSignUpString() {
    switch (this) {
      case .EMAIL:
        return 'Sign up with email ';
      case .PHONE:
        return 'Sign up with phone ';
      case .GOOGLE:
        return 'Sign in with Google';
      case .APPLE:
        return 'Sign in with Apple ';
    }
  }

  String toSignInString() {
    switch (this) {
      case .EMAIL:
        return 'Sign in with email ';
      case .PHONE:
        return 'Sign in with phone ';
      case .GOOGLE:
        return 'Sign in with Google';
      case .APPLE:
        return 'Sign in with Apple ';
    }
  }
}
