import 'package:flutter/material.dart';

void main() {
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
// 1. LOGIN & PHONE AUTH SCREEN
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
    // सीधा रोल सिलेक्शन स्क्रीन पर भेजें
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
                  child: const Text('लॉगिन करें (Get OTP / Continue)', style: TextStyle(fontSize: 18, color: Colors.white)),
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
// 2. ROLE SELECTION SCREEN (Worker or Client)
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
                // Worker Dashboard पर जाएं
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionCheckScreen(role: 'worker', phone: phone)),
                );
              },
              icon: const Icon(Icons.handyman, size: 28),
              label: const Text('मुझे काम चाहिए (Worker / मिस्त्री / लेबर)', style: TextStyle(fontSize: 16)),
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
                // Client Dashboard पर जाएं
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
    // यहाँ हम चेक करेंगे कि यूजर का ₹100 सब्सक्रिप्शन एक्टिव है या नहीं।
    // अभी के लिए डेमो पर्पस से पास एक्टिव मानकर आगे बढ़ा रहे हैं।
    bool isSubscribed = true; // इसे डेटाबेस से फेच करेंगे

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
// 4. CLIENT DASHBOARD (काम डालने वाला)
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

  final List<Map<String, String>> _myPostedJobs = [];

  void _postJob() {
    if (_titleController.text.isEmpty || _budgetController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया काम का नाम और बजट भरें')),
      );
      return;
    }

    setState(() {
      _myPostedJobs.add({
        'title': _titleController.text,
        'desc': _descController.text,
        'budget': _budgetController.text,
        'location': _locationController.text,
      });
    });

    _titleController.clear();
    _descController.clear();
    _budgetController.clear();
    _locationController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('काम सफलतापूर्वक पोस्ट कर दिया गया है!')),
    );
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _postJob,
              icon: const Icon(Icons.add),
              label: const Text('काम पब्लिश करें (Post Job)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.all(14)),
            ),
            const SizedBox(height: 30),
            const Text('आपके द्वारा डाले गए काम', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _myPostedJobs.isEmpty
                ? const Text('अभी तक कोई काम नहीं डाला गया है।', style: TextStyle(color: Colors.grey))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _myPostedJobs.length,
                    itemBuilder: (context, index) {
                      var job = _myPostedJobs[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(job['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('लोकेशन: ${job['location']}\nबजट: ₹${job['budget']}'),
                          trailing: const Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
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
// 5. WORKER DASHBOARD (काम करने वाला / मिस्त्री)
// ---------------------------------------------------------
class WorkerDashboard extends StatelessWidget {
  final String phone;
  const WorkerDashboard({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    // डेमो के लिए उपलब्ध काम की लिस्ट
    final List<Map<String, String>> availableJobs = [
      {'title': 'बाथरूम का नल लीक ठीक करना है', 'budget': '₹500', 'location': 'Sector 15, Faridabad', 'phone': '98765XXXXX'},
      {'title': 'घर की वायरिंग चेक करनी है', 'budget': '₹1200', 'location': 'Sector 16, Faridabad', 'phone': '91234XXXXX'},
      {'title': 'दीवार पर पेंट करवाना है', 'budget': '₹3000', 'location': 'Sector 10, Faridabad', 'phone': '99887XXXXX'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('लेबर/मिस्त्री डैशबोर्ड (Worker Panel)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('आपके आसपास उपलब्ध काम (Available Jobs)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: availableJobs.length,
                itemBuilder: (context, index) {
                  var job = availableJobs[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(job['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('लोकेशन: ${job['location']}', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('मजदूरी/बजट: ${job['budget']}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('मालिक का नंबर: [अनलॉकड]', style: TextStyle(fontSize: 12, color: Colors.blue)),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('कांटेक्ट नंबर: ${job['phone']} (सीधा कॉल करें)')),
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
