import 'dart:convert';
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
                child: const Icon(Icons.flash_on_rounded, size: 50, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Viziawork',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              const Text(
                'खुला बाज़ार - डायरेक्ट कारीगर से बात करें',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर दर्ज करें',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontSize: 18, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
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
                  elevation: 2,
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
            Text('+91 ${widget.phone} पर भेजा गया OTP यहाँ दर्ज करें:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.black),
              decoration: InputDecoration(
                hintText: '1234',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
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
      appBar: AppBar(
        title: const Text('Viziawork - मुख्य मेनू'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'आप ऐप का उपयोग कैसे करना चाहते हैं?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 35),
            _buildRoleCard(
              context,
              title: 'मुझे काम कराना है / मिस्त्री ढूंढना है',
              subtitle: 'कुछ भी सर्च करें, ₹10/कॉल कटेगा और ₹100, ₹200, ₹500 का रीचार्ज करें',
              icon: Icons.search_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CustomerServiceScreen(clientPhone: phone)),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              title: 'मैं कारीगर हूँ (अपनी प्रोफाइल बनाएं)',
              subtitle: 'प्रोफाइल बनाएं और ₹100, ₹200, ₹500 का सब्सक्रिप्शन रीचार्ज करें',
              icon: Icons.engineering_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterWorkerScreen(workerPhone: phone)),
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
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF10B981), size: 32),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.3)),
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
// 4. PAYMENT HELPERS & UPI DIALOG SYSTEM (CENTRAL + AIRTEL BANK)
// ---------------------------------------------------------
class PaymentHelper {
  static const String centralBankUpi = "9971968060@centralbank";
  static const String airtelBankUpi = "9971968060@airtel";

