#!/usr/bin/env bash

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/scriptzteam/Tor-Bridges-Collector/refs/heads/main"
TEMPLATE_DIR="multitor/templates/tor"

# Optional SOCKS5 proxy
# Example:
# export SOCKS5_PROXY="socks5h://127.0.0.1:9050"
SOCKS5_PROXY="${SOCKS5_PROXY:-}"

mkdir -p "$TEMPLATE_DIR"

fetch_bridges() {
    local url="$1"

    if [[ -n "$SOCKS5_PROXY" ]]; then
        curl -fsSL --proxy "$SOCKS5_PROXY" "$url"
    else
        curl -fsSL "$url"
    fi
}

generate_config() {
    local bridge_file="$1"
    local output_file="$2"
    local plugin_line="$3"

    local url="${BASE_URL}/${bridge_file}"

    echo "Fetching: $url"

    bridges=$(fetch_bridges "$url")

    cat > "$output_file" <<EOF
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

UseBridges 1

EOF

    # Add transport plugin only if defined
    if [[ -n "$plugin_line" ]]; then
        echo "$plugin_line" >> "$output_file"
        echo >> "$output_file"
    fi

    while IFS= read -r line; do
        [[ -n "$line" ]] && echo "Bridge $line" >> "$output_file"
    done <<< "$bridges"

    cat >> "$output_file" <<'EOF'

# Static Path #
ExitNodes CBCC85F335E20705F791CFC8685951C90E24134D,E8AD8C4FDC3FE152150C005BB2EAA6A0990B74DF,74C0C2705DB1192C03F19F7CD1BB234843B1A81F
MiddleNodes ED9A731373456FA071C12A3E63E2C8BEF0A6E721,5DB9AE27A44EB7B476CC04A66C67A71C97A001E6,9AB93B5422149E5DFF4BE6A3814E2F6D9648DB6A,844AE9CAD04325E955E2BE1521563B79FE7094B7,CC701FCE86D6AF95FC3D5B71645D3430794910C1
StrictNodes 1

CircuitBuildTimeout 60
# NewCircuitPeriod 3600
NewCircuitPeriod 86400
MaxCircuitDirtiness 86400
EOF

    echo "Generated: $output_file"
}

# WebTunnel
generate_config \
    "bridges-webtunnel" \
    "${TEMPLATE_DIR}/torrc-template-webtunnel.cfg" \
    "ClientTransportPlugin webtunnel exec /usr/bin/webtunnel-client"

# Obfs4
generate_config \
    "bridges-obfs4" \
    "${TEMPLATE_DIR}/torrc-template-obfs4.cfg" \
    "ClientTransportPlugin obfs2,obfs3,obfs4,scramblesuit exec /usr/bin/lyrebird"

# Obfs4 IPv6
generate_config \
    "bridges-obfs4-ipv6" \
    "${TEMPLATE_DIR}/torrc-template-obfs4-ipv6.cfg" \
    "ClientTransportPlugin obfs2,obfs3,obfs4,scramblesuit exec /usr/bin/lyrebird"

# Vanilla
generate_config \
    "bridges-vanilla" \
    "${TEMPLATE_DIR}/torrc-template-vanilla.cfg" \
    ""

echo "All bridge configs generated successfully."
echo

if [[ -n "$SOCKS5_PROXY" ]]; then
    echo "SOCKS5 proxy used: $SOCKS5_PROXY"
else
    echo "No SOCKS5 proxy used."
fi