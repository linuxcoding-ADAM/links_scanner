#!/bin/bash

# API Keys (Replace with your own)
# NOTE: These are example placeholders, not real keys.
GOOGLE_API_KEY="YOUR_GOOGLE_API_KEY_HERE"
VIRUSTOTAL_API_KEY="YOUR_VIRUSTOTAL_API_KEY_HERE"

# Colors for styling
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# Loading animation
loading() {
    local spin='🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘'
    while :; do
        for i in $spin; do
            echo -ne "\r$YELLOW Checking... $i $RESET"
            sleep 0.2
        done
    done
}

clear
echo -e "$CYAN"
echo " =========================================="
echo "            WELCOME BACK SIR   "
echo "  ✅ Google Safe Browsing + VirusTotal ✅"
echo "     ✅ WHOIS, IP, SSL, Hosting Info ✅"
echo " =========================================="
echo -e "$RESET"

# Get URL input
echo -e "$BLUE #Enter the URL to check: $RESET"
read URL

# Extract domain name
DOMAIN=$(echo $URL | awk -F/ '{print $3}')

### 🛡️ Step 1: Get Website IP & Hosting Details ###
echo " "
echo -e "$CYAN>>>🔍 Gathering Website Information...$RESET"
loading & 
LOADING_PID=$!

IP=$(dig +short $DOMAIN | head -n 1)
HOST_INFO=$(whois $DOMAIN | grep -E "Registrant|Registrar|Country|Creation Date|Updated Date|Expiration Date" | tr -s ' ')

kill $LOADING_PID  
wait $LOADING_PID 2>/dev/null

if [[ -z "$IP" ]]; then
    IP="${RED}Unable to resolve IP${RESET}"
fi

### 🔐 Step 2: Check SSL Certificate ###
echo ""
echo -e "$CYAN>>>🔍 Checking SSL Certificate...$RESET"
SSL_INFO=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -issuer -subject -dates)

if [[ -z "$SSL_INFO" ]]; then
    SSL_STATUS="${RED}No SSL certificate detected.${RESET}"
else
    SSL_STATUS="${GREEN}SSL Certificate Found:${RESET}\n$SSL_INFO"
fi

### 🛡️ Step 3: Google Safe Browsing Check ###
echo ""
echo -e "$CYAN>>>🔍 Checking Google Safe Browsing...$RESET"
loading &
LOADING_PID=$!

JSON_DATA=$(cat <<EOF
{
  "client": {
    "clientId": "AdamScanner",
    "clientVersion": "1.0"
  },
  "threatInfo": {
    "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION"],
    "platformTypes": ["ANY_PLATFORM"],
    "threatEntryTypes": ["URL"],
    "threatEntries": [{"url": "$URL"}]
  }
}
EOF
)

GOOGLE_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$GOOGLE_API_KEY")

kill $LOADING_PID  
wait $LOADING_PID 2>/dev/null

if [[ "$GOOGLE_RESPONSE" == "{}" ]]; then
    GOOGLE_STATUS="${GREEN}✅ Safe$RESET"
    GOOGLE_DETAILS="No threats found."
else
    GOOGLE_STATUS="${RED}⚠️ Dangerous$RESET"
    THREAT_TYPE=$(echo "$GOOGLE_RESPONSE" | grep -o '"threatType":"[^"]*' | cut -d':' -f2 | tr -d '"')
    GOOGLE_DETAILS="${RED}Threat Detected: $THREAT_TYPE${RESET}"
fi

### 🛡️ Step 4: VirusTotal Check ###
echo " "
echo -e "$CYAN>>>🔍 Checking VirusTotal...$RESET"
loading &
LOADING_PID=$!

VT_RESPONSE=$(curl -s --request POST --url "https://www.virustotal.com/api/v3/urls" \
  --header "x-apikey: $VIRUSTOTAL_API_KEY" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "url=$URL")

