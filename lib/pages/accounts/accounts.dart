import 'package:flutter/material.dart';
import 'package:one/widgets/main_drawer.dart';
import 'package:provider/provider.dart';
import 'package:one/pages/accounts/accounts_chart.dart';
import 'package:one/provide/authorize_provide.dart';

class Accounts extends StatefulWidget {
  static const String sName = "/accounts";

  const Accounts({super.key});
  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthorizeProvide>(builder: (context, auth, child) {
      return auth.authorized
          ? const AccountsChart()
          : Scaffold(
              drawer: MainDrawer(),
              body: Center(
                child: FilledButton(
                  child: const Text(
                    "指纹或面部认证",
                  ),
                  onPressed: () => auth.biometricsAuth(context, mounted),
                ),
              ),
            );
    }

        //  // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
