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
    
    @State var selectKey : [String] = []
    
    @State var editSheetVisible = false
    @State var renameSheetVisible = false
    
    var body: some View {
        let tag = data.tag
        List {
            ForEach(tag.contents.keys, id: \.self){ name in
                generateTree(key: [name], tag: tag[name]!)
            }
        }.sheet(isPresented: $editSheetVisible){
            EditValueSheetView(
                nbt: $data,
                key: $selectKey,
                visible: $editSheetVisible
            )
        }.sheet(isPresented: $renameSheetVisible){
            RenameSheetView(
                nbt: $data,
                key: $selectKey,
                visible: $renameSheetVisible
            )
        }
    }
    
    func getMenuItems(key: [String], tag : any NBTTag) -> some View{
        let parent = try! self.data.read(Array(key[0..<key.count-1]))
        return Group{
            if !(parent is NBTList){
                Button("Rename"){
                    self.selectKey = key
                    self.renameSheetVisible.toggle()
                }
            }
            if !(tag is NBTCompound) && !(tag is NBTList){
                Button("Edit Value"){
                    self.selectKey = key
                    self.editSheetVisible.toggle()
                }
            }
            Button("Delete Value"){
                self.deleteElement(key: key)
            }
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
            }
            .contextMenu{
                getMenuItems(key: key, tag: tag)
            }
            
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
                    }.contextMenu{
                        getMenuItems(key: key, tag: tag)
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
                    }.contextMenu{
                        getMenuItems(key: key, tag: tag)
                    }
                }
            ))
        default:
            return generatePrimitiveElementLine(key: key, tag: tag)
        }
    }
    
    func deleteElement(key: [String]){
        let parentKey = Array(key[0..<key.count - 1])
        let parent = try! self.data.read(parentKey)!
        
        if parent is NBTCompound{
            let itemName = key[key.count - 1]
            var compound = parent as! NBTCompound
            
            compound.contents.removeValue(forKey: itemName)
            try! self.data.write(compound, to: parentKey)
        }
        
        if parent is NBTList {
            let itemIndex = Int(key[key.count - 1])!
            var list = parent as! NBTList
            
            list.elements.remove(at: itemIndex)
            try! self.data.write(list, to: parentKey)
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

let PRIMITIVE_TYPES = [
    NBTTagType.byte,
    NBTTagType.short,
    NBTTagType.int,
    NBTTagType.long,
    NBTTagType.float,
    NBTTagType.double,
    NBTTagType.string
]

struct RenameSheetView : View {
    
    @Binding var nbt : NBTStructure
    @Binding var key : [String]
    @Binding var visible : Bool
    
    @State var name : String = ""
    @State var tag : (any NBTTag)!
    
    @State var alertDuplicateKey = false
    
    var body : some View {
        VStack(alignment: .leading){
            Text("Input a name:")
            TextField("Enter a name",text : $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(minWidth: 320)
            Divider()
            HStack{
                Spacer()
                Button("Cancel"){
                    visible.toggle()
                }
                Button("Confirm"){
                    let parentKey = Array(key[0..<key.count-1])
                    var parentCompound = try! self.nbt.read(parentKey)! as! NBTCompound
                    
                    if (parentCompound.contents.keys.contains(name)){
                        self.alertDuplicateKey.toggle()
                        return
                    }
                    
                    let keyIndex = parentCompound.contents.index(forKey: key[key.count - 1])!
                    parentCompound.contents[name] = tag
                    parentCompound.contents.swapAt(keyIndex, parentCompound.contents.count - 1)
                    parentCompound.contents.removeLast()
                    
                    try! nbt.write(parentCompound, to: parentKey)
                    visible.toggle()
                }.buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
        }.padding()
            .onAppear(){
                self.name = key.last!
                self.tag = try! nbt.read(key)!
            }.alert(isPresented: $alertDuplicateKey) {
                Alert(
                    title: Text("Duplicate Key"),
                    dismissButton: .default(Text("OK"))
                )
            }
    }
}

struct EditValueSheetView : View {
    
    @Binding var nbt : NBTStructure
    @Binding var key : [String]
    @Binding var visible : Bool
    
    @State private var type = 0
    @State var valueText : String = ""
    @State var errorAlert = false
    
    
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
                ForEach(PRIMITIVE_TYPES.indices, id: \.self) { index in
                    Text(PRIMITIVE_TYPES[index].description)
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
                    visible.toggle()
                }
                Button("Confirm"){
                    switch (PRIMITIVE_TYPES[self.type]){
                    case NBTTagType.byte:
                        if let value = Int8(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visible.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.short:
                        if let value = Int16(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visible.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.int:
                        if let value = Int32(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visible.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.long:
                        if let value = Int64(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visible.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.float:
                        if let value = Float32(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visible.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.double:
                        if let value = Float64(self.valueText){
                            let tag : any NBTTag = value
                            try! nbt.write(tag, to: key)
                            visible.toggle()
                        }else{
                            self.errorAlert = true
                        }
                    case NBTTagType.string:
                        let tag : any NBTTag = valueText
                        try! nbt.write(tag, to: key)
                        visible.toggle()
                    default:
                        break
                    }
                }.buttonStyle(.borderedProminent)
                    .keyboardShortcut(.defaultAction)
            }
        }.padding()
            .onAppear(){
                let tag = try! nbt.read(key)
                self.type = PRIMITIVE_TYPES.firstIndex(of: tag!.type)!
                self.valueText = tag!.description
            }.alert(isPresented: $errorAlert) {
                Alert(
                    title: Text("Invalid Value"),
                    message: Text("Accept Format: " + self.foramt[PRIMITIVE_TYPES[self.type]]!),
                    dismissButton: .default(Text("OK"))
                )
            }
        
    }
    
    
}
