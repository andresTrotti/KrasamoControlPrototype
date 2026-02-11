# SiLabs, Matter and iOS Integration Demo 
_This demo is an iOS application that integrates Apple's Matter.framework to commission, control, and monitor Matter‑certified devices. It is specifically designed to work with the Silicon Labs SiWG917 development kit. The project follows a clean MVVM architecture with dependency injection, use cases, and repositories, all built with SwiftUI._


![Demo view](https://github.com/user-attachments/assets/6bba14a8-6c47-41ff-b845-7bf0126b3c2c)

## 📋 Table of Contents

- [Overview](#overview)
- [Requirements](#requirements)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Initial Setup](#initial-setup)
- [Implemented Features](#implemented-features)
- [Commissioning Flow](#commissioning-flow)
- [Key Components](#key-components)
  - [AppContainer](#appcontainer)
  - [MatterControllerFactory](#mattercontrollerfactory)
  - [MatterKeypair](#matterkeypair)
  - [CommissioningWorker](#commissioningworker)
- [Repositories & Use Cases](#repositories--use-cases)
- [ViewModels & Views](#viewmodels--views)
- [Known Issues & Solutions](#known-issues--solutions)
- [Future Improvements](#future-improvements)
- [License](#license)

## Overview
ControlPrototype enables:

- Scanning Matter QR codes to start commissioning.
- Commissioning Matter devices over Bluetooth (PASE) and injecting Wi‑Fi credentials (CASE).
- Displaying a list of commissioned devices (mock data for testing).
- Controlling LED state (on/off) and reading temperature from compatible devices.
- Exploring a dashboard with home status (temperature, humidity, etc.).

The app is intended as a starting point for developers who want to integrate Matter into their iOS apps using Apple's native Matter.framework.

Look at **Deployment** to know how to launch the project 



### Requirements

- Xcode 15.0+ (tested with Xcode 16.4+)
- iOS 15.0+ (Matter requires iOS 15.0 or later)
- Physical device (iPhone/iPad) – Matter does not run on the simulator
- Apple Developer account (to run on device)
- Wi‑Fi network (2.4 GHz recommended for Matter devices)
- Matter‑capable chip (e.g. SiWG917, ESP32‑Matter, etc.)


### Architecture
The project follows MVVM (Model‑View‑ViewModel) with additional layers:

```Swift 
UI (SwiftUI) → ViewModels (ObservableObject) → UseCases → Repository → Matter SDK

SwiftUI Views: DeviceListView, DeviceDetailView, QRScannerView, DashboardView.
```


#### ViewModels: 
Manage state and presentation logic (DeviceListViewModel, DeviceDetailViewModel, QRScannerViewModel).

#### Use Cases: 
Encapsulate business logic (CommissionDeviceUseCase, ToggleLedUseCase, ReadTemperatureUseCase).

#### Repositories: 
Abstract the Matter SDK (MatterDeviceRepository, MatterDeviceRepositoryImpl).

#### Dependency Injection:
AppContainer acts as the main assembler and lifecycle manager for the MTRDeviceController.

_All Matter interactions are performed asynchronously using async/await and CheckedContinuation to wrap delegate‑based APIs._


### Project Structure
```text
ControlPrototype/
├── App/
│   ├── ControlPrototypeApp.swift          # SwiftUI App entry point
│   ├── AppContainer.swift                # Dependency container & Matter controller
│   └── AppRouter.swift                  # Legacy routing (replaced by MainTabView)
│
├── Domain/
│   ├── Entities/                         # Business models
│   │   ├── MatterDevice.swift
│   │   ├── LedState.swift
│   │   ├── HeaterState.swift
│   │   ├── CoolerState.swift
│   │   └── TemperatureReading.swift
│   │
│   └── UseCases/                        # Use cases
│       ├── CommissionDeviceUseCase.swift
│       ├── GetKnownDevicesUseCase.swift
│       ├── ToggleLedUseCase.swift
│       └── ReadTemperatureUseCase.swift
│
├── Data/
│   ├── Protocols/
│   │   └── MatterDeviceRepository.swift  # Repository abstraction
│   │
│   └── Repositories/
│       └── MatterDeviceRepositoryImpl.swift # Matter SDK implementation
│
├── Presentation/
│   ├── ViewModels/
│   │   ├── DeviceListViewModel.swift
│   │   ├── DeviceDetailViewModel.swift
│   │   └── QRScannerViewModel.swift
│   │
│   └── Views/
│       ├── DeviceListView.swift
│       ├── DeviceDetailView.swift
│       ├── FeatureCard.swift
│       ├── QRScannerView.swift
│       ├── QRScannerRepresentable.swift # UIKit bridge for VisionKit
│       ├── MainTabView.swift           # Main TabView navigation
│       ├── DashboardView.swift        # Home dashboard
│       └── HomeDashboardView.swift    # Dashboard extension
│
├── Infrastructure/
│   ├── Matter/
│   │   ├── MatterControllerFactory.swift # Matter controller factory
│   │   ├── MatterKeypair.swift           # MTRKeypair implementation
│   │   ├── MatterStorage.swift           # Persistent storage (UserDefaults)
│   │   ├── CommissioningWorker.swift     # Step‑by‑step commissioning helper
│   │   └── MatterError.swift            # Custom errors
│   │
│   └── Utils/
│       └── (extensions, helpers)
│
├── Resources/
│   ├── Assets.xcassets/
│   ├── Info.plist                       # Permissions (Bluetooth, Bonjour, Background modes)
│   └── ...
│
└── Tests/                               # (Not yet implemented)
    ├── UnitTests/
    └── UITests/
```


### Initial Setup
1. Clone the repository
```bash
git clone https://github.com/your-username/ControlPrototype.git
cd ControlPrototype
```
2. Open the project
The project uses no external dependency managers; Apple's Matter.framework is provided by the SDK. Simply open:

```bash
open ControlPrototype.xcodeproj
```

3. Configure team and bundle identifier

- In Xcode, select your Team under Signing & Capabilities.
- *Adjust the Bundle Identifier if needed (must be unique).*

4. Connect a physical device
- Matter requires Bluetooth and Wi‑Fi capabilities only available on real devices. Connect your iPhone/iPad and select it as the run destination.

5. (Optional) Configure Wi‑Fi credentials
- Currently, the SSID and password are hardcoded in MatterDeviceRepositoryImpl.swift inside the commissionDevice method:

```swift
let worker = CommissioningWorker(
    controller: controller,
    nodeID: nodeID,
    ssid: "miwifiname",      // <-- Change to your network
    pass: "12345678"         // <-- Change to your password
)
```
*Important: Modify these values to match your 2.4 GHz Wi‑Fi network before building.*

6. Run the app
Press Cmd+R and wait for the app to launch on your device.    



### Implemented Features
QR Code Scanning & Commissioning
  - Uses DataScannerViewController (VisionKit) to read Matter QR codes.
  - Commissioning process managed by CommissioningWorker.
  - Automatically sends Wi‑Fi credentials after Bluetooth connection is established. 
  
<img width="631" height="483" alt="Screenshot 2026-02-11 at 10 17 49 AM" src="https://github.com/user-attachments/assets/a6a67c8d-f04e-429f-a934-e22a37e08fbb" />


#### Device List
  - Searchable list with pull‑to‑refresh.
  - Mock data for testing (6 predefined devices).
  - Filtering by name and online/offline status.
    
<img width="676" height="504" alt="Screenshot 2026-02-11 at 10 18 52 AM" src="https://github.com/user-attachments/assets/891ab132-68ea-4a44-914c-52d63d403ece" />

#### Device Detail
  - Displays features according to device type (thermostat, light, fan, sensor).
  - LED On/Off control via Matter OnOff cluster.
  - Temperature reading (Matter Temperature Measurement cluster).
    
<img width="430" height="511" alt="Screenshot 2026-02-11 at 10 26 07 AM" src="https://github.com/user-attachments/assets/b6120445-44c6-4907-9e84-f589c9595c6a" />

#### Dashboard
  - Main view with a simulated thermostat, statistics cards, and quick actions.
  - Fully integrated with MainTabView navigation.

<img width="376" height="680" alt="Screenshot 2026-02-11 at 10 23 47 AM" src="https://github.com/user-attachments/assets/d5f02a94-5fc6-4489-9d67-28419aec7670" />

#### Tab Navigation
  - Home: Dashboard.
  - Devices: Device list.
  - Settings: Basic settings.

<img width="764" height="542" alt="Screenshot 2026-02-11 at 10 21 38 AM" src="https://github.com/user-attachments/assets/16068fef-b13a-44b0-9d43-7616395c1d66" />


### 🔄 Commissioning Flow
Matter commissioning consists of two main phases: PASE (Bluetooth) and CASE (certificate exchange + Wi‑Fi). Our implementation follows these steps:

  1. QR Scan: Obtains an MTRSetupPayload.
  2. Worker creation: CommissioningWorker receives the controller, nodeID, and Wi‑Fi credentials.
  3. Session start: setupCommissioningSession(with:payload, newNodeID:nodeID) – establishes the Bluetooth link.
  4. Delegate commissioningSessionEstablishmentDone: Bluetooth connected → send Wi‑Fi credentials via commissionNode(withID:nodeID, commissioningParams:).
  5. Delegate commissioningComplete: Device successfully commissioned.

#### Why CommissioningWorker?
It acts as a transient actor that stays alive during the whole process and releases memory when finished, avoiding leaks and state‑related bugs.

```Swift
let worker = CommissioningWorker(controller: controller, nodeID: nodeID, ssid: wifi, pass: pwd)
try await worker.start(payload: payload)
```

### Key Components

1. AppContainer
A @MainActor singleton that:

 - Holds the single MTRDeviceController instance.
 - Initialises MatterDeviceRepositoryImpl.
 - Acts as the delegate of the controller to receive commissioning events.
 - Factory for creating ViewModels used in navigation.

#### Why NSObject and @MainActor?
Matter's delegate protocol requires NSObjectProtocol conformance; as a singleton that updates the UI, it is forced to run on the main thread.

2. MatterControllerFactory

Builds the Matter controller with the minimum required parameters:
- MTRStorage: MatterStorage (UserDefaults with "matter." prefix).
- MTRKeypair: MatterKeypair (EC P‑256 key generation).
- IPK: 16‑byte key (fixed development value).
- Fabric ID: 1.
- Vendor ID: 0xFFF1 (test range).
- Handles storage corruption errors and resets UserDefaults when needed.

3. MatterKeypair
Implementation of MTRKeypair using Security.framework (SecKeyCreateRandomKey, SecKeyCreateSignature). Generates ephemeral key pairs (non‑persistent) and signs messages with ECDSA SHA256.

4. CommissioningWorker
A helper NSObject that implements MTRDeviceControllerDelegate and uses a CheckedContinuation to convert the delegate‑based asynchronous process into an async throws function. It retains itself until the work is complete.

5. Repositories & Use Cases

- MatterDeviceRepository: Defines contracts for commissioning, listing, reading attributes, and sending commands.
- MatterDeviceRepositoryImpl: Concrete implementation that uses MTRDevice and its clusters.
- readAttribute: Generic method to read any attribute (temperature, status, etc.).
- toggleLed: Sends on/off commands to the OnOff cluster.
- commissionDevice: Invokes CommissioningWorker.
- Use Cases: Simple wrappers that inject the repository and expose an execute method.

6. ViewModels & SwiftUI Views
 
 - DeviceListViewModel: Manages the device list (mock) and asynchronous loading.
 - DeviceDetailViewModel: Logic for the detail screen; exposes @Published properties for temperature, LED state, etc. Uses the injected use cases.
 - QRScannerViewModel: Controls scanning, prevents multiple simultaneous scans, and calls the commissioning use case.
 - Error handling: All ViewModels publish an optional errorMessage that is displayed in the UI.

<img width="766" height="855" alt="Captura de pantalla 2026-02-11 a la(s) 7 14 55 a  m" src="https://github.com/user-attachments/assets/8f34f44f-41de-40f7-957a-627d2bca3388" />



### MIT License

Copyright (c) 2026 Krasamo 

Andres Trotti

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.



## Build with

_Software that were used_

* [Simplicity Studio 6](https://www.silabs.com/software-and-tools/simplicity-studio) - SiWG917 project base
* [Xcode 16.4](https://developer.apple.com/xcode/) - iOS Development
* [Visual Studio Code](https://code.visualstudio.com/) - [Code editor]


## Autores

**Krasamo** - [https://www.krasamo.com/]
**Andres Trotti** - *Documentación* - [andresTrotti](https://github.com/andresTrotti)