SCAN_ID=$(echo "$VT_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

sleep 5  # Wait for the scan

VT_REPORT=$(curl -s --request GET --url "https://www.virustotal.com/api/v3/analyses/$SCAN_ID" \
  --header "x-apikey: $VIRUSTOTAL_API_KEY")

kill $LOADING_PID  
wait $LOADING_PID 2>/dev/null

VT_DETECTIONS=$(echo "$VT_REPORT" | grep -o '"malicious":[0-9]*' | cut -d':' -f2)

if [[ "$VT_DETECTIONS" -eq 0 ]]; then
    VT_STATUS="${GREEN}✅ Safe$RESET"
    VT_DETAILS="No threats detected."
else
    VT_STATUS="${RED}⚠️ Dangerous ($VT_DETECTIONS detections)$RESET"
    VT_DETAILS="${RED}This URL was flagged by $VT_DETECTIONS security vendors.${RESET}"
fi

### ✅ Final Report ###
echo " " 
echo -e "$YELLOW"
echo "=========================================="
echo ""
echo "🔍 **Final Security Report for:** $URL"
echo ""
echo "=========================================="
echo " "
echo -e ">>>🌐 IP Address: $IP"
echo -e ">>>🏢 Hosting Details: \n$HOST_INFO"
echo -e ">>>🔐 SSL Info: \n$SSL_STATUS"
echo -e ">>>🔹 Google Safe Browsing: $GOOGLE_STATUS"
echo -e "    ➜ $GOOGLE_DETAILS"
echo -e "🔹 VirusTotal: $VT_STATUS"
echo -e "    ➜ $VT_DETAILS"
echo " "
echo "=========================================="
echo -e "$RESET"
echo -e "${RED}=========================================="
echo ""
if [[ "$GOOGLE_STATUS" == *"⚠️ Dangerous"* || "$VT_STATUS" == *"⚠️ Dangerous"* ]]; then
    echo -e "⚠️ ${RED}WARNING: This URL is potentially **malicious**! Proceed with caution.${RESET}"
    echo " "
    echo "            GOOD BAY SIR"
else
    echo -e "  ✅ ${GREEN}This URL appears to be safe.${RESET}"
    echo " "
    echo "           GOOD BAY SIR"
echo -e "${RED}=========================================="
fi
echo""
echo""
echo -e "$CYAN"
echo "        MADE WITH ❤️  BY M.A"
#!/bin/bash

# API Keys (Replace with your own)
GOOGLE_API_KEY="AIzaSyBtmBqXoXyx4c466bxOHun9dbUGkq_GDAI"
VIRUSTOTAL_API_KEY="af0c0098e8d79335703623a468ad718bb13fea2087ca8d64f6923b5be152b2f9"

# Colors for styling
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
RESET="\e[0m"

# Loading animation
loading() {
    local spin='🌑 🌒 🌓 🌔 🌕 🌖 🌗 🌘'
    while :; do
        for i in $spin; do
            echo -ne "\r$YELLOW Checking... $i $RESET"
            sleep 0.2
        done
    done
}

clear
echo -e "$CYAN"
echo " =========================================="
echo "            WELCOME BACK SIR   "
echo "  ✅ Google Safe Browsing + VirusTotal ✅"
echo "     ✅ WHOIS, IP, SSL, Hosting Info ✅"
echo " =========================================="
echo -e "$RESET"

# Get URL input
echo -e "$BLUE #Enter the URL to check: $RESET"
read URL

# Extract domain name
DOMAIN=$(echo $URL | awk -F/ '{print $3}')

### 🛡️ Step 1: Get Website IP & Hosting Details ###
echo " "
echo -e "$CYAN>>>🔍 Gathering Website Information...$RESET"
loading & 
LOADING_PID=$!

IP=$(dig +short $DOMAIN | head -n 1)
HOST_INFO=$(whois $DOMAIN | grep -E "Registrant|Registrar|Country|Creation Date|Updated Date|Expiration Date" | tr -s ' ')

kill $LOADING_PID  
wait $LOADING_PID 2>/dev/null

if [[ -z "$IP" ]]; then
    IP="${RED}Unable to resolve IP${RESET}"
fi

### 🔐 Step 2: Check SSL Certificate ###
echo ""
echo -e "$CYAN>>>🔍 Checking SSL Certificate...$RESET"
SSL_INFO=$(echo | openssl s_client -connect $DOMAIN:443 -servername $DOMAIN 2>/dev/null | openssl x509 -noout -issuer -subject -dates)

if [[ -z "$SSL_INFO" ]]; then
    SSL_STATUS="${RED}No SSL certificate detected.${RESET}"
else
    SSL_STATUS="${GREEN}SSL Certificate Found:${RESET}\n$SSL_INFO"
fi

### 🛡️ Step 3: Google Safe Browsing Check ###
echo ""
echo -e "$CYAN>>>🔍 Checking Google Safe Browsing...$RESET"
loading &
LOADING_PID=$!

JSON_DATA=$(cat <<EOF
{
  "client": {
    "clientId": "AdamScanner",
    "clientVersion": "1.0"
  },
  "threatInfo": {
    "threatTypes": ["MALWARE", "SOCIAL_ENGINEERING", "UNWANTED_SOFTWARE", "POTENTIALLY_HARMFUL_APPLICATION"],
    "platformTypes": ["ANY_PLATFORM"],
    "threatEntryTypes": ["URL"],
    "threatEntries": [{"url": "$URL"}]
  }
}
EOF
)

GOOGLE_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$GOOGLE_API_KEY")

kill $LOADING_PID  
wait $LOADING_PID 2>/dev/null

if [[ "$GOOGLE_RESPONSE" == "{}" ]]; then
    GOOGLE_STATUS="${GREEN}✅ Safe$RESET"
    GOOGLE_DETAILS="No threats found."
else
    GOOGLE_STATUS="${RED}⚠️ Dangerous$RESET"
    THREAT_TYPE=$(echo "$GOOGLE_RESPONSE" | grep -o '"threatType":"[^"]*' | cut -d':' -f2 | tr -d '"')
    GOOGLE_DETAILS="${RED}Threat Detected: $THREAT_TYPE${RESET}"
fi

### 🛡️ Step 4: VirusTotal Check ###
echo " "
echo -e "$CYAN>>>🔍 Checking VirusTotal...$RESET"
loading &
LOADING_PID=$!

VT_RESPONSE=$(curl -s --request POST --url "https://www.virustotal.com/api/v3/urls" \
  --header "x-apikey: $VIRUSTOTAL_API_KEY" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "url=$URL")

SCAN_ID=$(echo "$VT_RESPONSE" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

sleep 5  # Wait for the scan

VT_REPORT=$(curl -s --request GET --url "https://www.virustotal.com/api/v3/analyses/$SCAN_ID" \
  --header "x-apikey: $VIRUSTOTAL_API_KEY")

kill $LOADING_PID  
wait $LOADING_PID 2>/dev/null

VT_DETECTIONS=$(echo "$VT_REPORT" | grep -o '"malicious":[0-9]*' | cut -d':' -f2)

if [[ "$VT_DETECTIONS" -eq 0 ]]; then
    VT_STATUS="${GREEN}✅ Safe$RESET"
    VT_DETAILS="No threats detected."
else
    VT_STATUS="${RED}⚠️ Dangerous ($VT_DETECTIONS detections)$RESET"
    VT_DETAILS="${RED}This URL was flagged by $VT_DETECTIONS security vendors.${RESET}"
fi

### ✅ Final Report ###
echo " " 
echo -e "$YELLOW"
echo "=========================================="
echo ""
echo "🔍 **Final Security Report for:** $URL"
echo ""
echo "=========================================="
echo " "
echo -e ">>>🌐 IP Address: $IP"
echo -e ">>>🏢 Hosting Details: \n$HOST_INFO"
echo -e ">>>🔐 SSL Info: \n$SSL_STATUS"
echo -e ">>>🔹 Google Safe Browsing: $GOOGLE_STATUS"
echo -e "    ➜ $GOOGLE_DETAILS"
echo -e "🔹 VirusTotal: $VT_STATUS"
echo -e "    ➜ $VT_DETAILS"
echo " "
echo "=========================================="
echo -e "$RESET"
echo -e "${RED}=========================================="
echo ""
if [[ "$GOOGLE_STATUS" == *"⚠️ Dangerous"* || "$VT_STATUS" == *"⚠️ Dangerous"* ]]; then
    echo -e "⚠️ ${RED}WARNING: This URL is potentially **malicious**! Proceed with caution.${RESET}"
    echo " "
    echo "            GOOD BAY SIR"
else
    echo -e "  ✅ ${GREEN}This URL appears to be safe.${RESET}"
    echo " "
    echo "           GOOD BAY SIR"
echo -e "${RED}=========================================="
fi
echo""
echo""
echo -e "$CYAN"
echo "        MADE WITH ❤️  BY M.A"
