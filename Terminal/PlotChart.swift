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
    
    /***----------------------Data Plot-----------------------***/
    
    // Initialize the plot
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        self.dataChanged = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let realdatapath = CGMutablePath()
        let targetdatapath = CGMutablePath()
        // Initialize
        removeAllChildren()
        // Set start point
        let realdata = real_data.getData()
        let targetdata = target_data.getData()
        
        let ABS_Datarange = self.dataRange.MaxValue - self.dataRange.MinValue
        
        // Plot data, add time scale later
        if(realdata.count != 0){
            
            // Get data
            let latest_data = realdata[realdata.count-1]
            
            // Initialize Inedex and paths
            var index = realdata.count - 1
            realdatapath.move(to: CGPoint(x: self.size.width, y: 0.0))
            targetdatapath.move(to: CGPoint(x: self.size.width, y: 0.0))
            
            while (abs(latest_data.Time - realdata[index].Time) < time_reveal && index > 0) {
                
                let pointx = CGFloat(Float((realdata[index].Time) - latest_data.Time)/Float(time_reveal)) * self.size.width + self.size.width
                print(pointx)
                let realdatapointy = CGFloat((realdata[index].Data)/Float(ABS_Datarange)) * self.size.height
                let targetdatapointy = CGFloat((targetdata[index].Data)/Float(ABS_Datarange)) * self.size.height
                
                let realdatapoint = CGPoint(x: pointx, y: realdatapointy)
                let targetdatapoint = CGPoint(x: pointx, y: targetdatapointy)
                realdatapath.addLine(to: realdatapoint)
                targetdatapath.addLine(to: targetdatapoint)
                index = index - 1
            }
        }
        // Set line Style
        let realdatachartpath = SKShapeNode(path: realdatapath)
        realdatachartpath.lineWidth = 2
        realdatachartpath.strokeColor = .systemBlue
        
        let targetdatachartpath = SKShapeNode(path: targetdatapath)
        targetdatachartpath.lineWidth = 2
        targetdatachartpath.strokeColor = .systemOrange
        
        // Show path
        addChild(realdatachartpath)
        addChild(targetdatachartpath)
        
        realdatachartpath.position = CGPoint(x: 0, y: self.size.height*0.5)
        targetdatachartpath.position = CGPoint(x: 0, y: self.size.height*0.5)
        self.dataChanged = false
    }
    
    /***----------------------Data Management------------------------***/
    func AddData(RealData_: Float, TargetData_: Float, Time_: Int) {
        if(self.target_data.isFull()){
            self.target_data.pop()
            self.real_data.pop()
        }
        self.target_data.push(DataPoint: PlotChart.Points(Data: TargetData_, Time: Time_))
        self.real_data.push(DataPoint: PlotChart.Points(Data: RealData_, Time: Time_))
        self.dataChanged = true
    }
    
    func ClearData() {
        // initialize the datasets
        self.target_data.front = 0
        self.target_data.rear = -1
        self.target_data.size = 0
        self.real_data.front = 0
        self.real_data.rear = -1
        self.real_data.size = 0
    }
    
    /***--------------------Data Storage----------------------***/
    
    var time_reveal = 20000
    var dataChanged: Bool = false
    struct dataRange_t {
        var MaxValue: Float
        var MinValue: Float
    }
    var dataRange = dataRange_t(MaxValue: 200.0, MinValue: -200.0)
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
    var real_data = Data(1000)
    var target_data = Data(1000)
}
