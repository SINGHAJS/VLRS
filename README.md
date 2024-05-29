# Vehicle Location Reporting System (VLRS) 
The Vehicle Location Reporting System (VLRS) is a Location-Based Service (LBS) application designed to provide real-time tracking of public transport. This system leverages a Publisher-Subscriber architecture, involving two distinct mobile applications: one functioning as the publisher and the other as the subscriber. This repository contains the code for the subscriber application.

## Table of Contents
- [Getting Started](#getting-started)
- [Technologies Used](#technologies-used)
- [Prerequisites](#prerequisites)
- [Installation / Use](#installation)
- [Features](#features)
- [Additional Setup](#additional-setup)

## Getting Started
These instructions will help you get a copy of the VLRS project up and running on your local machine for development and testing purposes. 

## Technologies Used
- Flutter
- Dart
- Web Sockets (WS)
- Open Street Map (OSM) 
- JSON Web Token (JWT)
- TomTom API

## Prerequisites
Flutter development environment set up (Flutter SDK, Android Studio or Xcode)

## Installation / Use
1. Clone the repository: `https://github.com/SINGHAJS/VLRS.git`
2. Navigate to the Project Directory: `cd vlrs`
3. Install Dependencies: `flutter pub get`
4. Set Up Your Device:
   - For Android:
     - Enable Developer Options and USB Debugging on your device.
       - Go to Settings > About phone and tap Build number seven times to enable Developer Options.
       - Go back to Settings > System > Developer options and enable USB Debugging.
     - Connect your device via USB, or ensure your emulator is running.
    
   - For iOS:
     - Open the ios directory in Xcode.
       - Launch Xcode and open the ios directory of your project.
     - Ensure your iOS device is connected, or use a simulator.
       - Connect your iOS device to your computer.
       - Alternatively, select a simulator from Xcode.
    
5. Run the application: `flutter run`

## Features
- Real-Time Tracking: Track the location of public transport vehicles in real-time.
- User Location Tracking: Monitor the location of the subscriber device for updates.
- Estimated Time of Arrival (ETA): Calculates and shows accurate ETAs for public transport vehicles based on their real-time location and the subscriber's current position.


## Additional Setup
To demonstrate all functionalities of this application, the publisher application must be installed and used. You can find the publisher application at: `https://github.com/jasonchriscodes/VLRS-mqtt-publisher.git`

With these steps, you should be able to set up and run the VLRS subscriber application on your Flutter-supported devices.


