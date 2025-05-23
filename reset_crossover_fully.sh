#!/bin/bash

# Function to log messages
log_message() {
  echo "[INFO] $1"
}

error_message() {
  echo "[ERROR] $1" >&2
}

echo "CrossOver Nuclear Trial Reset"
echo "============================"
echo "This script removes ALL trial tracking mechanisms including:"
echo "- Background license checking service"
echo "- HTTP/WebKit caches"
echo "- Registry entries"
echo "- Preference files"
echo "- TIE files (trial information exchange)"
echo "- Keychain entries"
echo

log_message "Starting nuclear reset process automatically..."
log_message "IMPORTANT: Close CrossOver and ALL Windows apps before running!"

ERRORS=0

# 1. Stop and remove the background license service
log_message "=== 1. Removing Background License Service ==="
PLIST_PATH="$HOME/Library/LaunchAgents/com.codeweavers.CrossOver.license.plist"
if [ -f "$PLIST_PATH" ]; then
    log_message "Stopping license service..."
    launchctl unload "$PLIST_PATH" 2>/dev/null
    rm -f "$PLIST_PATH"
    log_message "✓ License service removed"
else
    log_message "No license service found"
fi

# Remove the license script directory
LICENSE_DIR="$HOME/CrossOverLicence"
if [ -d "$LICENSE_DIR" ]; then
    rm -rf "$LICENSE_DIR"
    log_message "✓ License script directory removed"
fi

# 2. Nuclear preference reset
log_message "=== 2. Resetting Preferences ==="
PLIST_FILE="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"
if [ -f "$PLIST_FILE" ]; then
    # Backup first
    cp "$PLIST_FILE" "$PLIST_FILE.nuclear.bak.$(date +%Y%m%d_%H%M%S)"
    
    # Set trial date to today
    TODAY_DATE=$(date -u +"%Y-%m-%dT10:00:00Z")
    defaults write "$PLIST_FILE" FirstRunDate -date "$TODAY_DATE"
    
    # Remove any trial-related keys
    defaults delete "$PLIST_FILE" SULastCheckTime 2>/dev/null || true
    defaults delete "$PLIST_FILE" TrialExpired 2>/dev/null || true
    defaults delete "$PLIST_FILE" InstallTime 2>/dev/null || true
    defaults delete "$PLIST_FILE" NagTime 2>/dev/null || true
    defaults delete "$PLIST_FILE" Version 2>/dev/null || true
    
    log_message "✓ Preferences reset with FirstRunDate: $TODAY_DATE"
else
    error_message "Preferences file not found: $PLIST_FILE"
    error_message "Please ensure CrossOver has been run at least once."
    ERRORS=$((ERRORS + 1))
fi

# 3. Remove TIE files
log_message "=== 3. Removing TIE Files ==="
TIE_DIR="$HOME/Library/Application Support/CrossOver/tie"
if [ -d "$TIE_DIR" ]; then
    rm -rf "$TIE_DIR"
    log_message "✓ TIE directory removed"
else
    log_message "No TIE directory found"
fi

# 4. Nuclear cache clearing
log_message "=== 4. Nuclear Cache Clearing ==="
CACHE_DIRS=(
    "$HOME/Library/Caches/com.codeweavers.CrossOver"
    "$HOME/Library/HTTPStorages/com.codeweavers.CrossOver"
    "$HOME/Library/WebKit/com.codeweavers.CrossOver"
    "$HOME/Library/Saved Application State/com.codeweavers.CrossOver.savedState"
)

for cache_dir in "${CACHE_DIRS[@]}"; do
    if [ -d "$cache_dir" ]; then
        rm -rf "$cache_dir"
        log_message "✓ Removed: $(basename "$cache_dir")"
    fi
done

# 5. Reset ALL bottles
log_message "=== 5. Resetting ALL Bottles ==="
BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"
if [ -d "$BOTTLES_DIR" ]; then
    BOTTLE_COUNT=0
    find "$BOTTLES_DIR" -mindepth 1 -maxdepth 1 -type d | while read bottle_path; do
        bottle_name=$(basename "$bottle_path")
        log_message "Processing bottle: $bottle_name"
        BOTTLE_COUNT=$((BOTTLE_COUNT + 1))
        
        # Remove version tracking files
        rm -f "$bottle_path/.version" 2>/dev/null
        rm -f "$bottle_path/.update-timestamp" 2>/dev/null
        
        # Reset registry
        reg_file="$bottle_path/system.reg"
        if [ -f "$reg_file" ]; then
            # Create backup
            cp "$reg_file" "$reg_file.nuclear.bak.$(date +%Y%m%d_%H%M%S)"
            
            # Remove ALL CodeWeavers entries
            awk '
            BEGIN { flag = 0; }
            /^\[Software\\\\CodeWeavers/ { flag = 1; }
            flag && /^$/ { flag = 0; next; }
            !flag
            ' "$reg_file" > "${reg_file}.tmp" && mv "${reg_file}.tmp" "$reg_file"
            
            log_message "  ✓ Registry cleaned for $bottle_name"
        else
            error_message "  Registry file not found for $bottle_name"
        fi
    done
    log_message "✓ All bottles processed"
else
    error_message "CrossOver Bottles directory not found: $BOTTLES_DIR"
    ERRORS=$((ERRORS + 1))
fi

# 6. Remove any CrossOver keychain entries
log_message "=== 6. Cleaning Keychain ==="
security delete-generic-password -s "crossover" 2>/dev/null && log_message "✓ CrossOver keychain entry removed" || log_message "No CrossOver keychain entries"
security delete-generic-password -s "codeweavers" 2>/dev/null && log_message "✓ CodeWeavers keychain entry removed" || log_message "No CodeWeavers keychain entries"

# 7. Kill any running CrossOver processes
log_message "=== 7. Killing CrossOver Processes ==="
pkill -f CrossOver 2>/dev/null && log_message "✓ CrossOver processes killed" || log_message "No CrossOver processes running"

# Summary
echo
log_message "=== Nuclear Reset Complete! ==="
echo
if [ $ERRORS -eq 0 ]; then
    log_message "✅ All operations completed successfully!"
else
    error_message "⚠️  $ERRORS errors encountered. Check the output above."
fi

echo
log_message "IMPORTANT NEXT STEPS:"
log_message "1. Restart your Mac (this clears any memory-cached trial info)"
log_message "2. Ensure Little Snitch is blocking these domains:"
log_message "   - codeweavers.com"
log_message "   - www.codeweavers.com"
log_message "   - *.codeweavers.com"
log_message "3. Start CrossOver and check trial status"
echo
log_message "If CrossOver still shows expired after reboot, it may be using:"
log_message "- New online validation methods"
log_message "- Hardware fingerprinting"
log_message "- Encrypted validation servers"
echo
log_message "In that case, consider using alternative Wine implementations like:"
log_message "- PlayOnMac"
log_message "- Wineskin"
log_message "- Official Wine with custom prefixes" 