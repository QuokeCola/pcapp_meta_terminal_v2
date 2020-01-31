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
        
        // Plot data, add time scale later
        if(realdata.count != 0){
            
            // Get data
            let latest_data = realdata[realdata.count-1]
            
            // Initialize Inedex and paths
            var index = realdata.count - 1
            realdatapath.move(to: CGPoint(x: self.size.width, y: 0.0))
            targetdatapath.move(to: CGPoint(x: self.size.width, y: 0.0))
            var maxData: Float = 30.0
            var minData: Float = -30.0
            
            while (abs(latest_data.Time - realdata[index].Time) < time_reveal && index > 0) {
                
                // Auto Size
                
                //Get the maxdata and mindata in a loop
                if(realdata[index].Data > maxData || targetdata[index].Data > maxData) {
                    if(realdata[index].Data > targetdata[index].Data) {
                        maxData = realdata[index].Data
                    } else {
                        maxData = targetdata[index].Data
                    }
                }

                if(realdata[index].Data < minData || targetdata[index].Data < minData) {
                    if(realdata[index].Data < targetdata[index].Data) {
                        minData = realdata[index].Data
                    } else {
                        minData = realdata[index].Data
                    }
                }
                
                let pointx = CGFloat(Float((realdata[index].Time) - latest_data.Time)/Float(time_reveal)) * self.size.width + self.size.width
                let realdatapointy = mapDataToPlot(data: realdata[index].Data)
                let targetdatapointy = mapDataToPlot(data: targetdata[index].Data)
//                let targetdatapointy = CGFloat((targetdata[index].Data)/Float(dataRange.ABSDataRange())) * self.size.height
                
                let realdatapoint = CGPoint(x: pointx, y: realdatapointy)
                let targetdatapoint = CGPoint(x: pointx, y: targetdatapointy)
                realdatapath.addLine(to: realdatapoint)
                targetdatapath.addLine(to: targetdatapoint)
                index = index - 1
            }
            // Update MaxValue and MinValue, while left some void.
            self.dataRange.MaxValue = maxData+20.0
            self.dataRange.MinValue = minData-20.0
        }
        
        // Plot the chart background
        let basic_line_digit = String(Int(dataRange.ABSDataRange())).count
        var basic_seperation: Double = 1
        if(dataRange.ABSDataRange()/pow(10.0, Float(basic_line_digit-1)) > 2.0) {
            basic_seperation = pow(Double(10), Double(basic_line_digit - 1))
        } else {
            basic_seperation = pow(Double(10), Double(basic_line_digit - 2))
        }
        let backgroundplot = CGMutablePath()
        let lowerBound = Float(Int(dataRange.MinValue/Float(basic_seperation))) * Float(basic_seperation)
        
        backgroundplot.move(to: CGPoint(x: -1.0, y: mapDataToPlot(data: Float(lowerBound))))
        for i in stride(from: 0,to: Int(dataRange.ABSDataRange()/Float(basic_seperation)),by: 2) {
            
            let currentHeight = lowerBound + Float(i) * Float(basic_seperation)
            backgroundplot.addLine(to: CGPoint(x:self.size.width+1.0, y: mapDataToPlot(data: currentHeight)))
            backgroundplot.addLine(to: CGPoint(x:self.size.width+1.0, y: mapDataToPlot(data: currentHeight+Float(basic_seperation))))
            backgroundplot.addLine(to: CGPoint(x: -1.0, y: mapDataToPlot(data: currentHeight+Float(basic_seperation))))
            backgroundplot.addLine(to: CGPoint(x: -1.0, y: mapDataToPlot(data: currentHeight+2*Float(basic_seperation))))
            
            let label_low = SKLabelNode(text: "\(currentHeight)")
            let label_high = SKLabelNode(text: "\(currentHeight+Float(basic_seperation))")
            
            label_low.verticalAlignmentMode = .bottom;
            label_low.horizontalAlignmentMode = .right
            label_low.fontColor = SKColor.lightGray
            label_low.fontName = "Din Condensed"
            label_low.fontSize = 10
            label_low.position = CGPoint(x: self.size.width, y: mapDataToPlot(data: currentHeight))
            
            label_high.verticalAlignmentMode = .bottom;
            label_high.horizontalAlignmentMode = .right
            label_high.fontColor = SKColor.lightGray
            label_high.fontName = "Din Condensed"
            label_high.fontSize = 10
            let higherHeight = currentHeight + Float(basic_seperation)
            label_high.position = CGPoint(x: self.size.width, y: mapDataToPlot(data: higherHeight))
            
            addChild(label_low)
            addChild(label_high)
        }
        let backgroundpath = SKShapeNode(path: backgroundplot)
        backgroundpath.lineWidth = 1
        backgroundpath.strokeColor = NSColor.lightGray
        backgroundpath.position = CGPoint(x: 0.0, y: 0.0)

        // Set line Style
        let realdatachartpath = SKShapeNode(path: realdatapath)
        realdatachartpath.lineWidth = 1
        realdatachartpath.strokeColor = .systemBlue
        
        let targetdatachartpath = SKShapeNode(path: targetdatapath)
        targetdatachartpath.lineWidth = 1
        targetdatachartpath.strokeColor = .systemOrange
        
        let titlebar = SKLabelNode(text: title)
        titlebar.verticalAlignmentMode = .bottom;
        titlebar.horizontalAlignmentMode = .left
        titlebar.fontColor = SKColor.black
        titlebar.fontName = "Din Condensed"
        titlebar.fontSize = 10
        titlebar.position = CGPoint(x: 5.0, y: 3.0)
        
        backgroundpath.alpha = 0.3
        // Show path
        addChild(titlebar)
        addChild(realdatachartpath)
        addChild(targetdatachartpath)
        addChild(backgroundpath)

        realdatachartpath.position = CGPoint(x: 0, y: 0)
        targetdatachartpath.position = CGPoint(x: 0, y: 0)

        self.dataChanged = false
    }
    /***------------------------Plot Methods-------------------------***/
    
    func mapDataToPlot(data: Float)->CGFloat{
        return CGFloat((data - dataRange.MinValue)/Float(dataRange.ABSDataRange())) * self.size.height
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
    
    var title = "chart"
    var time_reveal = 20000
    var dataChanged: Bool = false
    struct dataRange_t {
        var MaxValue: Float
        var MinValue: Float
        func ABSDataRange() -> Float {
            return MaxValue - MinValue
        }
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
