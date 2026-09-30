import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkerDirectoryScreen extends StatefulWidget {
  const WorkerDirectoryScreen({super.key});

  @override
  State<WorkerDirectoryScreen> createState() => _WorkerDirectoryScreenState();
}

class _WorkerDirectoryScreenState extends State<WorkerDirectoryScreen> {
  String _selectedCategory = 'सभी';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // आम जनता के इस्तेमाल की पूरी 200 कैटेगरीज की लिस्ट
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
    'मेहंदी आर्टिस्ट', 'मेकअप आर्टिस्ट', 'कपड़े धोने वाली बाई',िन 'बर्तन साफ करने वाली बाई', 'घर की फुल सफाई वाली बाई', 
    'चौकीदार (नाइट शिफ्ट)', 'डॉग ट्रेनर', 'पेट्स ग्रूमर (पालतू जानवर)', 'एक्वेरियम क्लीनर', 'पौधे लगाने वाला', 
    'किचन गार्डन वाला', 'वर्मीकंपोस्ट खाद वाला', 'गोबर खाद सप्लायर', 'मिट्टी सप्लायर', 'गमले सप्लायर'
  ];

  final DatabaseReference _workersRef = FirebaseDatabase.instance.ref().child('public_workers');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        title: const Text('200+ कामगार और एक्सपर्ट डायरेक्टरी', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
      ),
      body: Column(
        children: [
          // सर्च बार (Search Bar)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.toLowerCase().trim();
                });
              },
              style: const TextStyle(color: Colors.white),
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
                fillColor: const Color(0xFF111827),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 200 कैटेगरीज का होरिजॉन्تال स्क्रॉलिंग फिल्टर बार
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 6),
            color: const Color(0xFF111827),
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
                    backgroundColor: const Color(0xFF1F2937),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
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
          const Divider(color: Color(0xFF1F2937), height: 1),
          
          // वर्कर की लिस्ट जो डेटाबेस से आएगी और सर्च/फिल्टर को फॉलो करेगी
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

                // कैटेगरी फिल्टर लॉजिक
                bool matchesCategory = _selectedCategory == 'सभी' || 
                    skill.toLowerCase().contains(_selectedCategory.toLowerCase());

                // सर्च बार लॉजिक (नाम या हुनर दोनों में मैच करेगा)
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
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      // प्रोफाइल फोटो
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF1F2937),
                        backgroundImage: profileImg.isNotEmpty ? MemoryImage(base64Decode(profileImg)) : null,
                        child: profileImg.isEmpty ? const Icon(Icons.person, size: 28, color: Colors.grey) : null,
                      ),
                      const SizedBox(width: 16),
                      // वर्कर की डिटेल्स
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F2937),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'चार्ज: ₹$charge',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      // डायरेक्ट कॉल बटन
                      IconButton(
                        onPressed: () {
                          if (phone.isNotEmpty) {
                            launchUrl(Uri.parse('tel:$phone'));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('फोन नंबर उपलब्ध नहीं है')),
                            );
                          }
                        },
                        icon: const CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(0xFF10B981),
                          child: Icon(Icons.call, color: Colors.black, size: 20),
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
