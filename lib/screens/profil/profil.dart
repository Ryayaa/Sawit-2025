import 'package:admin/screens/profil/editprofilpage.dart';
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
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1B263B),
          secondary: Color(0xFF415A77),
          background: Color(0xFF0D1B2A),
          surface: Color(0xFF1B263B),
          onPrimary: Colors.white,
          onSecondary: Colors.white70,
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B263B),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF415A77),
            foregroundColor: Colors.white,
          ),
        ),
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
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: theme.colorScheme.surface,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 28),
                onPressed: () {},
                tooltip: 'Home',
              ),
              IconButton(
                icon: const Icon(Icons.location_on, color: Colors.white, size: 28),
                onPressed: () {},
                tooltip: 'Map',
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 18),
                label: const Text('cari', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary.withOpacity(0.6),
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
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: const BorderRadius.only(
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
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 16),
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surface,
                        alignment: Alignment.center,
                        child: const Text(
                          'image',
                          style: TextStyle(color: Colors.white70),
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
              color: theme.colorScheme.surface,
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
                const ProfileRow(
                  label: 'PASSWORD',
                  value: '',
                  actionText: 'CHANGE',
                  isValueLink: true,
                ),
                const ProfileRow(
                  label: 'sutan***@gmail.com',
                  value: '',
                  actionText: 'CHANGE',
                  isValueLink: true,
                ),
                const ProfileRow(
                  label: 'NO HP',
                  value: '089680510618',
                  actionText: '',
                  isValueLink: true,
                ),
                const ProfileRow(
                  label: 'ALAMAT',
                  value: 'Jl. Sungai Andai Komplek Herlina Perkasa',
                  actionText: '',
                  isValueLink: true,
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfilPage()),
                    );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profil', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.black, // ubah teks dan ikon jadi warna hitam
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
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
  final theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.mail_outline, size: 48, color: theme.colorScheme.onSurface),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                decoration: isValueLink ? TextDecoration.underline : TextDecoration.none,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                ),
                softWrap: true,
              ),
            ),
          ),
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
                  child: const Text(
                    'CHANGE',
                    style: TextStyle(
                      color: Colors.lightBlue,
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
