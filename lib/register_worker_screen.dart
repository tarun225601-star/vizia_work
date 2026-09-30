import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

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

  String _selectedCategory = 'इलेक्ट्रीशियन'; // डिफ़ॉल्ट कैटेगरी
  Uint8List? _profileImageBytes;
  bool _isLoading = false;

  // वही 200 कैटेगरीज की लिस्ट यहाँ भी रहेगी ताकि वर्कर सही कैटेगरी चुन सके
  final List<String> _categories = [
    'लेबर', 'राजमिस्त्री', 'ठेकेदार', 'इलेक्ट्रीशियन', 'प्लंबर', 'कार मैकेनिक', 'बाइक मैकेनिक', 
    'एसी रिपेयर', 'कूलर रिपेयर', 'फ्रिज रिपेयर', 'वाशिंग मशीन रिपेयर', 'एलईडी/टीवी रिपेयर', 'कंप्यूटर रिपेयर', 
    'लैपटॉप रिपेयर', 'मोबाइल रिपेयर', 'पेंटर', 'वेल्डर / ग्रिल वाला', 'कारपेंटर (बढ़ई)', 'टाइल मिस्त्री', 
    'मार्बल पॉलिश वाला', 'बोर्सवेल / बोरिंग वाला', 'सफाई कर्मी (क्लीनर)', 'क्रेन / जेसीबी ऑपरेटर', 'ड्राइवर', 
    'सोलर पैनल वाला', 'CCTV कैमरा इंस्टॉलर', 'रोटी / कैटरिंग कुक', 'सुरक्षा गार्ड', 'इनवर्टर / बैटरी वाला', 
    'जनरेटर ऑपरेटर', 'RO वाटर प्यूरीफायर रिपेयर', 'गीजर रिपेयर', 'माइक्रोवेव रिपेयर', 'पंखा (Fan) रिपेयर', 
    'इन्टेरियर डिज़ाइनर', 'फॉल सीलिंग मिस्त्री', 'एल्युमिनियम/कांच वाला', 'शटर और गेट रिपेयर', 'कीटनाशक (Pest Control)', 
    'टेंट हाउस वाला', 'डीजे और साउंड सिस्टम', 'पेंट्री / हलवाई', 'वाहन धोने वाला (Car Washer)', 'गार्डन/लॉन केयर वाला', 
    'टेलर (दर्जी)', 'प्रेस/धोबी वाला', 'कचरा/मलबा उठाने वाला', 'पैकिंग और शिफ्टिंग (Packers)', 'लूज कोरियर/डिलीवरी बॉय',
    // (आप अपनी पूरी 200 कैटेगरीज की लिस्ट यहाँ डाल सकते हैं)
  ];

  // गैलरी से फोटो चुनने के लिए
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

  // डेटाबेस में सेव करने का फंक्शन
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
          const SnackBar(content: Text('आपकी प्रोफाइल सफलतापूर्वक जुड़ गई है!')),
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
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('अपनी सर्विस रजिस्टर करें', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111827),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // प्रोफाइल फोटो चुनने का बटन
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF1F2937),
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

              // नाम का फील्ड
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('पूरा नाम (Name)', Icons.person),
                validator: (val) => val!.isEmpty ? 'कृपया नाम दर्ज करें' : null,
              ),
              const SizedBox(height: 16),

              // कैटेगरी चुनने का ड्रॉपडाउन
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF111827),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: _inputDecoration('अपना हुनर / कैटेगरी चुनें', Icons.work),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // मोबाइल नंबर
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('मोबाइल नंबर (Phone Number)', Icons.phone),
                validator: (val) => val!.length < 10 ? 'सही मोबाइल नंबर दर्ज करें' : null,
              ),
              const SizedBox(height: 16),

              // चार्ज / मजदूरी
              TextFormField(
                controller: _chargeController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('दैनिक चार्ज या विजिटिंग फीस (जैसे: 500 / दिन)', Icons.currency_rupee),
                validator: (val) => val!.isEmpty ? 'कृपया चार्ज दर्ज करें' : null,
              ),
              const SizedBox(height: 16),

              // पूरा एड्रेस
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('पूरा पता / इलाका (Address / Location)', Icons.location_on),
                validator: (val) => val!.isEmpty ? 'कृपया पता दर्ज करें' : null,
              ),
              const SizedBox(height: 30),

              // सबमिट बटन
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
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        'डैशबोर्ड पर जोड़ें (Register)',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
      fillColor: const Color(0xFF111827),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
