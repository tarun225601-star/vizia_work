import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDummyKeyForEndoworkProductionReady2026",
      appId: "1:999888777666:android:viziaworkapp",
      messagingSenderId: "999888777666",
      projectId: "viziawork",
      databaseURL: "https://viziawork-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(const EndoworkMasterApp());
}

class EndoworkMasterApp extends StatelessWidget {
  const EndoworkMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENDOWORK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          primary: const Color(0xFF4F46E5),
          secondary: const Color(0xFF10B981),
          surface: const Color(0xFFF9FAFB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class ServiceItem {
  final String id;
  final String name;
  final String rate;
  final String category;
  final String iconName;

  ServiceItem({
    required this.id,
    required this.name,
    required this.rate,
    required this.category,
    required this.iconName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'category': category,
      'iconName': iconName,
    };
  }

  factory ServiceItem.fromMap(String key, Map<dynamic, dynamic> map) {
    return ServiceItem(
      id: key,
      name: map['name'] ?? '',
      rate: map['rate'] ?? '',
      category: map['category'] ?? 'General',
      iconName: map['iconName'] ?? 'cleaning_services',
    );
  }
}

class GigBooking {
  final String orderId;
  final String serviceName;
  final String rate;
  final String customerPhone;
  final String customerName;
  final String addressSector;
  final String fullAddress;
  final String workRequirement;
  final double calculatedTotal;
  final double adminCommission;
  final String status;
  final String partnerPhone;
  final String partnerName;
  final String paymentOtp;
  final bool isPaidToCompany;
  final int timestamp;
  final String formattedDate;

  GigBooking({
    required this.orderId,
    required this.serviceName,
    required this.rate,
    required this.customerPhone,
    required this.customerName,
    required this.addressSector,
    required this.fullAddress,
    required this.workRequirement,
    required this.calculatedTotal,
    required this.adminCommission,
    required this.status,
    required this.partnerPhone,
    required this.partnerName,
    required this.paymentOtp,
    required this.isPaidToCompany,
    required this.timestamp,
    required this.formattedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'serviceName': serviceName,
      'rate': rate,
      'customerPhone': customerPhone,
      'customerName': customerName,
      'addressSector': addressSector,
      'fullAddress': fullAddress,
      'workRequirement': workRequirement,
      'calculatedTotal': calculatedTotal,
      'adminCommission': adminCommission,
      'status': status,
      'partnerPhone': partnerPhone,
      'partnerName': partnerName,
      'paymentOtp': paymentOtp,
      'isPaidToCompany': isPaidToCompany,
      'timestamp': timestamp,
      'formattedDate': formattedDate,
    };
  }

  factory GigBooking.fromMap(String key, Map<dynamic, dynamic> map) {
    return GigBooking(
      orderId: key,
      serviceName: map['serviceName'] ?? '',
      rate: map['rate'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerName: map['customerName'] ?? 'Customer',
      addressSector: map['addressSector'] ?? 'Sector 15',
      fullAddress: map['fullAddress'] ?? '',
      workRequirement: map['workRequirement'] ?? 'सामान्य काम',
      calculatedTotal: (map['calculatedTotal'] ?? 200.0).toDouble(),
      adminCommission: (map['adminCommission'] ?? 30.0).toDouble(),
      status: map['status'] ?? 'PENDING',
      partnerPhone: map['partnerPhone'] ?? 'None',
      partnerName: map['partnerName'] ?? 'Unassigned',
      paymentOtp: map['paymentOtp'] ?? '0000',
      isPaidToCompany: map['isPaidToCompany'] ?? false,
      timestamp: map['timestamp'] ?? 0,
      formattedDate: map['formattedDate'] ?? 'हाल ही में',
    );
  }
}

class PartnerProfile {
  final String phone;
  final String name;
  final String address;
  final String skillCategory;
  final bool isOnline;
  final String status;
  final double rating;
  final int totalJobs;

  PartnerProfile({
    required this.phone,
    required this.name,
    required this.address,
    required this.skillCategory,
    required this.isOnline,
    required this.status,
    required this.rating,
    required this.totalJobs,
  });

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
      'address': address,
      'skillCategory': skillCategory,
      'isOnline': isOnline,
      'status': status,
      'rating': rating,
      'totalJobs': totalJobs,
    };
  }

  factory PartnerProfile.fromMap(String key, Map<dynamic, dynamic> map) {
    return PartnerProfile(
      phone: key,
      name: map['name'] ?? 'Partner',
      address: map['address'] ?? 'Faridabad',
      skillCategory: map['skillCategory'] ?? 'All Services',
      isOnline: map['isOnline'] ?? false,
      status: map['status'] ?? 'APPROVED',
      rating: (map['rating'] ?? 5.0).toDouble(),
      totalJobs: map['totalJobs'] ?? 0,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  void _bootstrapApp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('user_phone');
    String? role = prefs.getString('user_role');

    _seedDefaultServicesIfNecessary();

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    if (phone != null && phone.isNotEmpty) {
      if (phone == '9999999999' || role == 'ADMIN') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else if (role == 'PARTNER') {
        var snap = await FirebaseDatabase.instance.ref().child('partners').child(phone).get();
        if (!mounted) return;
        if (snap.exists && snap.value != null) {
          Map data = snap.value as Map;
          if (data['status'] == 'BLOCKED') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlockedAccountScreen(phone: phone)));
            return;
          }
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen(partnerPhone: phone)));
          return;
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: phone)));
          return;
        }
      } else if (role == 'CUSTOMER') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomeScreen(userPhone: phone)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: phone)));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  void _seedDefaultServicesIfNecessary() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('services');
    var snap = await ref.get();
    if (!snap.exists || snap.value == null) {
      List<Map<String, String>> defaults = [
        {'name': 'सफाई (House Cleaning)', 'rate': '₹200/घंटा', 'category': 'Cleaning', 'iconName': 'cleaning_services'},
        {'name': 'कुकिंग (Home Cook)', 'rate': '₹350/विज़िट', 'category': 'Cooking', 'iconName': 'restaurant'},
        {'name': 'ब्यूटी & होम सैलून (Salon)', 'rate': 'पैकेज अनुसार', 'category': 'Beauty', 'iconName': 'face'},
        {'name': 'सिलाई & फिटिंग (Tailoring)', 'rate': '₹150/कपड़ा', 'category': 'Stitching', 'iconName': 'content_cut'},
        {'name': 'ट्यूशन (Home Tuition)', 'rate': '₹2500/महीना', 'category': 'Tuition', 'iconName': 'menu_book'},
      ];
      for (var s in defaults) {
        String key = ref.push().key!;
        ref.child(key).set(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)],
              ),
              child: const Icon(Icons.handshake_rounded, size: 64, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 24),
            const Text('ENDOWORK', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            Text('फरीदाबाद (Sector 14 - 17) • Trusted Domestic Gigs', style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  void _handleSendOtp() {
    String phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सही 10-अंकों का मोबाइल नंबर दर्ज करें!'), backgroundColor: Colors.red),
      );
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => OtpVerificationScreen(phone: phone)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield_outlined, size: 70, color: Color(0xFF4F46E5)),
              const SizedBox(height: 20),
              const Text('ENDOWORK लॉगिन', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('सुरक्षित घरेलू सेवाएं - सेक्टर 14, 15, 16, 17 फरीदाबाद', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर',
                  hintText: '98XXXXXXXX',
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontSize: 18, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleSendOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('OTP प्राप्त करें', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              const Text(
                'नोट: एडमिन लॉगिन के लिए "9999999999" का प्रयोग करें।',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  const OtpVerificationScreen({super.key, required this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() async {
    String otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सही 4-अंकों का OTP दर्ज करें (Demo: 1234)')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', widget.phone);

    if (!mounted) return;

    if (widget.phone == '9999999999') {
      await prefs.setString('user_role', 'ADMIN');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
    } else {
      var snap = await FirebaseDatabase.instance.ref().child('partners').child(widget.phone).get();
      if (!mounted) return;
      if (snap.exists && snap.value != null) {
        await prefs.setString('user_role', 'PARTNER');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen(partnerPhone: widget.phone)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.phone)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP वेरिफिकेशन')),
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('+91 ${widget.phone} पर भेजा गया 4-अंकों का कोड (1234) डालें:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 16),
              decoration: InputDecoration(
                hintText: '1234',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('वेरिफाई करें', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectionScreen extends StatelessWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  void _chooseCustomerRole(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', 'CUSTOMER');
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomeScreen(userPhone: phone)));
    }
  }

  void _showPartnerForm(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    String selectedSkill = 'सफाई (Cleaning)';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('ENDOWORK Partner रजिस्ट्रेशन', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('अपनी प्रोफाइल बनाएं ताकि आपके पास सेक्टर 14-17 के ऑर्डर आ सकें।', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'पूरा नाम', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              TextField(controller: addressController, decoration: InputDecoration(labelText: 'एड्रेस (मकान नंबर / गली / सेक्टर)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedSkill,
                decoration: InputDecoration(labelText: 'मुख्य हुनर (Skill)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                items: ['सफाई (Cleaning)', 'कुकिंग (Cooking)', 'ब्यूटी (Salon)', 'सिलाई (Tailoring)', 'ट्यूशन (Tuition)', 'ऑल-राउंडर'].map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) { if (val != null) selectedSkill = val; },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () async {
                  String name = nameController.text.trim();
                  String address = addressController.text.trim();
                  if (name.isEmpty || address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सभी जानकारी भरें!')));
                    return;
                  }

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('user_role', 'PARTNER');

                  PartnerProfile partner = PartnerProfile(
                    phone: phone,
                    name: name,
                    address: address,
                    skillCategory: selectedSkill,
                    isOnline: true,
                    status: 'APPROVED',
                    rating: 5.0,
                    totalJobs: 0,
                  );

                  await FirebaseDatabase.instance.ref().child('partners').child(phone).set(partner.toMap());

                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen(partnerPhone: phone)));
                  }
                },
                child: const Text('रजिस्टर करें और काम शुरू करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ENDOWORK - रोल चुनें')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('आप ENDOWORK का इस्तेमाल कैसे करेंगे?', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            _buildRoleCard(
              context,
              title: '1. काम कराना है (कस्टमर)',
              subtitle: 'सेक्टर 14, 15, 16, 17 फरीदाबाद के घरों के लिए घरेलू वर्कर बुक करें।',
              icon: Icons.home_work_rounded,
              color: const Color(0xFF4F46E5),
              onTap: () => _chooseCustomerRole(context),
            ),
            const SizedBox(height: 16),
            _buildRoleCard(
              context,
              title: '2. काम करना है (ENDOWORK Partner)',
              subtitle: 'हुनरमंद महिलाएं/लड़कियां। जीरो कमीशन फ्रॉड, डायरेक्ट कंपनी पेमेंट्स।',
              icon: Icons.person_search_rounded,
              color: const Color(0xFF10B981),
              onTap: () => _showPartnerForm(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 36),
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
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerHomeScreen extends StatefulWidget {
  final String userPhone;
  const CustomerHomeScreen({super.key, required this.userPhone});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final DatabaseReference _servicesRef = FirebaseDatabase.instance.ref().child('services');
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');

  final List<ServiceItem> _fallbackServices = [
    ServiceItem(id: '1', name: 'सफाई (House Cleaning)', rate: '₹200/घंटा', category: 'Cleaning', iconName: 'cleaning_services'),
    ServiceItem(id: '2', name: 'कुकिंग (Home Cook)', rate: '₹350/विज़िट', category: 'Cooking', iconName: 'restaurant'),
    ServiceItem(id: '3', name: 'ब्यूटी & होम सैलून (Salon)', rate: 'पैकेज अनुसार', category: 'Beauty', iconName: 'face'),
    ServiceItem(id: '4', name: 'सिलाई & फिटिंग (Tailoring)', rate: '₹150/कपड़ा', category: 'Stitching', iconName: 'content_cut'),
    ServiceItem(id: '5', name: 'ट्यूशन (Home Tuition)', rate: '₹2500/महीना', category: 'Tuition', iconName: 'menu_book'),
  ];

  void _initiateBookingModal(BuildContext context, ServiceItem service) {
    final TextEditingController nameController = TextEditingController(text: 'Customer');
    final TextEditingController addressController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    String selectedSector = 'Sector 15';
    String selectedQuantity = '2 घंटे / 2 सूट';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('${service.name} बुक करें', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                Text('रेट: ${service.rate}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'आपका नाम', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedSector,
                  decoration: InputDecoration(labelText: 'सेक्टर (Faridabad)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: ['Sector 14', 'Sector 15', 'Sector 16', 'Sector 17'].map((sec) {
                    return DropdownMenuItem(value: sec, child: Text(sec));
                  }).toList(),
                  onChanged: (val) { if (val != null) selectedSector = val; },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: 'कोठी / मकान नंबर और गली एड्रेस', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedQuantity,
                  decoration: InputDecoration(labelText: 'मात्रा / समय चुनें', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: [
                    '1 घंटा / 1 सूट',
                    '2 घंटे / 2 सूट',
                    '3 घंटे / 3 सूट',
                    '4 घंटे / 4 सूट',
                    'पूरा दिन (Full Day)',
                    'महीने का पैकेज',
                  ].map((item) {
                    return DropdownMenuItem(value: item, child: Text(item));
                  }).toList(),
                  onChanged: (val) { if (val != null) selectedQuantity = val; },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'यहाँ लिखकर बताएं (जैसे 2 सूट की फिटिंग या झाड़ू-पोछा)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String address = addressController.text.trim();
                    String customNote = noteController.text.trim();
                    if (address.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया पूरा एड्रेस दर्ज करें!')));
                      return;
                    }

                    double baseRate = 200.0;
                    if (service.rate.contains('150')) baseRate = 150.0;
                    else if (service.rate.contains('350')) baseRate = 350.0;
                    else if (service.rate.contains('2500')) baseRate = 2500.0;
                    else if (service.rate.contains('पैकेज')) baseRate = 500.0;

                    int multiplier = 1;
                    if (selectedQuantity.startsWith('2')) multiplier = 2;
                    else if (selectedQuantity.startsWith('3')) multiplier = 3;
                    else if (selectedQuantity.startsWith('4')) multiplier = 4;
                    else if (selectedQuantity.contains('पूरा दिन')) multiplier = 6;
                    else if (selectedQuantity.contains('महीने')) multiplier = 1;

                    double calculatedTotal = baseRate * multiplier;
                    double adminCommission = calculatedTotal * 0.15;

                    String orderId = _ordersRef.push().key!;
                    String generatedOtp = (1000 + Random().nextInt(9000)).toString();

                    DateTime now = DateTime.now();
                    String formattedDate = "${now.day}/${now.month}/${now.year} - ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

                    String finalRequirement = 'मात्रा/समय: $selectedQuantity | विवरण: ${customNote.isEmpty ? "सामान्य" : customNote}';

                    GigBooking booking = GigBooking(
                      orderId: orderId,
                      serviceName: service.name,
                      rate: service.rate,
                      customerPhone: widget.userPhone,
                      customerName: name,
                      addressSector: selectedSector,
                      fullAddress: address,
                      workRequirement: finalRequirement,
                      calculatedTotal: calculatedTotal,
                      adminCommission: adminCommission,
                      status: 'PENDING',
                      partnerPhone: 'None',
                      partnerName: 'Pending Acceptance',
                      paymentOtp: generatedOtp,
                      isPaidToCompany: false,
                      timestamp: now.millisecondsSinceEpoch,
                      formattedDate: formattedDate,
                    );

                    await _ordersRef.child(orderId).set(booking.toMap());

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ऑर्डर बुक हुआ! कुल: ₹$calculatedTotal'), backgroundColor: Colors.green),
                      );
                    }
                  },
                  child: const Text('ऑर्डर कंफर्म करें (Book Order)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENDOWORK - घरेलू सेवाएं'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'मेरी बुकिंग्स',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerOrdersListScreen(phone: widget.userPhone))),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'रोल बदलें',
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.userPhone))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('100% वेरिफाइड वर्कर्स', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Text('सेक्टर 14, 15, 16, 17 फरीदाबाद। डायरेक्ट कंपनी पेमेंट से पूर्ण सुरक्षा।', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_user_rounded, color: Colors.white, size: 48),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('उपलब्ध सेवाएं (Book Domestic Help):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            StreamBuilder(
              stream: _servicesRef.onValue,
              builder: (context, snapshot) {
                List<ServiceItem> services = _fallbackServices;

                if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                  try {
                    Map map = (snapshot.data!.snapshot.value as Map);
                    services = [];
                    map.forEach((k, v) => services.add(ServiceItem.fromMap(k, v)));
                  } catch (e) {
                    services = _fallbackServices;
                  }
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.0),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    var s = services[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: InkWell(
                        onTap: () => _initiateBookingModal(context, s),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: const Color(0xFF4F46E5).withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.cleaning_services_rounded, color: Color(0xFF4F46E5), size: 32),
                              ),
                              const SizedBox(height: 12),
                              Text(s.name, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(s.rate, style: const TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerOrdersListScreen extends StatelessWidget {
  final String phone;
  const CustomerOrdersListScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('मेरी बुकिंग्स (Order History)')),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref().child('orders').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: Text('आपकी कोई एक्टिव बुकिंग नहीं है।'));
          }

          Map map = (snapshot.data!.snapshot.value as Map);
          List<GigBooking> myOrders = [];
          map.forEach((k, v) {
            var g = GigBooking.fromMap(k, v);
            if (g.customerPhone == phone) myOrders.add(g);
          });

          if (myOrders.isEmpty) {
            return const Center(child: Text('कोई बुकिंग रिकॉर्ड नहीं मिला।'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myOrders.length,
            itemBuilder: (context, index) {
              var order = myOrders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(order.serviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Chip(
                            label: Text(order.status, style: const TextStyle(color: Colors.white, fontSize: 11)),
                            backgroundColor: order.status == 'ACCEPTED' ? Colors.green : Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('तारीख/समय: ${order.formattedDate}', style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold)),
                      Text('पता: ${order.addressSector}, ${order.fullAddress}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text('विवरण: ${order.workRequirement}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                      const SizedBox(height: 4),
                      Text('कुल राशि: ₹${order.calculatedTotal}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Divider(height: 16),
                      Text('पार्टनर: ${order.partnerName} (${order.partnerPhone})\nOTP: ${order.paymentOtp}', style: const TextStyle(fontSize: 12)),
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
}

class PartnerDashboardScreen extends StatefulWidget {
  final String partnerPhone;
  const PartnerDashboardScreen({super.key, required this.partnerPhone});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  bool isOnline = true;
  String partnerName = 'Partner';
  String skillCategory = 'Service';
  String address = 'Faridabad';
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');

  @override
  void initState() {
    super.initState();
    _loadPartnerInfo();
    _listenForBlockStatus();
  }

  void _loadPartnerInfo() async {
    var snap = await FirebaseDatabase.instance.ref().child('partners').child(widget.partnerPhone).get();
    if (snap.exists && snap.value != null) {
      Map data = snap.value as Map;
      setState(() {
        partnerName = data['name'] ?? 'Partner';
        skillCategory = data['skillCategory'] ?? 'Service';
        address = data['address'] ?? 'Faridabad';
        isOnline = data['isOnline'] ?? true;
      });
    }
  }

  void _listenForBlockStatus() {
    FirebaseDatabase.instance.ref().child('partners').child(widget.partnerPhone).child('status').onValue.listen((event) {
      if (event.snapshot.value == 'BLOCKED') {
        if (mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlockedAccountScreen(phone: widget.partnerPhone)));
        }
      }
    });
  }

  void _toggleOnlineState(bool val) {
    setState(() { isOnline = val; });
    FirebaseDatabase.instance.ref().child('partners').child(widget.partnerPhone).update({'isOnline': val});
  }

  void _acceptGigJob(GigBooking gig) async {
    await _ordersRef.child(gig.orderId).update({
      'status': 'ACCEPTED',
      'partnerPhone': widget.partnerPhone,
      'partnerName': partnerName,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${gig.serviceName} बुकिंग स्वीकार कर ली गई!'), backgroundColor: Colors.green),
      );
    }
  }

  void _showPartnerProfileModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder(
            stream: _ordersRef.onValue,
            builder: (context, snapshot) {
              double myTotalEarnings = 0;
              int myTotalJobs = 0;
              List<GigBooking> myAcceptedGigs = [];

              if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                Map map = (snapshot.data!.snapshot.value as Map);
                map.forEach((k, v) {
                  var g = GigBooking.fromMap(k, v);
                  if (g.partnerPhone == widget.partnerPhone && g.status == 'ACCEPTED') {
                    myTotalEarnings += g.calculatedTotal;
                    myTotalJobs++;
                    myAcceptedGigs.add(g);
                  }
                });
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(partnerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        tooltip: 'लॉगआउट',
                        onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.clear();
                          if (context.mounted) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                          }
                        },
                      ),
                    ],
                  ),
                  Text('मोबाइल: +91 ${widget.partnerPhone}', style: const TextStyle(color: Colors.grey)),
                  Text('हुनर: $skillCategory | पता: $address', style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('कुल काम (Jobs)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('$myTotalJobs', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.indigo.shade200),
                        Column(
                          children: [
                            const Text('कुल बिजनेस (Total)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text('₹$myTotalEarnings', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('मेरे पूरे किए गए काम (तारीख के अनुसार):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: myAcceptedGigs.isEmpty
                        ? const Center(child: Text('अभी तक कोई काम पूरा नहीं किया।', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: myAcceptedGigs.length,
                            itemBuilder: (context, index) {
                              var g = myAcceptedGigs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(g.serviceName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  subtitle: Text('तारीख: ${g.formattedDate}\nविवरण: ${g.workRequirement}', style: const TextStyle(fontSize: 11)),
                                  trailing: Text('₹${g.calculatedTotal}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ENDOWORK Partner ($partnerName)'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Text(isOnline ? 'Online 🟢' : 'Offline 🔴', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOnline ? Colors.green : Colors.red)),
                Switch(value: isOnline, activeColor: Colors.green, onChanged: _toggleOnlineState),
              ],
            ),
          ),
          IconButton(
            icon: const CircleAvatar(backgroundColor: Color(0xFF4F46E5), child: Icon(Icons.person, color: Colors.white, size: 20)),
            tooltip: 'मेरी प्रोफाइल और बिजनेस',
            onPressed: () => _showPartnerProfileModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: isOnline ? Colors.green.shade50 : Colors.red.shade50,
            child: Row(
              children: [
                Icon(isOnline ? Icons.notifications_active_rounded : Icons.notifications_off_rounded, color: isOnline ? Colors.green : Colors.red),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOnline ? 'आप ऑनलाइन हैं! नए काम आते ही आपके फोन पर स्क्रीन फीड बजेगी।' : 'आप ऑफलाइन हैं। काम पाने के लिए ऊपर दिए स्विच से ऑनलाइन हों।',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isOnline ? Colors.green.shade900 : Colors.red.shade900),
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(alignment: Alignment.centerLeft, child: Text('लाइव गिग्स फीड (Live Available Orders):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ),

          Expanded(
            child: StreamBuilder(
              stream: _ordersRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text('फिलहाल कोई नया आर्डर नहीं है।', style: TextStyle(color: Colors.grey)));
                }

                Map map = (snapshot.data!.snapshot.value as Map);
                List<GigBooking> availableGigs = [];
                map.forEach((k, v) {
                  var g = GigBooking.fromMap(k, v);
                  if (g.status == 'PENDING') availableGigs.add(g);
                });

                if (availableGigs.isEmpty) {
                  return const Center(child: Text('आस-पास कोई नया ऑर्डर नहीं है। इंतजार करें...', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableGigs.length,
                  itemBuilder: (context, index) {
                    var gig = availableGigs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(gig.serviceName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                Text('₹${gig.calculatedTotal}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('तारीख/समय: ${gig.formattedDate}', style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 16, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text('${gig.addressSector} - ${gig.fullAddress}', style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Text('काम का विवरण: ${gig.workRequirement}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                            const SizedBox(height: 4),
                            Text('कस्टमर: ${gig.customerName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
                                onPressed: isOnline ? () => _acceptGigJob(gig) : null,
                                child: const Text('गिग बुक करें (Accept Order)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
          ),
        ],
      ),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');
  final DatabaseReference _partnersRef = FirebaseDatabase.instance.ref().child('partners');
  final DatabaseReference _servicesRef = FirebaseDatabase.instance.ref().child('services');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showAddServiceModal() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController rateController = TextEditingController();
    String category = 'General';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('नई सर्विस ऐड करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'सर्विस का नाम (जैसे सिलाई, क्लीनिंग)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: rateController, decoration: const InputDecoration(labelText: 'रेट (जैसे ₹200/घंटा)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () async {
              String name = nameController.text.trim();
              String rate = rateController.text.trim();
              if (name.isEmpty || rate.isEmpty) return;

              String key = _servicesRef.push().key!;
              ServiceItem item = ServiceItem(id: key, name: name, rate: rate, category: category, iconName: 'build');
              await _servicesRef.child(key).set(item.toMap());

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('नई सर्विस सफलतापूर्वक ऐड हो गई!')));
              }
            },
            child: const Text('सेव करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditServiceModal(ServiceItem service) {
    final TextEditingController nameController = TextEditingController(text: service.name);
    final TextEditingController rateController = TextEditingController(text: service.rate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${service.name} एडिट करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'सर्विस का नाम', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: rateController, decoration: const InputDecoration(labelText: 'रेट (जैसे ₹150/कपड़ा या ₹250/घंटा)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () async {
              String name = nameController.text.trim();
              String rate = rateController.text.trim();
              if (name.isEmpty || rate.isEmpty) return;

              await _servicesRef.child(service.id).update({
                'name': name,
                'rate': rate,
              });

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सर्विस का रेट और नाम अपडेट हो गया!'), backgroundColor: Colors.green));
              }
            },
            child: const Text('अपडेट करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _togglePartnerBlockStatus(String phone, String currentStatus) async {
    String newStatus = (currentStatus == 'BLOCKED') ? 'APPROVED' : 'BLOCKED';
    await _partnersRef.child(phone).update({'status': newStatus});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('पार्टनर (+91 $phone) स्टेटस बदल दिया गया: $newStatus')));
    }
  }

  void _showWorkerDetailReport(BuildContext context, PartnerProfile partner) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: StreamBuilder(
            stream: _ordersRef.onValue,
            builder: (context, snapshot) {
              double workerTotalBiz = 0;
              int workerJobsCount = 0;
              List<GigBooking> workerGigs = [];

              if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                Map map = (snapshot.data!.snapshot.value as Map);
                map.forEach((k, v) {
                  var g = GigBooking.fromMap(k, v);
                  if (g.partnerPhone == partner.phone && g.status == 'ACCEPTED') {
                    workerTotalBiz += g.calculatedTotal;
                    workerJobsCount++;
                    workerGigs.add(g);
                  }
                });
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${partner.name} (${partner.phone})', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  Text('हुनर: ${partner.skillCategory} | पता: ${partner.address}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('कुल काम किए', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('$workerJobsCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                        Container(height: 25, width: 1, color: Colors.green.shade200),
                        Column(
                          children: [
                            const Text('कुल बिजनेस (Total)', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            Text('₹$workerTotalBiz', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('तारीख-दर-तारीख काम का हिसाब (Date-wise Report):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: workerGigs.isEmpty
                        ? const Center(child: Text('इस वर्कर ने अभी कोई काम नहीं किया।', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: workerGigs.length,
                            itemBuilder: (context, index) {
                              var g = workerGigs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(g.serviceName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                  subtitle: Text('दिनांक: ${g.formattedDate}\nविवरण: ${g.workRequirement}', style: const TextStyle(fontSize: 11)),
                                  trailing: Text('₹${g.calculatedTotal}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarun - Admin Control Panel'),
        backgroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4F46E5),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4F46E5),
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long_rounded), text: 'सभी गिग्स'),
            Tab(icon: Icon(Icons.female_rounded), text: 'वर्कर डायरेक्टरी'),
            Tab(icon: Icon(Icons.add_circle_outline_rounded), text: 'सर्विस कंट्रोल'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder(
            stream: _ordersRef.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(child: Text('कोई लाइव गिग डेटा उपलब्ध नहीं है।'));
              }

              Map map = (snapshot.data!.snapshot.value as Map);
              List<GigBooking> allGigs = [];
              double totalRevenue = 0;
              double totalAdminCommission = 0;

              map.forEach((k, v) {
                var g = GigBooking.fromMap(k, v);
                allGigs.add(g);
                if (g.status == 'ACCEPTED') {
                  totalRevenue += g.calculatedTotal;
                  totalAdminCommission += g.adminCommission;
                }
              });

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('कुल पूरा बिजनेस', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('₹$totalRevenue', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.white54),
                        Column(
                          children: [
                            const Text('आपका कमीशन (15%)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('₹$totalAdminCommission', style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: allGigs.length,
                      itemBuilder: (context, index) {
                        var gig = allGigs[index];
                        bool isAccepted = gig.status == 'ACCEPTED';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(gig.serviceName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Chip(
                                      label: Text(gig.status, style: const TextStyle(color: Colors.white, fontSize: 10)),
                                      backgroundColor: isAccepted ? Colors.green : Colors.orange,
                                    ),
                                  ],
                                ),
                                Text('तारीख व समय: ${gig.formattedDate}', style: const TextStyle(fontSize: 12, color: Colors.indigo, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('कस्टमर: ${gig.customerName} (+91 ${gig.customerPhone})', style: const TextStyle(fontSize: 13)),
                                Text('पता: ${gig.addressSector}, ${gig.fullAddress}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text('विवरण: ${gig.workRequirement}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('कुल राशि: ₹${gig.calculatedTotal}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    Text('कमीशन: ₹${gig.adminCommission}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      isAccepted ? 'कारीगर: ${gig.partnerName} (+91 ${gig.partnerPhone})' : 'कारीगर: अभी असाइन नहीं हुआ',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isAccepted ? Colors.green : Colors.red),
                                    ),
                                    Text('OTP: ${gig.paymentOtp}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          StreamBuilder(
            stream: _partnersRef.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(child: Text('कोई पंजीकृत वर्कर नहीं मिला।'));
              }

              Map map = (snapshot.data!.snapshot.value as Map);
              List<PartnerProfile> partners = [];
              map.forEach((k, v) => partners.add(PartnerProfile.fromMap(k, v)));

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: partners.length,
                itemBuilder: (context, index) {
                  var p = partners[index];
                  bool isBlocked = p.status == 'BLOCKED';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _showWorkerDetailReport(context, p),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isBlocked ? Colors.red : Colors.green,
                              child: Text(p.name.isNotEmpty ? p.name[0] : 'W', style: const TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${p.name} (+91 ${p.phone})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text('हुनर: ${p.skillCategory} | पता: ${p.address}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text('स्टेटस: ${p.status} (क्लिक करके रिपोर्ट देखें)', style: const TextStyle(fontSize: 11, color: Color(0xFF4F46E5), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: isBlocked ? Colors.green : Colors.red),
                              onPressed: () => _togglePartnerBlockStatus(p.phone, p.status),
                              child: Text(isBlocked ? 'Unblock' : 'Block', style: const TextStyle(color: Colors.white, fontSize: 10)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: const EdgeInsets.all(16)),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('+ नई सर्विस जोड़ें (सिलाई / सफाई आदि)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _showAddServiceModal,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerLeft, child: Text('वर्तमान लाइव सर्विसेज (Edit / Delete):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder(
                    stream: _servicesRef.onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                        return const Center(child: Text('कोई सर्विस उपलब्ध नहीं है।'));
                      }

                      Map map = (snapshot.data!.snapshot.value as Map);
                      List<ServiceItem> services = [];
                      map.forEach((k, v) => services.add(ServiceItem.fromMap(k, v)));

                      return ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          var s = services[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(s.rate, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, color: Color(0xFF4F46E5)),
                                    tooltip: 'रेट या नाम एडिट करें',
                                    onPressed: () => _showEditServiceModal(s),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                    tooltip: 'डिलीट करें',
                                    onPressed: () => _servicesRef.child(s.id).remove(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlockedAccountScreen extends StatelessWidget {
  final String phone;
  const BlockedAccountScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.block_rounded, color: Colors.red, size: 80),
              const SizedBox(height: 24),
              const Text('आपकी आईडी लॉक कर दी गई है!', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 12),
              Text(
                'मोबाइल नंबर (+91 $phone) ने नियमों का उल्लंघन किया है। एडमिन की अनुमति के बिना आप लॉगिन नहीं कर सकते।',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (context.mounted) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  }
                },
                child: const Text('लॉगआउट करें', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
