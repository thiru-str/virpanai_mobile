# VirpanAI mobile app

## Run on an Android phone through USB

The workspace toolchain is in `../.local-tools`: Flutter, Java 17, and the Android SDK.

1. On your phone, open **Settings → About phone** and tap **Build number** seven times (some manufacturers put this under Software information).
2. Open **Developer options** and enable **USB debugging**.
3. Connect the phone using a USB cable that supports data transfer. Unlock it and accept **Allow USB debugging?**.
4. Connect the phone to the same Wi-Fi network as the computer and make sure it can reach **http://192.168.0.122:9000/health**. The local backend serves HTTP.
5. From this repository, run:

   ```bash
   bash tool/run-android.sh
   ```

The script runs the app on your USB-connected phone using the URL in `lib/utility/app_config.dart`. USB is used for installation and debugging; API requests use your local network. Keep the cable connected while developing. Press `r` in the terminal for hot reload, `R` for a full restart, or `q` to stop.

For multiple connected devices, specify a device ID:

```bash
source tool/dev-env.sh
adb devices -l
bash tool/run-android.sh DEVICE_ID
```

## Use Flutter commands in your terminal

```bash
source tool/dev-env.sh
flutter doctor
flutter devices
flutter pub get
```

Source the environment again in each new terminal. The tools are installed inside this workspace, so keep `../.local-tools` available.

## Debug in VS Code

Open this repository folder in VS Code and install the **Flutter** extension by Dart Code. Select your Android phone, choose **Android phone — local backend (USB)** in Run and Debug, and press **F5**.

If you open the parent `virpanai` workspace containing all the repositories, select **Virpanai mobile — Android USB** instead.

Launch configurations use the base URL directly from `lib/utility/app_config.dart`, without a localhost override. Restart the app after changing that URL.

## If the phone shows as unauthorized

Unlock the phone and accept the USB debugging prompt. If no prompt appears, disconnect the cable, toggle USB debugging off and on, reconnect, and check again. You may need **Revoke USB debugging authorizations** in Developer options, then reconnect and authorize this computer.
