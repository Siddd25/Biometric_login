import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'main.dart';
import 'package:flutter/services.dart';



class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late FocusNode pinFocusNode = FocusNode();
  final LocalAuthentication auth = LocalAuthentication();


  TextEditingController pin = TextEditingController();
  String currentText = "";
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? savedPin;
  String message = "Checking...";
  int wrongAttempts = 0;
  bool isLockedOut = false;
  int lockoutSecondsRemaining = 0;
  Timer? lockoutTimer;
  bool isValidating = false;

  @override

  void initState() {
    super.initState();
    pinFocusNode = FocusNode();
    _loadSavedPin();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          FocusScope.of(context).requestFocus(pinFocusNode);
          _showKeyboardWorkaround();
        }
      });
    });
  }
  void _showKeyboardWorkaround() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }
  Future<void> _loadSavedPin() async {   //function to load Saved pin from secure storage
    savedPin = await secureStorage.read(key: 'user_pin');
    setState(() {
      message = savedPin == null ? "Set your 4-digit PIN" : "Enter your PIN";
    });
  }


  Future<void> _saveUserPin(String pin) async { //function to load Saved pin from secure storage
    await secureStorage.write(key: 'user_pin', value: pin);
    setState(() {
      savedPin = pin;
      message = "PIN saved. Enter it to login.";
    });

  }
  void _startLockout() { //function to start lockout timer if pin entered incorrectly 3 times
    setState(() {
      isLockedOut = true;
      lockoutSecondsRemaining = 30;

    });

    lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        lockoutSecondsRemaining--;
        message = "Locked out. Try again in $lockoutSecondsRemaining seconds.";

        if (lockoutSecondsRemaining <= 0) {
          timer.cancel();
          isLockedOut = false;
          wrongAttempts = 0;
          message = "Enter your PIN";
        }
      });
    });
  }

  Future<void> _validateOrSavePin(String enteredPin) async {  //function to Validate pin or save it if not set
    if (isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Too many wrong attempts. Please wait.")),
      );
      return;
    }
    if (savedPin == null) {
      await _saveUserPin(enteredPin);
      pin.clear();
    } else if (enteredPin == savedPin) {
      setState(() {
        message = "Enter your PIN";
        wrongAttempts = 0;
      });
      pin.clear();



      // Navigate to home screen or unlock app
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ));
    }
    else {
      wrongAttempts++;
      pin.clear();

      if (wrongAttempts >= 3) {
        _startLockout();
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(" ❌ Incorrect Pin entered, please try again."),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );


      }
    }
  }

  @override


  Future<void> authenticate() async {

    bool hasBiometricSupport = await auth.isDeviceSupported();     // checks hardware support
    bool canUseBiometrics    = await auth.canCheckBiometrics;
    if (!hasBiometricSupport || !canUseBiometrics) {
      // Device doesn't support biometrics OR no biometric enrolled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Biometric authentication not available on this device."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (message == "Set your 4-digit PIN") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please set your PIN first"),
          duration: Duration(seconds: 2),
        ),
      );
      return; // Don't proceed if PIN is not set
    }
    final isAvailable = await auth.canCheckBiometrics;
    if (!isAvailable) return;

    final didAuthenticate = await auth.authenticate(

      localizedReason: 'Please authenticate to login',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
        sensitiveTransaction: true,
      ),
    );

    if (didAuthenticate) {
      // Proceed to home screen
      setState(() {
        message="Enter your PIN";
        wrongAttempts = 0;
      });
      Navigator.push(context, MaterialPageRoute(
        builder: (context) =>  MyHomePage(),
      ));

    } else {
      print("Authentication failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login"),
        centerTitle: true,
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            SizedBox(height: 100),
            Center(
                child:Text(message, style: const TextStyle(fontSize: 18))),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: PinCodeTextField(
                enabled: !isLockedOut,
                focusNode: pinFocusNode,
                autoFocus: false,
                keyboardType: TextInputType.number,
                controller: pin,
                length: 4,
                obscureText: true,
                animationType: AnimationType.fade,

                animationDuration: const Duration(milliseconds: 300),
                onTap: () {
                  FocusScope.of(context).requestFocus(pinFocusNode);
                  _showKeyboardWorkaround();
                },
                pinTheme:  PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 50,
                  fieldWidth: 50,

                  // Same fill color for all states
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,

                  // Same border color (black) for all states
                  activeColor: Colors.black,
                  selectedColor: Colors.black,
                  inactiveColor: Colors.black,

                  borderWidth: 1.5,
                ),
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                onChanged: (value) {
                  setState(() {
                    currentText = value;
                  });

                },
                onCompleted: _validateOrSavePin,

                appContext: context,

              ),
            ),

            const SizedBox(height: 20),
            Center(child:Text("Or",
                style: TextStyle(fontSize: 15))),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLockedOut?null:authenticate,
              icon: const Icon(Icons.fingerprint),
              label: const Text("Use Fingerprint"),
            )
          ],
        ),
      ),
    );
  }
  @override
  void dispose() {
    pin.dispose();
    pinFocusNode.dispose();
    lockoutTimer?.cancel(); // cleanup
    super.dispose();
  }
}

