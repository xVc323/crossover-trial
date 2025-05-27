# CrossOver Trial Reset Script

This script provides a comprehensive reset of CrossOver trial period and bottle settings on your Mac by targeting local trial tracking mechanisms.

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

This reset removes **local** trial tracking mechanisms:

- ✅ **Registry entries** and preference files
- ✅ **HTTP/WebKit caches** containing trial validation data  
- ✅ **TIE (Trial Information Exchange) files**
- ✅ **Keychain entries** for CrossOver/CodeWeavers
- ✅ **Running CrossOver processes**
- ✅ **Version tracking files** in bottles

## Prerequisites

- Make sure CrossOver is **fully closed**
- Ensure **ALL Windows emulated apps are NOT running**

## After Running the Script

1. **Restart your Mac** (this clears any memory-cached trial info)
2. **Start CrossOver** and verify trial status

## Script Features

- **Non-interactive**: Runs automatically without prompts
- **Comprehensive backup**: Creates timestamped backups of all modified files
- **Error handling**: Reports any issues encountered
- **Detailed logging**: Shows exactly what's being processed
- **Cross-version compatible**: Works with different CrossOver versions

## Troubleshooting

### If CrossOver still shows the trial as expired:

1. **Check that you restarted your Mac** after running the script
2. **Verify all CrossOver processes were killed** before running the script

### Common Issues:

- **Permission denied errors:** Grant Terminal Full Disk Access in System Settings > Privacy & Security > Full Disk Access
- **Applications won't launch:** Check bottle integrity and consider recreating bottles

### If Nothing Works:

CrossOver may be using new validation methods:
- Hardware fingerprinting
- New local validation protocols
- Additional hidden trial tracking files

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

## Contributing

If you discover improvements or fixes, please submit a pull request or open an issue.
