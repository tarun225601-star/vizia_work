import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
      home: const LoginScreen(),
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

  void _sendOtp() {
    String phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OtpVerificationScreen(phone: phone)),
    );
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
      appBar: AppBar(title: const Text('OTP सत्यापन')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viziawork - मुख्य मेनू'), automaticallyImplyLeading: false),
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
// 4. MAIN HOME SCREEN
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () => launchUrl(Uri.parse('tel:${worker['phone']}')),
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.teal),
                  onPressed: () => launchUrl(Uri.parse('whatsapp://send?phone=+91${worker['phone']}')),
                ),
              ],
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
        Map shop = snapshot.value as Map;
        String tier = shop['subscription_tier'] ?? 'FREE';
        String imgStr = shop['shopImage'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              backgroundImage: imgStr.isNotEmpty ? MemoryImage(base64Decode(imgStr)) : null,
              child: imgStr.isEmpty ? const Icon(Icons.store, color: Colors.orange) : null,
            ),
            title: Row(
              children: [
                Text(shop['shop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                if (tier == 'GOLD')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(6)),
                    child: const Text('GOLD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
              ],
            ),
            subtitle: Text('${shop['category']} • ${shop['address']}'),
            trailing: const Icon(Icons.verified, color: Color(0xFF10B981)),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// 5. REGISTER WORKER / CONTRACTOR (WITH BASE64 IMAGE)
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
  bool _isContractor = false;
  String? _base64Image;

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

  void _register() async {
    if (_nameController.text.isEmpty || _skillController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया नाम और हुनर भरें')));
      return;
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('public_workers').child(widget.workerPhone);
    await ref.set({
      'name': _nameController.text.trim(),
      'phone': widget.workerPhone,
      'skill': _skillController.text.trim(),
      'address': _addressController.text.trim(),
      'isContractor': _isContractor,
      'profileImage': _base64Image ?? '',
      'createdAt': ServerValue.timestamp,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('प्रोफाइल मुफ़्त में लाइव हो गई!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userPhone: widget.workerPhone, isContractor: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कारीगर / ठेकेदार रजिस्ट्रेशन')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _base64Image != null ? MemoryImage(base64Decode(_base64Image!)) : null,
                    child: _base64Image == null ? const Icon(Icons.person, size: 45, color: Colors.grey) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'पूरा नाम', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _skillController, decoration: InputDecoration(labelText: 'हुनर (जैसे: टाइल्स मिस्त्री, पेंटर, ठेकेदार)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            TextField(controller: _addressController, decoration: InputDecoration(labelText: 'पता / एरिया (जैसे: शीतला माता मंदिर रोड, फरीदाबाद)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('मैं ठेकेदार/बिल्डर हूँ (बल्क काम लेता हूँ)'),
              value: _isContractor,
              onChanged: (val) => setState(() => _isContractor = val!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('मुफ़्त प्रोफाइल लाइव करें', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
// =========================================================
// 1. SHOPKEEPER REGISTER / EDIT FORM (BRANDED + 5 PHOTOS + CUSTOM OFFER BOX)
// =========================================================
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
  final TextEditingController _offerController = TextEditingController(); // कस्टम ऑफर/एड बॉक्स

  String? _mainBase64Image;
  List<String> _galleryBase64Images = []; // 5 फोटो तक गैलरी

  @override
  void initState() {
    super.initState();
    if (widget.existingData != null) {
      _shopNameController.text = widget.existingData!['shop_name'] ?? '';
      _categoryController.text = widget.existingData!['category'] ?? '';
      _addressController.text = widget.existingData!['address'] ?? '';
      _offerController.text = widget.existingData!['custom_offer'] ?? '';
      _mainBase64Image = widget.existingData!['shopImage'] ?? '';
      
      if (widget.existingData!['galleryImages'] != null) {
        _galleryBase64Images = List<String>.from(widget.existingData!['galleryImages']);
      }
    }
  }

  // प्रोफाइल फोटो
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

  // 5 फोटो तक गैलरी पिकर
  Future<void> _pickGalleryImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 35);
    if (images.isNotEmpty) {
      List<String> tempImages = [];
      for (var img in images) {
        Uint8List bytes = await img.readAsBytes();
        tempImages.add(base64Encode(bytes));
        if (tempImages.length == 5) break; // मैक्सिमम 5 फोटो
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

    DatabaseReference ref = FirebaseDatabase.instance.ref().child('shops').child(widget.shopPhone);
    
    // पुराने बिल काउंट सुरक्षित रखें
    int totalPassedBills = widget.existingData?['totalPassedBills'] ?? 0;
    int totalSalesAmount = widget.existingData?['totalSalesAmount'] ?? 0;

    await ref.update({
      'shop_name': _shopNameController.text.trim(),
      'phone': widget.shopPhone,
      'category': _categoryController.text.trim(),
      'address': _addressController.text.trim(),
      'custom_offer': _offerController.text.trim(), // दुकानदार का अपना डिस्काउंट/ऑफर पाठ
      'shopImage': _mainBase64Image ?? '',
      'galleryImages': _galleryBase64Images, // 5 फोटो
      'totalPassedBills': totalPassedBills, // रैंकिंग के लिए आवश्यक
      'totalSalesAmount': totalSalesAmount,
      'subscription_tier': widget.existingData?['subscription_tier'] ?? 'FREE',
      'updatedAt': ServerValue.timestamp,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान की ब्रांडेड जानकारी सेव हो गई!')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ShopkeeperDashboardScreen(shopPhone: widget.shopPhone)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingData != null ? 'दुकान की जानकारी बदलें' : 'अपनी दुकान लिस्ट करें')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. मुख्य प्रोफाइल बैनर फोटो
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _mainBase64Image != null && _mainBase64Image!.isNotEmpty ? MemoryImage(base64Decode(_mainBase64Image!)) : null,
                    child: _mainBase64Image == null || _mainBase64Image!.isEmpty ? const Icon(Icons.store, size: 50, color: Colors.grey) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickMainImage,
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
            const SizedBox(height: 20),

            // 2. दुकान की 5 फ़ोटो अपलोड प्रिव्यू (Gallery)
            const Text('दुकान/स्टॉक की 5 फ़ोटो अपलोड करें:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickGalleryImages,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                ),
                child: _galleryBase64Images.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo, size: 32, color: Color(0xFF10B981)),
                          SizedBox(height: 4),
                          Text('यहाँ टैप करके दुकान/स्टॉक की 5 फोटो तक चुनें', style: TextStyle(fontSize: 12, color: Colors.black54)),
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
                              child: Image.memory(base64Decode(_galleryBase64Images[index]), width: 85, height: 85, fit: BoxFit.cover),
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

            // 3. दुकानदार का कस्टम ऐड/ऑफ़र टेक्स्ट बॉक्स
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
            const SizedBox(height: 28),

            ElevatedButton(
              onPressed: _saveShop,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('ब्रांडेड दुकान जानकारी सेव करें', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
// =========================================================
// BRANDED SHOPKEEPER DASHBOARD (LEDGER + BANNER + GALLERY ONLY)
// =========================================================
class ShopkeeperDashboardScreen extends StatefulWidget {
  final String shopPhone;
  const ShopkeeperDashboardScreen({super.key, required this.shopPhone});

  @override
  State<ShopkeeperDashboardScreen> createState() => _ShopkeeperDashboardScreenState();
}

class _ShopkeeperDashboardScreenState extends State<ShopkeeperDashboardScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  Map? _shopData;
  bool _isLoading = true;

  int _todaySales = 0;
  int _todayBills = 0;

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
      setState(() {
        _shopData = snapshot.value as Map;
        _isLoading = false;
      });
      _fetchTodayLedger();
    }
  }

  // आज के बिल और सेल्स का लाइव लेजर
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
            // 1. बड़ा मुख्य शॉप बैनर फोटो
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
                  // 2. दुकान का नाम, कैटेगरी और पता
                  Text(_shopData?['shop_name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${_shopData?['category']} • ${_shopData?['address']}', style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                  
                  // दुकानदार का स्पेशल डिस्काउंट ऑफर कार्ड
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

                  // 3. दुकान की 5 फोटो की गैलरी पट्टी
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

                  // 📊 4. रैंकिंग और सेल्स लेजर बोर्ड
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
                                const Text('कुल लाइफटाइम बिजनेस', style: TextStyle(color: Colors.grey, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text('₹$totalSales', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
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

    
                  
