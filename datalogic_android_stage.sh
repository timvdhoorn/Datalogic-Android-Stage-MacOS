#!/bin/bash

# Datalogic Android Staging Script for macOS
# Converted from Datalogic_Android_Stage_7.4_win.bat
# Original made by Peter de Jong, converted to MacOS by Tim van der Hoorn

# --- Configuration ---
RESET="FALSE"
LOG="TRUE"
DEBUG="FALSE"
REBOOT="FALSE"
REBOOT_TIMEOUT=10
LEAVE_ON_USB_DEBUGGING="TRUE"

FW_FOLDER="Firmware"
APK_FOLDER="APK"
CFG_FOLDER="Config"
ESPR_FOLDER="Espresso"
# The ADB folder is no longer needed.

# --- Script Functions ---

# Function to print a log message
log_msg() {
    if [ "$LOG" == "TRUE" ]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> logfile.txt
    fi
    echo "$1"
}

# Function to check for required commands
check_dependencies() {
    if ! command -v adb &> /dev/null; then
        echo "Error: 'adb' command not found."
        echo "Please install Android Platform Tools."
        echo "If you use Homebrew, you can run:"
        echo "  brew install --cask android-platform-tools"
        exit 1
    fi
}

# Function to get device model name from its codename
get_device_name() {
    local dn_code="$1"
    case "$dn_code" in
        "JoyaPR") echo "Joya_Touch_A6" ;;
        "jta11"|"jta11f") echo "Joya_Touch_22" ;;
        "dl35") echo "Memor_10" ;;
        "m11") echo "Memor_11" ;;
        "Q10") echo "Memor_20_wwan" ;;
        "Q10A") echo "Memor_20_wlan" ;;
        "sx5") echo "SkorpioX5" ;;
        "memor_k") echo "Memor_K" ;;
        "nebula_pda") echo "Memor_30_35" ;;
        "tomcat_pda") echo "Memor_12_17" ;;
        *) echo "Unknown_Device" ;;
    esac
}

# --- Main Script ---

main() {
    # 1. Check dependencies
    check_dependencies

    # 2. Detect device
    log_msg "Searching for connected devices..."
    
    # Get list of devices, skipping header and footer lines

    devices=$(adb devices | awk 'NR > 1 && $2 == "device" {print $1}')

    if [ -z "$devices" ]; then
        log_msg "Error: No device connected to ADB. Please connect a device with USB debugging on."
        exit 1
    fi
    
    # For now, we will only process the first device found.
    # The original script could launch a new window for each device.
    device=$(echo "$devices" | head -n 1)
    log_msg "Found device: $device"

    # Check device status
    status=$(adb -s "$device" get-state)
    if [ "$status" == "unauthorized" ]; then
        log_msg "Error: Device $device is unauthorized. Please allow USB debugging on the device."
        exit 1
    elif [ "$status" == "offline" ]; then
        log_msg "Error: Device $device is offline. Please reboot the device and try again."
        exit 1
    fi

    # 3. Identify Device Model
    devicetype_code=$(adb -s "$device" shell getprop ro.product.device)
    devicetype_code=$(echo "$devicetype_code" | tr -d '[:space:]') # remove whitespace/newlines
    dn=$(get_device_name "$devicetype_code")
    
    log_msg "Connected device $device is a $dn"

    # 4. Set device-specific parameters (This is a simplified version)
    # In a full conversion, a large case statement like in the .bat file would be here.
    sd_path="/sdcard" # Default path
    log_msg "Using default SD card path: $sd_path"

    # 5. Install APKs
    if [ -d "$APK_FOLDER" ]; then
        log_msg "Searching for APKs in '$APK_FOLDER'..."
        apks_found=$(find "$APK_FOLDER" -name "*.apk" | wc -l)
        if [ "$apks_found" -gt 0 ]; then
            log_msg "Found $apks_found APK(s). Installing..."
            for apk_file in "$APK_FOLDER"/*.apk; do
                log_msg "Installing $apk_file..."
                adb -s "$device" install -r -g "$apk_file"
            done
        else
            log_msg "No APKs found."
        fi
    else
        log_msg "APK folder not found, skipping APK installation."
    fi

    # 6. Apply Configurations from .tar or .json files
    if [ -d "$CFG_FOLDER" ]; then
        log_msg "Searching for configuration files in '$CFG_FOLDER'..."
        tar_files=$(find "$CFG_FOLDER" -name "*.tar")
        json_files=$(find "$CFG_FOLDER" -name "*.json")

        if [ -n "$tar_files" ]; then
            # Assuming one .tar file
            tar_file=$(echo "$tar_files" | head -n 1)
            base_tar=$(basename "$tar_file")
            log_msg "Applying Scan2Deploy config from $base_tar"
            adb -s "$device" push "$tar_file" "$sd_path/$base_tar"
            adb -s "$device" shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver" --es profile-path "'$sd_path/$base_tar'"
        elif [ -n "$json_files" ]; then
             # Assuming one .json file
            json_file=$(echo "$json_files" | head -n 1)
            base_json=$(basename "$json_file")
            log_msg "Applying JSON config from $base_json"
            adb -s "$device" push "$json_file" "$sd_path/$base_json"
            adb -s "$device" shell am broadcast -a datalogic.scan2deploy.intent.action.START_SERVICE -n "com.datalogic.scan2deploy/.S2dServiceReceiver" --es json-path "'$sd_path/$base_json'"
        else
            log_msg "No .tar or .json configuration files found."
        fi
    else
        log_msg "Config folder not found, skipping configuration."
    fi
    
    # NOTE: Firmware, Espresso, and other specific update logic from the original
    # script have been omitted for this initial conversion for brevity and safety.
    # A full conversion would require careful translation of over 1000 lines of batch code.

    # 7. Final Steps
    if [ "$LEAVE_ON_USB_DEBUGGING" == "FALSE" ]; then
        log_msg "Disabling USB Debugging."
        adb -s "$device" shell settings put global adb_enabled 0
    fi

    if [ "$REBOOT" == "TRUE" ]; then
        log_msg "Rebooting device in $REBOOT_TIMEOUT seconds."
        sleep "$REBOOT_TIMEOUT"
        adb -s "$device" reboot
    fi

    log_msg "Configuration done."
    exit 0
}

# Run the main function
main
