//
//  InstallCertError.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import Foundation

enum InstallCertError: String, Error {
  case success
  case strToDataFailed
  case readCertFileFailed
  case installCertFailed
  case establishCertTrustFailed
}
