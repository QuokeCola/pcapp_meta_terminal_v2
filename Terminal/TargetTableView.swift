//
//  TargetTableView.swift
//  Terminal
//
//  Created by 钱晨 on 2020/2/1.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa

class TargetTableView: NSTableView {
    
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
    
    func returnData() -> Array<targetData_t> {
        return Data
    }
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.dataSource = self
        self.delegate = self
        // Drawing code here.
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        print(tableColumns[0].dataCell(forRow: 0))
    }
}
extension TargetTableView: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Data.count
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
