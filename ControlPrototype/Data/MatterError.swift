import Foundation

enum MatterError: Error, LocalizedError {
    case invalidDeviceID
    case attributeNotFound
    case connectionFailed
    case commandFailed
    
    var errorDescription: String? {
        switch self {
        case .invalidDeviceID:
            return "El ID del dispositivo no es un formato de NodeID válido."
        case .attributeNotFound:
            return "No se pudo encontrar el atributo solicitado en el dispositivo."
        case .connectionFailed:
            return "No se pudo establecer comunicación con el chip SiLabs."
        case .commandFailed:
            return "El dispositivo recibió el comando pero no pudo ejecutarlo."
        }
    }
}