import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDummyKeyForEndowork",
      appId: "1:23456789:android:abcdef",
      messagingSenderId: "123456789",
      projectId: "endowork",
      databaseURL: "https://endowork-default-rtdb.firebaseio.com/",
    ),
  );
  runApp(const EndoworkApp());
}

class EndoworkApp extends StatelessWidget {
  const EndoworkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ENDOWORK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        primaryColor: const Color(0xFF6366F1),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ---------------------------------------------------------
// 0. SPLASH SCREEN (AUTO LOGIN)
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
    _checkUser();
  }

  void _checkUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('user_phone');
    String? role = prefs.getString('user_role');

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    if (phone != null && phone.isNotEmpty) {
      if (phone == '9999999999' || role == 'ADMIN') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      } else if (role == 'PARTNER') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen(partnerPhone: phone)));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomeScreen(userPhone: phone)));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF6366F1)),
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

  void _sendOtp() {
    String phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया सही 10 अंकों का मोबाइल नंबर दर्ज करें')));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) => OtpScreen(phone: phone)));
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
              const Icon(Icons.handshake_rounded, size: 64, color: Color(0xFF6366F1)),
              const SizedBox(height: 16),
              const Text('ENDOWORK', textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(height: 8),
              const Text('फरीदाबाद (Sector 14-17) - डोमेस्टिक गिग सर्विसेज', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर दर्ज करें',
                  prefixText: '+91 ',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('OTP भेजें', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. OTP SCREEN
// ---------------------------------------------------------
class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();

  void _verify() async {
    String otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सही OTP दर्ज करें (Demo: 1234)')));
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_phone', widget.phone);

    if (widget.phone == '9999999999') {
      await prefs.setString('user_role', 'ADMIN');
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
    } else {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.phone)));
    }
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
            Text('+91 ${widget.phone} पर भेजा गया OTP (1234) दर्ज करें:'),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verify,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF6366F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('सत्यापित करें', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. ROLE SELECTION (CUSTOMER OR PARTNER REGISTRATION)
// ---------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  void _setCustomerRole(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', 'CUSTOMER');
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHomeScreen(userPhone: phone)));
    }
  }

  void _showPartnerRegistrationDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ENDOWORK Partner रजिस्ट्रेशन'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'पूरा नाम', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'एड्रेस (सेक्टर / मोहल्ला)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () async {
              String name = nameController.text.trim();
              String address = addressController.text.trim();
              if (name.isEmpty || address.isEmpty) return;

              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setString('user_role', 'PARTNER');

              // Save partner full details to Firebase RTDB for Admin Dashboard
              await FirebaseDatabase.instance.ref().child('partners').child(phone).set({
                'name': name,
                'phone': phone,
                'address': address,
                'isOnline': true,
                'status': 'APPROVED', // APPROVED or BLOCKED
                'joinedAt': ServerValue.timestamp,
              });

              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PartnerDashboardScreen(partnerPhone: phone)));
              }
            },
            child: const Text('रजिस्टर करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ENDOWORK - प्रोफाइल चुनें')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('आप ऐप का उपयोग किस रूप में करना चाहते हैं?', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            _buildCard(context, '1. काम कराना है (कस्टमर)', 'सेक्टर 14-17 के घरेलू काम कराने के लिए', Icons.home_rounded, () => _setCustomerRole(context)),
            const SizedBox(height: 16),
            _buildCard(context, '2. काम करना है (ENDOWORK Partner)', 'लड़कियों / वर्कर्स के लिए (नाम & एड्रेस भरें)', Icons.engineering_rounded, () => _showPartnerRegistrationDialog(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
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
              Icon(icon, size: 36, color: const Color(0xFF6366F1)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ])),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. CUSTOMER HOME SCREEN (DYNAMIC SERVICES FROM FIREBASE)
// ---------------------------------------------------------
class CustomerHomeScreen extends StatelessWidget {
  final String userPhone;
  CustomerHomeScreen({super.key, required this.userPhone});

  final DatabaseReference _servicesRef = FirebaseDatabase.instance.ref().child('services');

  void _bookService(BuildContext context, String serviceName, String rate) {
    final TextEditingController addressController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$serviceName बुक करें ($rate)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('सेक्टर 14-17 फरीदाबाद का पूरा पता दर्ज करें:'),
            const SizedBox(height: 12),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'कोठी / मकान नंबर और ब्लॉक', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () async {
              String address = addressController.text.trim();
              if (address.isEmpty) return;

              String orderId = FirebaseDatabase.instance.ref().child('orders').push().key ?? 'ord_${DateTime.now().millisecondsSinceEpoch}';
              
              await FirebaseDatabase.instance.ref().child('orders').child(orderId).set({
                'orderId': orderId,
                'serviceName': serviceName,
                'rate': rate,
                'customerPhone': userPhone,
                'address': address,
                'status': 'PENDING',
                'assignedPartnerPhone': 'None',
                'assignedPartnerName': 'Pending Acceptance',
                'timestamp': ServerValue.timestamp,
              });

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गीग बुक हो गई! एडमिन और पार्टनर के पास नोटिफिकेशन चला गया है।')));
                _showPaymentModal(context, orderId);
              }
            },
            child: const Text('बुकिंग पक्की करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPaymentModal(BuildContext context, String orderId) {
    String otp = (1000 + Random().nextInt(9000)).toString();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('कंपनी-पेमेंट & QR कोड'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('काम पूरा होने पर नीचे दिए गए QR कोड से पेमेंट करें।'),
            const SizedBox(height: 16),
            Container(height: 140, width: 140, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.qr_code_2_rounded, size: 90, color: Colors.black87))),
            const SizedBox(height: 16),
            Text('सत्यापन OTP: $otp', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
            const Text('यह OTP काम खत्म होने पर वर्कर को बताएं।', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(context),
            child: const Text('बंद करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ENDOWORK - सेक्टर 14-17'),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: userPhone))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('पसंदीदा घरेलू सेवा चुनें:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder(
                stream: _servicesRef.onValue,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    // Default fallback services if database empty
                    return const Center(child: Text('एडमिन पैनल से सर्विसेज लोड हो रही हैं...'));
                  }

                  Map map = (snapshot.data!.snapshot.value as Map);
                  List list = map.entries.map((e) => {...e.value, 'key': e.key}).toList();

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.1),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      var item = list[index];
                      return InkWell(
                        onTap: () => _bookService(context, item['serviceName'], item['rate']),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cleaning_services_rounded, size: 36, color: Color(0xFF6366F1)),
                              const SizedBox(height: 12),
                              Text(item['serviceName'] ?? 'Service', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(item['rate'] ?? '₹200', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
    );
  }
}

