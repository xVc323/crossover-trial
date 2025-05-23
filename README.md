# CrossOver Trial Reset Script

This script provides a comprehensive nuclear reset of both the CrossOver trial period and bottle settings on your Mac.

## 🚀 Quick Reset (Recommended)

**Just run this one command:**

```sh
bash <(curl -fsSL "https://raw.githubusercontent.com/xVc323/crossover-trial/main/reset_crossover_fully.sh")
```

**Or download and run locally:**

```sh
curl -fsSL "https://raw.githubusercontent.com/xVc323/crossover-trial/main/reset_crossover_fully.sh" -o reset_crossover_fully.sh
chmod +x reset_crossover_fully.sh
./reset_crossover_fully.sh
```

## What This Script Does

This nuclear reset removes **ALL** trial tracking mechanisms:

- ✅ **Background license checking service** (the hidden culprit!)
- ✅ **HTTP/WebKit caches** containing trial validation data  
- ✅ **TIE (Trial Information Exchange) files**
- ✅ **All registry entries** and preference files
- ✅ **Keychain entries** for CrossOver/CodeWeavers
- ✅ **Running CrossOver processes**
- ✅ **Version tracking files** in bottles

## Prerequisites

- Make sure CrossOver is **fully closed**
- Ensure **ALL Windows emulated apps are NOT running**
- A firewall program (like **LuLu** or **Little Snitch**) to block CodeWeavers' domains

## After Running the Script

1. **Restart your Mac** (this clears any memory-cached trial info)
2. **Set up domain blocking** using Little Snitch or LuLu:
   - `codeweavers.com`
   - `www.codeweavers.com`
   - `*.codeweavers.com`
3. **Start CrossOver** and verify trial status

## Script Features

- **Non-interactive**: Runs automatically without prompts
- **Comprehensive backup**: Creates timestamped backups of all modified files
- **Error handling**: Reports any issues encountered
- **Detailed logging**: Shows exactly what's being processed
- **Cross-version compatible**: Works with different CrossOver versions

## Troubleshooting

### If CrossOver still shows the trial as expired:

1. **Ensure domain blocking is active** - This is the most critical step
2. **Check that you restarted your Mac** after running the script
3. **Verify all CrossOver processes were killed** before running the script

### Common Issues:

- **Permission denied errors:** Grant Terminal Full Disk Access in System Settings > Privacy & Security > Full Disk Access
- **Trial still expires:** Ensure firewall is properly blocking CodeWeavers domains
- **Applications won't launch:** Check bottle integrity and consider recreating bottles

### If Nothing Works:

CrossOver may be using new validation methods:
- Hardware fingerprinting
- Encrypted validation servers
- New online validation protocols

Consider alternative Wine implementations:
- **PlayOnMac**
- **Wineskin** 
- **Official Wine** with custom prefixes

## Manual Method (If Automated Script Fails)

<details>
<summary>Click to expand manual instructions</summary>

### Step 1: Reset Preferences
```bash
# Edit the preferences file
~/Library/Preferences/com.codeweavers.CrossOver.plist
# Change FirstRunDate to today's date
```

### Step 2: Reset Bottle Registry
```bash
# For each bottle in ~/Library/Application Support/CrossOver/Bottles/
# Edit system.reg and remove lines containing:
[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice]
```

### Step 3: Clear Caches
```bash
rm -rf ~/Library/Caches/com.codeweavers.CrossOver
rm -rf ~/Library/HTTPStorages/com.codeweavers.CrossOver
rm -rf ~/Library/WebKit/com.codeweavers.CrossOver
```

</details>

## Disclaimer

- This script modifies system preferences and bottle registry files. While it includes backup mechanisms, **use at your own risk**.
- The effectiveness may vary depending on CrossOver versions and other factors.
- This script is provided for **educational and personal use only**. Please support software developers by purchasing licenses for software you find useful.
- **Blocking internet access** via firewall is essential for the trial reset to persist.

## Contributing

If you discover improvements or fixes, please submit a pull request or open an issue.
