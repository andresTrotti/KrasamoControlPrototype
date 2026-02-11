# SiLabs, Matter and iOS Integration Demo 

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

Scanning Matter QR codes to start commissioning.

Commissioning Matter devices over Bluetooth (PASE) and injecting Wi‑Fi credentials (CASE).

Displaying a list of commissioned devices (mock data for testing).

Controlling LED state (on/off) and reading temperature from compatible devices.

Exploring a dashboard with home status (temperature, humidity, air quality, etc.).

The app is intended as a starting point for developers who want to integrate Matter into their iOS apps using Apple's native Matter.framework.

Mira **Deployment** para conocer como desplegar el proyecto.


###🛠 Requirements
- Xcode 15.0+ (tested with Xcode 16.4+)
- iOS 15.0+ (Matter requires iOS 15.0 or later)
- Physical device (iPhone/iPad) – Matter does not run on the simulator
- Apple Developer account (to run on device)
- Wi‑Fi network (2.4 GHz recommended for Matter devices)
- Matter‑capable chip (e.g. SiWG917, ESP32‑Matter, etc.)

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
