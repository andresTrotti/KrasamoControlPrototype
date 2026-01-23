//
//  MatterKeypair 2.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation
import Matter

final class MatterKeypair: NSObject, MTRKeypair {

    private let privateKey: SecKey
    private let publicKeyRef: SecKey

    override init() {
        // Generar clave EC P-256
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            fatalError("No se pudo generar la clave privada: \(error!.takeRetainedValue())")
        }

        self.privateKey = privateKey
        self.publicKeyRef = SecKeyCopyPublicKey(privateKey)!
    }

    func publicKey() -> Data {
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(publicKeyRef, &error) else {
            fatalError("No se pudo obtener la clave pública: \(error!.takeRetainedValue())")
        }
        return data as Data
    }

    func signMessage(_ message: Data) -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,
            message as CFData,
            &error
        ) else {
            fatalError("Error firmando mensaje: \(error!.takeRetainedValue())")
        }
        return signature as Data
    }
}
