import 'dart:io';
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
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.black,
                  elevation: 0,
                ),
                child: const Text('लॉगिन करें', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
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
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('भूमिका चुनें')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'आप Viziawork पर क्या करना चाहते हैं?',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.black, height: 1.2),
            ),
            const SizedBox(height: 40),
            _buildRoleCard(
              context,
              title: 'मुझे काम चाहिए',
              subtitle: 'लेबर, मिस्त्री, या कारीगर (Worker)',
              icon: Icons.engineering,
              isClient: false,
            ),
            const SizedBox(height: 20),
            _buildRoleCard(
              context,
              title: 'मुझे काम करवाना है',
              subtitle: 'मकान मालिक या ठेकेदार (Client)',
              icon: Icons.business_center,
              isClient: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required bool isClient}) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => isClient ? ClientDashboard(phone: phone) : WorkerDashboard(phone: phone)),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isClient ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isClient ? null : Border.all(color: Colors.black12, width: 2),
          boxShadow: isClient ? [const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))] : [],
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: isClient ? Colors.white : Colors.black),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isClient ? Colors.white : Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isClient ? Colors.white70 : Colors.black54)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: isClient ? Colors.white : Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. CLIENT DASHBOARD (Post Job)
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
  File? _selectedImage;
  bool _isLoading = false;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('jobs');

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _postJob() async {
    if (_titleController.text.isEmpty || _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('काम का नाम और बजट भरना ज़रूरी है')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      DatabaseReference newJobRef = _dbRef.push();
      await newJobRef.set({
        'id': newJobRef.key,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'budget': _budgetController.text.trim(),
        'location': _locationController.text.trim(),
        'imageUrl': _selectedImage != null ? _selectedImage!.path : '',
        'clientPhone': widget.phone,
        'timestamp': ServerValue.timestamp,
      });
      _titleController.clear(); _descController.clear(); _budgetController.clear(); _locationController.clear();
      setState(() => _selectedImage = null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('काम पब्लिश हो गया!')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('पोस्ट करें', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text('नया काम', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _postJob,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _isLoading 
              ? const CircularProgressIndicator(color: Colors.white) 
              : const Text('काम पब्लिश करें', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBlinkitTextField('काम का नाम (जैसे: प्लंबिंग)', _titleController, Icons.work_outline),
            const SizedBox(height: 16),
            _buildBlinkitTextField('काम का विवरण', _descController, Icons.description_outlined, maxLines: 3),
            const SizedBox(height: 16),
            _buildBlinkitTextField('बजट/मजदूरी (₹)', _budgetController, Icons.currency_rupee, isNumber: true),
            const SizedBox(height: 16),
            _buildBlinkitTextField('लोकेशन / पूरा पता', _locationController, Icons.location_on_outlined),
            const SizedBox(height: 24),
            const Text('काम की फोटो:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildImageBtn('कैमरा', Icons.camera_alt, ImageSource.camera)),
                const SizedBox(width: 12),
                Expanded(child: _buildImageBtn('गैलरी', Icons.photo_library, ImageSource.gallery)),
              ],
            ),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildBlinkitTextField(String hint, TextEditingController controller, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.black, width: 2)),
      ),
    );
  }

  Widget _buildImageBtn(String text, IconData icon, ImageSource source) {
    return OutlinedButton.icon(
      onPressed: () => _pickImage(source),
      icon: Icon(icon, color: Colors.black),
      label: Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.black12, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. WORKER DASHBOARD (Independent Job Unlock System)
// ---------------------------------------------------------
class WorkerDashboard extends StatefulWidget {
  final String phone;
  const WorkerDashboard({super.key, required this.phone});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  // यह सेट (Set) याद रखेगा कि किस-किस खास जॉब आईडी (jobId) का पेमेंट हो चुका है
  final Set<String> _unlockedJobIds = {};

  final String myUpiId = "tarun@paytm"; // यहाँ अपनी UPI ID डाल देना भाई

  void _payAndUnlock(String jobId, String clientPhone, String location) async {
    final Uri upiUri = Uri.parse(
      "upi://pay?pa=$myUpiId&pn=Viziawork&am=10.00&cu=INR&tn=Unlock_Job_$jobId",
    );

    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      }
      _showPaymentSuccessDialog(jobId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('पेमेंट एरर: $e')),
      );
    }
  }

  void _showPaymentSuccessDialog(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('पेमेंट कन्फर्मेशन'),
        content: const Text('क्या आपने ₹10 का भुगतान कर दिया है?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('नहीं'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              setState(() {
                _unlockedJobIds.add(jobId); // केवल इसी खास पोस्ट का ताला खुलेगा!
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('इस काम का नंबर और पता सफलतापूर्वक खुल गया है!')),
              );
            },
            child: const Text('हाँ, हो गया', style: TextStyle(color: Colors.white)),
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
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black, size: 28),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('आपके आसपास', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                Row(
                  children: const [
                    Text('Faridabad, HR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.black),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: FirebaseAnimatedList(
        query: jobsRef,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>?;
          if (json == null) return const SizedBox.shrink();

          // हर पोस्ट की अपनी यूनीक डेटाबेस की (Key) होती है
          String jobId = snapshot.key ?? index.toString();
          String title = json['title'] ?? '';
          String desc = json['description'] ?? '';
          String location = json['location'] ?? '';
          String budget = json['budget'] ?? '';
          String imageUrl = json['imageUrl'] ?? '';
          String clientPhone = json['clientPhone'] ?? '';

          // चेक करें कि क्या इस खास जॉब आईडी को वर्कर ने अनलॉक किया है या नहीं
          bool isThisJobUnlocked = _unlockedJobIds.contains(jobId);

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: imageUrl.startsWith('http')
                        ? Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover)
                        : Image.file(File(imageUrl), height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                            child: Text('₹$budget', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green.shade700)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(desc, style: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                      
                      // लोकेशन (अगर इस पोस्ट का पेमेंट हुआ है तभी दिखेगा)
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isThisJobUnlocked ? location : '🔒 पूरा पता देखने के लिए ₹10 Pay करें',
                              style: TextStyle(
                                fontSize: 14, 
                                color: isThisJobUnlocked ? Colors.black87 : Colors.red.shade700, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: Colors.black12),
                      ),

                      // मालिक का नंबर और अनलॉक बटन (हर पोस्ट के लिए अलग)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isThisJobUnlocked ? 'नंबर: $clientPhone' : '🔒 नंबर: [ब्लर किया गया]',
                            style: TextStyle(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: isThisJobUnlocked ? Colors.black : Colors.grey,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (isThisJobUnlocked) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('कॉल कर रहे हैं: $clientPhone')));
                              } else {
                                _payAndUnlock(jobId, clientPhone, location);
                              }
                            },
                            icon: Icon(isThisJobUnlocked ? Icons.call : Icons.lock, size: 18, color: Colors.white),
                            label: Text(
                              isThisJobUnlocked ? 'कॉल करें' : '₹10 देकर खोलें', 
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isThisJobUnlocked ? Colors.green : Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
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
