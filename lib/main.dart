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
