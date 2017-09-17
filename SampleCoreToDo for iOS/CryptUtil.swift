//
//  CryptUtil.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/16.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import Foundation
import IDZSwiftCommonCrypto

final public class CryptUtil {
    
    // MARK: - Properties
    
    // none
    
    // MARK: - Constructor
    
    private init() {}
    
    // MARK: - Functions
    
    // 与えられた平文を与えられたキーフレーズでAES256CBCにて暗号化してBASE64形式の文字列で返します。
    static public func encryptAES256CBC(key: String, plainText: String) -> String {
        let keyHexString = utf8ToHexString(value: key)
        let keyHex = arrayFrom(hexString: keyHexString)
        let cryptor = Cryptor(operation: .encrypt, algorithm: .aes, options: .PKCS7Padding, key: keyHex, iv: Array<UInt8>())
        let cipherData = cryptor.update(string: plainText)?.final()
        return dataFrom(byteArray: cipherData!).base64EncodedString()
    }
    
    // 与えられたBASE64形式の文字列を与えられたキーフレーズでAES256CBCにて復号化して平文で返します。
    static public func decryptAES256CBC(key: String, cipherText: String) -> String {
        let keyHexString = utf8ToHexString(value: key)
        let keyHex = arrayFrom(hexString: keyHexString)
        let cryptor = Cryptor(operation: .decrypt, algorithm: .aes, options: .PKCS7Padding, key: keyHex, iv: Array<UInt8>())
        let cipherData = Data(base64Encoded: cipherText)
        let decryptedText = cryptor.update(data: cipherData!)?.final()
        return decryptedText!.reduce("") { $0 + String(UnicodeScalar($1)) }
    }
    
    // 与えられた平文とソルトから指定された回数だけストレッチングした SHA256 ハッシュ値を返します。
    // ストレッチング回数に 0 以下の値が指定された場合においても最低 1 回はハッシュ関数を適用します。
    static public func hashSHA256(value: String, salt: String, stretching: Int) -> String {
        let sha256 = Digest(algorithm: Digest.Algorithm.sha256)
        var hashedValue = hexString(fromArray: (sha256.update(string: value + salt)?.final())!)
        Array(0..<stretching-1).forEach {_ in
            hashedValue = hexString(fromArray: (sha256.update(string: hashedValue + salt)?.final())!)
        }
        return hashedValue
    }
    
    // 与えられたUTF-8文字列を16進形式の文字列に変換して返します。
    static private func utf8ToHexString(value: String) -> String {
        return value.utf8.map { NSString(format: "%2X", $0) as String}.reduce("", {$0 + $1})
    }
    
}
