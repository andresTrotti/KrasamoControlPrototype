# SiLabs, Matter and iOS Integration Demo 
<img width="2560" height="1325" alt="Screenshot 2026-02-11 at 9 23 48 AM" src="https://github.com/user-attachments/assets/be2f79b1-0ed4-4f4c-a198-081a815afb7f" />

_This demo is an iOS application that integrates Apple's Matter.framework to commission, control, and monitor Matter‑certified devices. It is specifically designed to work with the Silicon Labs SiWG917 development kit. The project follows a clean MVVM architecture with dependency injection, use cases, and repositories, all built with SwiftUI._

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
- Exploring a dashboard with home status (temperature, humidity, air quality, etc.).

The app is intended as a starting point for developers who want to integrate Matter into their iOS apps using Apple's native Matter.framework.

Mira **Deployment** para conocer como desplegar el proyecto.


###🛠 Requirements

- Xcode 15.0+ (tested with Xcode 16.4+)
- iOS 15.0+ (Matter requires iOS 15.0 or later)
- Physical device (iPhone/iPad) – Matter does not run on the simulator
- Apple Developer account (to run on device)
- Wi‑Fi network (2.4 GHz recommended for Matter devices)
- Matter‑capable chip (e.g. SiWG917, ESP32‑Matter, etc.)


### 🏗 Architecture
The project follows MVVM (Model‑View‑ViewModel) with additional layers:

text
UI (SwiftUI) → ViewModels (ObservableObject) → UseCases → Repository → Matter SDK
SwiftUI Views: DeviceListView, DeviceDetailView, QRScannerView, DashboardView.

ViewModels: Manage state and presentation logic (DeviceListViewModel, DeviceDetailViewModel, QRScannerViewModel).

Use Cases: Encapsulate business logic (CommissionDeviceUseCase, ToggleLedUseCase, ReadTemperatureUseCase).

Repositories: Abstract the Matter SDK (MatterDeviceRepository, MatterDeviceRepositoryImpl).

Dependency Injection: AppContainer acts as the main assembler and lifecycle manager for the MTRDeviceController.

All Matter interactions are performed asynchronously using async/await and CheckedContinuation to wrap delegate‑based APIs.


graph TD
    subgraph "Presentation (UI)"
    V[Views] --> VM[ViewModels]
    end

    subgraph "Domain (Business)"
    VM --> UC[Use Cases]
    UC --> E[Entities]
    end

    subgraph "Data & Infra"
    UC --> R[Repositories]
    R --> SDK[Matter SDK / SiLabs]
    end

    style E fill:#f9f,stroke:#333,stroke-width:2px
    style UC fill:#bbf,stroke:#333,stroke-width:2px


### ⚙️ Initial Setup
1. Clone the repository
bash
git clone https://github.com/your-username/ControlPrototype.git
cd ControlPrototype
2. Open the project
The project uses no external dependency managers; Apple's Matter.framework is provided by the SDK. Simply open:

bash
open ControlPrototype.xcodeproj
3. Configure team and bundle identifier
In Xcode, select your Team under Signing & Capabilities.

Adjust the Bundle Identifier if needed (must be unique).

4. Connect a physical device
Matter requires Bluetooth and Wi‑Fi capabilities only available on real devices. Connect your iPhone/iPad and select it as the run destination.

5. (Optional) Configure Wi‑Fi credentials
Currently, the SSID and password are hardcoded in MatterDeviceRepositoryImpl.swift inside the commissionDevice method:

swift
let worker = CommissioningWorker(
    controller: controller,
    nodeID: nodeID,
    ssid: "miwifiname",      // <-- Change to your network
    pass: "12345678"         // <-- Change to your password
)
Important: Modify these values to match your 2.4 GHz Wi‑Fi network before building.

6. Run the app
Press Cmd+R and wait for the app to launch on your device.    



### 🚀 Implemented Features
✅ QR Code Scanning & Commissioning
Uses DataScannerViewController (VisionKit) to read Matter QR codes.

Commissioning process managed by CommissioningWorker.

Automatically sends Wi‑Fi credentials after Bluetooth connection is established.

✅ Device List
Searchable list with pull‑to‑refresh.

Mock data for testing (6 predefined devices).

Filtering by name and online/offline status.

✅ Device Detail
Displays features according to device type (thermostat, light, fan, sensor).

LED On/Off control via Matter OnOff cluster.

Temperature reading (Matter Temperature Measurement cluster).

Mock indicators for connectivity, battery, power consumption, etc.

✅ Dashboard
Main view with a simulated thermostat, statistics cards, and quick actions.

Fully integrated with MainTabView navigation.

✅ Tab Navigation
Home: Dashboard.

Devices: Device list.

Settings: Basic settings.



### 🔄 Commissioning Flow
Matter commissioning consists of two main phases: PASE (Bluetooth) and CASE (certificate exchange + Wi‑Fi). Our implementation follows these steps:

QR Scan: Obtains an MTRSetupPayload.

Worker creation: CommissioningWorker receives the controller, nodeID, and Wi‑Fi credentials.

Session start: setupCommissioningSession(with:payload, newNodeID:nodeID) – establishes the Bluetooth link.

Delegate commissioningSessionEstablishmentDone: Bluetooth connected → send Wi‑Fi credentials via commissionNode(withID:nodeID, commissioningParams:).

Delegate commissioningComplete: Device successfully commissioned.

