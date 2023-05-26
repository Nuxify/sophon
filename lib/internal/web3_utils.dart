import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:eth_sig_util/eth_sig_util.dart';

/// Get block time by [chainId]
/// Returned time is in milliseconds (ms)
int getBlockTime(int chainId) {
  // TODO: specify more blocktime based from chains
  switch (chainId) {
    default:
      // for ethereum and related networks, default blocktime is 12 seconds
      return 12000;
  }
}

/// Get network name by [chainId]
String getNetworkName(int chainId) {
  // TODO: you can specify more chains
  switch (chainId) {
    case 1:
      return 'Ethereum Mainnet';
    case 3:
      return 'Ropsten Testnet';
    case 4:
      return 'Rinkeby Testnet';
    case 5:
      return 'Goerli Testnet';
    case 42:
      return 'Kovan Testnet';
    case 137:
      return 'Polygon Mainnet';
    default:
      return 'Unknown Chain';
  }
}

enum LoginType {
  metaMask,
  google,
}

Uint8List bigIntToBytes(BigInt value, int length) {
  Uint8List result = Uint8List(length);
  for (int i = 0; i < length; i++) {
    result[length - 1 - i] = (value >> (8 * i)).toUnsigned(8).toInt();
  }
  return result;
}

String signStringWithEIP191(String message, String privateKeyHex) {
  Uint8List messageBytes = Uint8List.fromList(utf8.encode(message));
  Uint8List privateKeyBytes = Uint8List.fromList(hex.decode(privateKeyHex));

  ECCurve_secp256k1 curve = ECCurve_secp256k1();
  ECPrivateKey privateKey =
      ECPrivateKey(BigInt.parse(hex.encode(privateKeyBytes), radix: 16), curve);

  ECDSASigner signer = ECDSASigner(HMac(SHA256Digest(), 64) as Digest?);
  signer.init(true, PrivateKeyParameter<PrivateKey>(privateKey));

  ECSignature signature = signer.generateSignature(messageBytes) as ECSignature;
  Uint8List rBytes = bigIntToBytes(signature.r, 32);
  Uint8List sBytes = bigIntToBytes(signature.s, 32);

  Uint8List signatureBytes = Uint8List(64);
  signatureBytes.setRange(0, 32, rBytes);
  signatureBytes.setRange(32, 64, sBytes);

  return hex.encode(signatureBytes);
}

String signStringWithEIP712(
  String message,
  String privateKeyHex,
) {
  final List<int> codeUnits = message.codeUnits;
  final Uint8List messageInUint8 = Uint8List.fromList(codeUnits);

  return EthSigUtil.signMessage(
    privateKey: privateKeyHex,
    message: messageInUint8,
  );
}
