//
//  NBTEditorApp.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import MinecraftNBT

class AppDelegate : NSObject, NSApplicationDelegate {
    
//    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
//        return true;
//    }
    
}

@main
struct NBTEditorApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate;
    
    
    var body: some Scene {
        DocumentGroup(newDocument: NBTDocument()) {configuration in
            ContentView(document: configuration.$document)
        }
    }
}
