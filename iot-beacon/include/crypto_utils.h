// include\crypto_utils.h

#pragma once

#include <Arduino.h>
#include <stdint.h>

String generateNonce();

uint64_t generateTimestampMs();

String buildSignaturePayload(
    const String& beaconId,
    const String& nonce,
    uint64_t timestamp,
    int classroomId
);

String generateHmacSha256(
    const String& payload,
    const String& secret
);