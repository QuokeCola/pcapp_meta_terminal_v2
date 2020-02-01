//
//  PIDnEvaluateTableView.swift
//  Terminal
//
//  Created by 钱晨 on 2020/2/2.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa

class PIDnEvaluateTableView: NSTableView {

    private var dataPasteBoardType = NSPasteboard.PasteboardType(rawValue: "private.PIDTableRow")
    
    struct PIDnEvalData_t {
        var pidparam: MainController.PIDParams_t
        var StandardDifference: Float
        var AverageDifference: Float
    }
    fileprivate var Data = [PIDnEvalData_t]()
    
    func addData(DataItem: PIDnEvalData_t) {
        Data.append(DataItem)
        self.reloadData()
    }
    
    func loadData(DataSource: Array<PIDnEvalData_t>) {
        Data = DataSource
        self.reloadData()
    }
    
    fileprivate func swapData(originalIndex: Int, newIndex: Int) {
        self.delegate = nil
        if(newIndex == Data.count - 1) {
            Data.append(Data[originalIndex])
        } else {
            Data.insert(Data[originalIndex], at: newIndex)
        }
        if(originalIndex > newIndex) {
            Data.remove(at: originalIndex + 1)
        } else {
            Data.remove(at: originalIndex)
        }
        
        self.delegate = self
        self.reloadData()
    }
    func returnData() -> Array<PIDnEvalData_t> {
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
extension PIDnEvaluateTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Data.count
    }
    // Dragging
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let DraggingData = String(Data[row].pidparam.kp) + "," + String(Data[row].pidparam.ki) + "," + String(Data[row].pidparam.kd) + "," + String(Data[row].pidparam.i_limit) + "," + String(Data[row].pidparam.out_limit) + "," + String(Data[row].AverageDifference) + "," + String(Data[row].StandardDifference) + "," + String(row) // This is for dragging data out of window in the future.
        let pastboardItem = NSPasteboardItem()
        pastboardItem.setString(DraggingData, forType: dataPasteBoardType)
        return pastboardItem
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if (dropOperation == .above) {
            return .move
        } else {
            return []
        }
    }
    
    // Drop
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        guard
            let item = info.draggingPasteboard().pasteboardItems?.first,
            let rawDataString = item.string(forType: dataPasteBoardType),
            let originalRow = Int(rawDataString.split(separator: ",")[7])
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

extension PIDnEvaluateTableView: NSTableViewDelegate {
    fileprivate enum CellIdentifiers {
        static let kpCell = "kpCellID"
        static let kiCell = "kiCellID"
        static let kdCell = "kdCellID"
        static let i_limit_Cell = "ilimCellID"
        static let out_limit_Cell = "olimCellID"
        static let avgdiffCell = "avgdiffCellID"
        static let stddiffCell = "stddiffCellID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellIdentifier: String = ""
        var string: String = ""
        if (tableColumn == tableView.tableColumns[0]) {
            cellIdentifier = CellIdentifiers.kpCell
            string = String(Data[row].pidparam.kp)
        } else if (tableColumn == tableView.tableColumns[1]) {
            cellIdentifier = CellIdentifiers.kiCell
            string = String(Data[row].pidparam.ki)
        } else if (tableColumn == tableView.tableColumns[2]) {
            cellIdentifier = CellIdentifiers.kdCell
            string = String(Data[row].pidparam.kd)
        } else if (tableColumn == tableView.tableColumns[3]) {
            cellIdentifier = CellIdentifiers.i_limit_Cell
            string = String(Data[row].pidparam.i_limit)
        } else if (tableColumn == tableView.tableColumns[4]) {
            cellIdentifier = CellIdentifiers.out_limit_Cell
            string = String(Data[row].pidparam.out_limit)
        } else if (tableColumn == tableView.tableColumns[5]) {
            cellIdentifier = CellIdentifiers.stddiffCell
            if (Data[row].StandardDifference > 0.0) { // let standard difference is negative to show it's not valid.
                string = String(Data[row].StandardDifference)
            } else {
                string = "null"
            }
        } else if (tableColumn == tableView.tableColumns[6]) {
            cellIdentifier = CellIdentifiers.avgdiffCell
            if (Data[row].StandardDifference > 0.0 ) {
                string = String(Data[row].AverageDifference)
            } else {
                string = "null"
            }
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = string
            cell.textField?.textColor = NSColor.black
            return cell
        }
        return nil
    }
    
}
