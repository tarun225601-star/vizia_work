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
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        primaryColor: Colors.black,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.w900),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------
// 1. LOGIN SCREEN (Mobile Number Input)
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.flash_on_rounded, size: 80, color: Colors.black),
              const SizedBox(height: 16),
              const Text(
                'Viziawork',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.black, letterSpacing: -1),
              ),
              const SizedBox(height: 8),
              const Text(
                'रोजी-रोटी का सीधा ठिकाना',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 50),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'मोबाइल नंबर दर्ज करें',
                  labelStyle: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.normal),
                  prefixText: '+91 ',
                  prefixStyle: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _sendOtp,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.black,
                  elevation: 0,
                ),
                child: const Text('OTP भेजें', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('OTP सत्यापन')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('+91 ${widget.phone} पर भेजा गया OTP यहाँ दर्ज करें:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '1234',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('सत्यापित करें (Verify)', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. PROFILE SETUP SCREEN (अब फोटो जोड़ने के ऑप्शन के साथ)
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
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => _isClient ? ClientDashboard(phone: widget.phone) : WorkerDashboard(phone: widget.phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('अपनी प्रोफाइल बनाएं')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Viziawork में आपका स्वागत है!\nअपनी सही जानकारी भरें और प्रोफाइल फोटो लगाएं।', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),
            
            // प्रोफाइल फोटो चुनने का सेक्शन
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
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
                        backgroundColor: Colors.black,
                        child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
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
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _skillOrCompanyController,
              decoration: InputDecoration(
                labelText: _isClient ? 'कंपनी का नाम / मकान विवरण' : 'आपका हुनर (जैसे: राजमिस्त्री, इलेक्ट्रीशियन)',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text('आप क्या हैं?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('वर्कर'),
                    value: false,
                    groupValue: _isClient,
                    onChanged: (val) => setState(() => _isClient = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('क्लाइंट'),
                    value: true,
                    groupValue: _isClient,
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
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('प्रोफाइल सेव करें और आगे बढ़ें', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. CLIENT DASHBOARD (Post, Edit, Delete, Manage Posts)
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
        if (_selectedImagesBase64.length < 5) {
          File imgFile = File(file.path);
          List<int> imageBytes = await imgFile.readAsBytes();
          _selectedImagesBase64.add(base64Encode(imageBytes));
        }
      }
      setState(() {});
    }
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

  void _deleteJob(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पोस्ट डिलीट करें'),
        content: const Text('क्या आप वाकई इस पोस्ट को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbRef.child(jobId).remove();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पोस्ट डिलीट कर दी गई!')));
            },
            child: const Text('डिलीट', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editJobDialog(Map<dynamic, dynamic> jobData, String jobId) {
    TextLinkEdit titleEdit = TextLinkEdit(jobData['title'] ?? '');
    TextLinkEdit budgetEdit = TextLinkEdit(jobData['budget'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पोस्ट एडिट करें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleEdit.controller, decoration: const InputDecoration(labelText: 'काम का नाम')),
            const SizedBox(height: 10),
            TextField(controller: budgetEdit.controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'बजट (₹)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            onPressed: () async {
              await _dbRef.child(jobId).update({
                'title': titleEdit.controller.text,
                'budget': budgetEdit.controller.text,
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('पोस्ट अपडेट हो गई!')));
            },
            child: const Text('सेव करें'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('क्लाइंट डैशबोर्ड (मैनेज पोस्ट)'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(phone: widget.phone))),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'नया काम पोस्ट करें', icon: Icon(Icons.add_circle)),
              Tab(text: 'मेरी पोस्ट्स (List & Manage)', icon: Icon(Icons.list)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'काम का नाम (जैसे: मिस्त्री, प्लंबर)')),
                  const SizedBox(height: 12),
                  TextField(controller: _descController, decoration: const InputDecoration(labelText: 'काम का विवरण'), maxLines: 2),
                  const SizedBox(height: 12),
                  TextField(controller: _budgetController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'बजट (₹)')),
                  const SizedBox(height: 12),
                  TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'लोकेशन / पूरा पता')),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.photo),
                    label: Text('फोटो जोड़ें (${_selectedImagesBase64.length})'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _postJob,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, minimumSize: const Size(double.infinity, 50)),
                    child: const Text('पब्लिश करें', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ],
              ),
            ),
            FirebaseAnimatedList(
              query: _dbRef.orderByChild('clientPhone').equalTo(widget.phone),
              itemBuilder: (context, snapshot, animation, index) {
                final json = snapshot.value as Map<dynamic, dynamic>?;
                if (json == null) return const SizedBox.shrink();
                String jobId = snapshot.key ?? '';

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(json['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('बजट: ₹${json['budget']} | लोकेशन: ${json['location']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _editJobDialog(json, jobId)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteJob(jobId)),
                      ],
                    ),
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

class TextLinkEdit {
  final TextEditingController controller;
  TextLinkEdit(String text) : controller = TextEditingController(text: text);
}

// ---------------------------------------------------------
// 5. WORKER DASHBOARD (View All Jobs, UPI Unlock & Worker Profile/Rating)
// ---------------------------------------------------------
class WorkerDashboard extends StatefulWidget {
  final String phone;
  const WorkerDashboard({super.key, required this.phone});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final Set<String> _unlockedJobIds = {};
  final String myUpiId = "tarun@paytm";

  Future<void> _launchUpi(String jobId) async {
    final Uri upiUri = Uri.parse("upi://pay?pa=$myUpiId&pn=Viziawork&am=10.00&cu=INR&tn=UnlockJob");
    if (await canLaunchUrl(upiUri)) {
      await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      setState(() => _unlockedJobIds.add(jobId));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('सफलतापूर्वक भुगतान के बाद डिटेल्स खुल गई!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('UPI ऐप नहीं मिला')));
    }
  }

  void _rateWorkerDialog(String workerPhone) {
    double selectedRating = 5.0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('वर्कर को रेटिंग दें'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('आपको यह काम कैसा लगा? स्टार चुनें:'),
            Slider(
              value: selectedRating,
              min: 1,
              max: 5,
              divisions: 4,
              label: selectedRating.toString(),
              onChanged: (val) => setState(() => selectedRating = val),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(workerPhone);
              DataSnapshot snapshot = await userRef.get();
              if (snapshot.exists) {
                Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
                double currentRating = (data['rating'] ?? 5.0).toDouble();
                int totalReviews = (data['totalReviews'] ?? 0) + 1;
                double newRating = ((currentRating * (totalReviews - 1)) + selectedRating) / totalReviews;

                await userRef.update({
                  'rating': newRating,
                  'totalReviews': totalReviews,
                });
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('रेटिंग सफलतापूर्वक सबमिट हो गई!')));
            },
            child: const Text('सबमिट करें'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DatabaseReference jobsRef = FirebaseDatabase.instance.ref().child('jobs');

    return Scaffold(
      appBar: AppBar(
        title: const Text('वर्कर डैशबोर्ड (काम की सूची)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ViewProfileScreen(phone: widget.phone))),
          ),
        ],
      ),
      body: FirebaseAnimatedList(
        query: jobsRef,
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>?;
          if (json == null) return const SizedBox.shrink();

          String jobId = snapshot.key ?? '';
          bool isUnlocked = _unlockedJobIds.contains(jobId);

          return Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(json['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(json['description'] ?? '', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 10),
                  Text('बजट: ₹${json['budget']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(isUnlocked ? 'लोकेशन: ${json['location']}' : 'लोकेशन: [₹10 देकर खोलें]', style: TextStyle(color: isUnlocked ? Colors.black : Colors.red)),
                  Text(isUnlocked ? 'मोबाइल नंबर: ${json['clientPhone']}' : 'नंबर: [ब्लर किया गया]'),
                  const SizedBox(height: 10),
                  if (!isUnlocked)
                    ElevatedButton(
                      onPressed: () => _launchUpi(jobId),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      child: const Text('₹10 देकर पूरा पता और नंबर खोलें', style: TextStyle(color: Colors.white)),
                    ),
                  TextButton(
                    onPressed: () => _rateWorkerDialog(widget.phone),
                    child: const Text('इस काम की परफॉर्मेंस पर रेटिंग दें'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// 6. VIEW PROFILE & RATINGS SCREEN (फोटो देखने के साथ)
// ---------------------------------------------------------
class ViewProfileScreen extends StatelessWidget {
  final String phone;
  const ViewProfileScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(phone);

    return Scaffold(
      appBar: AppBar(title: const Text('मेरी प्रोफाइल और रेटिंग')),
      body: FutureBuilder(
        future: userRef.get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.value == null) {
            return const Center(child: CircularProgressIndicator());
          }
          Map<dynamic, dynamic> data = snapshot.data!.value as Map<dynamic, dynamic>;
          String? profileImageBase64 = data['profileImage'];

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.black,
                    backgroundImage: profileImageBase64 != null && profileImageBase64.isNotEmpty
                        ? MemoryImage(base64Decode(profileImageBase64))
                        : null,
                    child: profileImageBase64 == null || profileImageBase64.isEmpty
                        ? Text(data['name']?[0] ?? 'U', style: const TextStyle(fontSize: 40, color: Colors.white))
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                Text('नाम: ${data['name']}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('मोबाइल: +91 ${data['phone']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                Text('हुनर / कंपनी: ${data['skillOrCompany']}', style: const TextStyle(fontSize: 16)),
                const Divider(height: 40),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 30),
                    const SizedBox(width: 8),
                    Text('${(data['rating'] ?? 5.0).toStringAsFixed(1)} स्टार रेटिंग', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('कुल रिव्यूज: ${data['totalReviews'] ?? 0}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
