// iot-beacon/src/main.cpp

#include <Arduino.h>
#include <WiFi.h>
#include <time.h>
#include <NimBLEDevice.h>
#include <ArduinoJson.h>
#include "beacon_config.h"
#include "crypto_utils.h"

static const char* BEACON_SERVICE_UUID =
    "12345678-1234-1234-1234-123456789abc";

static const char* BEACON_CHARACTERISTIC_UUID =
    "87654321-4321-4321-4321-cba987654321";

NimBLEServer* pServer = nullptr;
NimBLEService* pService = nullptr;
NimBLECharacteristic* pCharacteristic = nullptr;

class BeaconServerCallbacks : public NimBLEServerCallbacks
{
public:

    void onConnect(
        NimBLEServer* pServer,
        NimBLEConnInfo& connInfo
    ) override
    {
        Serial.println(
            "BLE Client Connected"
        );
    }

    void onDisconnect(
        NimBLEServer* pServer,
        NimBLEConnInfo& connInfo,
        int reason
    ) override
    {
        Serial.println(
            "BLE Client Disconnected"
        );

        NimBLEDevice::getAdvertising()->start();

        Serial.println(
            "Advertising Restarted"
        );
    }
};

void updateBeaconPayload()
{
    String nonce = generateNonce();

    uint64_t timestamp = generateTimestampMs();

    String payloadString = buildSignaturePayload(
        BEACON_ID,
        nonce,
        timestamp,
        CLASSROOM_ID
    );

    String signature = generateHmacSha256(
        payloadString,
        BEACON_SECRET
    );

    JsonDocument doc;

    doc["beacon_id"] = BEACON_ID;
    doc["nonce"] = nonce;
    doc["timestamp"] = timestamp;
    doc["signature"] = signature;

    String jsonPayload;
    serializeJson(doc, jsonPayload);

    pCharacteristic->setValue(jsonPayload.c_str());

    Serial.println("Beacon Payload Updated");
}

void setup()
{
    Serial.begin(115200);

    Serial.println("ESP32 Beacon Booted");

    WiFi.mode(WIFI_STA);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    Serial.print("Connecting to WiFi");

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println();
    Serial.println("WiFi Connected");

    configTime(
        0,
        0,
        "pool.ntp.org",
        "time.nist.gov"
    );

    time_t now = time(nullptr);

    Serial.print("Waiting for NTP");

    while (now < 1700000000)
    {
        delay(500);
        Serial.print(".");

        now = time(nullptr);
    }

    Serial.println();
    Serial.println("NTP Time Synchronized");

    NimBLEDevice::init(DEVICE_NAME);

    pServer = NimBLEDevice::createServer();

    pServer->setCallbacks(
        new BeaconServerCallbacks()
    );

    pService = pServer->createService(BEACON_SERVICE_UUID);

    pCharacteristic = pService->createCharacteristic(
        BEACON_CHARACTERISTIC_UUID,
        NIMBLE_PROPERTY::READ
    );

    pService->start();

    updateBeaconPayload();

    NimBLEAdvertising* pAdvertising = NimBLEDevice::getAdvertising();

    NimBLEAdvertisementData advData;

    advData.setName(DEVICE_NAME);
    advData.addServiceUUID(BEACON_SERVICE_UUID);

    pAdvertising->setAdvertisementData(advData);

    pAdvertising->setMinInterval(32);
    pAdvertising->setMaxInterval(64);

    pAdvertising->start();

    Serial.println("BLE Advertising Started");
    Serial.println("Beacon Service Started");
}

void loop()
{
    static uint32_t lastUpdate = 0;

    if (millis() - lastUpdate >= 5000)
    {
        updateBeaconPayload();
        lastUpdate = millis();
    }

    delay(1000);
}