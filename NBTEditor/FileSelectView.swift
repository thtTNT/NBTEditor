//
//  FileSelectView.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileSelectView : View{
    
    @Binding var data: Data?
    
    var body: some View {
        VStack{
            Text("NBTEditor")
                .font(.largeTitle)
            Button(action: openFile){
                Text("Select File...")
            }
        }.padding()
    }
    
    private func openFile() {
        let dialog = NSOpenPanel()
        
        dialog.title = "Choose a file"
        dialog.allowedContentTypes = [UTType.data]
        dialog.canChooseDirectories = false
        dialog.canCreateDirectories = false
        dialog.allowsMultipleSelection = false
        
        if dialog.runModal() == .OK, let url = dialog.url {
            do {
                data = try Data(contentsOf: url)
            } catch {
                let alert = NSAlert()
                alert.messageText = "Failed to open file"
                alert.informativeText = "Please check the permission to make sure the file can be accessed."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "OK")
                
                alert.runModal();
            }
        }
        
    }
}
