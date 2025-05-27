#!/bin/bash

# Function to log messages
log_message() {
  echo "[INFO] $1"
}

error_message() {
  echo "[ERROR] $1" >&2
}

echo "CrossOver Trial Reset Script"
echo "============================"
echo "This script removes local trial tracking mechanisms including:"
echo "- Registry entries and preference files"
echo "- HTTP/WebKit caches containing trial data"
echo "- TIE files (trial information exchange)"
echo "- Keychain entries for CrossOver/CodeWeavers"
echo "- Version tracking files in bottles"
echo

log_message "Starting reset process automatically..."
log_message "IMPORTANT: Close CrossOver and ALL Windows apps before running!"

ERRORS=0

# 1. Nuclear preference reset
log_message "=== 1. Resetting Preferences ==="
PLIST_FILE="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"
if [ -f "$PLIST_FILE" ]; then
    # Backup first
    cp "$PLIST_FILE" "$PLIST_FILE.bak.$(date +%Y%m%d_%H%M%S)"
    
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

# 2. Remove TIE files
log_message "=== 2. Removing TIE Files ==="
TIE_DIR="$HOME/Library/Application Support/CrossOver/tie"
if [ -d "$TIE_DIR" ]; then
    rm -rf "$TIE_DIR"
    log_message "✓ TIE directory removed"
else
    log_message "No TIE directory found"
fi

# 3. Clear caches
log_message "=== 3. Clearing Caches ==="
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

# 4. Reset ALL bottles
log_message "=== 4. Resetting ALL Bottles ==="
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
            cp "$reg_file" "$reg_file.bak.$(date +%Y%m%d_%H%M%S)"
            
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

# 5. Remove any CrossOver keychain entries
log_message "=== 5. Cleaning Keychain ==="
security delete-generic-password -s "crossover" 2>/dev/null && log_message "✓ CrossOver keychain entry removed" || log_message "No CrossOver keychain entries"
security delete-generic-password -s "codeweavers" 2>/dev/null && log_message "✓ CodeWeavers keychain entry removed" || log_message "No CodeWeavers keychain entries"

# 6. Kill any running CrossOver processes
log_message "=== 6. Killing CrossOver Processes ==="
pkill -f CrossOver 2>/dev/null && log_message "✓ CrossOver processes killed" || log_message "No CrossOver processes running"

# Summary
echo
log_message "=== Reset Complete! ==="
echo
if [ $ERRORS -eq 0 ]; then
    log_message "✅ All operations completed successfully!"
else
    error_message "⚠️  $ERRORS errors encountered. Check the output above."
fi

echo
log_message "NEXT STEPS:"
log_message "1. Restart your Mac to clear any memory-cached trial information"
log_message "2. Start CrossOver and verify the trial has been reset"
echo
log_message "If the trial still shows as expired after following these steps,"
log_message "CrossOver may have implemented new validation methods."
echo
log_message "Alternative Wine implementations to consider:"
log_message "- PlayOnMac"
log_message "- Wineskin"
log_message "- Official Wine with custom prefixes" 