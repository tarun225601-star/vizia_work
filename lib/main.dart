import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences globalPrefs;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDummyKeyForViziawork",
      appId: "1:23456789:android:abcdef",
      messagingSenderId: "123456789",
      projectId: "viziawork",
      databaseURL: "https://viziawork-default-rtdb.firebaseio.com/",
    ),
  );

  globalPrefs = await SharedPreferences.getInstance();

  runApp(const EndoWorkApp());
}

class EndoWorkApp extends StatelessWidget {
  const EndoWorkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endo Work',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primaryColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF10B981),
        ),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------
// 0. SPLASH SCREEN
// ---------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  void _checkSavedUser() {
    String? phone = globalPrefs.getString('user_phone');

    if (!mounted) return;

    if (phone != null && phone.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PropertyDashboardScreen(userPhone: phone)),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F172A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.domain_rounded, size: 70, color: Color(0xFF10B981)),
            SizedBox(height: 16),
            Text(
              'ENDO WORK',
              style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF10B981)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 1. LOGIN SCREEN
// ---------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _sendOtp() async {
    String phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें')),
      );
      return;
    }

    await globalPrefs.setString('user_phone', phone);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OtpVerificationScreen(phone: phone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, spreadRadius: 5)],
                ),
                child: const Icon(Icons.apartment_rounded, size: 50, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Endo Work',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              const Text(
                'Security Proof Verified Properties & Land Deals',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर दर्ज करें',
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontSize: 18, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: const Color(0xFF0F172A),
                ),
                child: const Text('OTP भेजें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. OTP VERIFICATION SCREEN
// ---------------------------------------------------------
class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() {
    String otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही 4-अंकों का OTP दर्ज करें (Demo: 1234)')));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PropertyDashboardScreen(userPhone: widget.phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP सत्यापन'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('+91 ${widget.phone} पर भेजा गया OTP दर्ज करें:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '1234',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('सत्यापित करें', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. MAIN USER DASHBOARD (DIRECT PROPERTY LISTING FEED)
// ---------------------------------------------------------
class PropertyDashboardScreen extends StatelessWidget {
  final String userPhone;
  const PropertyDashboardScreen({super.key, required this.userPhone});

  @override
  Widget build(BuildContext context) {
    final DatabaseReference propertyRef = FirebaseDatabase.instance.ref().child('properties');

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 22),
            SizedBox(width: 8),
            Text('Endo Work - Properties'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white70),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminControl()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await globalPrefs.clear();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: StreamBuilder(
        stream: propertyRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.domain_disabled_rounded, size: 70, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'अभी कोई प्रॉपर्टी उपलब्ध नहीं है!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'एडमिन पैनल से अपनी पहली Security Proof प्रॉपर्टी लाइव करें।',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminControl()));
                      },
                      icon: const Icon(Icons.add_home_rounded, color: Colors.white),
                      label: const Text('प्रॉपर्टी जोड़ें (एडमिन)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return FirebaseAnimatedList(
            query: propertyRef,
            itemBuilder: (context, snapshotData, animation, index) {
              Map property = snapshotData.value as Map;
              property['key'] = snapshotData.key;

              List<String> imageList = [];
              if (property['images'] != null) {
                imageList = List<String>.from(property['images']);
              }

              return SizeTransition(
                sizeFactor: animation,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📸 फोटो कार्ड / टैप करते ही ज़ूम गैलरी खुलेगी
                      InkWell(
                        onTap: () {
                          if (imageList.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullScreenGalleryScreen(imagePaths: imageList),
                              ),
                            );
                          }
                        },
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: imageList.isNotEmpty
                                  ? _buildImageWidget(imageList.first)
                                  : Container(
                                      height: 200,
                                      color: Colors.grey.shade200,
                                      child: const Center(child: Icon(Icons.apartment, size: 60, color: Colors.grey)),
                                    ),
                            ),
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.photo_library_rounded, color: Colors.white, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${imageList.length} फोटो (देखने के लिए टैप करें)',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Security Proof Verified', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                Text(
                                  property['price'] ?? '',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              property['title'] ?? 'Property Title',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            // 📏 साइज (गज / फीट)
                            if (property['size'] != null && property['size'].toString().isNotEmpty) ...[
                              Row(
                                children: [
                                  const Icon(Icons.straighten_rounded, size: 16, color: Color(0xFF10B981)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'साइज़: ${property['size']}',
                                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                            ],
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    property['location'] ?? '',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // 📝 पूरी डिटेल (Description)
                            if (property['description'] != null && property['description'].toString().isNotEmpty) ...[
                              Text(
                                property['description'],
                                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.3),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showInquiryBottomSheet(context, property['title'] ?? 'Property', userPhone);
                                },
                                icon: const Icon(Icons.send_rounded, size: 18, color: Colors.white),
                                label: const Text('इंक्वायरी भेजें', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🛡️ सुरक्षित इमेज रेंडरर (क्रैश-फ्री)
  static Widget _buildImageWidget(String pathOrBase64) {
    if (pathOrBase64.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.apartment, size: 60, color: Colors.grey)),
      );
    }

    if (pathOrBase64.startsWith('http')) {
      return Image.network(
        pathOrBase64,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
        ),
      );
    }

    if (pathOrBase64.startsWith('/') || pathOrBase64.startsWith('file://')) {
      File imgFile = File(pathOrBase64.replaceFirst('file://', ''));
      if (imgFile.existsSync()) {
        return Image.file(
          imgFile,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      }
    }

    try {
      String cleanBase64 = pathOrBase64;
      if (cleanBase64.contains(',')) {
        cleanBase64 = cleanBase64.split(',').last;
      }
      return Image.memory(
        base64Decode(cleanBase64.trim()),
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: Colors.grey.shade300,
          child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
        ),
      );
    } catch (e) {
      return Container(
        height: 200,
        color: Colors.grey.shade300,
        child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
      );
    }
  }

  // ---------------------------------------------------------
  // INQUIRY FORM BOTTOM SHEET
  // ---------------------------------------------------------
  static void _showInquiryBottomSheet(BuildContext context, String propertyTitle, String defaultPhone) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController(text: defaultPhone);
    final addressController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inquiry for: $propertyTitle', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'आपका नाम',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'आपका पता / लोकेशन (Address)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty || phoneController.text.isEmpty || addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया नाम, मोबाइल नंबर और पता पूरा भरें')));
                      return;
                    }

                    DatabaseReference ref = FirebaseDatabase.instance.ref().child('inquiries');
                    await ref.push().set({
                      'property': propertyTitle,
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                      'timestamp': ServerValue.timestamp,
                    });

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('आपकी इंक्वायरी सफलतापूर्वक एडमिन को भेज दी गई है!'), backgroundColor: Color(0xFF10B981)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('सबमिट करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// 📸 FULL-SCREEN ZOOMABLE GALLERY
// ---------------------------------------------------------
class FullScreenGalleryScreen extends StatefulWidget {
  final List<String> imagePaths;
  const FullScreenGalleryScreen({super.key, required this.imagePaths});

  @override
  State<FullScreenGalleryScreen> createState() => _FullScreenGalleryScreenState();
}

class _FullScreenGalleryScreenState extends State<FullScreenGalleryScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('फोटो ${currentIndex + 1} / ${widget.imagePaths.length}'),
      ),
      body: PageView.builder(
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(0),
              minScale: 1.0,
              maxScale: 5.0,
              child: SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Builder(
                    builder: (context) {
                      String pathOrBase64 = widget.imagePaths[index];
                      if (pathOrBase64.startsWith('http')) {
                        return Image.network(pathOrBase64);
                      } else if (pathOrBase64.startsWith('/') || pathOrBase64.startsWith('file://')) {
                        return Image.file(File(pathOrBase64.replaceFirst('file://', '')));
                      } else {
                        try {
                          String cleanBase64 = pathOrBase64;
                          if (cleanBase64.contains(',')) {
                            cleanBase64 = cleanBase64.split(',').last;
                          }
                          return Image.memory(base64Decode(cleanBase64.trim()));
                        } catch (e) {
                          return const Icon(Icons.broken_image, color: Colors.white, size: 50);
                        }
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. ADMIN CONTROL PANEL (Passcode: Tarun#1)
// ---------------------------------------------------------
class AdminControl extends StatefulWidget {
  const AdminControl({super.key});

  @override
  State<AdminControl> createState() => _AdminControlState();
}

class _AdminControlState extends State<AdminControl> {
  final TextEditingController _passcodeController = TextEditingController();
  bool _isAuthenticated = false;
  final String _adminPasscode = "Tarun#1";

  void _verifyPasscode() {
    if (_passcodeController.text.trim() == _adminPasscode) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('गलत सीक्रेट कोड! एक्सेस अस्वीकृत।'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(title: const Text('Endo Work एडमिन लॉगिन')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.admin_panel_settings, size: 70, color: Color(0xFF10B981)),
                const SizedBox(height: 24),
                const Text('सुपर एडमिन एक्सेस', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                TextField(
                  controller: _passcodeController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    labelText: 'सीक्रेट कोड दर्ज करें',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyPasscode,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: const Text('अनलॉक पैनल', style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Desk (Endo Work)'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.add_photo_alternate_rounded), text: 'Add Property'),
              Tab(icon: Icon(Icons.inbox_rounded), text: 'Inquiries'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddPropertyAdminTab(),
            InquiriesAdminTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// TAB 1: ADD PROPERTY (WITH AUTO COMPRESSION)
// ---------------------------------------------------------
class AddPropertyAdminTab extends StatefulWidget {
  const AddPropertyAdminTab({super.key});

  @override
  State<AddPropertyAdminTab> createState() => _AddPropertyAdminTabState();
}

class _AddPropertyAdminTabState extends State<AddPropertyAdminTab> {
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _sizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  // 📸 ऑटो-कंप्रेशन (ताकि रैम पर लोड न पड़े और ऐप क्रैश न हो)
  Future<void> _pickImagesFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      imageQuality: 30,
      maxWidth: 500,
      maxHeight: 500,
    );
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _addProperty() async {
    if (_titleController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया टाइटल और रेट भरें')));
      return;
    }

    List<String> imageStringList = [];
    for (var img in _selectedImages) {
      List<int> imageBytes = await img.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      imageStringList.add(base64Image);
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('properties');
    await ref.push().set({
      'title': _titleController.text.trim(),
      'price': _priceController.text.trim(),
      'size': _sizeController.text.trim(),
      'location': _locationController.text.trim(),
      'description': _descController.text.trim(),
      'images': imageStringList,
      'timestamp': ServerValue.timestamp,
    });

    _titleController.clear();
    _priceController.clear();
    _sizeController.clear();
    _locationController.clear();
    _descController.clear();
    setState(() {
      _selectedImages.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('प्रॉपर्टी, साइज और फोटो सफलतापूर्वक लाइव हो गए!'), backgroundColor: Color(0xFF10B981)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('नई Property जोड़ें (ऑटो-कंप्रेस्ड फोटो)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'प्रॉपर्टी टाइटल (e.g. 3BHK Luxury Floor)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'कीमत (e.g. ₹1.25 Cr या ₹20 Lakh)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _sizeController, decoration: const InputDecoration(labelText: 'साइज़ / क्षेत्रफल (e.g. 100 गज या 1500 Sq.Ft)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'लोकेशन (e.g. Nehar Par, Faridabad)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'प्रॉपर्टी की पूरी डिटेल (जैसे: near hospital school main highway)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          
          ElevatedButton.icon(
            onPressed: _pickImagesFromGallery,
            icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
            label: Text('गैलरी से फोटो चुनें (${_selectedImages.length} चुने गए)', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
          const SizedBox(height: 12),

          if (_selectedImages.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(File(_selectedImages[index].path), width: 100, height: 100, fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _addProperty,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('प्रॉपर्टी लाइव करें', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// TAB 2: INQUIRIES LIST (ADMIN ONLY)
// ---------------------------------------------------------
class InquiriesAdminTab extends StatelessWidget {
  const InquiriesAdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    Query inquiryRef = FirebaseDatabase.instance.ref().child('inquiries');

    return FirebaseAnimatedList(
      query: inquiryRef,
      itemBuilder: (context, snapshot, animation, index) {
        Map inq = snapshot.value as Map;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF10B981),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text('${inq['name']} (${inq['phone']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('प्रॉपर्टी: ${inq['property']}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('पता / लोकेशन: ${inq['address']}', style: const TextStyle(color: Colors.black87)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
