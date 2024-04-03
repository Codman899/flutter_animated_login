import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';

import '../utils/extension.dart';
import '../utils/login_config.dart';

class EmailPhoneTextField extends StatelessWidget {
  final ValueNotifier<bool> isPhoneNotifier;
  final ValueNotifier<bool> isFormValidNotifier;
  final EmailPhoneTextFiledConfig config;
  final TextEditingController controller;
  const EmailPhoneTextField({
    super.key,
    required this.isPhoneNotifier,
    required this.isFormValidNotifier,
    required this.config,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return ValueListenableBuilder(
      valueListenable: isPhoneNotifier,
      builder: (context, isPhone, child) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: IntlPhoneField(
            controller: controller,
            initialCountryCode: config.initialCountryCode ?? 'IN',
            disableLengthCheck: !isPhone,
            inputFormatters: config.inputFormatters ?? const [],
            prefixIcon: isPhone ? null : const SizedBox.shrink(),
            decoration: config.decoration ??
                InputDecoration(
                  hintText: isPhone
                      ? 'Enter your phone'
                      : 'Enter your email or phone',
                  prefixIconConstraints: !isPhone
                      ? BoxConstraints.tight(const Size(10, 10))
                      : null,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
            style: config.style ??
                textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontSize: 20,
                ),
            dropdownTextStyle: config.dropdownTextStyle ??
                textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                ),
            onChanged: (phone) {
              isFormValidNotifier.value =
                  isPhone ? phone.isValidNumber() : phone.number.isEmail;
              config.onChanged?.call((
                number: phone,
                value: phone.number,
              ));
            },
            onCountryChanged: config.onCountryChanged,
            onEditingComplete: config.onEditingComplete,
            onSaved: (phone) => config.onSaved?.call((
              number: phone,
              value: phone?.number,
            )),
            keyboardType: config.keyboardType ?? TextInputType.emailAddress,
            textInputAction: config.textInputAction ?? TextInputAction.done,
            autofillHints: config.autofillHints ??
                [
                  AutofillHints.email,
                  AutofillHints.telephoneNumber,
                  AutofillHints.telephoneNumberNational,
                ],
            focusNode: config.focusNode,
            autofocus: config.autofocus,
            autovalidateMode: config.autovalidateMode,
            buildCounter: config.buildCounter,
            countries: config.countries,
            cursorColor: config.cursorColor,
            cursorWidth: config.cursorWidth,
            cursorHeight: config.cursorHeight,
            cursorRadius: config.cursorRadius,
            dialogType: config.dialogType,
            enabled: config.enabled,
            dropdownDecoration: config.dropdownDecoration,
            dropdownIcon: config.dropdownIcon,
            dropdownIconPosition: config.dropdownIconPosition,
            expands: config.expands,
            maxLength: config.maxLength,
            flagsButtonMargin: config.flagsButtonMargin,
            flagsButtonPadding: config.flagsButtonPadding,
            formFieldKey: config.formFieldKey,
            initialValue: config.initialValue,
            invalidMessage: config.invalidMessage,
            keyboardAppearance: config.keyboardAppearance,
            languageCode: config.languageCode,
            magnifierConfiguration: config.magnifierConfiguration,
            maxLengthEnforcement: config.maxLengthEnforcement,
            maxLines: config.maxLines,
            minLines: config.minLines,
            obscureText: config.obscureText,
            onSubmitted: config.onSubmitted,
            onTap: config.onTap,
            pickerDialogStyle: config.pickerDialogStyle,
            readOnly: config.readOnly,
            showCountryFlag: config.showCountryFlag,
            showCursor: config.showCursor,
            showDropdownIcon: config.showDropdownIcon,
            textAlign: config.textAlign,
            textAlignVertical: config.textAlignVertical,
            validator: isPhone
                ? null
                : (value) {
                    final userInput = value?.number ?? "";
                    if (userInput.isEmptyOrNull && value != null) {
                      return 'Please enter your email or phone number';
                    } else if (!(userInput.isEmail) &&
                        !(userInput.isIntlPhoneNumber)) {
                      return 'Please enter a valid email or phone number';
                    }
                    return null;
                  },
          ),
        );
      },
    );
  }
}