// ---------------------------------------------------------
// 5. PARTNER DASHBOARD (GIG WORKER VIEW)
// ---------------------------------------------------------
class PartnerDashboardScreen extends StatefulWidget {
  final String partnerPhone;
  const PartnerDashboardScreen({super.key, required this.partnerPhone});

  @override
  State<PartnerDashboardScreen> createState() => _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState extends State<PartnerDashboardScreen> {
  bool isOnline = true;
  String partnerName = 'Worker';
  final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref().child('orders');

  @override
  void initState() {
    super.initState();
    _fetchPartnerName();
  }

  void _fetchPartnerName() async {
    var snap = await FirebaseDatabase.instance.ref().child('partners').child(widget.partnerPhone).get();
    if (snap.exists && snap.value != null) {
      Map data = snap.value as Map;
      setState(() {
        partnerName = data['name'] ?? 'Worker';
      });
    }
  }

  void _toggleOnline(bool val) {
    setState(() { isOnline = val; });
    FirebaseDatabase.instance.ref().child('partners').child(widget.partnerPhone).update({'isOnline': val});
  }

  void _acceptOrder(String orderId) {
    _ordersRef.child(orderId).update({
      'status': 'ACCEPTED',
      'assignedPartnerPhone': widget.partnerPhone,
      'assignedPartnerName': partnerName,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('गिग स्वीकार कर ली गई! एडमिन डैशबोर्ड पर अपडेट हो गया है।')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ENDOWORK Partner ($partnerName)'),
        actions: [
          Row(
            children: [
              Text(isOnline ? 'Online 🟢' : 'Offline 🔴', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Switch(value: isOnline, activeColor: Colors.green, onChanged: _toggleOnline),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF6366F1).withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.notifications_active_rounded, color: Color(0xFF6366F1)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOnline ? 'आप ऑनलाइन हैं! नया आर्डर आते ही यहाँ अलर्ट बजेगा।' : 'आप ऑफलाइन हैं। आर्डर पाने के लिए बटन ऑन करें।',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(alignment: Alignment.centerLeft, child: Text('उपलब्ध लाइव गिग्स (Gigs Feed):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          Expanded(
            child: StreamBuilder(
              stream: _ordersRef.onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: Text('कोई नया आर्डर नहीं है।', style: TextStyle(color: Colors.grey)));
                }

                Map ordersMap = (snapshot.data!.snapshot.value as Map);
                List ordersList = ordersMap.entries.map((e) => {...e.value, 'key': e.key}).toList();
                var activeOrders = ordersList.where((o) => o['status'] == 'PENDING').toList();

                if (activeOrders.isEmpty) {
                  return const Center(child: Text('आस-पास कोई आर्डर नहीं है। इंतजार करें...', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  itemCount: activeOrders.length,
                  itemBuilder: (context, index) {
                    var order = activeOrders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.between,
                              children: [
                                Text(order['serviceName'] ?? 'Service', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6366F1))),
                                Text(order['rate'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('पता: ${order['address']}', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                onPressed: isOnline ? () => _acceptOrder(order['key']) : null,
                                child: const Text('गिग बुक करें (Accept Gig)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

// ---------------------------------------------------------
// 6. ADMIN DASHBOARD (TARUN'S MASTER CONTROL ROOM)
// ---------------------------------------------------------
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

  void _showAddServiceDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController rateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('नई सर्विस ऐड करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'सर्विस का नाम (जैसे: सिलाई, सफाई, कुकिंग)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: rateController, decoration: const InputDecoration(labelText: 'रेट (जैसे: ₹200/घंटा या ₹350/विज़िट)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () async {
              String name = nameController.text.trim();
              String rate = rateController.text.trim();
              if (name.isEmpty || rate.isEmpty) return;

              String key = _servicesRef.push().key ?? 'srv_${DateTime.now().millisecondsSinceEpoch}';
              await _servicesRef.child(key).set({
                'serviceName': name,
                'rate': rate,
                'createdAt': ServerValue.timestamp,
              });

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('नई सर्विस डैशबोर्ड में ऐड हो गई!')));
              }
            },
            child: const Text('सेव करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleBlockPartner(String phone, String currentStatus) {
    String newStatus = (currentStatus == 'BLOCKED') ? 'APPROVED' : 'BLOCKED';
    _partnersRef.child(phone).update({'status': newStatus});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('लड़की/पार्टनर का स्टेटस बदल दिया गया: $newStatus')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarun Admin Control Room'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6366F1),
          unselectedColor: Colors.grey,
          indicatorColor: const Color(0xFF6366F1),
          tabs: const [
            Tab(icon: Icon(Icons.work_rounded), text: 'सभी गिग्स (Gigs)'),
            Tab(icon: Icon(Icons.people_rounded), text: 'लड़कियां (Partners)'),
            Tab(icon: Icon(Icons.add_business_rounded), text: 'सर्विस कंट्रोल'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: ALL GIGS TRACKING
          StreamBuilder(
            stream: _ordersRef.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(child: Text('कोई बुकिंग डेटा नहीं है।'));
              }
              Map map = (snapshot.data!.snapshot.value as Map);
              List list = map.entries.map((e) => {...e.value, 'key': e.key}).toList();

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  var gig = list[index];
                  bool isAccepted = gig['status'] == 'ACCEPTED';
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text('${gig['serviceName']} - ${gig['rate'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('कस्टमर: +91 ${gig['customerPhone']} | पता: ${gig['address']}'),
                          const SizedBox(height: 4),
                          Text(
                            isAccepted ? 'बुक्ड बाय (लड़की): ${gig['assignedPartnerName']} (+91 ${gig['assignedPartnerPhone']})' : 'स्टेटस: अभी किसी ने एक्सेप्ट नहीं किया',
                            style: TextStyle(fontWeight: FontWeight.bold, color: isAccepted ? Colors.green : Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // TAB 2: PARTNER DIRECTORY & ID LOCK
          StreamBuilder(
            stream: _partnersRef.onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                return const Center(child: Text('कोई पार्टनर पंजीकृत नहीं है।'));
              }
              Map map = (snapshot.data!.snapshot.value as Map);
              List list = map.entries.map((e) => {...e.value, 'key': e.key}).toList();

              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  var p = list[index];
                  bool isBlocked = p['status'] == 'BLOCKED';
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isBlocked ? Colors.red : Colors.green,
                        child: Text(p['name'] != null && p['name'].toString().isNotEmpty ? p['name'][0] : 'W', style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text('${p['name'] ?? 'Worker'} (+91 ${p['phone']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('एड्रेस: ${p['address'] ?? 'Faridabad'} | स्टेटस: ${p['status']}'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: isBlocked ? Colors.green : Colors.red),
                        onPressed: () => _toggleBlockPartner(p['phone'], p['status'] ?? 'APPROVED'),
                        child: Text(isBlocked ? 'Unblock' : 'Block ID', style: const TextStyle(color: Colors.white, fontSize: 11)),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // TAB 3: DYNAMIC SERVICE MANAGEMENT
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), padding: const EdgeInsets.all(16)),
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: const Text('+ नई सर्विस ऐड करें (सिलाई/क्लीनिंग आदि)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _showAddServiceDialog,
                  ),
                ),
                const SizedBox(height: 16),
                const Align(alignment: Alignment.centerLeft, child: Text('मौजूदा एक्टिव सर्विसेज:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                Expanded(
                  child: StreamBuilder(
                    stream: _servicesRef.onValue,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                        return const Center(child: Text('कोई सर्विस ऐड नहीं है। ऊपर दिए बटन से ऐड करें।'));
                      }
                      Map map = (snapshot.data!.snapshot.value as Map);
                      List list = map.entries.map((e) => {...e.value, 'key': e.key}).toList();

                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          var s = list[index];
                          return Card(
                            child: ListTile(
                              title: Text(s['serviceName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(s['rate'] ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_rounded, color: Colors.red),
                                onPressed: () => _servicesRef.child(s['key']).remove(),
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
