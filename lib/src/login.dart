import 'package:flutter/material.dart';
import 'package:flutter_animated_login/src/forgot.dart';

import 'utils/extension.dart';
import 'utils/login_config.dart';
import 'utils/login_data.dart';
import 'utils/login_provider.dart';
import 'utils/page_config.dart';
import 'utils/signup_data.dart';
import 'utils/verify_config.dart';
import 'verify.dart';
import 'widget/button.dart';
import 'widget/email_phone_field.dart';
import 'widget/oauth.dart';
import 'widget/page.dart';
import 'widget/password_field.dart';
import 'widget/title.dart';

/// The callback triggered your login logic
/// The result is an error message, callback successes if message is null
typedef LoginCallback = Future<String?>? Function(LoginData);

/// The callback triggered your signup logic
/// The result is an error message, callback successes if message is null
typedef SignupCallback = Future<String?>? Function(SignupData);

/// If the callback returns true, the additional data card is shown
typedef ProviderNeedsSignUpCallback = Future<bool> Function();

/// The callback triggered your auth logic for the provider
typedef ProviderAuthCallback = Future<String?>? Function();

/// The callback triggered your OTP verification logic
typedef VerifyCallback = Future<String?>? Function(LoginData);

/// The callback triggered your OTP resend logic
typedef ResendOtpCallback = Future<String?>? Function(LoginData);

/// Signature of callbacks that have no arguments and return no data.
typedef VoidCallback = void Function();

///Signature of callbacks that have no arguments and return no data.
typedef Recovercallback = void Function();

class FlutterAnimatedLogin extends StatefulWidget {
  /// The callback triggered your login logic
  final LoginCallback? onLogin;

  /// The callback triggered your signup logic
  final SignupCallback? onSignup;

  /// [VerifyCallback] triggered your OTP verification logic
  /// The result is an error message, callback successes if message is null
  final VerifyCallback? onVerify;

  /// [ResendOtpCallback] triggered your OTP resend logic
  final ResendOtpCallback? onResendOtp;

  /// The configuration for the login text field
  final LoginConfig loginConfig;

  /// The list of login providers for the oauth
  final List<LoginProvider>? providers;

  /// The login type, default is [LoginType.loginWithOTP]
  final LoginType loginType;

  /// The configuration for the verify page
  final VerifyConfig verifyConfig;

  /// The terms and conditions for the login/signup page
  final TextSpan? termsAndConditions;

  /// [PageConfig] for the page widget to customize the page.
  final PageConfig config;

  const FlutterAnimatedLogin({
    super.key,
    this.onLogin,
    this.onSignup,
    this.onVerify,
    this.onResendOtp,
    this.loginConfig = const LoginConfig(),
    this.providers,
    this.loginType = LoginType.loginWithOTP,
    this.verifyConfig = const VerifyConfig(),
    this.termsAndConditions,
    this.config = const PageConfig(),
  });

  @override
  State<FlutterAnimatedLogin> createState() => _FlutterAnimatedLoginState();
}

class _FlutterAnimatedLoginState extends State<FlutterAnimatedLogin> {
  /// The text controller for the text field if not provided by the user
  late TextEditingController _textController;

  /// The text controller for the password field if not provided by the user
  late TextEditingController _passwordController;

  /// The notifier for the notifying if the text is a phone number
  final ValueNotifier<bool> _isPhoneNotifier = ValueNotifier(false);

  /// The notifier for the notifying if the form is valid
  final ValueNotifier<bool> _isFormValidNotifier = ValueNotifier(false);

  /// The notifier for the next page
  final ValueNotifier<int> _nextPageNotifier = ValueNotifier(0);

