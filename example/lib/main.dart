import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_login/flutter_animated_login.dart';

void main() {
  runApp(const MyApp());
}

ValueNotifier<bool> isDark = ValueNotifier<bool>(true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDark,
      builder: (context, value, child) => MaterialApp(
        title: 'Flutter Animated Login',
        themeMode: value ? ThemeMode.dark : ThemeMode.light,
        theme: value ? ThemeData.dark() : ThemeData.light(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          floatingActionButton: IconButton.filled(
            onPressed: () => isDark.value = !isDark.value,
            icon: value
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
          ),
          body: SingleChildScrollView(
            child: FlutterAnimatedLogin(
              loginType:
                  value ? LoginType.loginWithOTP : LoginType.loginWithPassword,
              onLogin: (loginData) async {
                final result = await Future.delayed(
                  const Duration(seconds: 2),
                  () => '',
                );
                SystemChannels.textInput.invokeMethod('TextInput.hide');
                TextInput.finishAutofillContext();
                return result;
              },
              loginConfig: const LoginConfig(
                title: 'Mohesu Enterprise',
                subtitle: 'Let\'s Sign In',
              ),
              providers: [
                LoginProvider(
                  icon: Icons.reddit,
                  label: 'Reddit',
                  callback: () async {
                    return "";
                  },
                ),
                LoginProvider(
                  icon: Icons.apple,
                  label: 'Apple',
                  callback: () async {
                    return "";
                  },
                ),
                LoginProvider(
                  icon: Icons.facebook,
                  label: 'Facebook',
                  callback: () async {
                    return "";
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
