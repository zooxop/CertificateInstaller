//
//  DragAndDropView.swift
//  CertificateInstaller
//
//  Created by 문철현 on 2/7/24.
//

import SwiftUI

struct DragAndDropView: View {
  @Binding var fileList: [String]
  
  var body: some View {
    Rectangle()
      .overlay {
        Text("Drop Ceritificate file here")
          .font(.title)
      }
      .foregroundStyle(Color.black.opacity(0.5))
      .cornerRadius(8)
      .onDrop(of: ["public.url","public.file-url"], isTargeted: nil) { (items) -> Bool in
        guard let item = items.first else { return false }
        guard let identifier = item.registeredTypeIdentifiers.first else { return false }
        
        if identifier != "public.url" && identifier != "public.file-url" { return false }
        
        item.loadItem(forTypeIdentifier: identifier, options: nil) { (urlData, error) in
          DispatchQueue.main.async {
            guard let urlData = urlData as? Data else { return }
            guard let urlString = String(data: urlData, encoding: .utf8) else { return }
            guard let fileURL = URL(string: urlString) else { return }
            
            let filePath = fileURL.path
            print("filePath : \(filePath)")
            fileList.removeAll()
            
            fileList.append(filePath)
          }
        }
        return true
      }
  }
}
