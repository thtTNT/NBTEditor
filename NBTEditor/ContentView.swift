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
    
    @Binding var document : NBTDocument
    
    var body: some View {
        NBTView(data: $document.nbt)
    }
    
    
}
