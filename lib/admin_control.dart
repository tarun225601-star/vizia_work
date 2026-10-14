import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

// ---------------------------------------------------------
// VIZIAWORK ADMIN CONTROL PANEL (PASSCODE: Tarun#1)
// ---------------------------------------------------------
class AdminControl extends StatefulWidget {
  const AdminControl({super.key});

  @override
  State<AdminControl> createState() => _AdminControlState();
}

class _AdminControlState extends State<AdminControl> {
  final TextEditingController _passcodeController = TextEditingController();
  bool _isAuthenticated = false;

  // 🔑 सीक्रेट एडमिन कोड
  final String _adminPasscode = "Tarun#1";

  void _verifyPasscode() {
    if (_passcodeController.text.trim() == _adminPasscode) {
      setState(() {
        _isAuthenticated = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('गलत सीक्रेट कोड! एक्सेस अस्वीकृत।'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text('Viziawork एडमिन लॉगिन'),
          backgroundColor: const Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.admin_panel_settings, size: 70, color: Color(0xFF10B981)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'सुपर एडमिन एक्सेस',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'कंट्रोल पैनल खोलने के लिए सीक्रेट कोड दर्ज करें',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _passcodeController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 4),
                  decoration: InputDecoration(
                    labelText: 'सीक्रेट कोड दर्ज करें',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.white24)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _verifyPasscode,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('अनलॉक एडमिन पैनल', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const AdminMainDashboard();
  }
}

// ---------------------------------------------------------
// ADMIN DASHBOARD CONTENT (SHOPS & WORKERS MANAGEMENT)
// ---------------------------------------------------------
class AdminMainDashboard extends StatefulWidget {
  const AdminMainDashboard({super.key});

  @override
  State<AdminMainDashboard> createState() => _AdminMainDashboardState();
}

class _AdminMainDashboardState extends State<AdminMainDashboard> with SingleTickerProviderTabController {
  late TabController _tabController;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  String _selectedCity = "All";
  final List<String> _cities = ["All", "Faridabad", "Gurugram", "Delhi", "Noida", "Ghaziabad"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // ---------------------------------------------------------
  // SHOP ACTION FUNCTIONS (दुकानें मैनेज करने के फंक्शन)
  // ---------------------------------------------------------
  
  // 1. दुकान अप्रूव करना
  void _approveShop(String shopPhone) async {
    await _dbRef.child('shops').child(shopPhone).update({
      'isApproved': true,
      'status': 'ACTIVE',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान अप्रूव कर दी गई है!')));
    }
  }

  // 2. दुकान डिलीट करना
  void _deleteShop(String shopPhone, String shopName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$shopName डिलीट करें?'),
        content: const Text('क्या आप वाकई इस दुकान को हमेशा के लिए हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbRef.child('shops').child(shopPhone).remove();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('दुकान डिलीट कर दी गई है')));
              }
            },
            child: const Text('डिलीट करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 3. दुकान लॉक / अनलॉक करना
  void _toggleShopLock(String shopPhone, bool currentLockState) async {
    await _dbRef.child('shops').child(shopPhone).update({'isLocked': !currentLockState});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(!currentLockState ? 'दुकान लॉक कर दी गई है' : 'दुकान अनलॉक कर दी गई है')),
      );
    }
  }

  // ---------------------------------------------------------
  // WORKER ACTION FUNCTIONS (कारीगर/मिस्त्री मैनेज करने के फंक्शन)
  // ---------------------------------------------------------

  // 1. कारीगर/ठेकेदार अप्रूव या वेरीफाई करना
  void _approveWorker(String workerPhone) async {
    await _dbRef.child('workers').child(workerPhone).update({
      'isVerified': true,
      'status': 'APPROVED',
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कारीगर की प्रोफाइल वेरिफाई हो गई है!')));
    }
  }

  // 2. कारीगर/ठेकेदार डिलीट करना
  void _deleteWorker(String workerPhone, String workerName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$workerName को हटाएं?'),
        content: const Text('क्या आप वाकई इस कारीगर/ठेकेदार को हटाना चाहते हैं?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('रद्द करें')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _dbRef.child('workers').child(workerPhone).remove();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('कारीगर डिलीट कर दिया गया है')));
              }
            },
            child: const Text('डिलीट करें', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('एडमिन कंट्रोल (Admin Control)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          // 🏙️ शहर के हिसाब से फ़िल्टर ड्रॉपडाउन
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF1E293B),
              value: _selectedCity,
              underline: const SizedBox(),
              icon: const Icon(Icons.location_on, color: Color(0xFF10B981)),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              onChanged: (String? newCity) {
                if (newCity != null) {
                  setState(() {
                    _selectedCity = newCity;
                  });
                }
              },
              items: _cities.map<DropdownMenuItem<String>>((String city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
            ),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'दुकानें (Shops)'),
            Tab(icon: Icon(Icons.engineering), text: 'कारीगर/ठेकेदार'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🏢 TAB 1: दुकानें मैनेज & अप्रूव/डिलीट/लॉक करें
          _buildShopsManager(),

          // 👷 TAB 2: कारीगर व ठेकेदार मैनेज & अप्रूव/डिलीट करें
          _buildWorkersManager(),
        ],
      ),
    );
  }

  // 🏢 दुकानें मैनेज करने का विजेट
  Widget _buildShopsManager() {
    Query query = _dbRef.child('shops');
    if (_selectedCity != "All") {
      query = query.orderByChild('city').equalTo(_selectedCity);
    }

    return FirebaseAnimatedList(
      query: query,
      defaultChild: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      emptyChild: const Center(child: Text('कोई दुकान नहीं मिली')),
      itemBuilder: (context, snapshot, animation, index) {
        Map shopData = snapshot.value as Map;
        String shopPhone = snapshot.key ?? '';
        String shopName = shopData['shop_name'] ?? 'अनाम दुकान';
        String category = shopData['category'] ?? 'हार्डवेयर';
        String city = shopData['city'] ?? 'Faridabad';
        bool isApproved = shopData['isApproved'] ?? false;
        bool isLocked = shopData['isLocked'] ?? false;
        double pending = (shopData['pendingCommission'] ?? 0.0).toDouble();

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        shopName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isApproved ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isApproved ? 'APPROVED' : 'PENDING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? Colors.green.shade900 : Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('श्रेणी: $category • शहर: $city', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('फ़ोन नंबर: +91 $shopPhone', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text('बकाया कमिशन: ₹${pending.toStringAsFixed(1)}', style: TextStyle(color: pending > 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),

                const Divider(height: 20),

                Row(
                  children: [
                    if (!isApproved) ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveShop(shopPhone),
                          icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
                          label: const Text('अप्रूव करें', style: TextStyle(color: Colors.white, fontSize: 12)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],

                    IconButton(
                      icon: Icon(isLocked ? Icons.lock : Icons.lock_open, color: isLocked ? Colors.red : Colors.grey),
                      tooltip: isLocked ? 'अनलॉक करें' : 'लॉक करें',
                      onPressed: () => _toggleShopLock(shopPhone, isLocked),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      tooltip: 'दुकान डिलीट करें',
                      onPressed: () => _deleteShop(shopPhone, shopName),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 👷 कारीगर और ठेकेदार मैनेज करने का विजेट
  Widget _buildWorkersManager() {
    Query query = _dbRef.child('workers');
    if (_selectedCity != "All") {
      query = query.orderByChild('city').equalTo(_selectedCity);
    }

    return FirebaseAnimatedList(
      query: query,
      defaultChild: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
      emptyChild: const Center(child: Text('कोई कारीगर/ठेकेदार नहीं मिला')),
      itemBuilder: (context, snapshot, animation, index) {
        Map workerData = snapshot.value as Map;
        String workerPhone = snapshot.key ?? '';
        String name = workerData['name'] ?? 'अनाम कारीगर';
        String workType = workerData['work_type'] ?? 'मिस्त्री';
        String city = workerData['city'] ?? 'Faridabad';
        bool isVerified = workerData['isVerified'] ?? false;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: isVerified ? Colors.blue : Colors.grey,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (isVerified) const Icon(Icons.verified, color: Colors.blue, size: 18),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('काम: $workType • शहर: $city'),
                Text('फ़ोन: +91 $workerPhone', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isVerified)
                  IconButton(
                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                    tooltip: 'वेरिफाई करें',
                    onPressed: () => _approveWorker(workerPhone),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  tooltip: 'हटाएं',
                  onPressed: () => _deleteWorker(workerPhone, name),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
