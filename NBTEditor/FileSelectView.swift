//
//  FileSelectView.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import MinecraftNBT

func isDataGzip(data : Data) -> Bool{
    guard data.count >= 2 else {
        return false;
    }
    
    return data[0] == 0x1F && data[1] == 0x8B;
}

func showUnsppourtedFileAlert(){
    let alert = NSAlert()
    alert.messageText = "Failed to open file"
    alert.informativeText = "Please make sure it's a valid NBT format file."
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    
    alert.runModal();
}

struct FileSelectView : View{
    
    @Binding var data: NBTStructure?
    
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
                let binaryData = try Data(contentsOf: url)
                let structure: NBTStructure?

                if isDataGzip(data: binaryData) {
                    structure = NBTStructure(compressed: binaryData)
                } else {
                    structure = NBTStructure(decompressed: binaryData)
                }

                guard structure != nil else {
                    showUnsppourtedFileAlert()
                    return
                }
                
                self.data = structure
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
