
import 'dart:convert';

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// 🚀 RAM में डेटा रखने के लिए ग्लोबल वेरिएबल (जीरो लेटेसी के लिए)
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

  // 🚀 ऐप स्टार्ट होने से पहले ही प्रेफरेंस RAM में लोड हो जाएगा (Instagram जैसी स्पीड)
  globalPrefs = await SharedPreferences.getInstance();

  runApp(const ViziaworkApp());
}

class ViziaworkApp extends StatelessWidget {
  const ViziaworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viziawork',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        primaryColor: const Color(0xFF10B981),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------
// 0. SPLASH SCREEN (INSTANT AUTO-LOGIN)
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
    // 🚀 अब कोई async/await नहीं, सीधे RAM से मिलीसेकंड में चेक होगा
    String? phone = globalPrefs.getString('user_phone');
    String? role = globalPrefs.getString('user_role');

    if (!mounted) return;

    if (phone != null && phone.isNotEmpty) {
      if (role == 'SHOPKEEPER') {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => ShopkeeperDashboardScreen(shopPhone: phone))
        );
      } else {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => HomeScreen(userPhone: phone, isContractor: role == 'CONTRACTOR'))
        );
      }
    } else {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const LoginScreen())
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', phone);

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
                  boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
                ),
                child: const Icon(Icons.build_circle_rounded, size: 50, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Viziawork',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              const Text(
                '100% फ्री कारीगर खोजें & मटीरियल बिल पर कैशबैक पाएं',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
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
                  backgroundColor: const Color(0xFF10B981),
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
// 2. OTP VERIFICATION SCREEN (WITH BACK BUTTON)
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
      MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.phone)),
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

