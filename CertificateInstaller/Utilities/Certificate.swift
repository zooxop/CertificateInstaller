//
//  Certificate.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import Foundation

protocol CertificateProtocol {
  var secCertificate: SecCertificate? { get }
  func getCName() -> String?
}

final public class Certificate: CertificateProtocol, Identifiable {
  
  private(set) var secCertificate: SecCertificate?
  
  init(path filePath: String) {
    self.convertCERtoPEM(cerFilePath: filePath)
    
    // ROOT_CERT를 SecCertificate 객체로 변환
    //self.secCertificate = self.createCertFromPemStr(certStr: pemString)
    
    if self.secCertificate == nil {
      NSLog("⚠️ 인증서 파일 변환 실패")
    }
  }

  /// 인증서 CName 가져오기
  public func getCName() -> String? {
    guard let cert = self.secCertificate else {
      print("secCertificate is nil")
      return nil
    }
    
    var cfName: CFString? = nil
    let osStatus = SecCertificateCopyCommonName(cert, &cfName)
    if osStatus != errSecSuccess {
      print("SecCertificateCopyCommonName is failed.")
      return nil
    }
    
    return cfName as String?
  }
}

// MARK: - 인증서 파일을 핸들링 가능한 상태로 변환하는 함수들.
// (cer, crt -> pem), (pem -> String)
extension Certificate {
  /// (1) .cer (또는 .crt) 파일을 PEM String으로 변환.
  func convertCERtoPEM(cerFilePath: String) { // -> String? {
    // Read the certificate data
    do {
      guard let certificateData = try? Data(contentsOf: URL(fileURLWithPath: cerFilePath)) else {
        throw NSError(domain: "CertificateConversionError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read certificate data."])
      }
      
      // Convert certificate data to a SecCertificate
      // MARK: 만약 여기서 nil이 리턴된다면, Data를 불러온 시점부터 이미 PEM String으로 변환되어서 불러와진것임. 따라서, 그대로 return.
      // MARK:
      guard let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
        self.secCertificate = createCertFromPemStr(certStr: String(data: certificateData, encoding: .utf8)!)
        return
      }
      
      self.secCertificate = certificate
      
    } catch {
      print(error)
    }
    
    //return nil
  }
  
  /// (2) PEM String을 SecCertificate 객체로 변환하여 리턴
  private func createCertFromPemStr(certStr: String) -> SecCertificate? {
    var tempStr = certStr
    
    // remove the header string
    let head = "-----BEGIN CERTIFICATE-----"
    let tail = "-----END CERTIFICATE-----"
    tempStr = tempStr.replacingOccurrences(of: head, with: "")
    tempStr = tempStr.replacingOccurrences(of: tail, with: "")
    
    let derData = Data(base64Encoded: tempStr, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters)!
    
    return SecCertificateCreateWithData(nil, derData as CFData)
  }
}
