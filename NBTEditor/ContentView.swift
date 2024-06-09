//
//  ContentView.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import UniformTypeIdentifiers
import MinecraftNBT


struct ContentView: View {
    @State private var data : NBTStructure? = nil
    
    var body: some View {
        if data == nil {
            FileSelectView(data: $data)
        }else{
            NBTView(data: $data)
        }
    }
    
}

#Preview {
    ContentView()
}
