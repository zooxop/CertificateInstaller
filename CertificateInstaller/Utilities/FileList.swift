//
//  FileList.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/5/24.
//

import Foundation

protocol FileListProtocol {
  var targetExtensionList: [String] { get set }
  func getFilesList(inDirectory directoryPath: String) -> [String]
}

final class FileList: FileListProtocol {
  var targetExtensionList: [String]
  
  init(extensionLists: [String] = [".crt", ".cer"]) {
    self.targetExtensionList = extensionLists
  }
  
  /// 전달받은 경로 아래에서 지정된 확장자와 일치하는 파일의 Full Path 리스트를 반환.
  func getFilesList(inDirectory directoryPath: String) -> [String] {
    do {
      // 지정된 디렉토리의 파일 목록을 가져옵니다.
      let fileManager = FileManager.default
      let fileURLs = try fileManager.contentsOfDirectory(atPath: directoryPath)
      
      // 확장자로 필터링
      let filteredFiles = fileURLs.filter { file in
        for certExtension in targetExtensionList {
          if file.hasSuffix(certExtension) {
            return true
          }
        }
        
        return false
      }
      
      // 전체 파일 경로를 만들어 반환합니다.
      let fullPaths = filteredFiles.map { directoryPath + $0 }
      
      return fullPaths
    } catch {
      print("Error reading directory: \(error)")
      return []
    }
  }
}