MaterialPageRoute(builder: (context) => ShopkeeperDashboardScreen(shopPhone: phone)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF10B981), size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
// ---------------------------------------------------------
// ROLE SELECTION SCREEN & ADMIN CONTROL (ALL-IN-ONE)
// ---------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  void _saveRole(String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viziawork - मुख्य मेनू'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            if (context.mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'आप Viziawork का उपयोग कैसे करना चाहते हैं?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            
            // 1. ग्राहक / काम कराने वाला
            _buildRoleCard(
              context,
              title: '1. मुझे काम कराना है / सामान खरीदना है',
              subtitle: '100% मुफ़्त मिस्त्री खोजें & मटीरियल बिल पर 1% कैशबैक पाएं',
              icon: Icons.person_search_rounded,
              iconColor: const Color(0xFF10B981),
              onTap: () {
                _saveRole('USER');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(userPhone: phone, isContractor: false)),
                );
              },
            ),
            const SizedBox(height: 16),

            // 2. कारीगर / ठेकेदार
            _buildRoleCard(
              context,
              title: '2. मैं कारीगर / ठेकेदार / बिल्डर हूँ',
              subtitle: 'मुफ़्त रजिस्ट्रेशन करें, नया काम पाएं और 0.5% मटीरियल बोनस कमाएं',
              icon: Icons.engineering_rounded,
              iconColor: const Color(0xFF10B981),
              onTap: () {
                _saveRole('CONTRACTOR');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterWorkerScreen(workerPhone: phone)),
                );
              },
            ),
            const SizedBox(height: 16),

            // 3. मटीरियल दुकान मालिक
            _buildRoleCard(
              context,
              title: '3. मैं मटीरियल दुकान मालिक हूँ',
              subtitle: 'अपनी दुकान लिस्ट करें, ग्राहक पाएं & बिल कोड वेरिफाई करें',
              icon: Icons.storefront_rounded,
              iconColor: const Color(0xFF10B981),
              onTap: () {
                _saveRole('SHOPKEEPER');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopkeeperDashboardScreen(shopPhone: phone)),
                );
              },
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),

            // 👑 4. एडमिन कंट्रोल (पासकोड Tarun#1)
            _buildRoleCard(
              context,
              title: '4. एडमिन कंट्रोल (Admin Control)',
              subtitle: 'दुकानें व कारीगर मैनेज करें, अप्रूव/डिलीट व लॉक लगाएं',
              icon: Icons.admin_panel_settings_rounded,
              iconColor: const Color(0xFF0F172A),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminControl()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// ADMIN CONTROL LOGIN & PASSCODE (Tarun#1)
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
        const SnackBar(
          content: Text('गलत सीक्रेट कोड! एक्सेस अस्वीकृत।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text('Viziawork एडमिन लॉगिन'),
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 70, color: Color(0xFF10B981)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'सुपर एडमिन एक्सेस',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'कंट्रोल पैनल खोलने के लिए सीक्रेट कोड दर्ज करें',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passcodeController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: 'सीक्रेट कोड दर्ज करें',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyPasscode,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('अनलॉक एडमिन पैनल', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const AdminMainDashboard();
  }
}

// ---------------------------------------------------------
// ADMIN DASHBOARD CONTENT (SHOPS & WORKERS MANAGEMENT)
// ---------------------------------------------------------
class AdminMainDashboard extends StatefulWidget {
  const AdminMainDashboard({super.key});

  @override
  State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String _selectedCity = "All";
  final List<String> _cities = ["All", "Faridabad", "Gurugram", "Delhi", "Noida", "Ghaziabad"];
  int _currentTabIndex = 0;

  void _approveShop(String shopPhone) async {
    await _dbRef.child('shops').child(shopPhone).update({
      'isApproved': true,
      'status': 'ACTIVE',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान अप्रूव कर दी गई है!')));
    }
  }

  void _deleteShop(String shopPhone, String shopName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$shopName डिलीट करें?'),
        content: const Text('क्या आप वाकई इस दुकान को हमेशा के लिए हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbRef.child('shops').child(shopPhone).remove();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान डिलीट कर दी गई है')));
              }
            },
            child: const Text('डिलीट करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleShopLock(String shopPhone, bool currentLockState) async {
    await _dbRef.child('shops').child(shopPhone).update({'isLocked': !currentLockState});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(!currentLockState ? 'दुकान लॉक कर दी गई है' : 'दुकान अनलॉक कर दी गई है')),
      );
    }
  }

  void _approveWorker(String workerPhone) async {
    await _dbRef.child('workers').child(workerPhone).update({
      'isVerified': true,
      'status': 'APPROVED',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कारीगर की प्रोफाइल वेरिफाई हो गई है!')));
    }
  }

  void _deleteWorker(String workerPhone, String workerName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$workerName को हटाएं?'),
        content: const Text('क्या आप वाकई इस कारीगर/ठेकेदार को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbRef.child('workers').child(workerPhone).remove();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कारीगर डिलीट कर दिया गया है')));
              }
            },
            child: const Text('डिलीट करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('एडमिन कंट्रोल (Admin Control)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF1E293B),
              value: _selectedCity,
              underline: const SizedBox(),
              icon: const Icon(Icons.location_on, color: Color(0xFF10B981)),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              onChanged: (String? newCity) {
                if (newCity != null) {
                  setState(() {
                    _selectedCity = newCity;
                  });
                }
              },
              items: _cities.map<DropdownMenuItem<String>>((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Custom Tab Header
          Container(
            color: const Color(0xFF1E293B),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _currentTabIndex = 0),
                    icon: const Icon(Icons.storefront, color: Color(0xFF10B981)),
                    label: Text('दुकानें (Shops)', style: TextStyle(color: _currentTabIndex == 0 ? const Color(0xFF10B981) : Colors.white60, fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _currentTabIndex = 1),
                    icon: const Icon(Icons.engineering, color: Color(0xFF10B981)),
                    label: Text('कारीगर/ठेकेदार', style: TextStyle(color: _currentTabIndex == 1 ? const Color(0xFF10B981) : Colors.white60, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _currentTabIndex == 0 ? _buildShopsManager() : _buildWorkersManager(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopsManager() {
    Query query = _dbRef.child('shops');
    if (_selectedCity != "All") {
      query = query.orderByChild('city').equalTo(_selectedCity);
    }

    return FirebaseAnimatedList(
      query: query,
      defaultChild: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      itemBuilder: (context, snapshot, animation, index) {
        if (snapshot.value == null) return const SizedBox.shrink();
        Map shopData = snapshot.value as Map;
        String shopPhone = snapshot.key ?? '';
        String shopName = shopData['shop_name'] ?? 'अनाम दुकान';
        String category = shopData['category'] ?? 'हार्डवेयर';
        String city = shopData['city'] ?? 'Faridabad';
        bool isApproved = shopData['isApproved'] ?? false;
        bool isLocked = shopData['isLocked'] ?? false;
        double pending = (shopData['pendingCommission'] ?? 0.0).toDouble();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        shopName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isApproved ? 'APPROVED' : 'PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('श्रेणी: $category • शहर: $city', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('फ़ोन नंबर: +91 $shopPhone', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text('बकाया कमिशन: ₹${pending.toStringAsFixed(1)}', style: TextStyle(color: pending > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                const Divider(height: 20),
                Row(
                  children: [
                    if (!isApproved) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveShop(shopPhone),
                          icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                          label: const Text('अप्रूव करें', style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      icon: Icon(isLocked ? Icons.lock : Icons.lock_open, color: isLocked ? Colors.red : Colors.grey),
                      tooltip: isLocked ? 'अनलॉक करें' : 'लॉक करें',
                      onPressed: () => _toggleShopLock(shopPhone, isLocked),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'दुकान डिलीट करें',
                      onPressed: () => _deleteShop(shopPhone, shopName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkersManager() {
    Query query = _dbRef.child('workers');
    if (_selectedCity != "All") {
      query = query.orderByChild('city').equalTo(_selectedCity);
    }

    return FirebaseAnimatedList(
      query: query,
      defaultChild: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      itemBuilder: (context, snapshot, animation, index) {
        if (snapshot.value == null) return const SizedBox.shrink();
        Map workerData = snapshot.value as Map;
        String workerPhone = snapshot.key ?? '';
        String name = workerData['name'] ?? 'अनाम कारीगर';
        String workType = workerData['work_type'] ?? 'मिस्त्री';
        String city = workerData['city'] ?? 'Faridabad';
        bool isVerified = workerData['isVerified'] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: isVerified ? Colors.blue : Colors.grey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (isVerified) const Icon(Icons.verified, color: Colors.blue, size: 18),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('काम: $workType • शहर: $city'),
                Text('फ़ोन: +91 $workerPhone', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isVerified)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    tooltip: 'वेरिफाई करें',
                    onPressed: () => _approveWorker(workerPhone),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'हटाएं',
                  onPressed: () => _deleteWorker(workerPhone, name),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// 4. MAIN HOME SCREEN (SHOWS UNLOCKED SHOPS ONLY)
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final String userPhone;
  final bool isContractor;

  const HomeScreen({super.key, required this.userPhone, required this.isContractor});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _walletBalance = 0;
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWallet();
  }

  void _loadWallet() {
    _userRef.child('users').child(widget.userPhone).child('wallet_balance').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _walletBalance = (event.snapshot.value as num).toInt();
        });
      }
    });
  }

  void _showGenerateCodeDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController mistryPhoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('4-Digit Bill Code बनाएं', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('दुकान पर बिल बनने पर कोड बनाएं और 1% कैशबैक पाएं!'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'अनुमानित बिल राशि (₹)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              if (!widget.isContractor)
                TextField(
                  controller: mistryPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'मिस्त्री/ठेकेदार का नंबर (वैकल्पिक)',
                    hintText: '0.5% बोनस दिलाने के लिए भरें',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () async {
                if (amountController.text.isEmpty) return;
                int amount = int.parse(amountController.text.trim());
                String code = (1000 + Random().nextInt(9000)).toString();

                await _userRef.child('pending_codes').child(code).set({
                  'code': code,
                  'userPhone': widget.userPhone,
                  'mistryPhone': mistryPhoneController.text.trim(),
                  'amount': amount,
                  'status': 'PENDING',
                  'createdAt': ServerValue.timestamp,
                });

                if (mounted) {
                  Navigator.pop(context);
                  _showCodeResultDialog(code, amount);
                }
              },
              child: const Text('कोड जनरेट करें', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCodeResultDialog(String code, int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('आपका बिल कोड', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF10B981), letterSpacing: 6)),
            const SizedBox(height: 10),
            Text('बिल राशि: ₹$amount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            const Text('यह 4-डिजिट कोड दुकानदार को बताएं। दुकानदार कोड एंटर करके बिल पक्का करेगा।', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () => Navigator.pop(context),
            child: const Text('ठीक है', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viziawork'),
        leading: IconButton(
          icon: const Icon(Icons.swap_horiz_rounded),
          tooltip: 'रोल बदलें',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.userPhone)),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Chip(
              backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
              avatar: const Icon(Icons.account_balance_wallet, size: 18, color: Color(0xFF10B981)),
              label: Text('कैशबैक: ₹$_walletBalance', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF10B981),
          tabs: const [
            Tab(icon: Icon(Icons.engineering), text: 'कारीगर व ठेकेदार'),
            Tab(icon: Icon(Icons.storefront), text: 'मटीरियल दुकानें'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkersList(),
          _buildShopsList(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton.icon(
          onPressed: _showGenerateCodeDialog,
          icon: const Icon(Icons.qr_code_2, color: Colors.white),
          label: const Text('दुकान बिल कोड (Dynamic 4-Digit Code) बनाएं', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }


  Widget _buildWorkersList() {
    DatabaseReference workersRef = FirebaseDatabase.instance.ref().child('public_workers');
    return FirebaseAnimatedList(
      query: workersRef,
      itemBuilder: (context, snapshot, animation, index) {
        if (snapshot.value == null) return Container();
        Map worker = snapshot.value as Map;
        String imgStr = worker['profileImage'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF10B981).withOpacity(0.2),
              backgroundImage: imgStr.isNotEmpty ? MemoryImage(base64Decode(imgStr)) : null,
              child: imgStr.isEmpty ? const Icon(Icons.person, color: Color(0xFF10B981)) : null,
            ),
            title: Text(worker['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${worker['skill']} • ${worker['address']}'),
            trailing: IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () async {
                String phone = worker['phone'] ?? '';
                if (phone.isNotEmpty) {
                  final Uri launchUri = Uri(scheme: 'tel', path: phone);
                  await launchUrl(launchUri);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildShopsList() {
    DatabaseReference shopsRef = FirebaseDatabase.instance.ref().child('shops');
    return FirebaseAnimatedList(
      query: shopsRef,
      itemBuilder: (context, snapshot, animation, index) {
        if (snapshot.value == null) return Container();
        Map shopData = snapshot.value as Map;

        bool isLocked = shopData['isLocked'] ?? false;
        if (isLocked) return Container(); // 🔒 locked दुकान ग्राहकों को नहीं दिखेगी

        String mainImage = shopData['shopImage'] ?? '';
        List galleryImages = shopData['galleryImages'] ?? [];
        String customOffer = shopData['custom_offer'] ?? '';
        int totalBills = shopData['totalPassedBills'] ?? 0;
        int totalSales = shopData['totalSalesAmount'] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  Container(
                    height: 160,
                    width: double.infinity,
                    color: Colors.grey.shade300,
                    child: mainImage.isNotEmpty
                        ? Image.memory(base64Decode(mainImage), fit: BoxFit.cover)
                        : const Icon(Icons.store, size: 60, color: Colors.grey),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: totalBills > 0 ? const Color(0xFF10B981) : Colors.orange.shade800,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            totalBills > 0 ? Icons.verified : Icons.stars,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalBills बिल पास',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payments_rounded, color: Colors.greenAccent, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'कुल बिजनेस: ₹$totalSales',
                            style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            shopData['shop_name'] ?? 'दुकान का नाम',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '₹$totalSales बिक्री',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shopData['category']} • ${shopData['address']}',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    if (customOffer.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade700),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_offer, color: Colors.amber, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                customOffer,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (galleryImages.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('दुकान/स्टॉक की गैलरी फोटो:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: galleryImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(galleryImages[index]),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
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
// 5. REGISTER WORKER SCREEN (WITH BACK BUTTON)
// ---------------------------------------------------------
class RegisterWorkerScreen extends StatefulWidget {
  final String workerPhone;
  const RegisterWorkerScreen({super.key, required this.workerPhone});

  @override
  State<RegisterWorkerScreen> createState() => _RegisterWorkerScreenState();
}

class _RegisterWorkerScreenState extends State<RegisterWorkerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String? _base64Image;

  @override
  void initState() {
    super.initState();
    _loadLocalWorker();
  }

  void _loadLocalWorker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('worker_name') ?? '';
      _skillController.text = prefs.getString('worker_skill') ?? '';
      _addressController.text = prefs.getString('worker_address') ?? '';
      _base64Image = prefs.getString('worker_image') ?? '';
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _saveWorker() async {
    if (_nameController.text.isEmpty || _skillController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया नाम और काम की कैटेगरी भरें')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('worker_name', _nameController.text.trim());
    await prefs.setString('worker_skill', _skillController.text.trim());
    await prefs.setString('worker_address', _addressController.text.trim());
    await prefs.setString('worker_image', _base64Image ?? '');

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('public_workers').child(widget.workerPhone);
    await ref.set({
      'name': _nameController.text.trim(),
      'phone': widget.workerPhone,
      'skill': _skillController.text.trim(),
      'address': _addressController.text.trim(),
      'profileImage': _base64Image ?? '',
      'createdAt': ServerValue.timestamp,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कारीगर प्रोफाइल सफलता से सेव हो गई!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userPhone: widget.workerPhone, isContractor: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('कारीगर / ठेकेदार रजिस्ट्रेशन'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.workerPhone)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _base64Image != null && _base64Image!.isNotEmpty ? MemoryImage(base64Decode(_base64Image!)) : null,
                    child: _base64Image == null || _base64Image!.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'आपका पूरा नाम', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _skillController, decoration: InputDecoration(labelText: 'कारीगरी / काम (जैसे: मिस्त्री, पेंटर, इलेक्ट्रीशियन)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'पता / क्षेत्र (जैसे: अनंगपुर, फरीदाबाद)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveWorker,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('रजिस्टर करें', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 6. SHOPKEEPER REGISTER / EDIT FORM (WITH BACK BUTTON)
// ---------------------------------------------------------
class RegisterShopScreen extends StatefulWidget {
  final String shopPhone;
  final Map? existingData;

  const RegisterShopScreen({super.key, required this.shopPhone, this.existingData});

  @override
  State<RegisterShopScreen> createState() => _RegisterShopScreenState();
}

class _RegisterShopScreenState extends State<RegisterShopScreen> {
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _offerController = TextEditingController();

  String? _mainBase64Image;
  List<String> _galleryBase64Images = [];

  @override
  void initState() {
    super.initState();
    _loadShopData();
  }

  void _loadShopData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (widget.existingData != null) {
      _shopNameController.text = widget.existingData!['shop_name'] ?? '';
      _categoryController.text = widget.existingData!['category'] ?? '';
      _addressController.text = widget.existingData!['address'] ?? '';
      _offerController.text = widget.existingData!['custom_offer'] ?? '';
      _mainBase64Image = widget.existingData!['shopImage'] ?? '';
      
      if (widget.existingData!['galleryImages'] != null) {
        _galleryBase64Images = List<String>.from(widget.existingData!['galleryImages']);
      }
    } else {
      _shopNameController.text = prefs.getString('shop_name') ?? '';
      _categoryController.text = prefs.getString('shop_category') ?? '';
      _addressController.text = prefs.getString('shop_address') ?? '';
      _offerController.text = prefs.getString('shop_offer') ?? '';
      _mainBase64Image = prefs.getString('shop_main_image') ?? '';
    }
    setState(() {});
  }

  Future<void> _pickMainImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _mainBase64Image = base64Encode(bytes);
      });
    }
  }

  Future<void> _pickGalleryImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 35);
    if (images.isNotEmpty) {
      List<String> tempImages = [];
      for (var img in images) {
        Uint8List bytes = await img.readAsBytes();
        tempImages.add(base64Encode(bytes));
        if (tempImages.length == 5) break;
      }
      setState(() {
        _galleryBase64Images = tempImages;
      });
    }
  }

  void _saveShop() async {
    if (_shopNameController.text.isEmpty || _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया दुकान का नाम और कैटेगरी भरें')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_name', _shopNameController.text.trim());
    await prefs.setString('shop_category', _categoryController.text.trim());
    await prefs.setString('shop_address', _addressController.text.trim());
    await prefs.setString('shop_offer', _offerController.text.trim());
    await prefs.setString('shop_main_image', _mainBase64Image ?? '');

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('shops').child(widget.shopPhone);
    
    int totalPassedBills = widget.existingData?['totalPassedBills'] ?? 0;
    int totalSalesAmount = widget.existingData?['totalSalesAmount'] ?? 0;

    await ref.update({
      'shop_name': _shopNameController.text.trim(),
      'phone': widget.shopPhone,
      'category': _categoryController.text.trim(),
      'address': _addressController.text.trim(),
      'custom_offer': _offerController.text.trim(),
      'shopImage': _mainBase64Image ?? '',
      'galleryImages': _galleryBase64Images,
      'totalPassedBills': totalPassedBills,
      'totalSalesAmount': totalSalesAmount,
      'isLocked': widget.existingData?['isLocked'] ?? false,
      'pendingCommission': widget.existingData?['pendingCommission'] ?? 0.0,
      'subscription_tier': widget.existingData?['subscription_tier'] ?? 'FREE',
      'updatedAt': ServerValue.timestamp,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान की जानकारी सेव हो गई!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShopkeeperDashboardScreen(shopPhone: widget.shopPhone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingData != null ? 'दुकान की जानकारी बदलें' : 'अपनी दुकान लिस्ट करें'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('दुकान का मुख्य बड़ा बैनर फोटो लगाएँ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickMainImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                  image: _mainBase64Image != null && _mainBase64Image!.isNotEmpty
                      ? DecorationImage(image: MemoryImage(base64Decode(_mainBase64Image!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _mainBase64Image == null || _mainBase64Image!.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_rounded, size: 40, color: Color(0xFF10B981)),
                          SizedBox(height: 6),
                          Text('यहाँ टैप करके मुख्य शॉप बैनर फोटो चुनें', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      )
                    : Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                          child: const Icon(Icons.edit, color: Colors.white, size: 18),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('दुकान/स्टॉक की 5 फ़ोटो अपलोड करें:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickGalleryImages,
              child: Container(
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: _galleryBase64Images.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.collections, size: 28, color: Colors.grey),
                          SizedBox(height: 4),
                          Text('यहाँ टैप करके 5 स्टॉक फोटो तक चुनें', style: TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _galleryBase64Images.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(base64Decode(_galleryBase64Images[index]), width: 75, height: 75, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _shopNameController, decoration: InputDecoration(labelText: 'दुकान का नाम', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _categoryController, decoration: InputDecoration(labelText: 'कैटेगरी (जैसे: सैनिटरी, टाइल्स, पेंट, हार्डवेयर)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'दुकान का पता (जैसे: अनंगपुर रोड, फरीदाबाद)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(
              controller: _offerController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'दुकान का स्पेशल ऑफर / डिस्काउंट संदेश (ऑप्शनल)',
                hintText: 'उदा: इस हफ्ते सैनिटरी फिटिंग पर स्पेशल 5% अतिरिक्त छूट!',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.amber.shade50,
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveShop,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('दुकान की जानकारी सेव करें', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

 // ---------------------------------------------------------
// SHOPKEEPER DASHBOARD (WITH 10 PM AUTO-LOCK & PAGINATION SYSTEM)
// ---------------------------------------------------------
class ShopkeeperDashboardScreen extends StatefulWidget {
  final String shopPhone;
  const ShopkeeperDashboardScreen({super.key, required this.shopPhone});

  @override
  State<ShopkeeperDashboardScreen> createState() => _ShopkeeperDashboardScreenState();
}

class _ShopkeeperDashboardScreenState extends State<ShopkeeperDashboardScreen> {
  final TextEditingController _codeController = TextEditingController();
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map? _shopData;
  bool _isLoading = true;

  int _todaySales = 0;
  int _todayBills = 0;
  double _pendingCommission = 0.0;
  bool _isLocked = false;
  String _shopCity = "Faridabad"; // 🚀 दुकान का शहर ट्रैक करने के लिए

  // 🏛️ Payment Settlement Destinations
  final String _viziaUpiId = "9971968060@ptyes";
  final String _viziaBankName = "Central Bank of India";
  final String _viziaAccountNumber = "4029330823";
  final String _viziaIfscCode = "CBIN0280248";
  final String _viziaBranch = "Jattari Branch, Aligarh";

  @override
  void initState() {
    super.initState();
    _checkShopExists();
  }

  void _checkShopExists() async {
    DataSnapshot snapshot = await _dbRef.child('shops').child(widget.shopPhone).get();
    if (!snapshot.exists) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterShopScreen(shopPhone: widget.shopPhone)),
        );
      }
    } else {
      Map data = snapshot.value as Map;
      bool lockedState = data['isLocked'] ?? false;
      double pending = (data['pendingCommission'] ?? 0.0).toDouble();
      String city = data['city'] ?? "Faridabad"; // डेटाबेस से सिटी उठा ली

      // ⏰ Check 10:00 PM Cutoff Logic
      DateTime now = DateTime.now();
      if (now.hour >= 22 && pending > 0) {
        lockedState = true;
        await _dbRef.child('shops').child(widget.shopPhone).update({'isLocked': true});
      }

      setState(() {
        _shopData = data;
        _isLocked = lockedState;
        _pendingCommission = pending;
        _shopCity = city;
        _isLoading = false;
      });
      _fetchTodayLedger();
    }
  }

  void _fetchTodayLedger() {
    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";

    _dbRef.child('passed_bills').orderByChild('shopPhone').equalTo(widget.shopPhone).onValue.listen((event) {
      if (event.snapshot.exists) {
        Map bills = event.snapshot.value as Map;
        int tSales = 0;
        int tBills = 0;

        bills.forEach((key, value) {
          if (value['dateKey'] == todayKey) {
            tSales += (value['amount'] as num).toInt();
            tBills++;
          }
        });

        if (mounted) {
          setState(() {
            _todaySales = tSales;
            _todayBills = tBills;
          });
        }
      }
    });
  }

  void _verifyAndDeductCommission() async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान लॉक है! पहले रात 10 बजे का कमिशन सेटल करें।')));
      return;
    }

    String code = _codeController.text.trim();
    if (code.length < 4) return;

    DataSnapshot snapshot = await _dbRef.child('pending_codes').child(code).get();
    if (!snapshot.exists) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('अमान्य कोड! दोबारा जाँचें')));
      return;
    }

    Map data = snapshot.value as Map;
    int amount = data['amount'];
    String userPhone = data['userPhone'];
    String mistryPhone = data['mistryPhone'] ?? '';

    // 3% Commission Breakdown
    double viziaCut = amount * 0.02; // 2% Viziawork Cut
    double customerCashback = mistryPhone.isEmpty ? (amount * 0.01) : (amount * 0.005);
    double mistryBonus = mistryPhone.isNotEmpty ? (amount * 0.005) : 0.0;

    // 1. Customer Cashback Transfer
    await _dbRef.child('users').child(userPhone).child('wallet_balance').set(ServerValue.increment(customerCashback.toInt()));

    // 2. Mistry Bonus Transfer
    if (mistryPhone.isNotEmpty) {
      await _dbRef.child('users').child(mistryPhone).child('wallet_balance').set(ServerValue.increment(mistryBonus.toInt()));
    }

    // 3. Update Pending Daily Commission Ledger
    await _dbRef.child('shops').child(widget.shopPhone).update({
      'totalPassedBills': ServerValue.increment(1),
      'totalSalesAmount': ServerValue.increment(amount),
      'pendingCommission': ServerValue.increment(viziaCut),
    });

    // 4. Save Entry
    await _dbRef.child('viziawork_settlements').push().set({
      'shopPhone': widget.shopPhone,
      'billAmount': amount,
      'viziaNetProfit': viziaCut,
      'settlementUpi': _viziaUpiId,
      'bankName': _viziaBankName,
      'accountNumber': _viziaAccountNumber,
      'ifscCode': _viziaIfscCode,
      'createdAt': ServerValue.timestamp,
    });

    DateTime now = DateTime.now();
    String todayKey = "${now.year}-${now.month}-${now.day}";
    await _dbRef.child('passed_bills').push().set({
      'shopPhone': widget.shopPhone,
      'userPhone': userPhone,
      'amount': amount,
      'dateKey': todayKey,
      'createdAt': ServerValue.timestamp,
    });

    await _dbRef.child('pending_codes').child(code).remove();

    if (mounted) {
      _codeController.clear();
      _checkShopExists();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('बिल कोड सफलता से पास हुआ!'),
          content: Text(
            'कुल बिल: ₹$amount\n'
            'कस्टमर कैशबैक: ₹${customerCashback.toInt()}\n'
            'मिस्त्री बोनस: ₹${mistryBonus.toInt()}\n'
            'Viziawork 2% कमिशन: ₹${viziaCut.toStringAsFixed(1)}\n\n'
            '⚠️ ध्यान दें: रात 10:00 बजे से पहले कमिशन पे करें, वरना दुकान लॉक हो जाएगी!',
          ),
          actions: [ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('ठीक है'))],
        ),
      );
    }
  }

  void _clearCommissionAndUnlock() async {
    await _dbRef.child('shops').child(widget.shopPhone).update({
      'pendingCommission': 0.0,
      'isLocked': false,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कमिशन सेटल हो गया! दुकान अनलॉक हो गई है।')));
      _checkShopExists();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))));
    }

    int totalBills = _shopData?['totalPassedBills'] ?? 0;
    int totalSales = _shopData?['totalSalesAmount'] ?? 0;
    String mainImage = _shopData?['shopImage'] ?? '';
    List galleryImages = _shopData?['galleryImages'] ?? [];
    String customOffer = _shopData?['custom_offer'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(_shopData?['shop_name'] ?? 'दुकानदार डैशबोर्ड'),
        leading: IconButton(
          icon: const Icon(Icons.swap_horiz_rounded),
          tooltip: 'रोल बदलें',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.shopPhone)),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF10B981)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterShopScreen(shopPhone: widget.shopPhone, existingData: _shopData)),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔒 LOCK WARNING BANNER
            if (_isLocked)
              Container(
                color: Colors.red.shade800,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock, color: Colors.white, size: 24),
                        SizedBox(width: 8),
                        Text('आपकी दुकान लॉक हो चुकी है!', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'रात 10:00 बजे तक ₹${_pendingCommission.toStringAsFixed(1)} कमिशन जमा न होने के कारण दुकान डेटाबेस में लॉक है।',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900),
                      onPressed: _clearCommissionAndUnlock,
                      child: const Text('कमिशन पे करके दुकान अनलॉक करें', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),

            Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey.shade300,
              child: mainImage.isNotEmpty
                  ? Image.memory(base64Decode(mainImage), fit: BoxFit.cover)
                  : const Icon(Icons.store, size: 70, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(_shopData?['shop_name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  // 🏙️ यहाँ सिटी और एड्रेस दोनों आ गए हैं
                  Text('${_shopData?['category']} • $_shopCity • ${_shopData?['address']}', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),

                  if (customOffer.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.amber.shade700),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer, color: Colors.amber, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              customOffer,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (galleryImages.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text('दुकान/स्टॉक की गैलरी फोटो:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: galleryImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                base64Decode(galleryImages[index]),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 📊 बिजनेस लेजर बोर्ड (Dual Settlement & 10 PM Cutoff)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🏆 पास हुए कुल बिल (रैंकिंग काउंट)', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                              child: Text('$totalBills बिल पास', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            )
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('आज का बिजनेस', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('₹$_todaySales', style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                                Text('($_todayBills बिल आज)', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('आज का देय कमिशन (10 PM)', style: TextStyle(color: Colors.orangeAccent, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('₹${_pendingCommission.toStringAsFixed(1)}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 10),
                        
                        // 💳 UPI Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, color: Colors.greenAccent, size: 16),
                            const SizedBox(width: 6),
                            Text('UPI ID: $_viziaUpiId', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // 🏛️ Direct Bank Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_rounded, color: Colors.amberAccent, size: 16),
                            const SizedBox(width: 6),
                            Text('A/C: $_viziaAccountNumber • IFSC: $_viziaIfscCode', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('($_viziaBankName, $_viziaBranch)', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔑 4-Digit Bill Code दर्ज करने का बॉक्स
                  const Text('ग्राहक/मिस्त्री का 4-Digit Code दर्ज करें:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _codeController,
                    enabled: !_isLocked,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 10),
                    decoration: InputDecoration(
                      hintText: _isLocked ? '🔒 दुकान लॉक है' : '6842',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLocked ? null : _verifyAndDeductCommission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLocked ? Colors.grey : const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(_isLocked ? '🔒 दुकान लॉक है (पेमेंट करें)' : 'बिल वेरिफाई करें & कैशबैक ट्रांसफर करें', style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
                             
