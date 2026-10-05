# VirpanAi mobile

Flutter app for Android and iOS. On Windows, run the Android app on a USB-connected phone; an emulator is not required.

## Run on an Android phone (Windows)

1. Install Flutter and the Android SDK, then reopen the terminal so `flutter` and `adb` are on `PATH`.
2. On the phone, enable **Developer options** and **USB debugging**. Connect a data-capable USB cable, unlock the phone, and approve its **Allow USB debugging?** prompt.
3. In PowerShell, from this folder, run:

   ```powershell
   adb devices -l
   flutter devices
   flutter pub get
   flutter run -d <device-id>
   ```

   Use the device ID shown by `flutter devices`. In the running Flutter terminal, press `r` for hot reload or `q` to stop.

If `adb devices -l` shows `unauthorized`, approve the prompt on the phone and run it again. If it shows no device, try a different data cable or USB port and install the manufacturer's Windows USB driver. Android SDK license prompts can be reviewed with `flutter doctor --android-licenses`.

## API connection

The app currently uses the URL in `lib/utility/app_config.dart` (`http://192.168.0.19:9000/`). The phone must be able to reach that address for API-backed screens to work. If the backend runs on this computer, start it and set that URL to this computer's LAN IP address; connect the phone to the same network. USB debugging alone does not make an unreachable LAN API available.
