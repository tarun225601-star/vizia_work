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

// 🚀 RAM में डेटा रखने के लिए ग्लोबल वेरिएबल (सुपर-फास्ट स्पीड के लिए)
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

  // 🚀 ऐप स्टार्ट होते ही SharedPreferences को RAM में लोड कर लो (Instagram जैसी स्पीड)
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
// 3. ROLE SELECTION SCREEN
// ---------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  void _saveRole(String role) async {
    await globalPrefs.setString('user_role', role);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viziawork - मुख्य मेनू'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () async {
            await globalPrefs.clear();
            if (context.mounted) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          },
        ),
      ),
      body: Padding(
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
            _buildRoleCard(
              context,
              title: '1. मुझे काम कराना है / सामान खरीदना है',
              subtitle: '100% मुफ़्त मिस्त्री खोजें & मटीरियल बिल पर 1% कैशबैक पाएं',
              icon: Icons.person_search_rounded,
              onTap: () {
                _saveRole('USER');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen(userPhone: phone, isContractor: false)),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              context,
              title: '2. मैं कारीगर / ठेकेदार / बिल्डर हूँ',
              subtitle: 'मुफ़्त रजिस्ट्रेशन करें, नया काम पाएं और 0.5% मटीरियल बोनस कमाएं',
              icon: Icons.engineering_rounded,
              onTap: () {
                _saveRole('CONTRACTOR');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterWorkerScreen(workerPhone: phone)),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              context,
              title: '3. मैं मटीरियल दुकान मालिक हूँ',
              subtitle: 'अपनी दुकान लिस्ट करें, ग्राहक पाएं & बिल कोड वेरिफाई करें',
              icon: Icons.storefront_rounded,
              onTap: () {
                _saveRole('SHOPKEEPER');
                Navigator.push(
                  context,
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
// 4. MAIN HOME SCREEN (WITH CITY FILTER & 5-SHOP PAGINATION)
// ---------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final String userPhone;
  final bool isContractor;

  const HomeScreen({super.key, required this.userPhone, required this.isContractor});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _walletBalance = 0;
  String _selectedCity = "Faridabad"; // 🎯 बाय डिफॉल्ट फरीदाबाद
  final List<String> _cities = ["Faridabad", "Gurugram", "Delhi", "Noida", "Ghaziabad"];
  final DatabaseReference _userRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  void _loadWallet() {
    _userRef.child('users').child(widget.userPhone).child('wallet_balance').onValue.listen((event) {
      if (event.snapshot.value != null && mounted) {
        setState(() {
          _walletBalance = (event.snapshot.value as num).toInt();
        });
      }
    });
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
          // 🏙️ सिटी चुनने का फ़िल्टर
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              value: _selectedCity,
              underline: const SizedBox(),
              icon: const Icon(Icons.location_on, color: Color(0xFF10B981)),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
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
          // 💳 वॉलेट बैलेंस कार्ड
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('आपका कुल वॉलेट बैलेंस', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('₹$_walletBalance', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 36),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$_selectedCity की मान्यता प्राप्त दुकानें:',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // 🚀 5-दुकानों की PAGINATED LIST (CITY-BY-CITY)
          Expanded(
            child: FirebaseAnimatedList(
              // 🎯 सिर्फ चुनी हुई सिटी की दुकानें आएंगी और एक बार में सिर्फ 5 लोड होंगी!
              query: FirebaseDatabase.instance
                  .ref()
                  .child('shops')
                  .orderByChild('city')
                  .equalTo(_selectedCity)
                  .limitToFirst(5), 
              itemBuilder: (context, snapshot, animation, index) {
                Map? shopData = snapshot.value as Map?;
                if (shopData == null) return const SizedBox.shrink();

                String shopName = shopData['shop_name'] ?? 'दुकान का नाम';
                String category = shopData['category'] ?? 'हार्डवेयर';
                String address = shopData['address'] ?? 'पता उपलब्ध नहीं है';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF10B981),
                      child: Icon(Icons.storefront, color: Colors.white),
                    ),
                    title: Text(shopName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('$category • $address', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. SHOPKEEPER DASHBOARD (WITH 10 PM AUTO-LOCK SYSTEM)
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                  Text('${_shopData?['category']} • ${_shopData?['address']}', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),

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

                  // 📊 लेजर बोर्ड
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🏆 पास हुए कुल बिल', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
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
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, color: Colors.greenAccent, size: 16),
                            const SizedBox(width: 6),
                            Text('UPI ID: $_viziaUpiId', style: const TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.account_balance_rounded, color: Colors.amberAccent, size: 16),
                            const SizedBox(width: 6),
                            Text('A/C: $_viziaAccountNumber • IFSC: $_viziaIfscCode', style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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

// Placeholder Screens
class RegisterWorkerScreen extends StatelessWidget {
  final String workerPhone;
  const RegisterWorkerScreen({super.key, required this.workerPhone});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Worker Registration')));
}

class RegisterShopScreen extends StatelessWidget {
  final String shopPhone;
  final Map? existingData;
  const RegisterShopScreen({super.key, required this.shopPhone, this.existingData});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Shop Registration')));
}