Why CommissioningWorker?
It acts as a transient actor that stays alive during the whole process and releases memory when finished, avoiding leaks and state‑related bugs.

let worker = CommissioningWorker(controller: controller, nodeID: nodeID, ssid: wifi, pass: pwd)
try await worker.start(payload: payload)



### 🔧 Key Components
1. AppContainer
A @MainActor singleton that:

Holds the single MTRDeviceController instance.

Initialises MatterDeviceRepositoryImpl.

Acts as the delegate of the controller to receive commissioning events.

Factory for creating ViewModels used in navigation.

Why NSObject and @MainActor?
Matter's delegate protocol requires NSObjectProtocol conformance; as a singleton that updates the UI, it is forced to run on the main thread.

2. MatterControllerFactory
Builds the Matter controller with the minimum required parameters:

MTRStorage: MatterStorage (UserDefaults with "matter." prefix).

MTRKeypair: MatterKeypair (EC P‑256 key generation).

IPK: 16‑byte key (fixed development value).

Fabric ID: 1.

Vendor ID: 0xFFF1 (test range).

Handles storage corruption errors and resets UserDefaults when needed.

3. MatterKeypair
Implementation of MTRKeypair using Security.framework (SecKeyCreateRandomKey, SecKeyCreateSignature). Generates ephemeral key pairs (non‑persistent) and signs messages with ECDSA SHA256.

4. CommissioningWorker
A helper NSObject that implements MTRDeviceControllerDelegate and uses a CheckedContinuation to convert the delegate‑based asynchronous process into an async throws function. It retains itself until the work is complete.

5. Repositories & Use Cases
MatterDeviceRepository: Defines contracts for commissioning, listing, reading attributes, and sending commands.

MatterDeviceRepositoryImpl: Concrete implementation that uses MTRDevice and its clusters.

readAttribute: Generic method to read any attribute (temperature, status, etc.).

toggleLed: Sends on/off commands to the OnOff cluster.

commissionDevice: Invokes CommissioningWorker.

Use Cases: Simple wrappers that inject the repository and expose an execute method.

6. ViewModels & SwiftUI Views
DeviceListViewModel: Manages the device list (mock) and asynchronous loading.

DeviceDetailViewModel: Logic for the detail screen; exposes @Published properties for temperature, LED state, etc. Uses the injected use cases.

QRScannerViewModel: Controls scanning, prevents multiple simultaneous scans, and calls the commissioning use case.

Error handling: All ViewModels publish an optional errorMessage that is displayed in the UI.




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


### 🙏 Acknowledgements
Apple for the Matter framework.

Silicon Labs for the SiWG917 hardware.

The Matter developer community for invaluable examples and insights.

```
Da un ejemplo
```

### Instalación 🔧

_Una serie de ejemplos paso a paso que te dice lo que debes ejecutar para tener un entorno de desarrollo ejecutandose_

_Dí cómo será ese paso_

```
Da un ejemplo
```

_Y repite_

```
hasta finalizar
```

_Finaliza con un ejemplo de cómo obtener datos del sistema o como usarlos para una pequeña demo_

## Ejecutando las pruebas ⚙️

_Explica como ejecutar las pruebas automatizadas para este sistema_

### Analice las pruebas end-to-end 🔩

_Explica que verifican estas pruebas y por qué_

```
Da un ejemplo
```

### Y las pruebas de estilo de codificación ⌨️

_Explica que verifican estas pruebas y por qué_

```
Da un ejemplo
```

## Despliegue 📦

_Agrega notas adicionales sobre como hacer deploy_

## Construido con 🛠️

_Menciona las herramientas que utilizaste para crear tu proyecto_

* [Dropwizard](http://www.dropwizard.io/1.0.2/docs/) - El framework web usado
* [Maven](https://maven.apache.org/) - Manejador de dependencias
* [ROME](https://rometools.github.io/rome/) - Usado para generar RSS

## Contribuyendo 🖇️

Por favor lee el [CONTRIBUTING.md](https://gist.github.com/villanuevand/xxxxxx) para detalles de nuestro código de conducta, y el proceso para enviarnos pull requests.

## Wiki 📖

Puedes encontrar mucho más de cómo utilizar este proyecto en nuestra [Wiki](https://github.com/tu/proyecto/wiki)

## Versionado 📌

Usamos [SemVer](http://semver.org/) para el versionado. Para todas las versiones disponibles, mira los [tags en este repositorio](https://github.com/tu/proyecto/tags).

## Autores ✒️

_Menciona a todos aquellos que ayudaron a levantar el proyecto desde sus inicios_

* **Andrés Villanueva** - *Trabajo Inicial* - [villanuevand](https://github.com/villanuevand)
* **Fulanito Detal** - *Documentación* - [fulanitodetal](#fulanito-de-tal)

También puedes mirar la lista de todos los [contribuyentes](https://github.com/your/project/contributors) quíenes han participado en este proyecto. 

## Licencia 📄

Este proyecto está bajo la Licencia (Tu Licencia) - mira el archivo [LICENSE.md](LICENSE.md) para detalles

## Expresiones de Gratitud 🎁

* Comenta a otros sobre este proyecto 📢
* Invita una cerveza 🍺 o un café ☕ a alguien del equipo. 
* Da las gracias públicamente 🤓.
* Dona con cripto a esta dirección: `0xf253fc233333078436d111175e5a76a649890000`
* etc.



---
⌨️ con ❤️ por [Villanuevand](https://github.com/Villanuevand) 😊
