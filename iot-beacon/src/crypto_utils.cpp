// src/crypto_utils.cpp

#include <Arduino.h>
#include <esp_system.h>
#include <mbedtls/md.h>
#include <WiFi.h>
#include <time.h>

String generateNonce()
{
    static const char hexChars[] = "0123456789abcdef";

    uint8_t randomBytes[16];
    char nonce[33];

    for (int i = 0; i < 16; ++i)
    {
        randomBytes[i] = static_cast<uint8_t>(esp_random() & 0xFF);
    }

    for (int i = 0; i < 16; ++i)
    {
        nonce[i * 2] = hexChars[(randomBytes[i] >> 4) & 0x0F];
        nonce[(i * 2) + 1] = hexChars[randomBytes[i] & 0x0F];
    }

    nonce[32] = '\0';

    return String(nonce);
}

uint64_t generateTimestampMs()
{
    struct timeval tv;

    if (gettimeofday(&tv, nullptr) != 0)
    {
        return 0;
    }

    return (static_cast<uint64_t>(tv.tv_sec) * 1000ULL) +
           (static_cast<uint64_t>(tv.tv_usec) / 1000ULL);
}

String buildSignaturePayload(
    const String& beaconId,
    const String& nonce,
    uint64_t timestamp,
    int classroomId
)
{
    return beaconId +
           "|" +
           nonce +
           "|" +
           String(timestamp) +
           "|" +
           String(classroomId);
}

String generateHmacSha256(
    const String &payload,
    const String &secretKey)
{
    static const char hexChars[] = "0123456789abcdef";

    uint8_t hmacOutput[32];
    char hexOutput[65];

    mbedtls_md_context_t ctx;
    const mbedtls_md_info_t *mdInfo = mbedtls_md_info_from_type(MBEDTLS_MD_SHA256);

    mbedtls_md_init(&ctx);
    mbedtls_md_setup(&ctx, mdInfo, 1);
    mbedtls_md_hmac_starts(
        &ctx,
        reinterpret_cast<const unsigned char *>(secretKey.c_str()),
        secretKey.length());
    mbedtls_md_hmac_update(
        &ctx,
        reinterpret_cast<const unsigned char *>(payload.c_str()),
        payload.length());
    mbedtls_md_hmac_finish(&ctx, hmacOutput);
    mbedtls_md_free(&ctx);

    for (int i = 0; i < 32; ++i)
    {
        hexOutput[i * 2] = hexChars[(hmacOutput[i] >> 4) & 0x0F];
        hexOutput[(i * 2) + 1] = hexChars[hmacOutput[i] & 0x0F];
    }

    hexOutput[64] = '\0';

    return String(hexOutput);
}