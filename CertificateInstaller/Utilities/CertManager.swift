//
//  CertManager.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import Foundation
import Security

// MARK: - manager
public class CertManager {
  @Published public var certificates: [Certificate]
  
  public init() {
    self.certificates = []
  }
  
  /// 인증서 설치 가능 여부 확인 & 리스트
  public func addCertificate(path certPath: String) -> Bool {
    // PEM을 String으로 입력받아서, Certificate 클래스로 생성
    let certificate = Certificate(path: certPath)

    guard certificate.secCertificate != nil else {
      print("Failed to read certificate file.")
      return false
    }
    
    self.certificates.append(certificate)
    
    return true
  }
  
  /// 인증서 설치 여부 검사
  public func isCertInstalled(index: Int) async -> Bool? {
    // PEM을 String으로 입력받아서, Certificate 클래스로 생성
    let certificate = self.certificates[index]

    guard let cert = certificate.secCertificate else {
      let msg = "Failed to read certificate file."
      print(msg)
      return nil
    }
    
    // 가져온 인증서의 Cname 받아오기
    let commonName = certificate.getCName() ?? ""
    
    // 인증서 설치 확인에 필요한 변수들. Apple 공식 사이트에서 찾아옴.
    let certArray: [SecCertificate] = [cert]
    let policy = SecPolicyCreateBasicX509()
    var optionalTrust: SecTrust?
    let status = SecTrustCreateWithCertificates(certArray as AnyObject, policy, &optionalTrust)
    
    guard status == errSecSuccess else {
      print("get Status is failed.")
      return nil
    }
    guard let trust = optionalTrust else {
      print("unwrap OptionalTrust is failed.")
      return nil
    }
    
    if status == errSecSuccess {
      let copyProperties = SecTrustEvaluateWithError(trust, nil)
      
      // 인증서가 설치되어 있으면 copyProperties 의 return이 true임.
      if copyProperties == true {
        print("Root certificates is installed. \(commonName)")
        return true
      } else {
        // 인증서 설치 화면으로 넘기도록.
        print("No root certificates found.")
        return false
      }
    }
    
    return nil
  }
}

// MARK: - Install Certificate
extension CertManager {
  /// 인증서 설치하기
  public func installCertificate(index: Int) throws {
    // 1. 설치할 인증서 불러오기
    guard let cert = self.certificates[index].secCertificate else {
      throw InstallCertError.readCertFileFailed
    }
    
    var err: Error?
    
    // 2. 인증서 설치
    err = addCert(cert: cert)
    if let error = err {
      print("Failed to install certificate. : \(error)")
      throw InstallCertError.installCertFailed  // "Failed to install certificate."
    }
  }
  
  /// 인증서 신뢰 활성화 하기 (Helper 아니고 App에서 실행하는 함수임)
  public func tryValidateCert(index: Int) throws {
    guard let cert = self.certificates[index].secCertificate else {
      throw InstallCertError.readCertFileFailed
    }
    
    var err: Error?
    
    // 3. 인증서 신뢰 활성화
    err = setTrustSetting(cert: cert)
    if let error = err {
      print("Failed to establish certificate trust. : \(error)")
      throw InstallCertError.establishCertTrustFailed  // "Failed to establish certificate trust."
    } else {
      print("Certificate trust establishment succeeded.")
    }
  }
}

// MARK: - Private methods
extension CertManager {
  /// 인증서 설치
  private func addCert(cert: SecCertificate) -> Error? {
    let keychain: SecKeychain? = nil
    let status = SecCertificateAddToKeychain(cert, keychain)
    if status != errSecSuccess {
      print("error \(status) : " + (SecCopyErrorMessageString(status, nil)! as String))
      
      // 예외처리: 키체인에 인증서가 이미 설치되어 있는데, 신뢰 활성화만 안되어 있는 경우.
      // (-25299 : 지정된 항목이 키체인에 이미 존재합니다.)
      if status == -25299 { return nil }
      
      return NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: ["msg": "SecCertificateAddToKeychain"])
    }
    
    return nil
  }
  
  /// 인증서 신뢰 활성화
  private func setTrustSetting(cert: SecCertificate) -> Error? {
    let trustSettings = [kSecTrustSettingsResult: NSNumber(value: SecTrustSettingsResult.trustRoot.rawValue)] as CFTypeRef
    let status = SecTrustSettingsSetTrustSettings(cert, .user, trustSettings)
    if status != errSecSuccess {
      let message = "error \(status) : " + (SecCopyErrorMessageString(status, nil)! as String)
      print(message)
      return NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: ["msg": message])
    }
    
    return nil
  }
}
