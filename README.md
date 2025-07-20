# I-Sawit 🌴

**I-Sawit** is an IoT-based oil palm plantation monitoring and management application developed using Flutter and Firebase. This app helps users (admin & user) to monitor sensor data (temperature, humidity, soil moisture, and GPS location) in real-time from multiple IoT device modules installed in the field.

---

## ✨ Main Features

- **Real-Time Dashboard**  
  Monitor temperature, humidity, and device status instantly.
- **Multi-Module Monitoring**  
  Supports multiple sensor modules for large plantation areas.
- **Automatic Notifications**  
  Receive alerts if temperature/humidity exceeds normal limits.
- **Log History**  
  View sensor data history and filter by time & module.
- **User Management**  
  Easily manage user and admin accounts.
- **GPS Integration**  
  Track device locations visually on the map.
- **Password Reset & Messages**  
  Request password reset and receive message notifications.

---

## 🛠️ Technologies Used

- **Flutter** (Frontend)
- **Firebase Realtime Database** (Backend & Auth)
- **ESP32 + DHT22 Sensor, Soil Moisture, GPS** (IoT Device)
- **LoRa** (Communication between IoT modules)
- **Google Maps / OpenStreetMap** (Location visualization)

---

## 📸 App Screenshots

> ![Dashboard Screenshot](assets/images/dashboard_preview.png)
> ![History Screenshot](assets/images/history_preview.png)

---

## 🚀 Getting Started

1. **Clone this repository**
2. Run `flutter pub get`
3. Configure Firebase (see `lib/config/firebase_options.dart`)
4. Run the app:  
   ```
   flutter run
   ```
5. For web mode:  
   ```
   flutter run -d chrome
   ```

---

## 👨‍💻 Contributors

- Arrya Fitriansyah  
- Aldi Riadi  
- Sutan Burhan Rasyidin

---

## 📄 License

This application was developed for educational purposes and as a final project at Politeknik Negeri Banjarmasin.

---

> © 2025 Sawit Team • All Rights Reserved
