#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include <TinyGPSPlus.h>
#include <SPI.h>
#include <LoRa.h>

// WiFi credentials
#define WIFI_SSID "Eka Helda"
#define WIFI_PASSWORD "banjarmasin970"

// Firebase credentials
#define API_KEY "AIzaSyC7j6TD3DWXq-gf_NE4r72JoK1wSRmPkU4"
#define DATABASE_URL "https://sawit-iot-default-rtdb.asia-southeast1.firebasedatabase.app"

// Sensor
#define DHT_PIN 4
#define SOIL_PIN 34
#define DHT_TYPE DHT22
#define SOIL_MOISTURE_AIR 3500
#define SOIL_MOISTURE_WATER 1500

DHT dht(DHT_PIN, DHT_TYPE);

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String moduleId = "module1";

// GPS
#define GPS_RX 16
#define GPS_TX 17
HardwareSerial gpsSerial(2);
TinyGPSPlus gps;

// LoRa Pin Definition
#define LORA_SCK     18
#define LORA_MISO    19
#define LORA_MOSI    23
#define LORA_SS      5
#define LORA_RST     14
#define LORA_DIO0    26

void setup() {
  Serial.begin(115200);

  dht.begin();
  pinMode(SOIL_PIN, INPUT);
  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
  Serial.println("GPS module initialized");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nWiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Firebase
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = "admin@sawit.com";
  auth.user.password = "admin123";
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // LoRa initialization with proper configuration
  SPI.begin(LORA_SCK, LORA_MISO, LORA_MOSI, LORA_SS);
  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  
  if (!LoRa.begin(433E6)) {
    Serial.println("❌ LoRa init failed. Check wiring!");
    while (true);
  }

  // Set LoRa parameters for better reception
  LoRa.setSpreadingFactor(7);        // Lower SF for faster transmission
  LoRa.setSignalBandwidth(125E3);    // 125 kHz
  LoRa.setCodingRate4(5);            // 4/5
  LoRa.setTxPower(20);               // Maximum power
  LoRa.enableCrc();                  // Enable CRC

  Serial.println("✅ LoRa initialized");
}

int getSoilMoisturePercent() {
  int soilValue = analogRead(SOIL_PIN);
  int percent = map(soilValue, SOIL_MOISTURE_AIR, SOIL_MOISTURE_WATER, 0, 100);
  return constrain(percent, 0, 100);
}

bool readGPS(float &latitude, float &longitude, String &gpsTime) {
  while (gpsSerial.available()) {
    gps.encode(gpsSerial.read());
  }

  if (gps.location.isValid() && gps.time.isValid()) {
    latitude = gps.location.lat();
    longitude = gps.location.lng();
    char timeBuffer[10];
    sprintf(timeBuffer, "%02d:%02d:%02d", gps.time.hour(), gps.time.minute(), gps.time.second());
    gpsTime = String(timeBuffer);
    return true;
  }

  return false;
}

// GANTI bagian dalam loop() Anda dengan ini:

void loop() {
  if (Firebase.ready() && WiFi.status() == WL_CONNECTED) {
    // Check for LoRa packets with improved error handling
    int packetSize = LoRa.parsePacket();
    if (packetSize) {
      String receivedData = "";
      
      Serial.println("\n📡 LoRa packet received!");
      Serial.print("Packet size: "); 
      Serial.println(packetSize);
      
      // Read the packet
      while (LoRa.available()) {
        receivedData += (char)LoRa.read();
      }
      
      Serial.println("Data received: " + receivedData);

      // Process the received data
      FirebaseJson jsonLoRa;
      FirebaseJsonData jsonData;

      if (jsonLoRa.setJsonData(receivedData)) {
        if (jsonLoRa.get(jsonData, "moduleId")) {
          String senderModuleId = jsonData.stringValue;
          Serial.println("Sender moduleId: " + senderModuleId);

          if (senderModuleId != moduleId) {
            jsonLoRa.set("timestamp/.sv", "timestamp"); // Use Firebase server timestamp
            
            String path = "/" + senderModuleId + "/readings";
            if (Firebase.RTDB.pushJSON(&fbdo, path.c_str(), &jsonLoRa)) {
              Serial.println("✅ LoRa data pushed to Firebase: " + path);
            } else {
              Serial.println("❌ Firebase push failed: " + fbdo.errorReason());
            }
          }
        }
      }
    }

    // ======= Local Sensor Read ========
    float temperature = dht.readTemperature();
    float humidity    = dht.readHumidity();
    int   soilMoisture = getSoilMoisturePercent();

    if (isnan(temperature) || isnan(humidity)) {
      Serial.println("❌ Failed to read from DHT sensor!");
      delay(10000);
      return;
    }

    // Baca GPS
    float latitude = 0.0, longitude = 0.0;
    String gpsTime = "";
    bool gpsAvailable = readGPS(latitude, longitude, gpsTime);

    // === readings data ===
    FirebaseJson readingsData;
    readingsData.set("temperature", temperature);
    readingsData.set("humidity", humidity);
    readingsData.set("soilMoisture", soilMoisture);
    // Gunakan millis() sebagai timestamp
    readingsData.set("timestamp", (double)millis());
    if (LoRa.parsePacket()) {
    Serial.println("LoRa packet detected");
    // Baca data dst...
  } else {
    // Kalau perlu print ini juga untuk tahu ada waktu tanpa paket
    Serial.println("No LoRa packet");
  }


    // Tambahkan object gps jika valid
    if (gpsAvailable) {
      FirebaseJson gpsObj;
      gpsObj.set("latitude", latitude);
      gpsObj.set("longitude", longitude);
      readingsData.set("gps", gpsObj);
    }

    // Push readings ke /module1/readings
    String readingsPath = "/" + moduleId + "/readings";
    if (Firebase.RTDB.pushJSON(&fbdo, readingsPath.c_str(), &readingsData)) {
      Serial.println("✅ Sensor readings pushed to Firebase");
    } else {
      Serial.println("❌ Failed to push readings: " + fbdo.errorReason());
    }

    // === latest_gps data ===
    if (gpsAvailable) {
      FirebaseJson latestGpsData;
      latestGpsData.set("latitude", latitude);
      latestGpsData.set("longitude", longitude);
      latestGpsData.set("last_update", (double)millis());

      String gpsPath = "/" + moduleId + "/latest_gps";
      if (Firebase.RTDB.setJSON(&fbdo, gpsPath.c_str(), &latestGpsData)) {
        Serial.println("✅ GPS data updated to latest_gps");
      } else {
        Serial.println("❌ Failed to update GPS data: " + fbdo.errorReason());
      }

      Serial.printf("GPS -> Lat: %.6f | Lng: %.6f | Time: %s\n", latitude, longitude, gpsTime.c_str());
    } else {
      Serial.println("⚠️ GPS data not valid yet...");
    }

    Serial.printf("Temp: %.2f°C | Humidity: %.2f%% | Soil: %d%%\n", temperature, humidity, soilMoisture);

    delay(10000);
  }
  delay(1000); // Short delay for stability
}