import 'package:flutter/material.dart';



void main() {
  runApp(const ProfileApp());
}

class ProfileApp extends StatelessWidget {
  const ProfileApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto',
      ),
      home: const ProfilePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomAppBar(
        color: Colors.grey[400],
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.black, size: 28),
                onPressed: () {},
                tooltip: 'Home',
              ),
              IconButton(
                icon: const Icon(Icons.location_on, color: Colors.black, size: 28),
                onPressed: () {},
                tooltip: 'Map',
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 18),
                label: const Text(
                  'cari',
                  style: TextStyle(fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600]?.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF999999),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
           padding: const EdgeInsets.only(top: 50, bottom: 40),
child: Stack(
  children: [
    Positioned(
      left: 10,
      top: 10,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()), //ganti halaman cuy
          );
        },
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.grey[600]?.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
    ),

                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Text(
                          'image',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Sutan B.R ✓',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                const Text(
                  'Profil Saya',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                ProfileRow(
                  label: 'PASSWORD',
                  value: '',
                  actionText: 'CHANGE',
                  isValueLink: true,
                ),
                ProfileRow(
                  label: 'sutan***@gmail.com',
                  value: '',
                  actionText: 'CHANGE',
                  isValueLink: true,
                ),
                ProfileRow(
                  label: 'NO HP',
                  value: '089680510618',
                  actionText: '',
                  isValueLink: true,
                ),
                ProfileRow(
                  label: 'ALAMAT',
                  value: 'Jl. Sungai Andai Komplek Herlina Perkasa',
                  actionText: '',
                  isValueLink: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
void showEmailVerificationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.mail_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Tolong masukkan email untuk verifikasi akun Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Masukkan email anda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Lakukan verifikasi di sini
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}


class ProfileRow extends StatelessWidget {
  final String label;
  final String value;
  final String actionText;
  final bool isValueLink;

  const ProfileRow({
    Key? key,
    required this.label,
    required this.value,
    required this.actionText,
    this.isValueLink = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.blue[700],
                decoration: isValueLink
                    ? TextDecoration.underline
                    : TextDecoration.none,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Value di kanan, bisa multi-baris dan rata kanan
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                ),
                softWrap: true,
              ),
            ),
          ),

          // Action di paling kanan (CHANGE)
          if (actionText.isNotEmpty)
            SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
  if (actionText == 'CHANGE') {
    showEmailVerificationDialog(context);
  }
},

                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(30, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    actionText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

