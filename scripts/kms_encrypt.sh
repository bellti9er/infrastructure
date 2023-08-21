#!/bin/bash

KEY_ID=$1
TEXT_TO_ENCRYPT=$2

echo "Encrypting $TEXT_TO_ENCRYPT with key id $KEY_ID"

aws kms encrypt                                  \
    --region ap-northeast-2                      \
    --key-id $KEY_ID                             \
    --plaintext fileb://<(echo $TEXT_TO_ENCRYPT) \
    --output text                                \
    --query CiphertextBlob                       \
    --profile bellti9er
