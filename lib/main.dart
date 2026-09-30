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
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        primaryColor: const Color(0xFF10B981),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFFF9FAFB),
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
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 20, spreadRadius: 5)
                  ],
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
                'रोजी-रोटी का सीधा ठिकाना (2050 Edition)',
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

    // OTP के बाद सीधा 'Role Selection Screen' पर भेजें ताकि यूजर खुद चुन सके कि उसे क्या करना है
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RoleSelectionScreen(phone: widget.phone)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
// 3. ROLE SELECTION SCREEN (ऐप खुलते ही विकल्प चुनने वाला पेज)
// ---------------------------------------------------------
class RoleSelectionScreen extends StatelessWidget {
  final String phone;
  const RoleSelectionScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('आप क्या करना चाहते हैं?'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'अपनी जरूरत के अनुसार विकल्प चुनें:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            
            // Option 1: काम कराना है (Client Dashboard)
            _buildRoleCard(
              context,
              title: 'मुझे काम कराना है',
              subtitle: 'यहाँ से आप अपना काम या प्रोजेक्ट पोस्ट कर सकते हैं',
              icon: Icons.post_add,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ClientDashboard(phone: phone)),
                );
              },
            ),
            const SizedBox(height: 16),

            // Option 2: काम ढूंढना है / कॉल करना है (Worker Directory / Calling)
            _buildRoleCard(
              context,
              title: 'मुझे काम ढूंढना है / कॉल करना है',
              subtitle: '200+ कामगारों और एक्सपर्ट्स की डायरेक्टरी देखें और सीधा कॉल करें',
              icon: Icons.phone_in_talk,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WorkerDirectoryScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // Option 3: मैं काम करने वाला हूँ (Worker Service Registration)
            _buildRoleCard(
              context,
              title: 'मैं काम करने वाला हूँ (रजिस्टर करें)',
              subtitle: 'अपनी दुकान या हुनर को डायरेक्टरी में जोड़ें ताकि लोग आपको कॉल कर सकें',
              icon: Icons.engineering,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterWorkerScreen()),
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
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF10B981), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
// 4. CLIENT DASHBOARD (काम पोस्ट करने का डैशबोर्ड)
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
  
  final List<String> _selectedImagesBase64 = [];
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('क्लाइंट डैशबोर्ड (काम पोस्ट करें)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('नया काम या प्रोजेक्ट पब्लिश करें:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            TextField(controller: _titleController, style: const TextStyle(color: Colors.black), decoration: InputDecoration(labelText: 'काम का नाम (जैसे: मिस्त्री, प्लंबर, इलेक्ट्रीशियन)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)))),
            const SizedBox(height: 12),
            TextField(controller: _descController, style: const TextStyle(color: Colors.black), decoration: InputDecoration(labelText: 'काम का पूरा विवरण', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: _budgetController, style: const TextStyle(color: Colors.black), keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'बजट (₹)', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)))),
            const SizedBox(height: 12),
            TextField(controller: _locationController, style: const TextStyle(color: Colors.black), decoration: InputDecoration(labelText: 'लोकेशन / पूरा पता', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)))),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library, color: Colors.white),
              label: const Text('काम की फोटो चुनें (Multiple)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            ),
            const SizedBox(height: 12),
            if (_selectedImagesBase64.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImagesBase64.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(base64Decode(_selectedImagesBase64[index]), width: 90, height: 90, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 18, color: Colors.redAccent),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _postJob,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), backgroundColor: const Color(0xFF10B981)),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('काम पब्लिश करें', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// 5. WORKER DIRECTORY SCREEN (200 Categories & Call Option)
// ---------------------------------------------------------
class WorkerDirectoryScreen extends StatefulWidget {
  const WorkerDirectoryScreen({super.key});

  @override
  State<WorkerDirectoryScreen> createState() => _WorkerDirectoryScreenState();
}

class _WorkerDirectoryScreenState extends State<WorkerDirectoryScreen> {
  String _selectedCategory = 'सभी';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'सभी', 'लेबर', 'राजमिस्त्री', 'ठेकेदार', 'इलेक्ट्रीशियन', 'प्लंबर', 'कार मैकेनिक', 'बाइक मैकेनिक', 
    'एसी रिपेयर', 'कूलर रिपेयर', 'फ्रिज रिपेयर', 'वाशिंग मशीन रिपेयर', 'एलईडी/टीवी रिपेयर', 'कंप्यूटर रिपेयर', 
    'लैपटॉप रिपेयर', 'मोबाइल रिपेयर', 'पेंटर', 'वेल्डर / ग्रिल वाला', 'कारपेंटर (बढ़ई)', 'टाइल मिस्त्री', 
    'मार्बल पॉलिश वाला', 'बोर्सवेल / बोरिंग वाला', 'सफाई कर्मी (क्लीनर)', 'क्रेन / जेसीबी ऑपरेटर', 'ड्राइवर', 
    'सोलर पैनल वाला', 'CCTV कैमरा इंस्टॉलर', 'रोटी / कैटरिंग कुक', 'सुरक्षा गार्ड', 'इनवर्टर / बैटरी वाला', 
    'जनरेटर ऑपरेटर', 'RO वाटर प्यूरीफायर रिपेयर', 'गीजर रिपेयर', 'माइक्रोवेव रिपेयर', 'पंखा (Fan) रिपेयर', 
    'इन्टेरियर डिज़ाइनर', 'फॉल सीलिंग मिस्त्री', 'एल्युमिनियम/कांच वाला', 'शटर और गेट रिपेयर', 'कीटनाशक (Pest Control)', 
    'टेंट हाउस वाला', 'डीजे और साउंड सिस्टम', 'पेंट्री / हलवाई', 'वाहन धोने वाला (Car Washer)', 'गार्डन/लॉन केयर वाला', 
    'टेलर (दर्जी)', 'प्रेस/धोबी वाला', 'कचरा/मलबा उठाने वाला', 'पैकिंग और शिफ्टिंग (Packers)', 'लूज कोरियर/डिलीवरी बॉय', 
    'ऑटो चालक', 'टैक्सी चालक', 'स्कूल वैन चालक', 'लोडर ऑटो चालक', 'ट्रैक्टर ड्राइवर', 'बोरवेल मोटर रिपेयर', 
    'सबमर्सिबल पंप वाला', 'स्टेबलाइजर रिपेयर', 'इनवर्टर बैटरी चार्जिंग', 'डीप फ्रीजर रिपेयर', 'वाटर कूलर रिपेयर', 
    'गीजर इंस्टॉलेशन', 'चिमनी रिपेयर', 'गैस चूल्हा रिपेयर', 'आरओ फिल्टर चेंज', 'सोफा ड्राई क्लीनिंग', 
    'कार ड्राई क्लीनिंग', 'वाटर टैंक सफाई', 'सेप्टिक टैंक सफाई', 'दीमक नियंत्रण (Termite)', 'मच्छर फॉगिंग वाला', 
    'जूता चप्पल रिपेयर', 'चाबी बनाने वाला (Locksmith)', 'लोहे की ग्रिल पेंट', 'घर की रंगाई-पुताई', 'वाटरप्रूफिंग वाला', 
    'छत की मरम्मत', 'पत्थर कटाई मिस्त्री', 'फर्नीचर पॉलिश वाला', 'गद्दे रजाई बनाने वाला', 'कंबल धुलाई वाला', 
    'पर्दे लगाने वाला', 'ब्लाइंड्स इंस्टॉलर', 'मच्छर जाली (Mosquito Net)', 'ग्लास फिल्म वाला', 'वॉलपेपर लगाने वाला', 
    'जिप्सम बोर्ड वाला', 'पीवीसी पैनल वाला', 'लकड़ी का ठेकेदार', 'लोहे का ठेकेदार', 'सड़क निर्माण लेबर', 
    'खुदाई वाली लेबर', 'भार उठाने वाले हम्माल', 'ईंट भट्ठा लेबर', 'कंक्रीट मिक्सर ऑपरेटर', 'वाइब्रेटर मशीन वाला', 
    'शटरिंग प्लेट वाला', 'स्केफोल्डिंग (बली-फट्टा)', 'स्टील बाइंडिंग मिस्त्री', 'ट्यूबवेल मिस्त्री', 'सोलर इन्वर्टर वाला', 
    'वाटर हीटर रिपेयर', 'इंडक्शन चूल्हा रिपेयर', 'कॉफी मशीन रिपेयर', 'प्रेस मशीन वाला', 'जिम इंस्ट्रक्टर', 
    'योग टीचर', 'होम ट्यूटर (पढ़ाने वाला)', 'म्यूजिक टीचर', 'डांस टीचर', 'नर्स / कम्पाउंडर (घरेलू)', 
    'एल्डरली केयरटेकर (बुजुर्गों की सेवा)', 'बेबी सिटर / नैनी', 'ड्राइवर (पर्सनल)', 'कुक (घर का खाना बनाने वाला)', 
    'माली (पौधों की देखभाल)', 'कार क्लीनर (रोज सुबह धोने वाला)', 'वॉचमैन / चौकीदार', 'इवेंट फोटोग्राफर', 
    'वीडियोग्राफर', 'ड्रोन ऑपरेटर', 'लाइटिंग डेकोरेशन वाला', 'फूलों की सजावट वाला', 'बर्थडे प्लानर', 
    'मैरिज गार्डन वर्कर', 'कैटरिंग वेटर', 'डिस्पोजेबल बर्तन सप्लायर', 'आइटम सप्लाई वाला', 'दूध वाला (Milk Man)', 
    'अखबार वाला', 'गैस सिलेंडर डिलीवरी मैन', 'आरओ वाटर केन सप्लायर', 'बिल्डिंग मटीरियल सप्लायर', 'रेत-बजरी सप्लायर', 
    'ईंट सप्लायर', 'सीमेंट सप्लायर', 'सरिया (Steel) सप्लायर', 'लकड़ी सप्लायर', 'पत्थर/ग्रेनाइट सप्लायर', 
    'टेंट सप्लायर', 'साउंड सप्लायर', 'जनरेटर रेंटल वाला', 'जैसीबी रेंटल वाला', 'डंपर/ट्रक ऑपरेटर', 
    'मिनी ट्रक (छोटा हाथी) चालक', 'पिकअप चालक', 'ट्रेलर चालक', 'क्रेन रेंटल वाला', 'स्कैफोल्डिंग रेंटल', 
    'शटरिंग मटीरियल रेंटल', 'मिक्सर मशीन रेंटल', 'वेल्डिंग मशीन रेंटल', 'कटर मशीन रेंटल', 'ब्रेकर मशीन रेंटल', 
    'वाटर पंप रेंटल', 'फॉगिंग मशीन रेंटल', 'स्टेचर/व्हीलचेयर सप्लायर', 'ऑक्सीजन सिलेंडर सप्लायर', 'हॉस्पिटल बेड सप्लायर', 
    'प्राथमिक उपचार वाला', 'वैद्य / हकीम', 'मालिश करने वाला (मसाज मैन)', 'नाई / हेयर सैलून वाला', 'लेडीज ब्यूटीशियन', 
    'मेहंदी आर्टिस्ट', 'मेकअप आर्टिस्ट', 'कपड़े धोने वाली बाई', 'बर्तन साफ करने वाली बाई', 'घर की फुल सफाई वाली बाई', 
    'चौकीदार (नाइट शिफ्ट)', 'डॉग ट्रेनर', 'पेट्स ग्रूमर (पालतू जानवर)', 'एक्वेरियम क्लीनर', 'पौधे लगाने वाला', 
    'किचन गार्डन वाला', 'वर्मीकंपोस्ट खाद वाला', 'गोबर खाद सप्लायर', 'मिट्टी सप्लायर', 'गमले सप्लायर'
  ];

  final DatabaseReference _workersRef = FirebaseDatabase.instance.ref().child('public_workers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('200+ कामगार डायरेक्टरी (कॉल करें)', style: TextStyle(fontSize: 16)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'नाम या हुनर से खोजें (जैसे: मिस्त्री, एसी, ड्राइवर)...',
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
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemBuilder: (context, index) {
                String cat = _categories[index];
                bool isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: const Color(0xFF10B981),
                    backgroundColor: Colors.grey.shade100,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.grey, height: 1),
          Expanded(
            child: FirebaseAnimatedList(
              query: _workersRef,
              itemBuilder: (context, snapshot, animation, index) {
                if (snapshot.value == null) return Container();
                Map workerData = snapshot.value as Map;
                String name = workerData['name'] ?? 'नाम उपलब्ध नहीं';
                String skill = workerData['skill'] ?? 'हुनर अज्ञात';
                String charge = workerData['dailyCharge'] ?? 'बातचीत अनुसार';
                String phone = workerData['phone'] ?? '';
                String profileImg = workerData['profileImage'] ?? '';

                bool matchesCategory = _selectedCategory == 'सभी' || 
                    skill.toLowerCase().contains(_selectedCategory.toLowerCase());

                bool matchesSearch = _searchQuery.isEmpty || 
                    name.toLowerCase().contains(_searchQuery) || 
                    skill.toLowerCase().contains(_searchQuery);

                if (!matchesCategory || !matchesSearch) {
                  return Container();
                }

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
                            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(skill, style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 6),
                            Text('चार्ज: ₹$charge', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (phone.isNotEmpty) {
                            launchUrl(Uri.parse('tel:$phone'));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('फोन नंबर उपलब्ध नहीं है')));
                          }
                        },
                        icon: const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF10B981),
                          child: Icon(Icons.call, color: Colors.white, size: 20),
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
// 6. REGISTER WORKER SCREEN (मैं काम करने वाला हूँ)
// ---------------------------------------------------------
class RegisterWorkerScreen extends StatefulWidget {
  const RegisterWorkerScreen({super.key});

  @override
  State<RegisterWorkerScreen> createState() => _RegisterWorkerScreenState();
}

class _RegisterWorkerScreenState extends State<RegisterWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _chargeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _selectedCategory = 'इलेक्ट्रीशियन';
  Uint8List? _profileImageBytes;
  bool _isLoading = false;

  final List<String> _categories = [
    'लेबर', 'राजमिस्त्री', 'ठेकेदार', 'इलेक्ट्रीशियन', 'प्लंबर', 'कार मैकेनिक', 'बाइक मैकेनिक', 
    'एसी रिपेयर', 'कूलर रिपेयर', 'फ्रिज रिपेयर', 'वाशिंग मशीन रिपेयर', 'एलईडी/टीवी रिपेयर', 'कंप्यूटर रिपेयर', 
    'लैपटॉप रिपेयर', 'मोबाइल रिपेयर', 'पेंटर', 'वेल्डर / ग्रिल वाला', 'कारपेंटर (बढ़ई)', 'टाइल मिस्त्री', 
    'मार्बल पॉलिश वाला', 'बोर्सवेल / बोरिंग वाला', 'सफाई कर्मी (क्लीनर)', 'क्रेन / जेसीबी ऑपरेटर', 'ड्राइवर', 
    'सोलर पैनल वाला', 'CCTV कैमरा इंस्टॉलर', 'रोटी / कैटरिंग कुक', 'सुरक्षा गार्ड', 'इनवर्टर / बैटरी वाला', 
    'जनरेटर ऑपरेटर', 'RO वाटर प्यूरीफायर रिपेयर', 'गीजर रिपेयर', 'माइक्रोवेव रिपेयर', 'पंखा (Fan) रिपेयर', 
    'इन्टेरियर डिज़ाइनर', 'फॉल सीलिंग मिस्त्री', 'एल्युमिनियम/कांच वाला', 'शटर और गेट रिपेयर', 'कीटनाशक (Pest Control)', 
    'टेंट हाउस वाला', 'डीजे और साउंड सिस्टम', 'पेंट्री / हलवाई', 'वाहन धोने वाला (Car Washer)', 'गार्डन/लॉन केयर वाला', 
    'टेलर (दर्जी)', 'प्रेस/धोबी वाला', 'कचरा/मलबा उठाने वाला', 'पैकिंग और शिफ्टिंग (Packers)', 'लूज कोरियर/डिलीवरी बॉय'
  ];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        _profileImageBytes = bytes;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        DatabaseReference ref = FirebaseDatabase.instance.ref().child('public_workers').push();
        String base64Image = _profileImageBytes != null ? base64Encode(_profileImageBytes!) : '';

        await ref.set({
          'id': ref.key,
          'name': _nameController.text.trim(),
          'skill': _selectedCategory,
          'phone': _phoneController.text.trim(),
          'dailyCharge': _chargeController.text.trim(),
          'address': _addressController.text.trim(),
          'profileImage': base64Image,
          'createdAt': ServerValue.timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('आपकी सर्विस सफलतापूर्वक डायरेक्टरी में जुड़ गई है!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('एरर: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(title: const Text('अपनी सर्विस रजिस्टर करें')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _profileImageBytes != null ? MemoryImage(_profileImageBytes!) : null,
                  child: _profileImageBytes == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: Color(0xFF10B981), size: 30),
                            SizedBox(height: 4),
                            Text('फोटो लगाएं', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: _inputDecoration('पूरा नाम (Name)', Icons.person),
                validator: (val) => val!.isEmpty ? 'कृपया नाम दर्ज करें' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: _inputDecoration('अपना हुनर / कैटेगरी चुनें', Icons.work),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat, style: const TextStyle(color: Colors.black)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.black),
                decoration: _inputDecoration('मोबाइल नंबर (Phone Number)', Icons.phone),
                validator: (val) => val!.length < 10 ? 'सही मोबाइल नंबर दर्ज करें' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chargeController,
                style: const TextStyle(color: Colors.black),
                decoration: _inputDecoration('दैनिक चार्ज या विजिटिंग फीस (जैसे: 500 / दिन)', Icons.currency_rupee),
                validator: (val) => val!.isEmpty ? 'कृपया चार्ज दर्ज करें' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                style: const TextStyle(color: Colors.black),
                decoration: _inputDecoration('पूरा पता / इलाका (Address / Location)', Icons.location_on),
                validator: (val) => val!.isEmpty ? 'कृपया पता दर्ज करें' : null,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _submitProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'डैशबोर्ड पर जोड़ें (Register)',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: Icon(icon, color: const Color(0xFF10B981)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