  @override
  void initState() {
    final controller = widget.loginConfig.textFiledConfig.controller;
    final passwordController = widget.loginConfig.passwordConfig.controller;
    _passwordController = passwordController ?? TextEditingController();
    _textController = controller ?? TextEditingController();
    final text = _textController.text;
    _isPhoneNotifier.value = text.isPhoneNumber || text.isIntlPhoneNumber;
    _isFormValidNotifier.value = text.isEmail || _isPhoneNotifier.value;
    // Sync the login field text with the forgot password field
    _textController.addListener(() {
      final text = _textController.text;
      if (text.isNotEmpty) {
        /// Check if the text is a international phone number
        _isPhoneNotifier.value = text.isIntlPhoneNumber;
      } else if (text.isEmptyOrNull ||
          text.contains(RegExp(r'^[a-zA-Z0-9]+$'))) {
        _isPhoneNotifier.value = false;
      }
      _isFormValidNotifier.value = text.isEmail || _isPhoneNotifier.value;
    });
    if (widget.loginType == LoginType.loginWithPassword) {
      _passwordController.addListener(() {
        final password = _passwordController.text;
        final text = _textController.text;
        _isFormValidNotifier.value = password.isNotEmptyOrNull &&
            (text.isNotEmptyOrNull && (text.isEmail || _isPhoneNotifier.value));
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _isPhoneNotifier.dispose();
    _isFormValidNotifier.dispose();
    _nextPageNotifier.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _nextPageNotifier,
      builder: (context, nextPage, child) {
        switch (nextPage) {
          case 0:
            return _LoginPage(
              config: widget.loginConfig,
              loginType: widget.loginType,
              onLogin: widget.onLogin,
              onVerify: widget.onVerify,
              providers: widget.providers,
              isPhoneNotifier: _isPhoneNotifier,
              isFormValidNotifier: _isFormValidNotifier,
              nextPageNotifier: _nextPageNotifier,
              textController: _textController,
              termsAndConditions: widget.termsAndConditions,
              passwordController: _passwordController,
              pageConfig: widget.config,
            );
          case 1:
            return FlutterAnimatedVerify(
              onVerify: widget.onVerify,
              name: _textController.text,
              nextPageNotifier: _nextPageNotifier,
              config: widget.verifyConfig,
              onResendOtp: widget.onResendOtp,
              termsAndConditions: widget.termsAndConditions,
              pageConfig: widget.config,
            );
          case 2: // for forgot password
            return ForgotPassword(
              onRecover: () {},
              nextPageNotifier: _nextPageNotifier,
              textController: _textController,
              //
              isFormValidNotifier: _isFormValidNotifier,
              config: widget.loginConfig, pageConfig: widget.config,

              // onRecover: onRecover
            );
          default:
            return const Center(
              child: FlutterLogo(size: 100),
            );
        }
      },
    );
  }
}

enum LoginType { loginWithOTP, loginWithPassword }

class _LoginPage extends StatelessWidget {
  final LoginConfig config;
  final TextSpan? termsAndConditions;
  final LoginType loginType;
  final LoginCallback? onLogin;
  final VerifyCallback? onVerify;
  final List<LoginProvider>? providers;
  final TextEditingController textController;
  final TextEditingController passwordController;

  final ValueNotifier<bool> isPhoneNotifier;
  final ValueNotifier<bool> isFormValidNotifier;
  final ValueNotifier<int> nextPageNotifier;

  /// [PageConfig] for the page widget to customize the page.
  final PageConfig pageConfig;

  const _LoginPage({
    this.onLogin,
    this.onVerify,
    this.providers,
    required this.config,
    required this.loginType,
    required this.isPhoneNotifier,
    required this.isFormValidNotifier,
    required this.nextPageNotifier,
    required this.textController,
    required this.passwordController,
    this.termsAndConditions,
    this.pageConfig = const PageConfig(),
  });

  @override
  Widget build(BuildContext context) {
    final textConfig = config.textFiledConfig;
    final passConfig = config.passwordConfig;

    final isLoginWithOTP = loginType == LoginType.loginWithPassword;
    return PageWidget(
      config: pageConfig,
      builder: (context, constraints) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          config.header ??
              config.titleWidget ??
              TitleWidget(
                title: config.title,
                subtitle: config.subtitle,
                child: config.logo,
              ),
          EmailPhoneTextField(
            controller: textController,
            config: textConfig,
            isFormValidNotifier: isFormValidNotifier,
            isPhoneNotifier: isPhoneNotifier,
          ),
          if (!isLoginWithOTP) ...[
            // if (!isPhoneNotifier.value) ...[
            const SizedBox(height: 20),
            PasswordTextField(
              config: passConfig,
              isFormValidNotifier: isFormValidNotifier,
              controller: passwordController,
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              alignment: Alignment.centerRight,
              child: MaterialButton(
                onPressed: () {
                  String? writtenEmail = textController.text;
                  if (writtenEmail.isEmail) {
                    nextPageNotifier.value = 2;
                  } else {
                    context.error("emptyemail",
                        description: "Please enter a email");
                  }
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ),
            )
          ],
          const SizedBox(height: 40),
          SignInButton(
            formNotifier: isFormValidNotifier,
            onPressed: () async {
              if (onLogin != null) {
                final result = await onLogin?.call(LoginData(
                  name: textController.text,
                  secret: passwordController.text,
                ));
                if (context.mounted) {
                  if (result.isNotEmptyOrNull) {
                    context.error("Error", description: result);
                  } else {
                    nextPageNotifier.value = 1;
                  }
                }
              }
              return null;
            },
            config: config,
            constraints: constraints,
            buttonText: 'Sign In',
          ),
          const SizedBox(height: 7),
          MaterialButton(
            onPressed: () {},
            child: const Text(
              'SIGNUP',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          OAuthWidget(
            providers: providers,
            termsAndConditions: termsAndConditions,
            footerWidget: config.footer,
          ),
        ],
      ),
    );
  }
}
