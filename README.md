### Ewon Flexy Auto-Firmware Updater (Legacy Models)

Automated firmware update script for Ewon Flexy and Cosy 131 devices using onboard BASIC scripting.
Designed for fleets stuck with the post-v15 manual FTP process – this script lets devices pull and apply the latest firmware automatically over HTTPS, including proper handling of pre-v15 (.edf) and v15+ (.edfs) formats.
Ideal for maintaining ~30+ legacy units without manual FTP every time HMS releases a new version.

### Why This Exists

Starting with firmware 15.0, HMS disabled easy remote updates (eBuddy, open FTP/HTTP) for EU RED cybersecurity compliance.
Newer Cosy+ models get beautiful fleet auto-updates via eCatcher/Talk2M Pro.
Legacy Flexy/Cosy 131 do not – you're left with manual FTP or SD cards.This script is the community-standard workaround: devices self-update by downloading signed firmware from your own HTTPS server using GETHTTP.

### Features
- Full version parsing (handles 14.6s4, 15.0s2, 19.3s1, etc.)
- Automatic format detection:Pre-v15 → downloads and triggers .edf
- v15+ → downloads and triggers .edfs
- Version comparison (only updates when newer)
- Approximate download progress via timer polling
- Timestamped logging to console and persistent file (/usr/update_log.txt)
- Safe error handling and cleanup

### Prerequisites
Devices must have internet access (outbound HTTPS to your server).
Initial bootstrap:Enable FTP once (CloseDevice=0)
Upload this script via FTP to /usr/auto_update.bas
Add to INIT section or schedule daily

A public or authenticated HTTPS server you control hosting:ewon_latest_version.txt → plain text, e.g. 19.3s1
ewon_latest.edfs → latest signed firmware (downloaded from HMS portal)
ewon_pre15_latest.edf → latest pre-v15 unsigned (if supporting old units)
ewon_latest_size.txt → file size in bytes (for progress estimation)

### Setup Instructions

1. Download the latest script from this repo (auto_update.bas)
2. For each device (one-time):Connect via m2web.talk2m.com or eCatcher VPN
- Enable FTP (Setup → System → COM Parameters → CloseDevice = 0)
- FTP to device (adm credentials)
- Upload script to /usr/auto_update.bas
3. In BASIC IDE:Open the script
- Add to INIT section (runs on boot) or schedule with OnDate/OnTime
- Save and reboot
4. Host your files securely and update URLs in script if needed (currently hardcoded)

After this, devices will check daily (or on boot) and self-update automatically.

### Script Configuration

Edit these lines near the top to match your server:
`GETHTTP "https://yourserver.com/ewon_latest_version.txt","/tmp/latest.txt"
GETHTTP "https://yourserver.com/ewon_latest_size.txt","/tmp/expected_size.txt"
...
Url$ = "https://yourserver.com/ewon_latest.edfs"   // for v15+
Url$ = "https://yourserver.com/ewon_pre15_latest.edf"  // for pre-v15`

### Safety Notes
Always test on one device first
HMS-signed .edfs files are verified by the bootloader – corrupted downloads are rejected
Interrupted transfers are safe (file remains incomplete, ignored)
For large version jumps (e.g. 12 → 19), consider intermediate staged updates

### Contributing
Pull requests welcome! Especially:
- Staged/multi-step update logic
- HTTPS auth (basic/cert)
- Better progress reporting
