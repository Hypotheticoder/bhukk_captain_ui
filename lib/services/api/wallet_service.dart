import 'package:bhukkdelivery/services/api/api_config.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WalletService {
  static final Dio _dio = ApiConfig.dio;

  /// Initiates a PayU settlement.
  /// Calls /drivers/me/wallet/settle/initiate with the amount.
  /// Returns the PayU params (key, txnid, hash, etc.) for the Checkout SDK.
  static Future<Map<String, dynamic>> initiateSettlement(double amount) async {
    try {
      final response = await _dio.post(
        '/drivers/me/wallet/settle/initiate',
        data: {'amount': amount},
      );

      if (response.statusCode == 200 && response.data != null) {
        debugPrint('[WalletService] Settlement initiate response: ${response.data}');
        return Map<String, dynamic>.from(response.data);
      }
      return {};
    } catch (e) {
      debugPrint('[WalletService] Settlement error: $e');
      rethrow;
    }
  }

  /// Generates hash for the PayU SDK callback.
  /// Called when the SDK requests a hash during checkout.
  static Future<Map<String, dynamic>> generateHash(Map<String, dynamic> hashData) async {
    final String hashName = hashData['hashName'] ?? '';
    final String hashString = hashData['hashString'] ?? '';

    try {
      // 1. Send the raw string to the FastAPI route
      final response = await _dio.post(
        '/drivers/me/wallet/settle/hash',
        data: {
          "hash_string": hashString,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // 2. Extract the scrambled hash created by the backend
        String generatedHash = response.data['hash'];

        // 3. Return it in a format the UI can pass to PayU
        return {hashName: generatedHash};
      } else {
        debugPrint("Backend failed to generate hash");
        return {hashName: ""};
      }
    } catch (e) {
      debugPrint('Error calling hash API: $e');
      return {hashName: ""};
    }
  }

  /// Requests a withdrawal/payout to the driver's bank account.
  static Future<Map<String, dynamic>> requestWithdrawal({
    required double amount,
    required String accountHolder,
    required String accountNumber,
    required String ifscCode,
    String? upiId,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'account_holder_name': accountHolder,
        'account_number': accountNumber,
        'ifsc_code': ifscCode,
      };
      if (upiId != null && upiId.isNotEmpty) {
        body['upi_id'] = upiId;
      }

      final response = await _dio.post(
        '/drivers/me/wallet/withdraw',
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'status': 'error', 'message': 'Unexpected response'};
    } catch (e) {
      debugPrint('[WalletService] Withdrawal error: $e');
      rethrow;
    }
  }
}
