//
//  NBTDocument.swift
//  NBTEditor
//
//  Created by 屠昊天 on 17/6/2024.
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

struct NBTDocument : FileDocument {
    static var readableContentTypes: [UTType] = [UTType.data]
    var nbt : NBTStructure
    
    init(){
        self.nbt = NBTStructure()
    }

    init(configuration: ReadConfiguration) throws {
        guard let binaryData = configuration.file.regularFileContents else {
            throw NSError()
        }
        
        let structure: NBTStructure?

        if isDataGzip(data: binaryData) {
            structure = NBTStructure(compressed: binaryData)
        } else {
            structure = NBTStructure(decompressed: binaryData)
        }

        guard structure != nil else {
            throw NSError()
        }
        
        self.nbt = structure!
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: self.nbt.data)
    }
    
    
}
