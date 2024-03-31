import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_login/src/utils/extension.dart';
import 'package:material_loading_buttons/material_loading_buttons.dart';

import '../utils/login_provider.dart';
import 'divider.dart';

class OAuthWidget extends StatelessWidget {
  final List<LoginProvider>? providers;
  const OAuthWidget({
    super.key,
    this.providers,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (providers.isNotEmptyOrNull) ...[
          const SizedBox(height: 20),
          const DividerText(),
          const SizedBox(height: 20),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: providers?.map((provider) {
                final index = providers?.indexOf(provider) ?? 0;
                final length = providers?.length ?? 0;
                return Padding(
                  padding:
                      EdgeInsets.only(right: (index == length - 1) ? 0 : 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconAutoLoadingButton.filled(
                        onPressed: () async {
                          final result = await provider.callback.call();
                          if (context.mounted) {
                            if (result.isNotEmptyOrNull) {
                              context.error("Error", description: result);
                            }
                          }
                        },
                        key: Key(provider.label ?? index.toString()),
                        icon: Icon(provider.icon),
                      ),
                      if (provider.label.isNotEmptyOrNull)
                        Text(provider.label ?? ""),
                    ],
                  ),
                );
              }).toList() ??
              [],
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            text: 'By signing in, you agree to the ',
            children: [
              TextSpan(
                text: 'Terms and policy',
                style: TextStyle(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => print('Terms and policy'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => print('Powered by MOHESU'),
          child: const Text('Powered by MOHESU'),
        ),
      ],
    );
  }
}
