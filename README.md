# Sophon

Nuxify's very own template for building decentralized apps (dApps) with Flutter and Dart.

Interacts with a Greeter Smart Contract found here: <https://sepolia.etherscan.io/address/0x0e10e90f67C67c2cB9DD5071674FDCfb7853a6F5>.
Supports MetaMask and other wallet providers.

Template architecture closely resembles our other Flutter template: <https://github.com/Nuxify/flirt> but this one is geared towards dApps.

## Demo

Download the Sophon demo app from Google Play Store: <https://play.google.com/store/apps/details?id=com.nuxify.sophon>

Coming soon in Apple App Store.

## MetaMask

Download MetaMask mobile here: <https://metamask.io/download/>

## Flutter Version Manager (FVM)

 We recommend using FVM to manage Flutter versions as you may switch from different Flutter versions depending on the projects compatibility. Follow the guide here: <https://fvm.app/documentation/getting-started/installation>

## Build steps

All these steps are assuming you're using VS Code as your editor.

1. Make sure that the [Flutter SDK](https://flutter.dev/docs/get-started/install) is installed on your machine.

- The installation of the SDK requires plenty of other software such as **Android Studio** and **Xcode** (if you're developing in Mac). Ensure that you have these too.

2. You can run the project in multiple ways:

- Android Emulator (Open Android Studio -> Configure -> AVD Manager)
- iOS Simulator (Run ```open -a Simulator``` in the Terminal)
- Physical device (Connect phone to your development machine)

3. Run the command ``make`` on the Terminal. This will automatically run a sequence of commands such as ```make install``` that are necessary for running the project.

4. Create a `.env` file in the root of the folder, copy the contents of `.env.example` and fill it with the corresponding data. Greeter contract address can be found at the top of this README file.

5. Voila! The project should now be running on your designated simulator/device.

To use Flutter debug tools, go to Run -> Start Debugging in VS Code.

See Makefile for other commands.

Made with ❤️ at [Nuxify](https://nuxify.tech)
