import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Current Firebase user (null if not signed in).
  static User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  static bool get isSignedIn => _auth.currentUser != null;

  /// Send OTP to the given phone number.
  /// [onCodeSent] is called with verificationId and resendToken when the SMS is dispatched.
  /// [onError] is called if verification fails.
  /// [onAutoVerified] is called if the device auto-verifies (Android only).
  static Future<void> sendOtp({
    required String phone,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function(PhoneAuthCredential credential) onAutoVerified,
    int? forceResendingToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: '+91$phone',
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Auto-verification (Android only)
        onAutoVerified(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(e.message ?? 'Verification failed. Please try again.');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (_) {
        // Auto-retrieval timed out — user must enter OTP manually
      },
    );
  }

  /// Verify the OTP code against the verificationId.
  /// Returns the UserCredential if sign-in succeeds, null otherwise.
  static Future<UserCredential?> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Sign in with an auto-verified credential (Android).
  static Future<UserCredential?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException {
      return null;
    }
  }

  /// Sign out the current user.
  static Future<void> signOut() async {
    await _auth.signOut();
  }
}
