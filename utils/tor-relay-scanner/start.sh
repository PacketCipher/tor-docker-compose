#!/bin/bash

set -euo pipefail

# Scan
python3 tor-relay-scanner-1.0.4.pyz \
    --torrc \
    --outfile torrc-template-relay-scanner.cfg \
    --ssl \
    --ssl-data-amount 1 \
    -g 1000 \
    --timeout 10.0 \
    --relay-outfile relays \
    --relay-infile relays \
    --relay-infile-fallback

SRC_FILE="torrc-template-relay-scanner.cfg"
DEST_FILE="../../multitor/templates/tor/torrc-template-relay-scanner.cfg"

TMP_FILE="$(mktemp)"

# Build final config
cat > "$TMP_FILE" <<'EOF'
RunAsDaemon 1
# CookieAuthentication 0
SocksBindAddress 127.0.0.1
# NewCircuitPeriod 15
# MaxCircuitDirtiness 15
# NumEntryGuards 8
# CircuitBuildTimeout 5
# ExitRelay 0
# RefuseUnknownExits 0
ClientOnly 1
# StrictNodes 1
# AllowSingleHopCircuits 1
# KeepalivePeriod 60

EOF

# Append generated relay scanner config
cat "$SRC_FILE" >> "$TMP_FILE"

# Append static config block
cat >> "$TMP_FILE" <<'EOF'

# Static Path #
ExitNodes CBCC85F335E20705F791CFC8685951C90E24134D,E8AD8C4FDC3FE152150C005BB2EAA6A0990B74DF,74C0C2705DB1192C03F19F7CD1BB234843B1A81F
MiddleNodes ED9A731373456FA071C12A3E63E2C8BEF0A6E721,5DB9AE27A44EB7B476CC04A66C67A71C97A001E6,9AB93B5422149E5DFF4BE6A3814E2F6D9648DB6A,844AE9CAD04325E955E2BE1521563B79FE7094B7,CC701FCE86D6AF95FC3D5B71645D3430794910C1
StrictNodes 1

# LearnCircuitBuildTimeout 1
CircuitBuildTimeout 60
# NewCircuitPeriod 3600
NewCircuitPeriod 86400
MaxCircuitDirtiness 86400
EOF

# Ensure destination directory exists
mkdir -p "$(dirname "$DEST_FILE")"

# Replace destination file
mv -f "$TMP_FILE" "$DEST_FILE"

# Cleanup source file
rm -f "$SRC_FILE"

echo "Updated and moved file to: $DEST_FILE"