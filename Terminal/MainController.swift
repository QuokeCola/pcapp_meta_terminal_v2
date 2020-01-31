//
//  MainController.swift
//  Terminal
//
//  Created by 钱晨 on 2020/1/28.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa
import ORSSerial
import SpriteKit

class MainController: NSObject, ORSSerialPortDelegate {
    

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var ConnectButton: NSButton!
    
    @IBOutlet weak var TerminalBackGround: NSVisualEffectView!
    @IBOutlet weak var GimbalBackGround: NSVisualEffectView!
    @IBOutlet weak var ChassisBackGround: NSVisualEffectView!
    
    @IBOutlet weak var TabViews: NSTabView!
    
    /***--------------------SideView Interfaces-----------------------***/
    
    @IBAction func ConnectButtonClk(_ sender: Any) {
        if let port = self.serialPort {
            if(port.isOpen == true) {
                port.close()
                port.delegate = nil
                ConnectButton.title = "Connect"
            } else {
                port.delegate = self
                port.open()
                port.parity = .none
            }
        }
    }
    
    @IBAction func TerminalBtnClk(_ sender: Any) {
        TerminalBackGround.material = NSVisualEffectView.Material.dark
        GimbalBackGround.material = NSVisualEffectView.Material.ultraDark
        ChassisBackGround.material = NSVisualEffectView.Material.ultraDark
        TabViews.selectTabViewItem(at: 0)
        
        // Stop the Gimbal Chart View.
        GimbalMainChartView.isPaused = true
        GimbalSecondChartView.isPaused = true
        GimbalThirdChartView.isPaused = true
        
        if let port = self.serialPort {
            let command = "g_enable_fb 0 0\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func GimbalBtnClk(_ sender: Any) {
        TerminalBackGround.material = NSVisualEffectView.Material.ultraDark
        GimbalBackGround.material = NSVisualEffectView.Material.dark
        ChassisBackGround.material = NSVisualEffectView.Material.ultraDark
        TabViews.selectTabViewItem(at: 1)
        
        // Initialize three views
        yawVelocityChart.scaleMode = .aspectFill
        yawCurrentChart.scaleMode = .aspectFill
        yawAngleChart.scaleMode = .aspectFill
        pitchVelocityChart.scaleMode = .aspectFit
        pitchCurrentChart.scaleMode = .aspectFit
        pitchAngleChart.scaleMode = .aspectFit
        
        yawVelocityChart.title = "Velocity"
        yawAngleChart.title = "Angle"
        yawCurrentChart.title = "Current"
        pitchVelocityChart.title = "Velocity"
        pitchAngleChart.title = "Angle"
        pitchCurrentChart.title = "Current"
        
        // Start the Gimbal Chart View.
        GimbalMainChartView.isPaused = false
        GimbalSecondChartView.isPaused = false
        GimbalThirdChartView.isPaused = false
        
        selectGimbalViews()
        if let port = self.serialPort {
            var commandString = "g_enable_fb 0 0\r"
            if(MotorSelector.selectedItem == MotorSelector.item(at: 0)) {
                commandString = "g_enable_fb 1 0\r"
            } else if(MotorSelector.selectedItem == MotorSelector.item(at: 1)){
                commandString = "g_enable_fb 0 1\r"
            }
            let command = commandString.data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func ChassisBtnClk(_ sender: Any) {
        
        // Stop the Gimbal Chart View.
        GimbalMainChartView.isPaused = true
        GimbalSecondChartView.isPaused = true
        GimbalThirdChartView.isPaused = true
        
        TerminalBackGround.material = NSVisualEffectView.Material.ultraDark
        GimbalBackGround.material = NSVisualEffectView.Material.ultraDark
        ChassisBackGround.material = NSVisualEffectView.Material.dark
        TabViews.selectTabViewItem(at: 2)
        
    }
    
    /***--------------------Terminal Interface-----------------------***/
    
    @IBAction func ShellClearBtnClk(_ sender: Any) {
        ShellView.string = ""
        yawAngleChart.ClearData()
        yawVelocityChart.ClearData()
        yawCurrentChart.ClearData()
    }
    
    @IBAction func HelloBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let command = "hello\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func StatsBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let command = "stats\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func MemBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let command = "mem\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func SystimeBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let command = "systime\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func ThreadsBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let command = "threads\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func SendBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let commandstr = CommandTextField.stringValue + "\r"
            let command = commandstr.data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func ReturnPressedinTextField(_ sender: Any) {
        SendBtnClk(sender)
    }
    
    @IBOutlet weak var CommandTextField: NSTextField!
    @IBOutlet var ShellView: NSTextView!
    @IBOutlet weak var ShellScroller: NSScrollView!
    
    /***--------------------Gimbal Interface-----------------------***/
    
    @IBOutlet weak var GimbalMainChartView: SKView!
    @IBOutlet weak var GimbalSecondChartView: SKView!
    @IBOutlet weak var GimbalThirdChartView: SKView!
    
    // TODO: remove these test data
    lazy var time = 0
    lazy var testdata: Float = 0.0
    // to here
    
    lazy var yawVelocityChart = PlotChart(size: GimbalMainChartView.bounds.size)
    lazy var yawAngleChart = PlotChart(size: GimbalSecondChartView.bounds.size)
    lazy var yawCurrentChart = PlotChart(size: GimbalThirdChartView.bounds.size)
    
    lazy var pitchVelocityChart = PlotChart(size: GimbalMainChartView.bounds.size)
    lazy var pitchAngleChart = PlotChart(size: GimbalSecondChartView.bounds.size)
    lazy var pitchCurrentChart = PlotChart(size: GimbalThirdChartView.bounds.size)

    @IBOutlet weak var MotorSelector: NSPopUpButton!
    @IBAction func MotorSelect(_ sender: Any) {
        if(MotorSelector.selectedItem == MotorSelector.item(at: 0)) {
            if let port = self.serialPort {
                let command = "g_enable_fb 1 0\r".data(using: String.Encoding.ascii)!
                port.send(command)
            }
        } else if (MotorSelector.selectedItem == MotorSelector.item(at: 1)) {
            if let port = self.serialPort {
                let command = "g_enable_fb 0 1\r".data(using: String.Encoding.ascii)!
                port.send(command)
            }
        }
        // switch Views
        selectGimbalViews()
    }
    @IBOutlet weak var PIDSelector: NSPopUpButton!
    
    @IBAction func PIDSelect(_ sender: Any) {
        selectGimbalViews()
    }
    
    @IBOutlet weak var EnableAHRSBtn: NSButton!
    
    @IBAction func EnableAHRSBtnClk(_ sender: Any) {
        var commandString: String
        if let port = serialPort {
            if(EnableAHRSBtn.state == .on) {
                commandString = "g_ahrs_e 1\r\n"
            } else {
                commandString = "g_ahrs_e 0\r\n"
            }
            let command = commandString.data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBAction func SetFrontABtnClk(_ sender: Any) {
        if let port = serialPort {
            let command = "g_fix\r\n".data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    func selectGimbalViews() {
        if (MotorSelector.selectedItem == MotorSelector.item(at: 0)) {  // YAW
            if (PIDSelector.selectedItem == PIDSelector.item(at: 0)) {
                
                yawVelocityChart.size = self.GimbalMainChartView.bounds.size
                yawAngleChart.size = self.GimbalSecondChartView.bounds.size
                yawCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(yawVelocityChart)
                GimbalSecondChartView.presentScene(yawAngleChart)
                GimbalThirdChartView.presentScene(yawCurrentChart)
                
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 1)) {
                
                yawVelocityChart.size = self.GimbalSecondChartView.bounds.size
                yawAngleChart.size = self.GimbalMainChartView.bounds.size
                yawCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(yawAngleChart)
                GimbalSecondChartView.presentScene(yawVelocityChart)
                GimbalThirdChartView.presentScene(yawCurrentChart)
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 2)) {
                yawVelocityChart.size = self.GimbalThirdChartView.bounds.size
                yawAngleChart.size = self.GimbalSecondChartView.bounds.size
                yawCurrentChart.size = self.GimbalMainChartView.bounds.size
                
                GimbalMainChartView.presentScene(yawCurrentChart)
                GimbalSecondChartView.presentScene(yawAngleChart)
                GimbalThirdChartView.presentScene(yawVelocityChart)
            }
        } else if (MotorSelector.selectedItem == MotorSelector.item(at: 1)) { // PITCH
            if (PIDSelector.selectedItem == PIDSelector.item(at: 0)) {
                
                pitchVelocityChart.size = self.GimbalMainChartView.bounds.size
                pitchAngleChart.size = self.GimbalSecondChartView.bounds.size
                pitchCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(pitchVelocityChart)
                GimbalSecondChartView.presentScene(pitchAngleChart)
                GimbalThirdChartView.presentScene(pitchCurrentChart)
                
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 1)) {
                
                pitchVelocityChart.size = self.GimbalSecondChartView.bounds.size
                pitchAngleChart.size = self.GimbalMainChartView.bounds.size
                pitchCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(pitchAngleChart)
                GimbalSecondChartView.presentScene(pitchVelocityChart)
                GimbalThirdChartView.presentScene(pitchCurrentChart)
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 2)) {
                pitchVelocityChart.size = self.GimbalThirdChartView.bounds.size
                pitchAngleChart.size = self.GimbalSecondChartView.bounds.size
                pitchCurrentChart.size = self.GimbalMainChartView.bounds.size
                
                GimbalMainChartView.presentScene(pitchCurrentChart)
                GimbalSecondChartView.presentScene(pitchAngleChart)
                GimbalThirdChartView.presentScene(pitchVelocityChart)
            }
        } else if (MotorSelector.selectedItem == MotorSelector.item(at: 2)) {  // LOADER
            
        }
        
    }
    
    @IBOutlet weak var RevealTime: NSTextField!
    @IBAction func SetTime(_ sender: Any) {
        if(isPureFloat(string: RevealTime.stringValue)) {
            if let revealTime = Int(RevealTime.stringValue) {
                
                yawAngleChart.time_reveal = revealTime * 1000
                yawCurrentChart.time_reveal = revealTime * 1000
                yawVelocityChart.time_reveal = revealTime * 1000
                
                pitchAngleChart.time_reveal = revealTime * 1000
                pitchCurrentChart.time_reveal = revealTime * 1000
                pitchVelocityChart.time_reveal = revealTime * 1000
            }
        }
    }
    
    struct PIDParams_t {
        var kp: Float
        var ki: Float
        var kd: Float
        var i_limit: Float
        var out_limit: Float
    }
    /***--------------------Serial Config-----------------------***/
    @objc let serialPortManager = ORSSerialPortManager.shared()
    @objc dynamic var shouldAddLineEnding = false
    @objc dynamic var serialPort: ORSSerialPort? {
        didSet {
            oldValue?.close()
            oldValue?.delegate = nil
            serialPort?.delegate = self
            serialPort?.baudRate = 115200
            serialPort?.parity = .none
            serialPort?.numberOfStopBits = 1
            serialPort?.usesRTSCTSFlowControl = false
        }
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        self.ConnectButton.title = "Disconnect"
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        self.ConnectButton.title = "Connect"
    }
    
    lazy var GimbalRXString: String = ""
    // serial port recieve action (In a loop)
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if (TabViews.selectedTabViewItem == TabViews.tabViewItem(at: 0)) { // Current view is at Terminal
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                self.ShellView.textStorage?.mutableString.append(string as String)
                self.ShellView.needsDisplay = true
            }
            self.ShellView.scrollToEndOfDocument(self.ShellView)
        } else if(TabViews.selectedTabViewItem == TabViews.tabViewItem(at: 1)) {
            if let rawline = getrawline(data: data) {
                var dividedData = rawline.split(separator: ",")
                var isValidData = true
                var index = 1
                
                // Check Data Validation
                if(dividedData.count != 8) {
                    isValidData = false
                }
                while (index < dividedData.count - 1 && isValidData) {
                    if(index < 2 || index > 5) {
                        isValidData = isPureInt(string: String(dividedData[index]))
                    } else {
                        isValidData = isPureFloat(string: String(dividedData[index]))
                    }
                    index += 1
                }
                // Add data to plot
                if (isValidData) {
                    if(dividedData[0] == "!gy") {
                        yawVelocityChart.AddData(RealData_: Float(dividedData[4])!, TargetData_: Float(dividedData[5])!, Time_: Int(dividedData[1])!)
                        yawAngleChart.AddData(RealData_: Float(dividedData[2])!, TargetData_: Float(dividedData[3])!, Time_: Int(dividedData[1])!)
                        yawCurrentChart.AddData(RealData_: Float(dividedData[6])!, TargetData_: Float(dividedData[7])!, Time_: Int(dividedData[1])!)
                    } else if (dividedData[0] == "!gp") {
                        pitchVelocityChart.AddData(RealData_: Float(dividedData[4])!, TargetData_: Float(dividedData[5])!, Time_: Int(dividedData[1])!)
                        pitchAngleChart.AddData(RealData_: Float(dividedData[2])!, TargetData_: Float(dividedData[3])!, Time_: Int(dividedData[1])!)
                        pitchCurrentChart.AddData(RealData_: Float(dividedData[6])!, TargetData_: Float(dividedData[7])!, Time_: Int(dividedData[1])!)
                    }
                }
            }
            // This is only for test
            time += 100
            testdata = Float(time/100 % 100)
            // TODO: Add feedback data reveal here

        }
    }
    
    // Raw Data process methods
    lazy var OverFlowCount = 0
    func getrawline(data: Data) -> String? {
        if(!GimbalRXString.contains("\r\n")) {
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
                GimbalRXString += String(string)
                OverFlowCount += 1
                if(OverFlowCount>20) {
                    GimbalRXString = ""
                }
                return nil
            }
        } else {
            OverFlowCount = 0
            if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
                GimbalRXString += String(string)
            }
            if let range: Range = GimbalRXString.range(of: "\r\n") {
                let endLineFrontLocation = GimbalRXString.distance(from: GimbalRXString.startIndex, to: range.lowerBound)
                let endLineBackLocation = GimbalRXString.distance(from: range.upperBound, to: GimbalRXString.endIndex)
                let returnedString = String(GimbalRXString.prefix(endLineFrontLocation))
                GimbalRXString = String(GimbalRXString.suffix(endLineBackLocation))
                return returnedString
            }
        }
        return nil
    }
    // Data Validation
    func isPureFloat(string: String) -> Bool {
        
        let scan: Scanner = Scanner(string: string)
        
        var val:Float = 0
        
        return scan.scanFloat(&val) && scan.isAtEnd
        
    }
    
    func isPureInt(string: String) -> Bool {
        
        let scan: Scanner = Scanner(string: string)
        
        var val:Int = 0
        
        return scan.scanInt(&val) && scan.isAtEnd
        
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.ConnectButton.title = "Connect"
    }
}
