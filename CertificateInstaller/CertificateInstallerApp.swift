//
//  CertificateInstallerApp.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import SwiftUI

//let ROOT_CERT: String = """
//      -----BEGIN CERTIFICATE-----
//      MIICNDCCAdugAwIBAgIUGfHh8Ac3OM/uJ1kD8W5uXjah1tswCgYIKoZIzj0EAwIw
//      cDELMAkGA1UEBhMCS1IxDjAMBgNVBAgMBVNlb3VsMQ0wCwYDVQQHDARHdXJvMRgw
//      FgYDVQQKDA9NT05JVE9SQVBQIEluYy4xKDAmBgNVBAMMH0FJT05DTE9VRCBDZXJ0
//      aWZpY2F0ZSBBdXRob3JpdHkwHhcNMjMwODI4MDgwOTQwWhcNMzMwODI1MDgwOTQw
//      WjBwMQswCQYDVQQGEwJLUjEOMAwGA1UECAwFU2VvdWwxDTALBgNVBAcMBEd1cm8x
//      GDAWBgNVBAoMD01PTklUT1JBUFAgSW5jLjEoMCYGA1UEAwwfQUlPTkNMT1VEIENl
//      cnRpZmljYXRlIEF1dGhvcml0eTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABPEv
//      PK/C1/l9BHbKoV2pEpQbWMrbSP42NN4/bNuzfwP4clgFAzd52KKNnH1YrOcj9noC
//      TW8DJSwdocqfPrW6plujUzBRMB0GA1UdDgQWBBRmLtDdKN6fsUtf0KG8C54zp9fV
//      uzAfBgNVHSMEGDAWgBRmLtDdKN6fsUtf0KG8C54zp9fVuzAPBgNVHRMBAf8EBTAD
//      AQH/MAoGCCqGSM49BAMCA0cAMEQCIEEgw/VQdNqutg9MqqMJ9/yrhIWZrILWZAKn
//      0/w2thRHAiBDApUX+2RNlJvQkf3Emf2eySLIPW//tWWRGGgHmbDKVg==
//      -----END CERTIFICATE-----
//      """

@main
struct CertificateInstallerApp: App {
  var body: some Scene {
    WindowGroup {
      CertificateInstallView()
        .frame(minWidth: 400, minHeight: 300)
        //.frame(maxWidth: 400, maxHeight: 300)
    }
    .windowStyle(HiddenTitleBarWindowStyle())  // 상단 TitleBar 안나오게 하는 옵션
    .contentSizedWindowResizability()
  }
}

extension Scene {
  func contentSizedWindowResizability() -> some Scene {
    if #available(macOS 13.0, *) {
      return self.windowResizability(.contentSize)
    } else {
      return self
    }
  }
}
