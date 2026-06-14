import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}


// 1. REPOSITORY PATTERN CLASS

class DataRepository {
  static String loginName = '';

  // Profile Form fields
  static String firstName = '';
  static String lastName = '';
  static String phoneNumber = '';
  static String emailAddress = '';

  static final EncryptedSharedPreferences _encryptedPrefs = EncryptedSharedPreferences();

  // Load variables from EncryptedSharedPreferences asynchronously
  static Future<void> loadData() async {
    // The library returns an empty string if nothing is stored yet, no '??' needed!
    loginName = await _encryptedPrefs.getString('username');
    firstName = await _encryptedPrefs.getString('firstName');
    lastName = await _encryptedPrefs.getString('lastName');
    phoneNumber = await _encryptedPrefs.getString('phoneNumber');
    emailAddress = await _encryptedPrefs.getString('emailAddress');
  }

  // Save variables to EncryptedSharedPreferences asynchronously
  static Future<void> saveData() async {
    await _encryptedPrefs.setString('username', loginName);
    await _encryptedPrefs.setString('firstName', firstName);
    await _encryptedPrefs.setString('lastName', lastName);
    await _encryptedPrefs.setString('phoneNumber', phoneNumber);
    await _encryptedPrefs.setString('emailAddress', emailAddress);
  }
}

// ==========================================
// 2. MATERIAL APP STRUCTURE WITH NAMED ROUTES
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}

// ==========================================
// 3. UPDATED LOGIN PAGE
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String imageSource = "images/question-mark.jpg";

  @override
  void initState() {
    super.initState();
    _initializeRepoAndLoad();
  }

  // Load repository fields on the first page once your app loads
  Future<void> _initializeRepoAndLoad() async {
    await DataRepository.loadData();
    if (DataRepository.loginName.isNotEmpty) {
      setState(() {
        usernameController.text = DataRepository.loginName;
      });

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

  void _showSaveCredentialsDialog(bool isPasswordCorrect) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Credentials"),
          content: const Text("Would you like to save your username and password for the next time you run the application?"),
          actions: [
            TextButton(
              onPressed: () async {
                // Clear or reset stored data on 'No' selection
                DataRepository.loginName = '';
                await DataRepository.saveData();
                if (mounted) {
                  Navigator.of(context).pop();
                  _handlePostLoginNavigation(isPasswordCorrect);
                }
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                DataRepository.loginName = usernameController.text;
                await DataRepository.saveData();
                if (mounted) {
                  Navigator.of(context).pop();
                  _handlePostLoginNavigation(isPasswordCorrect);
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  void _handlePostLoginNavigation(bool isPasswordCorrect) {
    if (isPasswordCorrect) {
      // Show Welcome Back Snackbar message using the login name from the first page
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome Back ${usernameController.text}"),
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate to your new profile page using Named Routes
      Navigator.pushNamed(context, '/profile');
    }
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
                bool isCorrect = (passwordController.text == "ASDF");

                setState(() {
                  if (isCorrect) {
                    imageSource = "images/lightbulb.jpg";
                  } else {
                    imageSource = "images/stop.jpg";
                  }
                });

                _showSaveCredentialsDialog(isCorrect);
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

// ==========================================
// 4. NEW SECOND PAGE: PROFILE PAGE
// ==========================================
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Distribute data from repository directly into fields
    firstNameController.text = DataRepository.firstName;
    lastNameController.text = DataRepository.lastName;
    phoneController.text = DataRepository.phoneNumber;
    emailController.text = DataRepository.emailAddress;

    // Use addListener to save values down to repository whenever text edits occur
    firstNameController.addListener(() {
      DataRepository.firstName = firstNameController.text;
      DataRepository.saveData();
    });
    lastNameController.addListener(() {
      DataRepository.lastName = lastNameController.text;
      DataRepository.saveData();
    });
    phoneController.addListener(() {
      DataRepository.phoneNumber = phoneController.text;
      DataRepository.saveData();
    });
    emailController.addListener(() {
      DataRepository.emailAddress = emailController.text;
      DataRepository.saveData();
    });
  }

  // Universal helper function to check protocols safely using canLaunch / .then() patterns
  void _launchProtocolUrl(String urlString) {
    final Uri urlUri = Uri.parse(urlString);

    // ignore: deprecated_member_use
    canLaunchUrl(urlUri).then((bool itCan) {
      if (itCan) {
        // ignore: deprecated_member_use
        launchUrl(urlUri);
      } else {
        _showUnsupportedSchemeDialog(urlString);
      }
    });
  }

  void _showUnsupportedSchemeDialog(String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Not Supported"),
          content: Text("The URL format '$url' is not supported on this device."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top welcome text showing the username from page 1
            Text(
              "Welcome Back ${DataRepository.loginName}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // First Name Field
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: "First Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Last Name Field
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: "Last Name",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // Phone Number Row with integrated call/text buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      _launchProtocolUrl("tel:${phoneController.text.trim()}");
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      _launchProtocolUrl("sms:${phoneController.text.trim()}");
                    },
                  ),
                ],
              ),
            ),

            // Email Address Row with integrated mailto button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email address",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.mail),
                    onPressed: () {
                      _launchProtocolUrl("mailto:${emailController.text.trim()}");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}