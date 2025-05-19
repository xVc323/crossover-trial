# CrossOver Trial Reset Script

This script is designed to assist macOS users in resetting the CrossOver trial period and attempting to clear specific registry entries within CrossOver bottles that may relate to trial status.

## Features

*   Resets the CrossOver `FirstRunDate` preference to the current date.
*   Automatically scans for all CrossOver bottles.
*   For each bottle found, it attempts to:
    *   Back up the `system.reg` file.
    *   Find and remove specific registry keys related to `CodeWeavers\CrossOver\cxoffice`.
*   Clears CrossOver's application cache.
*   Runs non-interactively.
*   Provides detailed logging of its actions.

## Prerequisites

*   CrossOver for Mac installed.
*   Bash (standard on macOS).

## Usage

1.  **Important**: Ensure CrossOver and ALL emulated Windows applications are FULLY CLOSED before running the script.
2.  Download or clone the `reset_crossover_fully.sh` script to your Mac.
3.  Open Terminal.
4.  Navigate to the directory where you saved the script.
5.  Make the script executable:
    ```bash
    chmod +x reset_crossover_fully.sh
    ```
6.  Run the script:
    ```bash
    ./reset_crossover_fully.sh
    ```
    Or, if you've placed it in a directory within your PATH, you can run it directly by name. You can also run it from any location using its full path:
    ```bash
    /full/path/to/reset_crossover_fully.sh
    ```

## Disclaimer

*   This script modifies system preferences and bottle registry files. While it includes backup mechanisms for registry files, use it at your own risk.
*   The effectiveness of this script in resetting the trial may vary depending on CrossOver versions and other factors.
*   This script is provided for educational and personal use only. Please support software developers by purchasing licenses for software you find useful.
*   Blocking CrossOver's internet access via a firewall (not handled by this script) might be necessary for the trial reset to persist. 