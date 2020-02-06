//
//  ChassisPIDnEvaluateTableView.swift
//  Terminal
//
//  Created by 钱晨 on 2020/2/6.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa

class ChassisPIDnEvaluateTableView: NSOutlineView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.delegate = self
        self.dataSource = self 
        // Drawing code here.
    }
    
    struct PIDnEvalData_t {
        var pidparam: AppDelegate.PIDParams_t
        var FLAnalysis: MotorAnalysis_t
        var FRAnalysis: MotorAnalysis_t
        var RLAnalysis: MotorAnalysis_t
        var RRAnalysis: MotorAnalysis_t
    }
    struct MotorAnalysis_t{
        var StdDiff: Float
        var AvgDiff: Float
    }
    var Data = [PIDnEvalData_t]()
    func getDataSetForSelectItem() -> PIDnEvalData_t? {
        let selectedItem = self.item(atRow: self.selectedRow)
        guard let selectedDataSet = selectedItem as? PIDnEvalData_t
            else {return self.parent(forItem: selectedItem) as? PIDnEvalData_t}
        return selectedDataSet
    }
    
    func getSelectedRowPID() -> AppDelegate.PIDParams_t {
        let selectedItem = self.item(atRow: self.selectedRow)
        guard let selectedPIDParams = selectedItem as? PIDnEvalData_t
            else {return ((self.parent(forItem: selectedItem) as? PIDnEvalData_t)?.pidparam)!}
        return selectedPIDParams.pidparam
    }
    
    func addData(Item: PIDnEvalData_t){
        Data.append(Item)
        self.reloadData()
    }
}
extension ChassisPIDnEvaluateTableView: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return Data.count
        } else {
            if (item as? PIDnEvalData_t) != nil {
                return 4
            } else {
                return 1
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return Data[index]
        } else {
            if let item = item as? PIDnEvalData_t {
                switch index {
                case 0:
                    return item.FLAnalysis
                case 1:
                    return item.FRAnalysis
                case 2:
                    return item.RLAnalysis
                case 3:
                    return item.RRAnalysis
                default:
                    return item
                }
            } else {
                return item!
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let _ = item as? PIDnEvalData_t else {return false}
        return true
    }
}

extension ChassisPIDnEvaluateTableView: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let colIdentifier = tableColumn?.identifier else {return nil}
        if colIdentifier == NSUserInterfaceItemIdentifier(rawValue: "col1") {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell1")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else {return nil}
            if item is PIDnEvalData_t {
                cell.textField?.stringValue = "Trial"
            } else if let MotorAnalysisData = item as? MotorAnalysis_t {
                if MotorAnalysisData.StdDiff == -1.0 {
                    cell.textField?.stringValue = "Null"
                } else {
                    cell.textField?.stringValue = String(format: "%.2f", MotorAnalysisData.AvgDiff)
                }
            }
            return cell
        } else {
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "cell2")
            guard let cell = outlineView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView else {return nil}
            if let PIDEvalData = item as? PIDnEvalData_t {
                cell.textField?.stringValue = String(format: "%.2f,", PIDEvalData.pidparam.kp) + String(format: "%.2f,", PIDEvalData.pidparam.ki) + String(format: "%.2f,", PIDEvalData.pidparam.kd) + String(format: "%.2f,", PIDEvalData.pidparam.i_limit) + String(format: "%.2f", PIDEvalData.pidparam.out_limit)
            } else if let MotorAnalysisData = item as? MotorAnalysis_t {
                if MotorAnalysisData.StdDiff == -1.0 {
                    cell.textField?.stringValue = "Null"
                } else {
                    cell.textField?.stringValue = String(format: "%.2f", MotorAnalysisData.StdDiff)
                }
            }
            return cell
        }
    }
}
