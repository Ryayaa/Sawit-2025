# I-Sawit 🌴

**I-Sawit** adalah aplikasi monitoring dan manajemen kebun sawit berbasis IoT yang dikembangkan menggunakan Flutter dan Firebase. Aplikasi ini membantu pengguna (admin & user) untuk memantau data sensor (suhu, kelembaban, kelembaban tanah, dan lokasi GPS) secara real-time dari beberapa modul perangkat IoT yang terpasang di lapangan.

---

## ✨ Fitur Utama

- **Dashboard Real-Time**  
  Pantau suhu, kelembaban, dan status perangkat secara langsung.
- **Monitoring Multi-Module**  
  Mendukung banyak modul sensor untuk area kebun yang luas.
- **Notifikasi Otomatis**  
  Dapatkan peringatan jika suhu/kelembaban melebihi batas normal.
- **Log History**  
  Lihat riwayat data sensor dan filter berdasarkan waktu & modul.
- **Manajemen User**  
  Kelola akun user dan admin dengan mudah.
- **Integrasi GPS**  
  Lacak lokasi perangkat secara visual di peta.
- **Reset Password & Pesan**  
  Fitur permintaan reset password dan notifikasi pesan.

---

## 🛠️ Teknologi yang Digunakan

- **Flutter** (Frontend)
- **Firebase Realtime Database** (Backend & Auth)
- **ESP32 + Sensor DHT22, Soil Moisture, GPS** (IoT Device)
- **LoRa** (Komunikasi antar modul IoT)
- **Google Maps / OpenStreetMap** (Visualisasi lokasi)

---

## 📸 Tampilan Aplikasi

> ![Dashboard Screenshot](assets/images/dashboard_preview.png)
> ![History Screenshot](assets/images/history_preview.png)

---

## 🚀 Cara Menjalankan

1. **Clone repository ini**
2. Jalankan `flutter pub get`
3. Konfigurasikan Firebase (lihat file `lib/config/firebase_options.dart`)
4. Jalankan aplikasi:  
   ```
   flutter run
   ```
5. Untuk mode web:  
   ```
   flutter run -d chrome
   ```

---

## 👨‍💻 Kontributor

- Arrya Fitriansyah  
- Aldi Riadi  
- Eka Helda

---

## 📄 Lisensi

Aplikasi ini dikembangkan untuk keperluan edukasi dan tugas akhir di Politeknik Negeri Banjarmasin.

---

> © 2025 Sawit Team • All Rights Reserved
