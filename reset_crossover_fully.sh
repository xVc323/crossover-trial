#!/bin/bash

# Function to log messages
log_message() {
  echo "[INFO] $1"
}

error_message() {
  echo "[ERROR] $1" >&2
}

# --- Part 1: Reset the Trial Period ---
reset_trial_period() {
  log_message "Attempting to reset CrossOver trial period..."
  PLIST_FILE="$HOME/Library/Preferences/com.codeweavers.CrossOver.plist"

  if [ ! -f "$PLIST_FILE" ]; then
    error_message "Preferences file not found: $PLIST_FILE"
    error_message "Please ensure CrossOver has been run at least once."
    return 1
  fi

  # Get today's date in the format YYYY-MM-DDTHH:MM:SSZ (e.g., 2023-10-27T10:00:00Z)
  # Forcing time to 10:00:00Z as an example, as plists often store full datetime
  TODAY_DATE=$(date -u +"%Y-%m-%dT10:00:00Z")

  log_message "Setting FirstRunDate to: $TODAY_DATE"

  # Check current FirstRunDate
  CURRENT_FIRSTRUNDATE=$(defaults read "$PLIST_FILE" FirstRunDate 2>/dev/null)
  if [ $? -eq 0 ]; then
    log_message "Current FirstRunDate: $CURRENT_FIRSTRUNDATE"
  else
    log_message "FirstRunDate key not found or could not be read. Will attempt to add it."
  fi

  # Modify the FirstRunDate
  defaults write "$PLIST_FILE" FirstRunDate -date "$TODAY_DATE"
  if [ $? -eq 0 ]; then
    log_message "Successfully updated FirstRunDate in $PLIST_FILE."
  else
    error_message "Failed to update FirstRunDate. You might need to grant Terminal Full Disk Access or edit the file manually."
    error_message "To grant Full Disk Access: System Settings > Privacy & Security > Full Disk Access. Add Terminal."
    return 1
  fi
  return 0
}

