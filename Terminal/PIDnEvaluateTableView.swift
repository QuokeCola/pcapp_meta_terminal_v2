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
    
    enum DataIdentifier_t {
        case YAWV
        case YAWA
        case PITCHV
        case PITCHA
    }
    
    var dataIdentifier: DataIdentifier_t = DataIdentifier_t.YAWV
    
    struct PIDnEvalData_t {
        var pidparam: MainController.PIDParams_t
        var StandardDifference: Float
        var AverageDifference: Float
    }
    fileprivate var yawVelocityData = [PIDnEvalData_t]()
    fileprivate var pitchVelocityData = [PIDnEvalData_t]()
    fileprivate var yawAngleData = [PIDnEvalData_t]()
    fileprivate var pitchAngleData = [PIDnEvalData_t]()
    
    func switchDataSource(identifier: DataIdentifier_t) {
        self.dataIdentifier = identifier
        self.reloadData()
    }
    func addData(DataItem: PIDnEvalData_t) {
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
    
    func loadData(DataSource: Array<PIDnEvalData_t>, DataTarget: DataIdentifier_t) {
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
    func returnData() -> Array<PIDnEvalData_t> {
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
}

extension PIDnEvaluateTableView: NSTableViewDataSource {
    
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
    
    // Dragging
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let DraggingData = String(row)
//        let DraggingData = String(Data[row].pidparam.kp) + "," + String(Data[row].pidparam.ki) + "," + String(Data[row].pidparam.kd) + "," + String(Data[row].pidparam.i_limit) + "," + String(Data[row].pidparam.out_limit) + "," + String(Data[row].AverageDifference) + "," + String(Data[row].StandardDifference) + "," + String(row) // This is for dragging data out of window in the future.
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
        var Data = [PIDnEvalData_t]()
        switch dataIdentifier {
        case .YAWV:
            Data = self.yawVelocityData
        case .YAWA:
            Data = self.yawAngleData
        case .PITCHV:
            Data = self.pitchVelocityData
        case .PITCHA:
            Data = self.pitchAngleData
        }
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
