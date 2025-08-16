# Datalogic Android Stage Tool

A simple, cross-platform command-line tool to easily stage Datalogic mobile computers with firmware, configuration files, and applications via a USB connection.

This repository contains a shell script (`datalogic_android_stage.sh`) that works on macOS, Linux, and Windows (via WSL).

## Credits and Acknowledgements

This project is a macOS-compatible conversion of the original Windows-based [Datalogic Android Stage tool by Peter de Jong](https://github.com/Pcdejong/Datalogic-Android-Stage). This version has been adapted to use a shell script (`.sh`) instead of the original batch file (`.bat`), allowing it to run on macOS, Linux, and other Unix-like systems.

## Getting Started

Follow these steps to download the tool and prepare your environment.

### 1. Download the Source Code

Click the green "Code" button on the main GitHub page and select "Download ZIP". Unzip the downloaded file to a location on your computer.

### 2. Install Dependencies

The only dependency is the **Android Debug Bridge (`adb`)**. If you don't have it, you can install it using Homebrew on macOS:

```sh
brew install --cask android-platform-tools
```

For other operating systems, follow the official installation instructions.

### 3. Make the Script Executable

Before running the script for the first time, you need to make it executable. Open a terminal, navigate to the directory where you saved the files, and run the following command:

```sh
chmod +x datalogic_android_stage.sh
```

## Usage

1.  **Enable USB Debugging:** Turn on USB debugging on your Datalogic device. You can do this manually in the developer settings or by using a Scan2Deploy profile.

2.  **Prepare Files:**
    *   Place firmware `.zip` files in the `Firmware/` directory.
    *   Place application `.apk` files in the `APK/` directory.
    *   Place configuration files (`.tar`, `.json`) in the `Config/` directory.
    *   Place Espresso `.zip` files in the `Espresso/` directory.

3.  **Run the Script:** Connect your device and execute the script from your terminal:
    ```sh
    ./datalogic_android_stage.sh
    ```

The script will automatically detect the device and apply the files found in the respective folders.

---

## Original Windows Batch File (`.bat`) Documentation

The following is the documentation for the original Windows-based batch file. While the new shell script aims for feature parity, some advanced options described below may not be present in the current version.

### Warning
Please be aware that the script may rename files to remove spaces to ensure correct installation.

### Firmware Update
To update the firmware, place the update `.zip` file in the `Firmware/` folder and run the script. The script will check the device's current firmware version and skip the update if it's already up-to-date.

*   **Factory Reset:** By default, a factory reset is performed after the update. You can change this by editing the `RESET` parameter inside the script.
*   **Battery Check:** A check is built-in to ensure the battery is sufficiently charged before starting a firmware update.

### Configuration Files
You can add various configuration files to the `Config/` folder, which will be applied to the device. This includes:
*   Scan2Deploy `.tar` or `.json` files.
*   Visual Formatter files.

### Application (APK) Files
To install your application(s), you can add one or multiple `.apk` files in the `APK/` folder.

### Multiple Devices
You can stage or update multiple devices at once. Just connect more than one device to your computer with USB debugging enabled.

### Log File
Logging is enabled by default. A `logfile.txt` is created with the date, time, serial number, and a record of the operations performed. To disable logging, change the `LOG` parameter inside the script to `FALSE`.

### Bugs and Enhancements
If you encounter bugs or have suggestions for new features, please feel free to open an issue on this GitHub repository.

---

## Changelog

*   **Version 7.4:** Update for multiple prefixes. Installation of Espresso files first. Wait for the device to come back. Check on files to be copied correctly to the device (firmware, espresso, scan2deploy)
*   **Version 7.3:** Support Memor 12/17/30/35 combined firmware files
*   **Version 7.2:** Update on Scan2Deploy tar files and added support for JSON files. Deprecation of DXU, GLink, Velocity, Copy files and more (cleanup ;-))
*   **Version 7.1:** Initial support for Memor 12
*   **Version 7.0:** Support for Memor 30/35
*   **Version 6.9:** Initial support for Memor 30
*   **Version 6.8:** Added support to turn off the usb debugging on exit of the process.
*   **Version 6.7:** Added support for JTA22 CR (Kyoto) versions.
*   **Version 6.6:** Support for Memor11
*   **Version 6.5:** Initial support for Memor11
*   **Version 6.4:** Firmware support for the JTA22.
*   **Version 6.3:** Create a check on the Scan2deploy payload if it's gets so big that it exceeds the limit of 1022 characters. Give the option to modify the payload manually.
*   **Version 6.2:** Support for Memor 20 sideload
*   **Version 6.1:** Fix for Security updates on SX5 and M20 firmware
*   **Version 6.0:** Fix for Memor 20 Android 11 firmware
*   **Version 5.9:** Skipped sideload for incremenatal firmware.
*   **Version 5.8:** Initial support for firmware update JTA22. Created support for more sideload devices. (currently SX5 and JTA22)
*   **Version 5.7:** Changed the model check to the adb status (works much faster). Fixed the JTA6 firmware update.
*   **Version 5.6:** Added DefaultScanParameters and DisableLockscreen parameters to easily set some default parameters and to disable the lockscreen
*   **Version 5.5:** Changed the adb status check to an individual check. So you can still use the files when for example a different terminal is doing a sideload update.
*   **Version 5.4:** Make sure DXU is started before a DXU file is applied.
*   **Version 5.3:** Bugfix on Glink config files. Added Espresso folder to the zip file.
*   **Version 5.2:** Added support for Wifi configuring WPA2 networks. Added support for autoreboot a terminal.
*   **Version 5.1:** Bugfix on Espresso firmware installations.
*   **Version 5.0:** Added SurelockRun parameter to easily start Surelock. Added Glink support to copy config.glinki config files to the correct import directory (https://www.gar.no/products/glink-for-android)
*   **Version 4.9:** Added Xtralogic support (RDP application) and introduced SkorpioX5 sideload method. Removed direct import for Surelock and Surefox settings (4.3)
*   **Version 4.8:** Removed renaming of spaces in dxu/apk and firmware files
*   **Version 4.7:** Fixed Surefox import. Fixed Memor K firmware update.
*   **Version 4.6:** Created a debug mode for troubleshooting purposes
*   **Version 4.5:** Build in support for Espresso packages
*   **Version 4.4:** Implement possibility to set fixed ip adresses with the DLintentSDK
*   **Version 4.3:** Implement direct import of Surelock and Surefox settings files (instead of autoimport)
*   **Version 4.2:** Fix for offline devices (ADB).
*   **Version 4.1:** Implementation of deploying local Scan2Deploy files
*   **Version 4.0:** Implementation of fixed firmware folder with selecting the hightest firmware
*   **Version 3.9:** Initial release on fixed firmware folder
*   **Version 3.8:** Changes on firmware selection
*   **Version 3.7:** Build in check for applying correct firmware version type for JTA6, Memor 1, 10, 20, K and SkorpioX5
*   **Version 3.6:** Added support for loading correct firmware version (ROW/AOSP/US) on Memor 10
*   **Version 3.5:** Added support for Memor 20 Wifi models (and build in check for loading correct version)
*   **Version 3.4:** Added support for Velocity
*   **Version 3.3:** Added support for separate folders for firmware/apk and config files
*   **Version 3.2:** Added support for Visual Formatter files.
*   **Version 3.1:** Added support for Handscanner/SkorpioX5
*   **Version 3.0:** Fixed a bug supporting AM/PM timezones
*   **Version 2.9:** Fixed a bug finding zip files
*   **Version 2.8:** Added support for Memor K
*   **Version 2.7:** Added check on installation on Datalogic Android Drivers. Added a autocopy function for jpg,jpeg and settings folder to SDCARD
*   **Version 2.6:** Automatic reboot after firmware update for Android 9 and higher.
*   **Version 2.5:** Initial support for Memor 20.
*   **Version 2.4:** Better handling on zip files.
*   **Version 2.3:** Bugfix on multiple devices. Created a readme.txt for a better documentation. Rename to Datalogic Android Stage tool (DAS)
*   **Version 2.2:** Bugfix
*   **Version 2.1:** Added support for incremental firmware check on Memor 10. Added a check on battery level > 20% for firmware updates.
*   **Version 2.0:** Implemented logging
*   **Version 1.9:** Fix for unauthorized devices. Clean up code.
*   **Version 1.8:** Support to stage multiple devices at once. (make sure they are all authorized) Added aditional Options at the bottom. (Copy/Start/Log)
*   **Version 1.7:** Added check for unauthorized devices. Grant permissions on installation of APK files. Added support for check on build version
*   **Version 1.6:** Added support for incremental updates
*   **Version 1.5:** FW support for Memor 1 Gun
*   **Version 1.4:** Added reset support
*   **Version 1.3:** Added firmware support for Memor 10
*   **Version 1.2:** Default use of Datalogic ADB. Support for 32 and 64 bit. Remove spaces from DXU files
*   **Version 1.1:** Updated current directory. Build in check for multiple zip files.
*   **Version 1.0:** Initial setup.
