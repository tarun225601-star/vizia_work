import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        primaryColor: const Color(0xFF10B981),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111827),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
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
      backgroundColor: const Color(0xFF0A0E1A),
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
                  color: const Color(0xFF1F2937),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withOpacity(0.3), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: const Icon(Icons.flash_on_rounded, size: 50, color: Color(0xFF10B981)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Viziawork',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              const Text(
                'रोजी-रोटी का सीधा ठिकाना (2050 Edition)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर दर्ज करें',
                  labelStyle: const TextStyle(color: Colors.grey),
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontSize: 18, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFF111827),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
                  elevation: 5,
                ),
                child: const Text('OTP भेजें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
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

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(widget.phone);
    userRef.get().then((snapshot) {
      if (snapshot.exists) {
        Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;
        bool isClient = userData['isClient'] ?? false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => isClient ? ClientDashboard(phone: widget.phone) : WorkerDashboard(phone: widget.phone)),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetupScreen(phone: widget.phone)),
        );
      }
    });
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
            Text('+91 ${widget.phone} पर भेजा गया OTP यहाँ दर्ज करें:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8, color: Colors.white),
              decoration: InputDecoration(
                hintText: '1234',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
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
              child: const Text('सत्यापित करें', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. PROFILE SETUP SCREEN
// ---------------------------------------------------------
class ProfileSetupScreen extends StatefulWidget {
  final String phone;
  const ProfileSetupScreen({super.key, required this.phone});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _skillOrCompanyController = TextEditingController();
  bool _isClient = false;
  String? _profileImageBase64;

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 40);
    if (pickedFile != null) {
      File imgFile = File(pickedFile.path);
      List<int> imageBytes = await imgFile.readAsBytes();
      setState(() {
        _profileImageBase64 = base64Encode(imageBytes);
      });
    }
  }

  void _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कृपया अपना नाम दर्ज करें')));
      return;
    }

    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(widget.phone);
    await userRef.set({
      'phone': widget.phone,
      'name': _nameController.text.trim(),
      'skillOrCompany': _skillOrCompanyController.text.trim(),
      'isClient': _isClient,
      'profileImage': _profileImageBase64 ?? '',
      'rating': 5.0,
      'totalReviews': 0,
      'walletCoins': 100,
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _isClient ? ClientDashboard(phone: widget.phone) : WorkerDashboard(phone: widget.phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('अपनी प्रोफाइल बनाएं')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Viziawork में आपका स्वागत है!\nअपनी सही जानकारी भरें और प्रोफाइल फोटो लगाएं।', style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF1F2937),
                      backgroundImage: _profileImageBase64 != null
                          ? MemoryImage(base64Decode(_profileImageBase64!))
                          : null,
                      child: _profileImageBase64 == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF10B981),
                        child: Icon(Icons.camera_alt, size: 16, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'पूरा नाम',
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillOrCompanyController,
              decoration: InputDecoration(
                labelText: _isClient ? 'कंपनी का नाम / मकान विवरण' : 'आपका हुनर (जैसे: राजमिस्त्री, इलेक्ट्रीशियन)',
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text('आप क्या हैं?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('वर्कर', style: TextStyle(color: Colors.white)),
                    value: false,
                    groupValue: _isClient,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _isClient = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('क्लाइंट', style: TextStyle(color: Colors.white)),
                    value: true,
                    groupValue: _isClient,
                    activeColor: const Color(0xFF10B981),
                    onChanged: (val) => setState(() => _isClient = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF10B981),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('प्रोफाइल सेव करें और आगे बढ़ें', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. CLIENT DASHBOARD (Supports up to 5+ Photos Selection)
// ---------------------------------------------------------
class ClientDashboard extends StatefulWidget {
  final String phone;
  const ClientDashboard({super.key, required this.phone});

  @override
  State<ClientDashboard> createState() => _ClientDashboardState();
}

class _ClientDashboardState extends State<ClientDashboard> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  
  List<String> _selectedImagesBase64 = [];
  bool _isLoading = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('jobs');

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(imageQuality: 50);
    if (pickedFiles.isNotEmpty) {
      for (var file in pickedFiles) {
        File imgFile = File(file.path);
        List<int> imageBytes = await imgFile.readAsBytes();
        _selectedImagesBase64.add(base64Encode(imageBytes));
      }
      setState(() {});
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImagesBase64.removeAt(index);
    });
  }

  Future<void> _postJob() async {
    if (_titleController.text.isEmpty || _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('काम का नाम और बजट भरना ज़रूरी है')));
      return;
    }
    setState(() => _isLoading = true);
    DatabaseReference newJobRef = _dbRef.push();
    await newJobRef.set({
      'id': newJobRef.key,
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'budget': _budgetController.text.trim(),
      'location': _locationController.text.trim(),
      'images': _selectedImagesBase64,
      'clientPhone': widget.phone,
      'timestamp': ServerValue.timestamp,
    });
    _titleController.clear();
    _descController.clear();
    _budgetController.clear();
    _locationController.clear();
    _selectedImagesBase64.clear();
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('काम सफलतापूर्वक पब्लिश हो गया!')));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('क्लाइंट डैशबोर्ड (Viziawork)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person, color: Color(0xFF10B981)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(phone: widget.phone))),
            ),
          ],
          bottom: const TabBar(
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF10B981),
            tabs: [
              Tab(text: 'नया काम पोस्ट करें', icon: Icon(Icons.add_circle)),
              Tab(text: 'मेरी पोस्ट्स', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _titleController, decoration: InputDecoration(labelText: 'काम का नाम (जैसे: मिस्त्री, प्लंबर, इलेक्ट्रीशियन)', filled: true, fillColor: const Color(0xFF111827))),
                  const SizedBox(height: 12),
                  TextField(controller: _descController, decoration: InputDecoration(labelText: 'काम का पूरा विवरण (कैसे करना है, कितना समय, आदि)', filled: true, fillColor: const Color(0xFF111827)), maxLines: 3),
                  const SizedBox(height: 12),
                  TextField(controller: _budgetController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'बजट (₹)', filled: true, fillColor: const Color(0xFF111827))),
                  const SizedBox(height: 12),
                  TextField(controller: _locationController, decoration: InputDecoration(labelText: 'लोकेशन / पूरा पता', filled: true, fillColor: const Color(0xFF111827))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo_library, color: Colors.black),
                    label: const Text('काम की 5 या अधिक फोटो चुनें', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 16),
                  _selectedImagesBase64.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('चुनी गई फोटो (${_selectedImagesBase64.length}):', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImagesBase64.length,
                                itemBuilder: (context, index) => Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      width: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        image: DecorationImage(image: MemoryImage(base64Decode(_selectedImagesBase64[index])), fit: BoxFit.cover),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: GestureDetector(
                                        onTap: () => _removeImage(index),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.red,
                                          child: Icon(Icons.close, size: 14, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _postJob,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text('काम पब्लिश करें', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            FirebaseAnimatedList(
              query: _dbRef.orderByChild('clientPhone').equalTo(widget.phone),
              itemBuilder: (context, snapshot, animation, index) {
                Map jobData = snapshot.value as Map;
                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(jobData['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(jobData['description'] ?? '', style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text('बजट: ₹${jobData['budget']}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. WORKER DASHBOARD (Zoomable Multiple Photos & Full Details)
// ---------------------------------------------------------
class WorkerDashboard extends StatefulWidget {
  final String phone;
  const WorkerDashboard({super.key, required this.phone});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('jobs');
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _userCoins = 50;

  @override
  void initState() {
    super.initState();
    _fetchUserCoins();
  }

  void _fetchUserCoins() {
    FirebaseDatabase.instance.ref().child('users').child(widget.phone).child('walletCoins').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _userCoins = int.parse(event.snapshot.value.toString());
        });
      }
    });
  }

  void _deductCoinsAndReveal(String clientPhone, String location, String title, String description, String budget) async {
    if (_userCoins < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कॉइन खत्म हो गए हैं! कृपया वॉलेट में कॉइन जोड़ें।')));
      return;
    }

    int updatedCoins = _userCoins - 10;
    await FirebaseDatabase.instance.ref().child('users').child(widget.phone).update({'walletCoins': updatedCoins});

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        title: const Text('संपर्क और पूरी डीटेल खुली', style: TextStyle(color: Color(0xFF10B981))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('काम: $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('विवरण: $description', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Text('बजट: ₹$budget', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('लोकेशन: $location', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              Text('मालिक का फोन: +91 $clientPhone', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () {
              Navigator.pop(context);
              launchUrl(Uri.parse('tel:$clientPhone'));
            },
            child: const Text('कॉल करें', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('वर्कर डैशबोर्ड (रोजी-रोटी)'),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981)),
              ),
              child: Text('🪙 कॉइन्स: $_userCoins', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF10B981)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(phone: widget.phone))),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'काम या हुनर खोजें...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                filled: true,
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: FirebaseAnimatedList(
              query: _dbRef,
              itemBuilder: (context, snapshot, animation, index) {
                Map jobData = snapshot.value as Map;
                String title = jobData['title'] ?? '';
                String desc = jobData['description'] ?? '';
                String budget = jobData['budget'] ?? '';
                String location = jobData['location'] ?? 'लोकेशन सुरक्षित';
                String clientPhone = jobData['clientPhone'] ?? '';
                List images = jobData['images'] ?? [];

                if (_searchQuery.isNotEmpty && !title.toLowerCase().contains(_searchQuery)) {
                  return Container();
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: const Color(0xFF1F2937)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
                      const SizedBox(height: 6),
                      Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 12),
                      images.isNotEmpty
                          ? SizedBox(
                              height: 150,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: images.length,
                                itemBuilder: (context, imgIndex) => GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImageViewer(imageBase64: images[imgIndex]),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(image: MemoryImage(base64Decode(images[imgIndex])), fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween, // <-- यहाँ ठीक कर दिया गया है
                        children: [
                          Text('बजट: ₹$budget', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          const Text('लोकेशन: [🪙 10 देकर खोलें]', style: TextStyle(fontSize: 12, color: Colors.redAccent)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _deductCoinsAndReveal(clientPhone, location, title, desc, budget),
                          icon: const Icon(Icons.phone, color: Colors.black),
                          label: const Text('10 कॉइन देकर पूरी डिटेल और नंबर खोलें', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
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
// 6. FULL SCREEN ZOOMABLE IMAGE VIEWER
// ---------------------------------------------------------
class FullScreenImageViewer extends StatelessWidget {
  final String imageBase64;
  const FullScreenImageViewer({super.key, required this.imageBase64});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.memory(base64Decode(imageBase64)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 7. VIEW PROFILE SCREEN
// ---------------------------------------------------------
class ViewProfileScreen extends StatelessWidget {
  final String phone;
  const ViewProfileScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('मेरी प्रोफाइल')),
      body: FutureBuilder(
        future: FirebaseDatabase.instance.ref().child('users').child(phone).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.value == null) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }
          Map userData = snapshot.data!.value as Map;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF1F2937),
                    backgroundImage: userData['profileImage'] != null && userData['profileImage'].isNotEmpty
                        ? MemoryImage(base64Decode(userData['profileImage']))
                        : null,
                    child: userData['profileImage'] == null || userData['profileImage'].isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text(userData['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('+91 ${userData['phone']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('वॉलेट कॉइन्स', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('🪙 ${userData['walletCoins'] ?? 0}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('रेटिंग', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('⭐ ${userData['rating'] ?? 5.0}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
