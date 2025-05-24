#include <Arduino.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <DHT.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// WiFi credentials
#define WIFI_SSID "Eka Helda "
#define WIFI_PASSWORD "banjarmasin970"

// Firebase credentials
#define API_KEY "gf_NE4r72JoK1wSRmPkU4"
#define DATABASE_URL "https://sawit-iot-default-rtdb.asia-southeast1.firebasedatabase.app"

// Sensor pins
#define DHT_PIN 4        // DHT22 on GPIO 4
#define SOIL_PIN 34      // Soil Moisture on GPIO 34
#define DHT_TYPE DHT22

// Constants for soil moisture mapping
#define SOIL_MOISTURE_AIR 3500    // Value in air (dry)
#define SOIL_MOISTURE_WATER 1500  // Value in water (wet)

void loop() {
  // ...existing code...

  // Create JSON data for latest reading
  FirebaseJson jsonLatest;
  jsonLatest.set("temperature", temperature);
  jsonLatest.set("humidity", humidity);
  jsonLatest.set("soilMoisture", soilMoisture);
  jsonLatest.set("timestamp/.sv", "timestamp");
  
  // Send latest data
  if (Firebase.RTDB.setJSON(&fbdo, "/sensor_modules/" + moduleId + "/latest_reading", &jsonLatest)) {
    Serial.println("Latest data sent successfully");
  } else {
    Serial.println("Failed to send latest data");
    Serial.println("Reason: " + fbdo.errorReason());
  }

  // Create JSON data for historical readings
  FirebaseJson jsonHistory;
  String timestamp = String(millis());
  String historyPath = "/sensor_modules/" + moduleId + "/readings/" + timestamp;
  
  jsonHistory.set("temperature", temperature);
  jsonHistory.set("humidity", humidity);
  jsonHistory.set("soilMoisture", soilMoisture);
  jsonHistory.set("timestamp", timestamp);

  // Send historical data
  if (Firebase.RTDB.setJSON(&fbdo, historyPath, &jsonHistory)) {
    Serial.println("Historical data sent successfully");
  } else {
    Serial.println("Failed to send historical data");
    Serial.println("Reason: " + fbdo.errorReason());
  }
  
  delay(5000);  // 5 seconds delay between readings
}