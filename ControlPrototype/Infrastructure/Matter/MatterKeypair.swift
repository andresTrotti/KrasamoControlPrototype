//
//  MatterKeypair.swift
//  ControlPrototype
//
//  Created by Andres Trotti on 1/23/26.
//


import Matter
import Security

class MatterKeypair: NSObject, MTRKeypair {
    private var publicKey: SecKey
    private var privateKey: SecKey

    override init() {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        var error: Unmanaged<CFError>?
        privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error)!
        publicKey = SecKeyCopyPublicKey(privateKey)!
        super.init()
    }

    func publicKey() -> Data {
        var error: Unmanaged<CFError>?
        return SecKeyCopyExternalRepresentation(publicKey, &error)! as Data
    }

    func signMessage(_ message: Data) throws -> Data {
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, .ecdsaSignatureMessageX962SHA256, message as CFData, &error) else {
            throw error!.takeRetainedValue()
        }
        return signature as Data
    }
}