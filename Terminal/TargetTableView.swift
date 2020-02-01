//
//  TargetTableView.swift
//  Terminal
//
//  Created by 钱晨 on 2020/2/1.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa

class TargetTableView: NSTableView {
//    let kUTTypePlainText: CFString
//    let dataPasteBoardType = NSPasteboard.PasteboardType(rawValue: "kUTTypePlainText")
    private var dataPasteBoardType = NSPasteboard.PasteboardType(rawValue: "private.TargetTableRow")
    struct targetData_t {
        var Target: Float
        var MaintainTime: Float
    }
    fileprivate var Data = [targetData_t]()
    
    func addData(DataItem: targetData_t) {
        Data.append(DataItem)
        self.reloadData()
    }
    
    func loadData(DataSource: Array<targetData_t>) {
        Data = DataSource
        self.reloadData()
    }
    
    func swapData(originalIndex: Int, newIndex: Int){
        self.delegate = nil
        Data.insert(Data[originalIndex], at: newIndex)
        if(originalIndex > newIndex) {
            Data.remove(at: originalIndex + 1)
        } else {
            Data.remove(at: originalIndex)
        }
        
        self.delegate = self
        self.reloadData()
    }
    
    func returnData() -> Array<targetData_t> {
        return Data
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.dataSource = self
        self.delegate = self
        self.registerForDraggedTypes([dataPasteBoardType])
        // Drawing code here.
    }
    
}
extension TargetTableView: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Data.count
    }
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let DraggingData = String(Data[row].Target)+","+String(Data[row].MaintainTime) + "," + String(row)
        let pasteboardItem = NSPasteboardItem()
        pasteboardItem.setString(DraggingData, forType: dataPasteBoardType)
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
            let originalRow = Int(rawDataString.split(separator: ",")[2])
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
extension TargetTableView: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let TargetCell = "TargetCellID"
        static let TimeCell = "TimeCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        
        if (tableColumn == tableView.tableColumns[0]) {
            cellIdentifier = CellIdentifiers.TargetCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = String(Data[row].Target)
                cell.textField?.textColor = NSColor.black
                return cell
            }
        } else if (tableColumn == tableView.tableColumns[1]) {
            cellIdentifier = CellIdentifiers.TimeCell
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
                cell.textField?.stringValue = String(Data[row].MaintainTime)
                return cell
            }
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if(tableColumn == tableView.tableColumns[0]) {
            return Data[row].Target
        } else if (tableColumn == tableView.tableColumns[1]) {
            return Data[row].MaintainTime
        }
        return nil
    }
}
