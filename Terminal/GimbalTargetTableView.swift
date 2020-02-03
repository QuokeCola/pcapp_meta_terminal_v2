//
//  TargetTableView.swift
//  Terminal
//
//  Created by 钱晨 on 2020/2/1.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa

class GimbalTargetTableView: NSTableView {
    
    enum DataIdentifier_t {
        case YAWV
        case YAWA
        case PITCHV
        case PITCHA
    }
    
    var dataIdentifier: DataIdentifier_t = .YAWV
    
    private var dataPasteBoardType = NSPasteboard.PasteboardType(rawValue: "private.TargetTableRow")
    
    struct targetData_t {
        var Target: Float
        var MaintainTime: Float
    }
    
    fileprivate var yawVelocityData = [targetData_t]()
    fileprivate var yawAngleData = [targetData_t]()
    fileprivate var pitchVelocityData = [targetData_t]()
    fileprivate var pitchAngleData = [targetData_t]()
    
    func switchDataSource(identifier: DataIdentifier_t) {
        self.dataIdentifier = identifier
        self.reloadData()
    }
    
    func addData(DataItem: targetData_t) {
        switch dataIdentifier {
        case .YAWV:
            self.yawVelocityData.append(DataItem)
        case .YAWA:
            self.yawAngleData.append(DataItem)
        case .PITCHV:
            self.pitchVelocityData.append(DataItem)
        case .PITCHA:
            self.pitchAngleData.append(DataItem)
        }
        self.reloadData()
    }
    
        func loadData(DataSource: Array<targetData_t>, DataTarget: DataIdentifier_t) {
        switch DataTarget {
        case .YAWV:
            self.yawVelocityData = DataSource
        case .YAWA:
            self.yawAngleData = DataSource
        case .PITCHV:
            self.pitchVelocityData = DataSource
        case .PITCHA:
            self.pitchAngleData = DataSource
        }
        self.reloadData()
    }
    
    fileprivate func swapData(originalIndex: Int, newIndex: Int) {
        self.delegate = nil
        switch dataIdentifier {
        case .YAWV:
            if(newIndex == yawVelocityData.count - 1) {
                yawVelocityData.append(yawVelocityData[originalIndex])
            } else {
                yawVelocityData.insert(yawVelocityData[originalIndex], at: newIndex)
            }
            if(originalIndex > newIndex) {
                yawVelocityData.remove(at: originalIndex + 1)
            } else {
                yawVelocityData.remove(at: originalIndex)
            }
        case .YAWA:
            if(newIndex == yawAngleData.count - 1) {
                yawAngleData.append(yawAngleData[originalIndex])
            } else {
                yawAngleData.insert(yawAngleData[originalIndex], at: newIndex)
            }
            if(originalIndex > newIndex) {
                yawAngleData.remove(at: originalIndex + 1)
            } else {
                yawAngleData.remove(at: originalIndex)
            }
        case .PITCHV:
            if(newIndex == pitchVelocityData.count - 1) {
                pitchVelocityData.append(pitchVelocityData[originalIndex])
            } else {
                pitchVelocityData.insert(pitchVelocityData[originalIndex], at: newIndex)
            }
            if(originalIndex > newIndex) {
                pitchVelocityData.remove(at: originalIndex + 1)
            } else {
                pitchVelocityData.remove(at: originalIndex)
            }
        case .PITCHA:
            if(newIndex == pitchAngleData.count - 1) {
                pitchAngleData.append(pitchAngleData[originalIndex])
            } else {
                pitchAngleData.insert(pitchAngleData[originalIndex], at: newIndex)
            }
            if(originalIndex > newIndex) {
                pitchAngleData.remove(at: originalIndex + 1)
            } else {
                pitchAngleData.remove(at: originalIndex)
            }
        }
        self.delegate = self
        self.reloadData()
    }
    
