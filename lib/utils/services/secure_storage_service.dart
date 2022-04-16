import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create storage
const secureStorage = FlutterSecureStorage();

/// If the key doesn't exist, returns "no data" as String type instead of null.
/// Useful for FutureBuilders & functions that require String and not String? type
Future<String> getNonNullSSData(key)async {
  var readData = await secureStorage.read(key: key);
  if(readData == null) return "no data";
  return readData;
}