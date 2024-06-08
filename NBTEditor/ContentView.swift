//
//  ContentView.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import UniformTypeIdentifiers


struct ContentView: View {
    @State private var data : Data? = nil
    
    var body: some View {
        if data == nil {
            FileSelectView(data: $data)
        }else{
            NBTView(data: $data)
        }
    }
    
}


struct Sidebar: View {
    var body: some View {
        ZStack {
            VisualEffectView()
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Text("Item 1")
                Text("Item 2")
                Text("Item 3")
                Spacer()
            }
            .padding()
        }
        .frame(minWidth: 200)
    }
}

struct VisualEffectView: View {
    var body: some View {
        VStack {
            Spacer()
        }
        .background(.regularMaterial)
        .cornerRadius(10)
    }
}

//struct VisualEffectView: NSViewRepresentable {
//    var material: NSVisualEffectView.Material
//    var blendingMode: NSVisualEffectView.BlendingMode
//
//    func makeNSView(context: Context) -> NSVisualEffectView {
//        let view = NSVisualEffectView()
//        view.material = material
//        view.blendingMode = blendingMode
//        view.state = .active
//        return view
//    }
//
//    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
//        nsView.material = material
//        nsView.blendingMode = blendingMode
//    }
//}
#Preview {
    ContentView()
}