# --- Part 2: Reset the Bottle (Registry Fix) ---
reset_bottle_registry() {
  log_message "Attempting to reset all bottle registries (non-interactive mode)..."
  BOTTLES_DIR="$HOME/Library/Application Support/CrossOver/Bottles"
  OVERALL_BOTTLE_RESET_STATUS=0 # 0 for success, 1 for any failure

  if [ ! -d "$BOTTLES_DIR" ]; then
    error_message "CrossOver Bottles directory not found: $BOTTLES_DIR"
    return 1
  fi

  BOTTLE_NAMES=()
  while IFS= read -r line;
  do
    BOTTLE_NAMES+=("$line")
  done < <(find "$BOTTLES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

  if [ ${#BOTTLE_NAMES[@]} -eq 0 ]; then
    error_message "No CrossOver bottles found in $BOTTLES_DIR. Skipping bottle reset."
    return 1 # Indicate failure as no bottles were processed
  fi

  log_message "Found bottles: ${BOTTLE_NAMES[*]}"
  log_message "Attempting to reset each one..."

  for BOTTLE_TO_PROCESS in "${BOTTLE_NAMES[@]}"; do
    log_message "--- Processing bottle: $BOTTLE_TO_PROCESS ---"
    CURRENT_BOTTLE_FAILED=0

    REGFILE="$BOTTLES_DIR/$BOTTLE_TO_PROCESS/system.reg"
    BAKFILE="$REGFILE.bak.$(date +%Y%m%d_%H%M%S)" # Unique backup file name
    FINDSTR="\[Software\\\\CodeWeavers\\\\CrossOver\\\\cxoffice\] [0-9]*" # Escaped for grep

    if [ ! -f "$REGFILE" ]; then
      error_message "Registry file not found for bottle '$BOTTLE_TO_PROCESS': $REGFILE"
      OVERALL_BOTTLE_RESET_STATUS=1
      CURRENT_BOTTLE_FAILED=1
      continue # Move to the next bottle
    fi

    cp "$REGFILE" "$BAKFILE"
    if [ $? -eq 0 ]; then
      log_message "Backup of registry created for '$BOTTLE_TO_PROCESS': $BAKFILE"
    else
      error_message "Failed to create backup of $REGFILE. Aborting bottle reset for '$BOTTLE_TO_PROCESS'."
      OVERALL_BOTTLE_RESET_STATUS=1
      CURRENT_BOTTLE_FAILED=1
      continue # Move to the next bottle
    fi

    MATCH_LINES=$(grep -nE "$FINDSTR" "$REGFILE")

    if [ -n "$MATCH_LINES" ]; then
      FIRST_MATCH_LN=$(echo "$MATCH_LINES" | head -n 1 | cut -d: -f1)
      log_message "Match found for pattern '$FINDSTR' starting at line $FIRST_MATCH_LN in $REGFILE for bottle '$BOTTLE_TO_PROCESS'."
      log_message "The following 5 lines will be automatically deleted:"
      sed -n "${FIRST_MATCH_LN},$((FIRST_MATCH_LN + 4))p" "$REGFILE"

      awk -v start_line="$FIRST_MATCH_LN" 'NR >= start_line && NR <= start_line + 4 {next} {print}' "$REGFILE" > "${REGFILE}.tmp" && mv "${REGFILE}.tmp" "$REGFILE"
      if [ $? -eq 0 ]; then
        log_message "Successfully deleted the lines from $REGFILE for bottle '$BOTTLE_TO_PROCESS'."
      else
        error_message "Failed to delete lines from $REGFILE. Restoring from backup for '$BOTTLE_TO_PROCESS'."
        cp "$BAKFILE" "$REGFILE" # Attempt to restore
        OVERALL_BOTTLE_RESET_STATUS=1
        CURRENT_BOTTLE_FAILED=1
      fi
    else
      log_message "No match found for pattern '$FINDSTR' in $REGFILE for bottle '$BOTTLE_TO_PROCESS'."
      log_message "No changes made to this bottle registry."
    fi
    if [ $CURRENT_BOTTLE_FAILED -eq 0 ]; then
        log_message "--- Finished processing bottle: $BOTTLE_TO_PROCESS successfully ---"
    else
        error_message "--- Finished processing bottle: $BOTTLE_TO_PROCESS with errors ---"
    fi
  done

  if [ $OVERALL_BOTTLE_RESET_STATUS -eq 0 ]; then
    log_message "All found bottles processed successfully or no changes needed."
  else
    error_message "One or more bottles encountered errors during processing. Please check logs."
  fi
  return $OVERALL_BOTTLE_RESET_STATUS
}

# --- Part 3 (from Troubleshooting): Clear Caches ---
clear_crossover_caches() {
  log_message "Attempting to clear CrossOver caches..."
  CACHE_DIR="$HOME/Library/Caches/com.codeweavers.CrossOver"

  if [ -d "$CACHE_DIR" ]; then
    rm -rf "$CACHE_DIR"
    if [ $? -eq 0 ]; then
      log_message "Successfully deleted CrossOver cache directory: $CACHE_DIR"
    else
      error_message "Failed to delete CrossOver cache directory: $CACHE_DIR"
      return 1
    fi
  else
    log_message "CrossOver cache directory not found: $CACHE_DIR. Nothing to delete."
  fi
  return 0
}


# --- Main Script ---
main() {
  echo "CrossOver Full Reset Script"
  echo "---------------------------"
  echo "IMPORTANT:"
  echo "1. Ensure CrossOver and ALL emulated Windows apps are FULLY CLOSED before running this script."
  echo "2. This script modifies system files. Make sure you understand what it does."
  echo "3. A backup of the bottle's system.reg file will be created."
  echo "4. Consider using a firewall (LuLu, Little Snitch) to block Codeweavers' domains for best results (not handled by this script)."
  # read -p "Press Enter to continue, or Ctrl+C to abort."
  log_message "Starting CrossOver reset process..."

  reset_trial_period
  TRIAL_RESET_STATUS=$?

  reset_bottle_registry
  BOTTLE_RESET_STATUS=$?

  clear_crossover_caches
  CACHE_CLEAR_STATUS=$?

  echo ""
  log_message "--- Summary ---"
  if [ $TRIAL_RESET_STATUS -eq 0 ]; then
    log_message "Trial period reset: SUCCESS"
  else
    error_message "Trial period reset: FAILED"
  fi

  if [ $BOTTLE_RESET_STATUS -eq 0 ]; then
    log_message "Bottle registry processing: COMPLETED. All bottles checked; changes made where applicable. No critical errors."
  else
    error_message "Bottle registry processing: FAILED. At least one bottle encountered a critical error (e.g., file missing, unable to write). Check logs above for details."
  fi

  if [ $CACHE_CLEAR_STATUS -eq 0 ]; then
    log_message "Cache clearing: SUCCESS (or no caches to clear)"
  else
    error_message "Cache clearing: FAILED"
  fi

  echo ""
  log_message "Reset process finished."
  log_message "Please restart CrossOver and check if the trial has been reset and your applications work."
  log_message "If issues persist, consider the 'Prevent Online Verification' and 'Troubleshooting' steps from the guide."
}

# Run the main function
main 