#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "usage: $0 <recipient_address> [creator_share] [owner_share] [recipient_share]"
  exit 1
fi

RECIPIENT_ADDRESS="$1"
CREATOR_SHARE="${2:-0}"
OWNER_SHARE="${3:-0}"
RECIPIENT_SHARE="${4:-10000000}"

cast abi-encode \
  "f((uint256 creatorShare,uint256 ownerShare,(address recipient,uint256 share)[] recipientShares))" \
  "(${CREATOR_SHARE},${OWNER_SHARE},[(${RECIPIENT_ADDRESS},${RECIPIENT_SHARE})])"
