# OTP Auto-Fill Implementation Guide

This document explains the technical implementation of the OTP (One-Time Password) auto-fill logic in the PGezy mobile application.

## 1. Core Dependencies

The implementation relies on two primary Flutter packages:

*   **`pinput`**: A highly customizable library for creating the OTP input field UI (the digit boxes).
*   **`otp_autofill`**: Used to listen for incoming SMS messages and automatically extract the OTP code using the SMS User Consent API (on Android).

```yaml
dependencies:
  pinput: ^latest
  otp_autofill: ^4.1.0
```

## 2. Key Files & Changes

The logic is primarily implemented in:
`/widget/unified_otp_screen.dart`

### A. Controller Initialization
We use `OTPTextEditController` which extends the standard `TextEditingController` but adds SMS listening capabilities.

```dart
// Declared in State class
late OTPTextEditController _otpAutoController;

@override
void initState() {
  super.initState();
  
  // Setup OTP auto-fill
  _otpAutoController = OTPTextEditController(
    codeLength: 6,
    onCodeReceive: (code) {
      if (!mounted) return;
      setState(() {
        otpController.text = code; // Update the UI controller
      });
      // Automatically verify once code is received
      if (isOTPSend && orderId.isNotEmpty && code.length == 6) {
        _verifyOTP();
      }
    },
  )..startListenUserConsent((code) {
    // Regex to extract 6 digits from the SMS body
    final exp = RegExp(r'(\d{6})');
    return exp.stringMatch(code ?? '') ?? '';
  });
}
```

### B. UI Integration (Pinput)
The `Pinput` widget is linked to the `otpController`. When `otp_autofill` updates the text, the `Pinput` boxes reflect it immediately.

```dart
Pinput(
  length: 6,
  controller: otpController, // Linked controller
  keyboardType: TextInputType.number,
  onCompleted: (pin) {
    _verifyOTP(); // Manual completion trigger
  },
)
```

## 3. How the Auto-Fill Workflow Works

1.  **Request OTP**: The user enters their mobile number and clicks "Send OTP".
2.  **Start Listening**: Once the server confirms the OTP is sent (`isOTPSend = true`), the app starts listening for the SMS.
3.  **SMS Arrival**: When the SMS arrives on the device, the Android system detects it.
4.  **User Consent**: A system dialog (bottom sheet) usually appears asking the user for permission to share the SMS content with the app (this is the "User Consent" flow which is more secure than reading all SMS).
5.  **Extraction**: Once allowed, the `otp_autofill` package uses the Regex provided (`\d{6}`) to find the 6-digit number in the text.
6.  **Auto-Fill & Verify**: The code is passed to `onCodeReceive`, which updates the text field and triggers the `_verifyOTP()` function automatically, providing a seamless "Zero-touch" login experience.

## 4. Why this implementation?

*   **User Experience**: Users don't have to switch apps to copy the code or memorize it.
*   **Security**: Uses the User Consent API, which doesn't require high-risk "READ_SMS" permissions in the Android Manifest, making it more privacy-friendly.
*   **Reliability**: Works across most modern Android versions and handles various SMS formats as long as they contain a 6-digit code.

---
*Created for PGezy Development Documentation*
