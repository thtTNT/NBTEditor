//
//  NBTView.swift
//  NBTEditor
//
//  Created by 屠昊天 on 8/6/2024.
//

import SwiftUI
import MinecraftNBT

struct NBTView : View {
    
    @Binding var data: NBTStructure
    
    @State var SelectedKey : [String] = []
    
    @State var editSheetVisible = false
    
    var body: some View {
        let tag = data.tag
        List {
            ForEach(tag.contents.keys, id: \.self){ name in
                generateTree(key: [name], tag: tag[name]!)
            }
        }.sheet(isPresented: $editSheetVisible){
            EditValueSheetView(
                nbt: $data,
                key: $SelectedKey,
                visiable: $editSheetVisible
            )
        }
    }
    
    func generatePrimitiveElementLine(key: [String], tag : any NBTTag) -> AnyView{
        let name = key.last!
        var letterView : LetterView
        switch tag {
        case is NBTByte:
            letterView = LetterView(letter: "B", color: Color(red: 158 / 255, green: 39 / 255, blue: 50 / 255))
        case is NBTShort:
            letterView = LetterView(letter: "S", color: Color(red: 156 / 255,green: 31 / 255, blue: 179 / 255))
        case is NBTInt:
            letterView = LetterView(letter: "I", color: Color(red: 50 / 255, green : 42 / 255, blue: 173 / 255))
        case is NBTLong:
            letterView = LetterView(letter: "L", color: Color(red: 54 / 255, green: 123 / 255, blue: 138 / 255))
        case is NBTDouble:
            letterView = LetterView(letter: "D", color: Color(red: 87 / 255, green: 175 / 255, blue: 83 / 255))
        case is NBTString:
            letterView = LetterView(letter: "S", color: Color(red: 62 / 255, green: 62 / 255, blue: 62 / 255))
        default:
            letterView = LetterView(letter: "U", color: Color.pink)
        }
        return AnyView(
            HStack {
                letterView
                Text(name + ":").bold()
                Text(tag.description)
            }.contextMenu(menuItems: {
                Button("Rename"){}.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                Button("Edit Value"){
                    self.SelectedKey = key
                    self.editSheetVisible.toggle()
                }
                Button("Delete Value"){}.disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            })
            
        )
    }
    
    func generateTree(key: [String], tag: any NBTTag) -> AnyView{
        let name = key.last!
        switch tag{
        case is NBTByte:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTShort:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTInt:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTLong:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTFloat:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTDouble:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTString:
            return generatePrimitiveElementLine(key: key, tag: tag)
        case is NBTList:
            let list = tag as! NBTList
            return AnyView(DisclosureGroup(
                content: {
                    if list.elements.count != 0 {
                        ForEach(0..<list.elements.count,id: \.self){ index in
                            generateTree(key: key + [String(index)], tag: list.elements[index])
                        }
                    }
                },
                label: {
                    HStack {
                        LetterView(letter: "A", color: Color(red: 228 / 255, green: 139 / 255, blue: 51 / 255))
                        Text(name).bold()
                    }
                }
            ))
        case is NBTCompound:
            let compound = tag as! NBTCompound
            return AnyView(DisclosureGroup(
                content: {
                    ForEach(compound.contents.keys.elements, id: \.self){ name in
                        generateTree(key: key + [name], tag: compound[name]!)
                    }
                },
                label: {
                    HStack {
                        LetterView(letter: "C", color: Color(red: 242 / 255, green: 194 / 255, blue: 79 / 255))
                        Text(name).bold()
                    }
                }
            ))
        default:
            return generatePrimitiveElementLine(key: key, tag: tag)
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

struct EditValueSheetView : View {
    
    @Binding var nbt : NBTStructure
    @Binding var key : [String]
    @Binding var visiable : Bool
    
    @State private var type = 0
    @State var valueText : String = ""
    @State var errorAlert = false
    
    let types = [
        NBTTagType.byte,
        NBTTagType.short,
        NBTTagType.int,
        NBTTagType.long,
        NBTTagType.float,
        NBTTagType.double,
        NBTTagType.string
    ]
    
    let foramt = [
        NBTTagType.byte: "[\(Int8.min),\(Int8.max)]",
        NBTTagType.short: "[\(Int16.min),\(Int16.max)]",
        NBTTagType.int: "[\(Int32.min),\(Int32.max)]",
        NBTTagType.long: "[\(Int64.min),\(Int64.max)]",
        NBTTagType.float: "only 0-9 and .",
        NBTTagType.double: "only 0-9 and .",
        NBTTagType.string: "UTF-8 String"
    ]
    
    var body: some View {
        VStack(alignment: .leading){
            Picker("Value Type", selection: $type){
                ForEach(types.indices, id: \.self) { index in
                    Text(types[index].description)
                }
            }
            Text("Input a value:")
            TextField("Enter a value",text : $valueText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 320)
            Divider()
            HStack{
                Spacer()
                Button("Cancel"){
                    visiable.toggle()
                }
                Button("Confirm"){
                    switch (types[self.type]){
                    case NBTTagType.byte:
                        if let value = Int8(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visiable.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.short:
                        if let value = Int16(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visiable.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.int:
                        if let value = Int32(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visiable.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.long:
                        if let value = Int64(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visiable.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.float:
                        if let value = Float32(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visiable.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.double:
                        if let value = Float64(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visiable.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.string:
                        let tag : any NBTTag = valueText
                        try! nbt.write(tag, to: key)
                        visiable.toggle()
                    default:
                        break
                    }
                }.buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
        }.padding()
            .onAppear(){
                let tag = try! nbt.read(key)
                self.type = types.firstIndex(of: tag!.type)!
                self.valueText = tag!.description
            }.alert(isPresented: $errorAlert) {
                Alert(
                    title: Text("Invalid Value"),
                    message: Text("Accept Format: " + self.foramt[types[self.type]]!),
                    dismissButton: .default(Text("OK"))
                )
            }
        
    }
    
    
}
