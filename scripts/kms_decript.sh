#!/bin/bash

TEXT_DECRYPT=$1

echo "Decrypting $TEXT_DECRYPT"

aws kms decrypt --ciphertext $TEXT_DECRYPT --output text --query Plaintext --profile bellti9er --region ap-northeast-2 | base64 --decode

