//
//  PlotChart.swift
//  Terminal
//
//  Created by 钱晨 on 2020/1/30.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa
import SpriteKit

class PlotChart: SKScene {
    
    
    /***----------------------Data Add------------------------***/
    func AddData(RealData_: Float, TargetData_: Float, Time_: Int) {
        if(self.target_data.isFull()){
            self.target_data.pop()
            self.real_data.pop()
        }
        self.target_data.push(DataPoint: PlotChart.Points(Data: TargetData_, Time: Time_))
        self.real_data.push(DataPoint: PlotChart.Points(Data: RealData_, Time: Time_))
        self.dataChanged = true
    }
    /***----------------------Data Plot-----------------------***/
    override func didMove(to view: SKView) {
        if(self.dataChanged) {
            
            self.dataChanged = false
            print("datachanged")
        }
    }
    override func update(_ currentTime: TimeInterval) {
        
    }
    /***--------------------Data Storage----------------------***/
    
    var dataChanged: Bool = false
    // A Basic Point
    struct Points {
        var Data: Float = 0.0
        var Time: Int = 0
    }
    
    // A Queue to store the points
    class Data: NSObject {
        var DataSet: [Points]
        var front:Int
        var rear:Int
        var size:Int
        var MAXSize: Int
    
        init(_ size: Int) {
            self.DataSet = [Points](repeating: Points(Data: 0.0, Time: 0), count: size)
            self.front = 0
            self.rear = -1
            self.size = 0
            self.MAXSize = size
            super.init()
        }
        public func push(DataPoint: Points) {
            if(size < self.MAXSize) {
                self.rear += 1                       // Rear Increment
                if(self.rear == self.MAXSize) { // If rear is out of range
                    self.rear = 0
                }
                self.DataSet[self.rear] = DataPoint
                self.size += 1
            } else {
                print("length out of range, data not recorded")
            }
        }
        public func pop() {
            if(size > 0) {
                self.front += 1
                if (self.front == MAXSize) { // If front is out of range
                    self.front = 0
                }
                self.size -= 1
                // Doesnot return poped item.
            } else {
                print("No data in the queue, data not poped")
            }
        }
        public func isFull() -> Bool{
            if (self.size >= self.MAXSize) {
                return true
            } else {
                return false
            }
        }
        public func isEmpty() -> Bool{
            if(self.size <= 0) {
                return true
            } else {
                return false
            }
        }
        public func getData() -> [Points] {
            var returnData = [Points](repeating: Points(Data: 0.0, Time: 0), count: self.size)
            var pointer = self.front
            for index in stride(from: 0, to: self.size, by: 1) {
                returnData[index] = DataSet[pointer]
                pointer += 1
                if(pointer == size) { // Pointer out of range
                    pointer = 0
                }
            }
            return returnData
        }
    }
    // Two Data Variables Stored
    var real_data = Data(300)
    var target_data = Data(300)
}
