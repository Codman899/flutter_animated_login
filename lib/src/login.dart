import 'package:flutter/material.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';
import 'package:toastification/toastification.dart';

import 'utils/login_data.dart';
import 'utils/login_provider.dart';
import 'utils/signup_data.dart';
import 'widget/button.dart';
import 'widget/email_field.dart';
import 'widget/phone_field.dart';

/// The callback triggered after login
/// The result is an error message, callback successes if message is null
typedef LoginCallback = Future<String?>? Function(LoginData);

/// The callback triggered after signup
/// The result is an error message, callback successes if message is null
typedef SignupCallback = Future<String?>? Function(SignupData);

/// If the callback returns true, the additional data card is shown
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

typedef ProviderAuthCallback = Future<String?>? Function();

class FlutterAnimatedLogin extends StatefulWidget {
  final LoginCallback? onLogin;
  final SignupCallback? onSignup;
  final TextEditingController? controller;
  final LoginConfig config;
  final Widget? headerWidget;
  final Widget? footerWidget;
  final List<LoginProvider>? providers;
  const FlutterAnimatedLogin({
    super.key,
    this.onLogin,
    this.onSignup,
    this.controller,
    this.config = const LoginConfig(),
    this.headerWidget,
    this.footerWidget,
    this.providers,
  });

  @override
  State<FlutterAnimatedLogin> createState() => _FlutterAnimatedLoginState();
}

class _FlutterAnimatedLoginState extends State<FlutterAnimatedLogin> {
  late TextEditingController _textController;
  final ValueNotifier<bool> _isPhoneNotifier = ValueNotifier(false);
  bool _isStartTyping = false;
  final ValueNotifier<bool> _isFormValidNotifier = ValueNotifier(false);

  @override
  void initState() {
    _textController = widget.controller ?? TextEditingController();
    _textController.addListener(() {
      final text = _textController.text;
      if (text.isNotEmpty) {
        /// Check if the text is a international phone number
        _isPhoneNotifier.value =
            text.contains(RegExp(r'^[+]?[0-9]+$')) && text.length > 5;
      } else if (text.isEmpty || text.contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
        _isPhoneNotifier.value = false;
      }
      if (_textController.text.isNotEmpty) {
        _isStartTyping = true;
      }
      _isFormValidNotifier.value =
          text.contains(RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'));
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _isPhoneNotifier.dispose();
    _isFormValidNotifier.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final phoneConfig = widget.config.phoneTextFiled;
    final emailConfig = widget.config.emailTextFiled;
    return PageWidget(
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.headerWidget ??
              TitleWidget(
                title: widget.config.title,
                subtitle: widget.config.subtitle,
              ),
          ValueListenableBuilder(
            valueListenable: _isPhoneNotifier,
            builder: (context, isPhone, child) {
              return isPhone
                  ? PhoneField(
                      controller: _textController,
                      isFormValidNotifier: _isFormValidNotifier,
                      phoneConfig: phoneConfig,
                    )
                  : EmailField(
                      autofocus: _isStartTyping,
                      controller: _textController,
                      isFormValidNotifier: _isFormValidNotifier,
                      emailConfig: emailConfig,
                    );
            },
          ),
          const SizedBox(height: 20),
          SignInButton(
            formNotifier: _isFormValidNotifier,
            onPressed: () async {
              if (widget.onLogin == null) {
                final result = await widget.onLogin!(LoginData(
                  name: _textController.text,
                  password: null,
                ));
                if (result != null && context.mounted) {
                  toastification.show(
                    context: context,
                    title: Text(result),
                    type: ToastificationType.error,
                  );
                }
              }
              return null;
            },
            config: widget.config,
            constraints: constraints,
          ),
          widget.footerWidget ?? OAuthWidget(providers: widget.providers),
        ],
      ),
    );
  }
}
