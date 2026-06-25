import 'dart:convert';
import 'dart:typed_data';

import 'package:core_module/core/constants/core_hive_constants.dart';
import 'package:hive/hive.dart';

abstract class ISecureHive {
  Future<Uint8List> getKey();
}

class SecureHive implements ISecureHive {
  @override
  Future<Uint8List> getKey() async {
    final encryptionBox = await Hive.openBox(CoreHiveBoxName.usersBox);
    String? encryptioKey = encryptionBox.get("encryption_key");
    if(encryptioKey == null) {
      final newKey = Hive.generateSecureKey();
      await encryptionBox.put("encryption_key", base64Encode(newKey));
    }
    final key = await encryptionBox.get("encryption_key");
    final encryptionKeyUint8List = base64Url.decode(key!);
    return encryptionKeyUint8List;
  }
}