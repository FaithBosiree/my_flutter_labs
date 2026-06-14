import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String imageSource = "images/question-mark.jpg";

  // Synchronous constructor instantiation as per instructions
  final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  @override
  void initState() {
    super.initState();
    // Load saved credentials when the application starts
    _loadSavedCredentials();
  }

  // Asynchronous retrieval of stored data
  Future<void> _loadSavedCredentials() async {
    String savedUser = await _encryptedPrefs.getString('username');
    String savedPass = await _encryptedPrefs.getString('password');

    if (savedUser.isNotEmpty && savedPass.isNotEmpty) {
      setState(() {
        usernameController.text = savedUser;
        passwordController.text = savedPass;
      });

      // SnackBar-confirming the reloading4
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Previous login name and passwords have been loaded."),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Function to save data to EncryptedSharedPreferences
  Future<void> _saveCredentials() async {
    await _encryptedPrefs.setString('username', usernameController.text);
    await _encryptedPrefs.setString('password', passwordController.text);
  }

  // Function to clear data from EncryptedSharedPreferences
  Future<void> _clearCredentials() async {
    await _encryptedPrefs.clear(); // Or remove specific keys: _encryptedPrefs.setString('username', '');
  }

  // Function to display the AlertDialog
  void _showSaveCredentialsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Credentials"),
          content: const Text("Would you like to save your username and password for the next time you run the application?"),
          actions: [
            TextButton(
              onPressed: () async {
                await _clearCredentials();
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await _saveCredentials();
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Page")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Login Name",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(
              onPressed: () {
                String password = passwordController.text;

                setState(() {
                  if (password == "ASDF") {
                    imageSource = "images/lightbulb.jpg";
                  } else {
                    imageSource = "images/stop.jpg";
                  }
                });

                // Trigger the AlertDialog challenge requirements
                _showSaveCredentialsDialog();
              },
              child: const Text("Login"),
            ),
          ),
          Semantics(
            label: "Login result image",
            child: Image.asset(
              imageSource,
              width: 300,
              height: 300,
            ),
          ),
        ],
      ),
    );
  }
}