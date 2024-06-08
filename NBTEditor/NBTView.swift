//
//  NBTView.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import MinecraftNBT

struct NBTView : View {
    
    @Binding var data: Data?
    @State var nbtStructure : NBTStructure = NBTStructure()
    
    var body: some View {
        List {
            generateTree(name: "Root", tag: NBTStructure(compressed: data!)!.tag)
        }
    }
    
    func updateNBTStructure(){
        if data == nil {
            return
        }
        self.nbtStructure = NBTStructure(compressed: data!)!
    }
    
    func generateTree(name: String, tag: any NBTTag) -> AnyView{
        
        switch tag{
        case is NBTByte:
            return AnyView(
                HStack {
                    LetterView(letter: "B", color: Color(red: 158 / 255, green: 39 / 255, blue: 50 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTShort:
            return AnyView(
                HStack {
                    LetterView(letter: "S", color: Color(red: 156 / 255,green: 31 / 255, blue: 179 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTInt:
            return AnyView(
                HStack {
                    LetterView(letter: "I", color: Color(red: 50 / 255, green : 42 / 255, blue: 173 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTLong:
            return AnyView(
                HStack {
                    LetterView(letter: "L", color: Color(red: 54 / 255, green: 123 / 255, blue: 138 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTFloat:
            return AnyView(
                HStack {
                    LetterView(letter: "F", color: Color(red: 231 / 255, green: 224 / 255, blue: 85 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTDouble:
            return AnyView(
                HStack {
                    LetterView(letter: "D", color: Color(red: 87 / 255, green: 175 / 255, blue: 83 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTString:
            return AnyView(
                HStack {
                    LetterView(letter: "S", color: Color(red: 62 / 255, green: 62 / 255, blue: 62 / 255))
                    Text(name + ":").bold()
                    Text(tag.description)
                }
            )
        case is NBTList:
            let list = tag as! NBTList
            return AnyView(DisclosureGroup(
                content: {
                    ForEach(0..<list.elements.count,id: \.self){ index in
                        generateTree(name: String(index), tag: list.elements[index])
                    }
                },
                label: {
                    HStack {
                        LetterView(letter: "A", color: Color(red: 228 / 255, green: 139 / 255, blue: 51 / 255))
                        Text(name).bold()
                    }
                }
            )
            )
        case is NBTCompound:
            let compound = tag as! NBTCompound
            return AnyView(DisclosureGroup(
                content: {
                    ForEach(compound.contents.keys.elements, id: \.self){ key in
                        generateTree(name: key, tag: compound[key]!)
                    }
                },
                label: {
                    HStack {
                        LetterView(letter: "C", color: Color(red: 242 / 255, green: 194 / 255, blue: 79 / 255))
                        Text(name).bold()
                    }
                }
            )
            )
        default:
            return AnyView(
                HStack {
                    LetterView(letter: "U", color: Color.pink)
                    Text(name + ": ").bold()
                    Text(tag.description)
                }
            )
        }
    }
    
}

struct LetterView: View {
    var letter: String
    var color: Color
    
    var body: some View {
        Text(letter)
            .font(.footnote)
            .foregroundColor(.white)
            .padding(2)
            .frame(minWidth: 14)
            .background(color)
            .cornerRadius(2)
    }
}
