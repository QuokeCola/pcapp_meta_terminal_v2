//
//  AppDelegate.swift
//  Terminal
//
//  Created by 钱晨 on 2020/1/28.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa
import ORSSerial
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, ORSSerialPortDelegate {
    @IBOutlet weak var window: MainController!
    /***--------------------Initialzie-----------------------***/
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
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
    @IBOutlet weak var statusInfo: NSTextField!
    
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
    
    var yawTargetAngleData = [GimbalTargetTableView.targetData_t]()
    var yawTargetVelocityData = [GimbalTargetTableView.targetData_t]()
    var pitchTargetAngleData = [GimbalTargetTableView.targetData_t]()
    var pitchTargetVelocityData = [GimbalTargetTableView.targetData_t]()
    
    func selectGimbalViews() {
        if (MotorSelector.selectedItem == MotorSelector.item(at: 0)) {  // YAW
            if (PIDSelector.selectedItem == PIDSelector.item(at: 0)) {  // Main: Velocity
                
                yawVelocityChart.size = self.GimbalMainChartView.bounds.size
                yawAngleChart.size = self.GimbalSecondChartView.bounds.size
                yawCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(yawVelocityChart)
                GimbalSecondChartView.presentScene(yawAngleChart)
                GimbalThirdChartView.presentScene(yawCurrentChart)
                
                self.setDataSource(Source: .YAWV)
                
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 1)) {  // Main: Angle
                
                yawVelocityChart.size = self.GimbalSecondChartView.bounds.size
                yawAngleChart.size = self.GimbalMainChartView.bounds.size
                yawCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(yawAngleChart)
                GimbalSecondChartView.presentScene(yawVelocityChart)
                GimbalThirdChartView.presentScene(yawCurrentChart)
                
                self.setDataSource(Source: .YAWA)
                
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 2)) {   // Main: Current
                yawVelocityChart.size = self.GimbalThirdChartView.bounds.size
                yawAngleChart.size = self.GimbalSecondChartView.bounds.size
                yawCurrentChart.size = self.GimbalMainChartView.bounds.size
                
                GimbalMainChartView.presentScene(yawCurrentChart)
                GimbalSecondChartView.presentScene(yawAngleChart)
                GimbalThirdChartView.presentScene(yawVelocityChart)
            }
        } else if (MotorSelector.selectedItem == MotorSelector.item(at: 1)) { // PITCH
            if (PIDSelector.selectedItem == PIDSelector.item(at: 0)) {  // Main: Velocity
                
                pitchVelocityChart.size = self.GimbalMainChartView.bounds.size
                pitchAngleChart.size = self.GimbalSecondChartView.bounds.size
                pitchCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(pitchVelocityChart)
                GimbalSecondChartView.presentScene(pitchAngleChart)
                GimbalThirdChartView.presentScene(pitchCurrentChart)
                
                self.setDataSource(Source: .PITCHV)
                
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 1)) {   // Main: Angle
                
                pitchVelocityChart.size = self.GimbalSecondChartView.bounds.size
                pitchAngleChart.size = self.GimbalMainChartView.bounds.size
                pitchCurrentChart.size = self.GimbalThirdChartView.bounds.size
                
                GimbalMainChartView.presentScene(pitchAngleChart)
                GimbalSecondChartView.presentScene(pitchVelocityChart)
                GimbalThirdChartView.presentScene(pitchCurrentChart)
                
                self.setDataSource(Source: .PITCHA)
                
            } else if (PIDSelector.selectedItem == PIDSelector.item(at: 2)) {   // Main: Current
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
    
    @IBOutlet weak var GimbalTargetContent: NSTextField!
    @IBOutlet weak var GimbalTargetTime: NSTextField!
    
    @IBOutlet weak var targetTableView: GimbalTargetTableView!
    @IBOutlet weak var GimbalDataEvaluateView: PIDnEvaluateTableView!
    
    @IBAction func addTargetBtnClk(_ sender: Any) {
        if let target = Float(GimbalTargetContent.stringValue) {
            if let maintaintime = Float(GimbalTargetTime.stringValue) {
                targetTableView.addData(DataItem: GimbalTargetTableView.targetData_t(Target: target, MaintainTime: maintaintime))
            } else {
                statusInfo.stringValue = "Value illegal"
            }
        } else {
            statusInfo.stringValue = "Value illegal"
        }
    }
    
    func updateTargetData() {
        if(MotorSelector.selectedItem == MotorSelector.item(at: 0)) {    // YAW
            if(PIDSelector.selectedItem == PIDSelector.item(at: 0)) {   // Velocity
                self.setDataSource(Source: .YAWV)
                yawTargetVelocityData = targetTableView.returnData()
            } else if(PIDSelector.selectedItem == PIDSelector.item(at: 1)) { // Angle
                self.setDataSource(Source: .YAWA)
                yawTargetAngleData = targetTableView.returnData()
            }
        } else if(MotorSelector.selectedItem == MotorSelector.item(at: 1)) {    // PITCH
            if(PIDSelector.selectedItem == PIDSelector.item(at: 0)) {   // Velocity
                self.setDataSource(Source: .PITCHV)
                pitchTargetVelocityData = targetTableView.returnData()
            } else if(PIDSelector.selectedItem == PIDSelector.item(at: 1)) { // Angle
                self.setDataSource(Source: .PITCHA)
                pitchTargetAngleData = targetTableView.returnData()
            }
        } else if(MotorSelector.selectedItem == MotorSelector.item(at: 2)) {    //Loader
            
        }
    }
    
    func setDataSource(Source: GimbalTargetTableView.DataIdentifier_t) {
        targetTableView.switchDataSource(identifier: Source)
        switch Source {
        case .YAWV:
            GimbalDataEvaluateView.switchDataSource(identifier: .YAWV)
        case .YAWA:
            GimbalDataEvaluateView.switchDataSource(identifier: .YAWA)
        case .PITCHV:
            GimbalDataEvaluateView.switchDataSource(identifier: .PITCHV)
        case .PITCHA:
            GimbalDataEvaluateView.switchDataSource(identifier: .PITCHA)
        }
    }
    
    struct PIDParams_t {
        var kp: Float
        var ki: Float
        var kd: Float
        var i_limit: Float
        var out_limit: Float
    }
    
    struct RunningTest {
        var target = [GimbalTargetTableView.targetData_t]()
        var PIDParam : PIDParams_t
        var Result_AvgDiff : Float
        var Result_StdDiff : Float
        enum runStatus {
            case notStartRunning
            case waitForRunning
            case isRunning
            case RunFinished
        }
        var RunStatus: runStatus
        var startTime: Int
        func fullTime() -> Int {
            var fulltime = 0
            for targetItem in target{
                fulltime += Int(targetItem.MaintainTime*1000)
            }
            return fulltime
        }
    }
    var GimbalCurrentRunningTest: RunningTest? = nil
    var GimbalRunningTag = 0
    var GimbalRunningIndex = 1
    @IBAction func GimbalTargetTextFieldEnterPressed(_ sender: Any) {
        self.GimbalTargetTime.becomeFirstResponder()
    }
    
    @IBAction func GimbalTimeTextFieldEnterPressed(_ sender: Any) {
        addTargetBtnClk(sender)
        self.GimbalTargetContent.becomeFirstResponder()
    }
    
    @IBOutlet weak var GimbalkpTextField: NSTextField!
    @IBAction func GimbalkpTextFieldEntrPrsd(_ sender: Any) {
        self.GimbalkiTextField.becomeFirstResponder()
    }
    
    @IBOutlet weak var GimbalkiTextField: NSTextField!
    @IBAction func GimbalkiTextFieldEntrPrsd(_ sender: Any) {
        self.GimbalkdTextField.becomeFirstResponder()
    }
    
    @IBOutlet weak var GimbalkdTextField: NSTextField!
    @IBAction func GimbalkdTextFieldEntrPrsd(_ sender: Any) {
        self.Gimbali_limitTextField.becomeFirstResponder()
    }
    
    @IBOutlet weak var Gimbali_limitTextField: NSTextField!
    @IBAction func Gimbali_limitTextFieldEntrPrsd(_ sender: Any) {
        self.Gimbalout_limitTestField.becomeFirstResponder()
    }
    
    @IBOutlet weak var GimbalPIDSetButton: NSButton!
    @IBOutlet weak var Gimbalout_limitTestField: NSTextField!
    @IBAction func Gimbalout_limitTextFieldEntrPrsd(_ sender: Any) {
        self.GimbalkpTextField.becomeFirstResponder()
        GimbalPIDSetBtnClk(sender)
    }
    
    @IBAction func GimbalPIDSetBtnClk(_ sender: Any) {
        if let hasrunned = GimbalCurrentRunningTest?.RunStatus {
            if hasrunned == .notStartRunning {
                GimbalDataEvaluateView.addData(DataItem: PIDnEvaluateTableView.PIDnEvalData_t(pidparam: GimbalCurrentRunningTest!.PIDParam, StandardDifference: -1.0, AverageDifference: -1.0))
            }
        }
        guard
            let kp = Float(GimbalkpTextField.stringValue),
            let ki = Float(GimbalkiTextField.stringValue),
            let kd = Float(GimbalkdTextField.stringValue),
            let i_limit = Float(Gimbali_limitTextField.stringValue),
            let out_limit = Float(Gimbalout_limitTestField.stringValue)
            else {statusInfo.stringValue = "PID Value Invalid"; return}
        GimbalCurrentRunningTest = RunningTest(target: [GimbalTargetTableView.targetData_t](), PIDParam: PIDParams_t(kp: kp, ki: ki, kd: kd, i_limit: i_limit, out_limit: out_limit), Result_AvgDiff: -1.0, Result_StdDiff: -1.0, RunStatus: .notStartRunning, startTime: -1)
        if let port = serialPort {
            var string = "g_set_params "
            switch targetTableView.dataIdentifier {
            case .YAWV:
                string += "0 1 "
            case .YAWA:
                string += "0 0 "
            case .PITCHV:
                string += "1 1 "
            case .PITCHA:
                string += "1 0 "
            }
            string += (GimbalkpTextField.stringValue + " " + GimbalkiTextField.stringValue + " " + GimbalkdTextField.stringValue + " " + Gimbali_limitTextField.stringValue + " " + Gimbalout_limitTestField.stringValue + "\r\n")
            let command = string.data(using: String.Encoding.ascii)!
            port.send(command)
        }
    }
    
    @IBOutlet weak var GimbalMotorEnableButton: NSButton!
    @IBAction func MotorEnableBtnClk(_ sender: Any) {
        if GimbalMotorEnableButton.state == .off {
            if let port = serialPort {
                let command = "g_enable 0 0\r\n".data(using: String.Encoding.ascii)!
                port.send(command)
                GimbalRunBtn.isEnabled = true
                MotorSelector.isEnabled = true
                PIDSelector.isEnabled = true
                GimbalTargetTime.isEnabled = true
                GimbalTargetContent.isEnabled = true
                GimbalCurrentRunningTest?.RunStatus = .RunFinished
            }
        } else {
            GimbalMotorEnableButton.state = .off
        }
    }
    
    var GimbalRunFullTime = 100
    @IBOutlet weak var GimbalRunBtn: NSButton!
    @IBAction func GimbalRunBtnClk(_ sender: Any) {
        if (GimbalCurrentRunningTest != nil && targetTableView.returnData().count != 0) {
            GimbalCurrentRunningTest?.RunStatus = .waitForRunning
            if MotorSelector.selectedItem == MotorSelector.item(at: 0) {
                if let port = serialPort {
                    let command = "g_enable 1 0\r\n".data(using: String.Encoding.utf8)!
                    port.send(command)
                    GimbalMotorEnableButton.state = .on
                    GimbalRunBtn.isEnabled = false
                    MotorSelector.isEnabled = false
                    PIDSelector.isEnabled = false
                    ProgressBar.doubleValue = 0.0
                }
            } else if MotorSelector.selectedItem == MotorSelector.item(at: 1) {
                if let port = serialPort {
                    let command = "g_enable 0 1\r\n".data(using: String.Encoding.utf8)!
                    port.send(command)
                    GimbalMotorEnableButton.state = .on
                    GimbalRunBtn.isEnabled = false
                    GimbalTargetTime.isEnabled = false
                    GimbalTargetContent.isEnabled = false
                }
            }
        } else {
            if (GimbalCurrentRunningTest == nil) {
                statusInfo.stringValue = "PIDParam Not Set!"
            } else {
                statusInfo.stringValue = "Target Not Set!"
            }
            
        }
    }
    
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    
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
                if rawline.contains("!ps") {
                    statusInfo.stringValue = "PID Params Set"
                }
                // Check Data Validation
                if(dividedData.count != 8) {
                    isValidData = false
                }
                while (index < dividedData.count && isValidData) {
                    if(index < 2 || index > 5) {
                        isValidData = isPureInt(string: String(dividedData[index]))
                    } else {
                        isValidData = isPureFloat(string: String(dividedData[index]))
                    }
                    if (Float(dividedData[index]) == nil) {
                        isValidData = false
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
                        pitchCurrentChart.AddData(RealData_: Float(Int(dividedData[6])!), TargetData_: Float(Int(dividedData[7])!), Time_: Int(dividedData[1])!)
                    }
                    if let gimbalrunningsession = GimbalCurrentRunningTest {
                        switch gimbalrunningsession.RunStatus {
                        case .waitForRunning:
                            GimbalCurrentRunningTest?.RunStatus = .isRunning
                            GimbalCurrentRunningTest?.startTime = Int(dividedData[1])!
                            GimbalCurrentRunningTest?.target = targetTableView.returnData()
                            GimbalRunFullTime = (GimbalCurrentRunningTest?.fullTime())!
                            if let port = self.serialPort {
                                var commandString = "\r\n"
                                switch targetTableView.dataIdentifier {
                                case .YAWV:
                                    commandString = "g_set_v \(GimbalCurrentRunningTest!.target[0].Target)  0\r\n"
                                case .YAWA:
                                    commandString = "g_set_angle \(GimbalCurrentRunningTest!.target[0].Target)  0\r\n"
                                case .PITCHV:
                                    commandString = "g_set_v 0 \(GimbalCurrentRunningTest!.target[0].Target)\r\n"
                                case .PITCHA:
                                    commandString = "g_set_angle 0 \(GimbalCurrentRunningTest!.target[0].Target)\r\n"
                                }
                                let command = commandString.data(using: String.Encoding.ascii)!
                                port.send(command)
                                GimbalRunningIndex = 0
                                GimbalRunningTag = Int(dividedData[1])!
                            }
                        case .isRunning:
                            let currentTime = Int(dividedData[1])!
                            ProgressBar.doubleValue = Double(Float(currentTime - (GimbalCurrentRunningTest?.startTime)!)/Float(GimbalRunFullTime)) * 100.0
                            if (GimbalRunningIndex < (GimbalCurrentRunningTest?.target.count)!) {
                                if(currentTime > GimbalRunningTag) {
                                    GimbalRunningTag += Int(GimbalCurrentRunningTest!.target[GimbalRunningIndex].MaintainTime * 1000.0)
                                    if let port = self.serialPort {
                                        var commandString = "\r\n"
                                        switch targetTableView.dataIdentifier {
                                        case .YAWV:
                                            commandString = "g_set_v \(GimbalCurrentRunningTest!.target[GimbalRunningIndex].Target) 0\r\n"
                                        case .YAWA:
                                            commandString = "g_set_angle \(GimbalCurrentRunningTest!.target[GimbalRunningIndex].Target) 0\r\n"
                                        case .PITCHV:
                                            commandString = "g_set_v 0 \(GimbalCurrentRunningTest!.target[GimbalRunningIndex].Target)\r\n"
                                        case .PITCHA:
                                            commandString = "g_set_angle 0 \(GimbalCurrentRunningTest!.target[GimbalRunningIndex].Target)\r\n"
                                        }
                                        let command = commandString.data(using: String.Encoding.ascii)!
                                        port.send(command)
                                    }
                                    //                                    ProgressBar.increment(by: Double(1.0/Float((GimbalCurrentRunningTest?.target.count)!)*100.0))
                                    GimbalRunningIndex += 1
                                }
                            } else if(currentTime > GimbalRunningTag){
                                GimbalCurrentRunningTest?.RunStatus = .RunFinished
                                if let port = self.serialPort {
                                    var commandString = "\r\n"
                                    switch targetTableView.dataIdentifier {
                                    case .YAWV:
                                        commandString = "g_set_v 0 0\r\n"
                                    case .YAWA:
                                        commandString = "g_set_angle 0 0\r\n"
                                    case .PITCHV:
                                        commandString = "g_set_v 0 0\r\n"
                                    case .PITCHA:
                                        commandString = "g_set_angle 0 0\r\n"
                                    }
                                    let command = commandString.data(using: String.Encoding.ascii)!
                                    let command2 = "g_enable 0 0\r\n".data(using: String.Encoding.ascii)!
                                    port.send(command)
                                    port.send(command2)
                                    self.GimbalRunBtn.isEnabled = true
                                    self.GimbalMotorEnableButton.state = .off
                                    GimbalTargetTime.isEnabled = true
                                    GimbalTargetContent.isEnabled = true
                                    MotorSelector.isEnabled = true
                                    PIDSelector.isEnabled = true
                                    self.GimbalCurrentRunningTest?.RunStatus = .RunFinished
                                }
                            }
                        default: ()
                        }
                    }
                }
            }
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
                return ""
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

