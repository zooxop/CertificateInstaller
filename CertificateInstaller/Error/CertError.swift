//
//  CertError.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import Foundation

enum CertError: String, Error {
  case addCertificate
  case installCert
  case tryValidateCert
}
