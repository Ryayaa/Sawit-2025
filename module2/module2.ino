#include <DHT.h>
#include <TinyGPSPlus.h>
#include <SPI.h>
#include <LoRa.h>

// Sensor Pins
#define DHT_PIN 4
#define SOIL_PIN 34
#define DHT_TYPE DHT22
#define SOIL_MOISTURE_AIR 3500
#define SOIL_MOISTURE_WATER 1500

DHT dht(DHT_PIN, DHT_TYPE);

// GPS
#define GPS_RX 16
#define GPS_TX 17
HardwareSerial gpsSerial(2);
TinyGPSPlus gps;

// LoRa Pins
#define LORA_SCK     18
#define LORA_MISO    19
#define LORA_MOSI    23
#define LORA_SS      5
#define LORA_RST     14
#define LORA_DIO0    26

String moduleId = "module2";

void setup() {
  Serial.begin(115200);
  dht.begin();
  pinMode(SOIL_PIN, INPUT);

  // GPS
  gpsSerial.begin(9600, SERIAL_8N1, GPS_RX, GPS_TX);
  Serial.println("📡 GPS started");

  // LoRa Setup with matching configuration
  SPI.begin(LORA_SCK, LORA_MISO, LORA_MOSI, LORA_SS);
  LoRa.setPins(LORA_SS, LORA_RST, LORA_DIO0);
  
  if (!LoRa.begin(433E6)) {
    Serial.println("❌ LoRa init failed!");
    while (true);
  }
  
  // Match these settings exactly with Module 1
  LoRa.setSpreadingFactor(7);
  LoRa.setSignalBandwidth(125E3);
  LoRa.setCodingRate4(5);
  LoRa.setTxPower(20);
  LoRa.enableCrc();
  
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

void loop() {
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();
  int soilMoisture = getSoilMoisturePercent();

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("❌ Failed to read DHT!");
    delay(2000);
    return;
  }

  // Create JSON string
  String data = "{";
  data += "\"moduleId\":\"module2\",";
  data += "\"temperature\":" + String(temperature, 1) + ",";
  data += "\"humidity\":" + String(humidity, 1) + ",";
  data += "\"soilMoisture\":" + String(soilMoisture);
  data += "}";

  // Send with retry mechanism
  bool sent = false;
  int retries = 3;
  
  while (!sent && retries > 0) {
    LoRa.beginPacket();
    LoRa.print(data);
    sent = LoRa.endPacket();
    
    if (sent) {
      Serial.println("✅ Data sent: " + data);
    } else {
      Serial.println("❌ Send failed, retrying... (" + String(retries) + " left)");
      delay(1000);
    }
    retries--;
  }

  delay(10000); // Wait 10 seconds before next transmission
}