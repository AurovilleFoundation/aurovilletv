import 'package:aurovilletv/ui/widgets/buttons.dart';
import 'package:aurovilletv/utils/theme/styles.dart';
import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _content());
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Text(
              "Oops! We apologize for the inconvenience. An unexpected issue has occurred.",
              style: AppStyle.textStyleRegular,
              textAlign: TextAlign.center,
            ),
            MyTextButton(onPressed: () {}, text: "Login again"),
          ],
        ),
      ),
    );
  }
}