  static Future<bool> launchUpi({
    required BuildContext context,
    required String upiId,
    required int amount,
    required String note,
  }) async {
    final String upiUrl = 'upi://pay?pa=$upiId&pn=Viziawork&am=$amount&cu=INR&tn=$note';
    final Uri uri = Uri.parse(upiUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('कोई UPI ऐप (Paytm/GPay/PhonePe) नहीं मिला')),
        );
      }
      return false;
    }
  }

  static void showPaymentBottomSheet({
    required BuildContext context,
    required Function(int amount) onSuccess,
    bool isWorkerSubscription = false,
  }) {
    int selectedAmount = 100;
    String selectedUpi = centralBankUpi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isWorkerSubscription ? 'सब्सक्रिप्शन प्लान लें' : 'वॉलेट रीचार्ज करें',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWorkerSubscription
                        ? 'अपनी प्रोफाइल एक्टिव रखने के लिए प्लान चुनें'
                        : 'कारीगर को संपर्क करने पर वॉलेट से ₹10 काटेंगे',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  const Text('1. प्लान / अमाउंट चुनें:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [100, 200, 500].map((amt) {
                      bool isSelected = selectedAmount == amt;
                      return ChoiceChip(
                        label: Text('₹$amt', style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF10B981),
                        backgroundColor: Colors.grey.shade200,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedAmount = amt);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                  const Text('2. बैंक UPI विकल्प चुनें:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: selectedUpi == centralBankUpi ? const Color(0xFF10B981) : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<String>(
                      title: const Text('Central Bank of India', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(centralBankUpi, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      value: centralBankUpi,
                      groupValue: selectedUpi,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) => setModalState(() => selectedUpi = val!),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: selectedUpi == airtelBankUpi ? const Color(0xFF10B981) : Colors.grey.shade300, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: RadioListTile<String>(
                      title: const Text('Airtel Payments Bank', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(airtelBankUpi, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      value: airtelBankUpi,
                      groupValue: selectedUpi,
                      activeColor: const Color(0xFF10B981),
                      onChanged: (val) => setModalState(() => selectedUpi = val!),
                    ),
                  ),

                  const SizedBox(height: 24),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      bool ok = await launchUpi(
                        context: context,
                        upiId: selectedUpi,
                        amount: selectedAmount,
                        note: isWorkerSubscription ? 'Worker_Subscription' : 'Client_Wallet_Recharge',
                      );
                      if (ok) {
                        onSuccess(selectedAmount);
                      }
                    },
                    child: Text('₹$selectedAmount भुगतान करें', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------
// 5. CUSTOMER SERVICE SCREEN (₹10 कटने का पूरा लॉजिक)
// ---------------------------------------------------------
class CustomerServiceScreen extends StatefulWidget {
  final String clientPhone;

  const CustomerServiceScreen({super.key, required this.clientPhone});

  @override
  State<CustomerServiceScreen> createState() => _CustomerServiceScreenState();
}

class _CustomerServiceScreenState extends State<CustomerServiceScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _displayLimit = 15;
  int _walletBalance = 0;

  final ScrollController _scrollController = ScrollController();
  final DatabaseReference _workersRef = FirebaseDatabase.instance.ref().child('public_workers');
  late DatabaseReference _clientRef;

  @override
  void initState() {
    super.initState();
    _clientRef = FirebaseDatabase.instance.ref().child('clients').child(widget.clientPhone);
    _loadWalletBalance();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        setState(() {
          _displayLimit += 15;
        });
      }
    });
  }

  void _loadWalletBalance() {
    _clientRef.child('wallet_balance').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _walletBalance = (event.snapshot.value as num).toInt();
        });
      } else {
        _clientRef.set({'wallet_balance': 0});
      }
    });
  }

  void _openRechargeSheet() {
    PaymentHelper.showPaymentBottomSheet(
      context: context,
      isWorkerSubscription: false,
      onSuccess: (amt) async {
        await _clientRef.update({'wallet_balance': _walletBalance + amt});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₹$amt सफ़लतापूर्वक रीचार्ज हुए!')));
        }
      },
    );
  }

  Future<void> _handleContactAction(String phone, String type) async {
    if (_walletBalance < 10) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('बैलेंस कम है!'),
          content: const Text('कारीगर से बात करने के लिए वॉलेट में कम से कम ₹10 होना आवश्यक है।'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                Navigator.pop(context);
                _openRechargeSheet();
              },
              child: const Text('रीचार्ज करें', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    await _clientRef.update({'wallet_balance': _walletBalance - 10});

    if (type == 'call') {
      launchUrl(Uri.parse('tel:$phone'));
    } else {
      launchUrl(Uri.parse('whatsapp://send?phone=+91$phone&text=नमस्ते, मुझे आपके काम की जरूरत है।'));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('कारीगर खोजें'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ActionChip(
              backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
              avatar: const Icon(Icons.account_balance_wallet, size: 18, color: Color(0xFF10B981)),
              label: Text('₹$_walletBalance', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              onPressed: _openRechargeSheet,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'क्या काम चाहिए? (जैसे: प्लंबर, मिस्त्री, कारपेंटर)...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          Expanded(
            child: FirebaseAnimatedList(
              query: _workersRef.limitToFirst(_displayLimit),
              controller: _scrollController,
              itemBuilder: (context, snapshot, animation, index) {
                if (snapshot.value == null) return Container();
                Map workerData = snapshot.value as Map;
                String name = workerData['name'] ?? 'नाम उपलब्ध नहीं';
                String skill = workerData['skill'] ?? 'हुनर अज्ञात';
                String phone = workerData['phone'] ?? '';
                String address = workerData['address'] ?? '';
                String profileImg = workerData['profileImage'] ?? '';

                bool matchesSearch = _searchQuery.isEmpty || 
                    name.toLowerCase().contains(_searchQuery) || 
                    skill.toLowerCase().contains(_searchQuery);

                if (!matchesSearch) return Container();

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, spreadRadius: 2)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: profileImg.isNotEmpty ? MemoryImage(base64Decode(profileImg)) : null,
                        child: profileImg.isEmpty ? const Icon(Icons.person, size: 28, color: Colors.grey) : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(skill, style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 6),
                            if (address.isNotEmpty)
                              Text('पता: $address', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 2),
                            const Text('संपर्क करने पर ₹10 कटेगा', style: TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => _handleContactAction(phone, 'call'),
                            icon: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Color(0xFF10B981),
                              child: Icon(Icons.call, color: Colors.white, size: 18),
                            ),
                          ),
                          const SizedBox(height: 2),
                          IconButton(
                            onPressed: () => _handleContactAction(phone, 'whatsapp'),
                            icon: const CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.green,
                              child: Icon(Icons.chat, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ],
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
// 6. REGISTER WORKER SCREEN (सब्सक्रिप्शन प्लान चयन)
// ---------------------------------------------------------
class RegisterWorkerScreen extends StatefulWidget {
  final String workerPhone;
  const RegisterWorkerScreen({super.key, required this.workerPhone});

  @override
  State<RegisterWorkerScreen> createState() => _RegisterWorkerScreenState();
}

class _RegisterWorkerScreenState extends State<RegisterWorkerScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  String? _base64Image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.workerPhone;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _base64Image = base64Encode(bytes);
      });
    }
  }

  void _startRegistrationWithSubscription() {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String skill = _skillController.text.trim();
    String address = _addressController.text.trim();

    if (name.isEmpty || phone.length < 10 || skill.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया नाम, सही फोन नंबर और हुनर भरें')),
      );
      return;
    }

    PaymentHelper.showPaymentBottomSheet(
      context: context,
      isWorkerSubscription: true,
      onSuccess: (paidAmount) async {
        setState(() {
          _isUploading = true;
        });

        try {
          DatabaseReference ref = FirebaseDatabase.instance.ref().child('public_workers').child(phone);
          await ref.set({
            'name': name,
            'phone': phone,
            'skill': skill,
            'address': address,
            'profileImage': _base64Image ?? '',
            'subscriptionBalance': paidAmount,
            'createdAt': ServerValue.timestamp,
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('बधाई हो! आपकी प्रोफाइल लाइव हो गई है')),
          );
          Navigator.pop(context);
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('त्रुटि: $e')),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isUploading = false;
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('कारीगर रजिस्ट्रेशन')),
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
                    backgroundImage: _base64Image != null ? MemoryImage(base64Decode(_base64Image!)) : null,
                    child: _base64Image == null ? const Icon(Icons.person, size: 50, color: Colors.grey) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'पूरा नाम',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'मोबाइल नंबर',
                prefixText: '+91 ',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillController,
              decoration: InputDecoration(
                labelText: 'अपना हुनर (जैसे: एसी रिपेयर, प्लंबर, राजमिस्त्री)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'पता / एरिया (जैसे: सेक्टर 15, फरीदाबाद)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isUploading ? null : _startRegistrationWithSubscription,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('सब्सक्रिप्शन चुनें और प्रोफाइल लाइव करें', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
