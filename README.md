# links_scanne

**Quick URL / link scanner (Bash).**  
Scans URLs/domains with local checks (DNS, SSL, WHOIS, etc.) and optional online reputation checks via **Google Safe Browsing (v4)** and **VirusTotal (v3)** APIs.

---

## 🔒 Safe to Publish
✅ The script is safe to upload.  
It only contains **placeholder variables** for API keys, no sensitive data or credentials.  
Just make sure **you never commit real API keys** to the repository.

---

## ⚙️ What this Script Does
1. Resolves domains and retrieves IPs (using `dig` or `host`).
2. Pulls SSL certificate information (`openssl`).
3. Performs WHOIS lookup to extract registrar, country, and creation/expiry dates.
4. Checks URL status via `curl`.
5. Optionally:
   - Queries **Google Safe Browsing** for phishing/malware detection.  
   - Queries **VirusTotal** for reputation and scanning results.

---

## 📦 Requirements
- OS: **Linux** or **macOS** (requires `bash`)
- Tools:  
  `curl`, `jq`, `whois`, `dig` or `host`, `openssl`, `grep`, `sed`, `awk`
- You need to get API's for the script to make it works:  
  - `GOOGLE_API_KEY` — for Google Safe Browsing API  
  - `VIRUSTOTAL_API_KEY` — for VirusTotal API

---

## 🧩 Install Dependencies (Debian/Ubuntu Example)
```bash
sudo apt update
sudo apt install -y curl jq dnsutils whois openssl