    func returnData() -> Array<targetData_t> {
        switch dataIdentifier {
        case .YAWV:
            return self.yawVelocityData
        case .YAWA:
            return self.yawAngleData
        case .PITCHV:
            return self.pitchVelocityData
        case .PITCHA:
            return self.pitchAngleData
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.dataSource = self
        self.delegate = self
        self.registerForDraggedTypes([dataPasteBoardType])
        // Drawing code here.
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 51 {
            switch dataIdentifier {
            case .YAWV:
                self.yawVelocityData.remove(at: self.selectedRow)
            case .YAWA:
                self.yawAngleData.remove(at: self.selectedRow)
            case .PITCHV:
                self.pitchVelocityData.remove(at: self.selectedRow)
            case .PITCHA:
                self.pitchAngleData.remove(at: self.selectedRow)
            }
            reloadData()
        }
        
    }
}
    
extension GimbalTargetTableView: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch dataIdentifier {
        case .YAWV:
            return self.yawVelocityData.count
        case .YAWA:
            return self.yawAngleData.count
        case .PITCHV:
            return self.pitchVelocityData.count
        case .PITCHA:
            return self.pitchAngleData.count
        }
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//        let DraggingData = String(Data[row].Target)+","+String(Data[row].MaintainTime) + "," + String(row)
        let DraggingIndex = String(row)
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(DraggingIndex, forType: dataPasteBoardType)
        return pasteboardItem
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        } else {
            return []
        }
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item = info.draggingPasteboard().pasteboardItems?.first,
            let rawDataString  = item.string(forType: dataPasteBoardType),
            //let originalRow = Int(rawDataString.split(separator: ",")[2])
            let originalRow = Int(rawDataString)
            else { return false }
        var newRow = row
        if originalRow < newRow {
            newRow = row - 1
        }
        tableView.beginUpdates()
        tableView.moveRow(at: originalRow, to: newRow)
        tableView.endUpdates()
        self.swapData(originalIndex: originalRow, newIndex: newRow)
        return true
    }
}
extension GimbalTargetTableView: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let TargetCell = "TargetCellID"
        static let TimeCell = "TimeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        
        if (tableColumn == tableView.tableColumns[0]) {
            cellIdentifier = CellIdentifiers.TargetCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                var string = ""
                switch dataIdentifier {
                case .YAWV:
                    string = String(yawVelocityData[row].Target)
                case .YAWA:
                    string = String(yawAngleData[row].Target)
                case .PITCHV:
                    string = String(pitchVelocityData[row].Target)
                case .PITCHA:
                    string = String(pitchAngleData[row].Target)
                }
                cell.textField?.stringValue = string
                cell.textField?.textColor = NSColor.black
                return cell
            }
        } else if (tableColumn == tableView.tableColumns[1]) {
            cellIdentifier = CellIdentifiers.TimeCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                var string = ""
                switch dataIdentifier {
                case .YAWV:
                    string = String(yawVelocityData[row].MaintainTime)
                case .YAWA:
                    string = String(yawAngleData[row].MaintainTime)
                case .PITCHV:
                    string = String(pitchVelocityData[row].MaintainTime)
                case .PITCHA:
                    string = String(pitchAngleData[row].MaintainTime)
                }
                cell.textField?.stringValue = string
                cell.textField?.textColor = NSColor.black
                return cell
            }
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if(tableColumn == tableView.tableColumns[0]) {
            switch dataIdentifier {
            case .YAWV:
                return self.yawVelocityData[row].Target
            case .YAWA:
                return self.yawAngleData[row].Target
            case .PITCHV:
                return self.pitchVelocityData[row].Target
            case .PITCHA:
                return self.pitchAngleData[row].Target
            }
        } else if (tableColumn == tableView.tableColumns[1]) {
            switch dataIdentifier {
            case .YAWV:
                return self.yawVelocityData[row].MaintainTime
            case .YAWA:
                return self.yawAngleData[row].MaintainTime
            case .PITCHV:
                return self.pitchVelocityData[row].MaintainTime
            case .PITCHA:
                return self.pitchAngleData[row].MaintainTime
            }
        }
        return nil
    }
}
