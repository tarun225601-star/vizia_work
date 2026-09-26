import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:image_picker/image_picker.dart';

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
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto',
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

  void _handleLogin() {
    String phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया सही मोबाइल नंबर दर्ज करें')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.work_outline, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                const Text(
                  'Viziawork',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'रोजी-रोटी का सीधा ठिकाना',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'मोबाइल नंबर (Mobile Number)',
                    prefixText: '+91 ',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('लॉगिन करें (Continue)', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 2. ROLE SELECTION SCREEN
// ---------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('अपनी भूमिका चुनें (Select Role)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'आप Viziawork पर क्या करना चाहते हैं?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionCheckScreen(role: 'worker', phone: phone)),
                );
              },
              icon: const Icon(Icons.handyman, size: 28),
              label: const Text('मुझे काम चाहिए (Worker / मिस्त्री)', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionCheckScreen(role: 'client', phone: phone)),
                );
              },
              icon: const Icon(Icons.business_center, size: 28),
              label: const Text('मुझे काम करवाना है (Client / मालिक)', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. SUBSCRIPTION GATE (₹100 Monthly Pass Check)
// ---------------------------------------------------------
class SubscriptionCheckScreen extends StatelessWidget {
  final String role;
  final String phone;
  const SubscriptionCheckScreen({super.key, required this.role, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Viziawork - सब्सक्रिप्शन पास')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              '₹100 मासिक पास (Monthly Pass)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'बिना किसी रुकावट के काम देखने और डालने के लिए आपका ₹100 महीने का पास एक्टिव है।',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (role == 'client') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ClientDashboard(phone: phone)),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => WorkerDashboard(phone: phone)),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('आगे बढ़ें (Proceed to Dashboard)', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. CLIENT DASHBOARD (Realtime Database - Post Job with Gallery/Camera Image)
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

  File? _selectedImage; // चुनी गई फोटो को होल्ड करने के लिए
  bool _isLoading = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('jobs');

  // गैलरी या कैमरा से फोटो चुनने का फंक्शन
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _postJob() async {
    if (_titleController.text.isEmpty || _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया काम का नाम और बजट भरें')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // नोट: अभी के लिए हम फोटो पाथ या डमी यूआरएल भेज रहे हैं। 
      // असली ऐप में फोटो को Firebase Storage पर अपलोड करके उसका URL निकाला जाता है।
      String imagePathOrUrl = _selectedImage != null ? _selectedImage!.path : '';

      DatabaseReference newJobRef = _dbRef.push();
      await newJobRef.set({
        'id': newJobRef.key,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'budget': _budgetController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': imagePathOrUrl, 
        'clientPhone': widget.phone,
        'status': 'Active',
      });

      _titleController.clear();
      _descController.clear();
      _budgetController.clear();
      _locationController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('काम सफलतापूर्वक पब्लिश हो गया!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('एरर: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('मालिक डैशबोर्ड (Client Panel)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('नया काम पोस्ट करें', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'काम का नाम (जैसे: प्लंबिंग ठीक करवानी है)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'विवरण (Description)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'बजट (₹)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'लोकेशन/सेक्टर (जैसे: Sector 15, Faridabad)', border: OutlineInputBorder(), filled: true, fillColor: Colors.white),
            ),
            const SizedBox(height: 15),

            // फोटो दिखाने और चुनने के लिए UI
            const Text('काम की फोटो जोड़ें:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('कैमरा से खींचें'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('गैलरी से चुनें'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // चुनी गई फोटो का प्रीव्यू
            if (_selectedImage != null) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(_selectedImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red, size: 30),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],

            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _postJob,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('काम पब्लिश करें (Post Job)'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
                  ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. WORKER DASHBOARD (Realtime Database - Live Feed)
// ---------------------------------------------------------
class WorkerDashboard extends StatelessWidget {
  final String phone;
  const WorkerDashboard({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    DatabaseReference jobsRef = FirebaseDatabase.instance.ref().child('jobs');

    return Scaffold(
      appBar: AppBar(title: const Text('लेबर/मिस्त्री डैशबोर्ड (Worker Panel)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('आपके आसपास उपलब्ध लाइव काम', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: FirebaseAnimatedList(
                query: jobsRef,
                itemBuilder: (context, snapshot, animation, index) {
                  final json = snapshot.value as Map<dynamic, dynamic>?;
                  if (json == null) return const SizedBox.shrink();

                  String title = json['title'] ?? '';
                  String desc = json['description'] ?? '';
                  String location = json['location'] ?? '';
                  String budget = json['budget'] ?? '';
                  String imageUrl = json['imageUrl'] ?? '';
                  String clientPhone = json['clientPhone'] ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // अगर लोकल फाइल पाथ या यूआरएल मौजूद है
                          if (imageUrl.isNotEmpty) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl.startsWith('http')
                                  ? Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover)
                                  : Image.file(File(imageUrl), height: 180, width: double.infinity, fit: BoxFit.cover),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('विवरण: $desc', style: const TextStyle(color: Colors.black87)),
                          const SizedBox(height: 4),
                          Text('लोकेशन: $location', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('मजदूरी/बजट: ₹$budget', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('मालिक का नंबर: [अनलॉकड]', style: TextStyle(fontSize: 12, color: Colors.blue)),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('मालिक को कॉल करें: $clientPhone')),
                                  );
                                },
                                icon: const Icon(Icons.phone, size: 16),
                                label: const Text('कॉल करें'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                              ),
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
        ),
      ),
    );
  }
}
