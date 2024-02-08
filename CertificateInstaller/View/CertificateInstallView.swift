//
//  CertificateInstallView.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import SwiftUI

// MARK: View
struct CertificateInstallView: View {
  @ObservedObject var viewModel: ViewModel
  
  init(viewModel: ViewModel = .init()) {
    self._viewModel = ObservedObject(wrappedValue: viewModel)
  }
    
  var body: some View {
    HStack {
      DragAndDropView(fileList: $viewModel.certFilesList)
        .frame(width: 320, height: 320)
    }
    .onChange(of: viewModel.certFilesList) { list in
      Task {
        try await viewModel.updateCertificateList()
        try await viewModel.installCert(index: 0)
        try await viewModel.tryValidateCert(index: 0)
      }
    }
    .padding()
  }
}

// MARK: - ViewModel
extension CertificateInstallView {
  class ViewModel: ObservableObject {
    @Published var certFilesList: [String]

    let certManager: CertManager
    let fileList: FileListProtocol
    
    init(
      certManager: CertManager = .init(),
      fileList: FileListProtocol = FileList()
    ) {
      self.certFilesList = []
      self.certManager = certManager
      self.fileList = FileList(extensionLists: [".crt", ".cer"])
    }
    
    /// 인증서 매니저의 리스트에 인증서들을 등록(갱신).
    func updateCertificateList() async throws {
      var result = true
      
      certManager.certificates.removeAll()
      
      for filePath in certFilesList {
        result = certManager.addCertificate(path: filePath)
      }
      
      if !result {
        throw CertError.addCertificate
      }
      
      DispatchQueue.main.async {
        _ = self.certManager.certificates.map {  certificate in
          print(certificate.getCName() ?? "NiL")
        }
      }
    }
    
    /// 인증서 설치
    func installCert(index: Int) async throws {
      do {
        try certManager.installCertificate(index: index)
        
      } catch {
        print(#function, "Error : \(error)")
        
        throw CertError.installCert
      }
    }
    
    /// 인증서 신뢰 활성화
    func tryValidateCert(index: Int) async throws {
      do {
        try certManager.tryValidateCert(index: index)
        
      } catch {
        print(#function, "Error : \(error)")
        
        throw CertError.tryValidateCert
      }
    }
  }
}

#if DEBUG
#Preview {
  CertificateInstallView()
}
#endif
