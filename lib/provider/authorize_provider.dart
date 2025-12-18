import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:one/utils/navigator_util.dart';
import 'package:one/utils/utils.dart';

class AuthorizeProvide with ChangeNotifier {
  bool _authorized = false;
  bool get authorized => _authorized;
  final LocalAuthentication auth = LocalAuthentication();

  ///指纹或面部验证
  Future<void> biometricsAuth(BuildContext context, bool mounted) async {
    bool didAuthemticate = false;
    List<BiometricType> availableBiometrics = [];
    try {
      bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      if (canAuthenticate) {
        availableBiometrics = await auth.getAvailableBiometrics();
      }
      if (availableBiometrics.contains(BiometricType.strong) ||
          availableBiometrics.contains(BiometricType.face)) {
        auth.stopAuthentication();
        didAuthemticate = await auth.authenticate(
          localizedReason: '请验证指纹或面部',
          biometricOnly: true,
        );
      } else {
        showErrorMsg("未添加指纹或面部");
      }
    } on PlatformException catch (e) {
      auth.stopAuthentication();
      showErrorMsg(e.code);
    }

    changeState(didAuthemticate);
    if (didAuthemticate && mounted) {
      NavigatorUtil.goAccounts(context);
    }
  }

  void changeState(bool authed) {
    _authorized = authed;

    notifyListeners();
  }
}
