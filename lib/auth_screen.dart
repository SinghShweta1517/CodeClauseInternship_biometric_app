import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:newproject/home.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum SupportState {
  unknown,
  supported,
  unSupported
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  SupportState supportState = SupportState.unknown;
  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    auth.isDeviceSupported().then((bool isSupported) =>
        setState(() =>
        supportState =
        isSupported ? SupportState.supported : SupportState.unSupported));
    super.initState();
    checkBiometric();
    getAvailableBiometrics();
  }

  Future<void> checkBiometric() async {
    late bool canCheckBiometric;
    try {
      canCheckBiometric = await auth.canCheckBiometrics;
      print("Biometric supported: $canCheckBiometric");
    } on PlatformException catch (e) {
      print(e);
      canCheckBiometric = false;
    }
  }

  Future<void> getAvailableBiometrics() async {
    late List<BiometricType> biometricTypes;
    try {
      biometricTypes = await auth.getAvailableBiometrics();
      print("supported biometric: $BiometricType");
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) {
      return;
    }
    setState(() {
      availableBiometrics = biometricTypes;
    });
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
          localizedReason: "Authenticate with fingerprint or Face ID",
          options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true
          ));
      if (!mounted) {
        return;
      }
      if (authenticated) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const Home()));
      }
    } on PlatformException catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.deepPurple[500]!,
              Colors.deepPurple[400]!,
              Colors.deepPurple[200]!
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 70.0),
            const Padding(
              padding:  EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Text(
                    "Biometric",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                        color: Colors.white
                    ),
                  ),
                  Text(
                    "Authentication !!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: Colors.white
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60,),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[100],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              supportState == SupportState.supported
                                  ? "Biometric Authentication is supported on this device"
                                  : supportState == SupportState.unSupported
                                  ? "Biometric Authentication is not Supported on this device"
                                  : "Checking Biometric support...",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: supportState == SupportState.supported
                                    ? Colors.green
                                    : supportState == SupportState.unSupported
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(" Supported biometric:",
                            style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          const Text("BiometricType.face or BiometricType.fingerprint",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assests/img.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.fill,
                              ),
                              const SizedBox(width: 20.0),
                              ElevatedButton(
                                onPressed: authenticateWithBiometrics,
                                child: const Text("Authenticate",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
