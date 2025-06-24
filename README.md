# 🔐 Biometric Login App (Flutter)

A Flutter application that allows users to log in securely using either a **4-digit PIN** or **biometric authentication** (fingerprint or face unlock). PINs are securely stored using `flutter_secure_storage`, and biometric authentication is handled using the `local_auth` plugin.

---

## 🚀 Features

- ✅ 4-digit PIN-based login and secure setup
- ✅ Fingerprint / Face Unlock via biometrics
- ✅ Secure local storage of PIN (not in plain text)
- ✅ Lockout for 60 seconds after 3 incorrect attempts
- ✅ Beautiful animated PIN input UI

---

## 📦 Dependencies

These Flutter packages are used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  local_auth: ^2.1.4
  local_auth_android: ^1.0.33
  pin_code_fields: ^8.0.1
  flutter_secure_storage: ^8.0.0

```
## 🛠️ Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/Siddd25/Biometric_login.git
cd Biometric_login
```
### 2. Get Flutter dependencies
```bash
flutter pub get
```
---

### 3. Configure Android for Biometric & Keyboard Support

Open `android/app/src/main/AndroidManifest.xml` and make the following changes:

#### ✅ Inside `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```
#### ✅ Inside `<activity>` tag:
```xml
<activity
    android:name=".MainActivity"
    android:windowSoftInputMode="stateVisible|adjustResize"
    android:exported="true">
```
### 4. Set SDK versions
Inside `android/build.gradle.kts`:
``` xml
android
{
compileSdk = 35
}
```

### 5. Run App on Physical Device
```bash
flutter run
```

### 6. Download Apk from Release section to try out the app on Android Mobile device.








