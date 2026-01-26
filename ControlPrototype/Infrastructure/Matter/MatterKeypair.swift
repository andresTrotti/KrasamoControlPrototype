//
//  MatterKeypair 2.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Foundation
import Matter


@objcMembers
final class MatterKeypair: NSObject, MTRKeypair {

    private let privateKey: SecKey
    private let publicKeyRef: SecKey

    override init() {
        // Clave EC P-256
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

    // DEPRECATED en el header, pero perfectamente válido para tu SDK actual.
    // El protocolo dice: optional func publicKey() -> Unmanaged<SecKey>
    func publicKey() -> Unmanaged<SecKey> {
        return Unmanaged.passRetained(publicKeyRef)
    }

    // Usamos la variante DER, que el bridge sabe interpretar.
    // optional func signMessageECDSA_DER(_ message: Data) -> Data
    func signMessageECDSA_DER(_ message: Data) -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(
            privateKey,
            .ecdsaSignatureMessageX962SHA256,   // firma DER sobre el mensaje
            message as CFData,
            &error
        ) else {
            fatalError("Error firmando mensaje: \(error!.takeRetainedValue())")
        }
        return signature as Data
    }
}
