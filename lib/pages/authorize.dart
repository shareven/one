import 'package:flutter/material.dart';
import 'package:one/provider/authorize_provider.dart';
import 'package:provider/provider.dart';
import 'package:one/widgets/main_drawer.dart';

class Authorize extends StatefulWidget {
  static const String sName = "/authorize";

  const Authorize({super.key});
  @override
  State<Authorize> createState() => _AuthorizeState();
}

class _AuthorizeState extends State<Authorize> {
  @override
  Widget build(BuildContext context) {
    context.read<AuthorizeProvide>().biometricsAuth(context, mounted);
    return Scaffold(
      appBar: AppBar(title: const Text("指纹或面部认证")),
      drawer: const MainDrawer(),
      body: Center(
        child: FilledButton(
          child: const Text(
            "指纹或面部认证",
          ),
          onPressed: () =>
              context.read<AuthorizeProvide>().biometricsAuth(context, mounted),
        ),
      ),
    );
  }
}
