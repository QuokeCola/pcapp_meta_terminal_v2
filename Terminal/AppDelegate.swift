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
    @IBOutlet weak var window: NSWindow!
    /***--------------------Initialzie-----------------------***/
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let oldFrame = window.frame
        let newFrameSize = NSSize(width: 840, height: 740)
        window.setFrame(NSRect(x: oldFrame.origin.x, y: oldFrame.origin.y + oldFrame.size.height - newFrameSize.height, width: newFrameSize.width, height: newFrameSize.height), display: true)
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag{
            window.makeKeyAndOrderFront(self)
        }
        return true
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
        
        ChassisFLView.isPaused = true
        ChassisFRView.isPaused = true
        ChassisRLView.isPaused = true
        ChassisRRView.isPaused = true
        
        if let port = self.serialPort {
            let command = "g_enable_fb 0 0\r".data(using: String.Encoding.ascii)!
            port.send(command)
        }
        
        let oldFrame = window.frame
        let newFrameSize = NSSize(width: 840, height: 740)
        window.setFrame(NSRect(x: oldFrame.origin.x, y: oldFrame.origin.y + oldFrame.size.height - newFrameSize.height, width: newFrameSize.width, height: newFrameSize.height), display: true, animate: true)
        window.minSize = NSSize(width: 840, height: 740)
        window.maxSize = NSSize(width: 840, height: 740)
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
        
        let oldFrame = window.frame
        let newFrameSize = NSSize(width: 1175, height: 720)
        window.setFrame(NSRect(x: oldFrame.origin.x, y: oldFrame.origin.y + oldFrame.size.height - newFrameSize.height, width: newFrameSize.width, height: newFrameSize.height), display: true, animate: true)
        window.minSize = NSSize(width: 1175, height: 720)
        window.maxSize = NSSize(width: 1700, height: 1500)
        // Start the Gimbal Chart View.
        GimbalMainChartView.isPaused = false
        GimbalSecondChartView.isPaused = false
        GimbalThirdChartView.isPaused = false
        
        ChassisFLView.isPaused = true
        ChassisFRView.isPaused = true
        ChassisRLView.isPaused = true
        ChassisRRView.isPaused = true
        
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
        
        ChassisFLView.presentScene(ChassisFLChart)
        ChassisFRView.presentScene(ChassisFRChart)
        ChassisRLView.presentScene(ChassisRLChart)
        ChassisRRView.presentScene(ChassisRRChart)
        
        ChassisFLView.isPaused = false
        ChassisFRView.isPaused = false
        ChassisRLView.isPaused = false
        ChassisRRView.isPaused = false
        
        let oldFrame = window.frame
        let newFrameSize = NSSize(width: 1440, height: 770)
        window.setFrame(NSRect(x: oldFrame.origin.x, y: oldFrame.origin.y + oldFrame.size.height - newFrameSize.height, width: newFrameSize.width, height: newFrameSize.height), display: true, animate: true)
        window.minSize = NSSize(width: 1440, height: 770)
        window.maxSize = NSSize(width: 1700, height: 1500)
        
        ChassisFLChart.size = ChassisFLView.bounds.size
        ChassisFRChart.size = ChassisFRView.bounds.size
        ChassisRLChart.size = ChassisRLView.bounds.size
        ChassisRRChart.size = ChassisRRView.bounds.size
        
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
    
    @IBOutlet weak var GimbalRevealTime: NSTextField!
    @IBAction func GimbalSetRevealTime(_ sender: Any) {
        if(isPureFloat(string: GimbalRevealTime.stringValue)) {
            if let revealTime = Int(GimbalRevealTime.stringValue) {
                
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
    
    @IBOutlet weak var GimbalAddTargetButton: NSButton!
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
    var ChassisFRRunningError = [Float]()
    var ChassisFLRunningError = [Float]()
    var ChassisRLRunningError = [Float]()
    var ChassisRRRunningError = [Float]()
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
                GimbalTargetTime.isEnabled = true
                GimbalTargetContent.isEnabled = true
                MotorSelector.isEnabled = true
                PIDSelector.isEnabled = true
                GimbalPIDSetButton.isEnabled = true
                GimbalkpTextField.isEnabled = true
                GimbalkiTextField.isEnabled = true
                GimbalkdTextField.isEnabled = true
                Gimbali_limitTextField.isEnabled = true
                Gimbalout_limitTestField.isEnabled = true
                GimbalAddTargetButton.isEnabled = true
                GimbalRunBtn.isEnabled = true
                GimbalCurrentRunningTest?.RunStatus = .RunFinished
                
                GimbalCurrentRunningTest?.Result_AvgDiff = AvgDiff(Data: GimbalCurrentRunningErrorData)
                GimbalCurrentRunningTest?.Result_StdDiff = StdDev(Data: GimbalCurrentRunningErrorData)
                GimbalDataEvaluateView.addData(DataItem: PIDnEvaluateTableView.PIDnEvalData_t(pidparam: GimbalCurrentRunningTest!.PIDParam, StandardDifference: (GimbalCurrentRunningTest?.Result_StdDiff)!, AverageDifference: (GimbalCurrentRunningTest?.Result_AvgDiff)!))
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
                    GimbalTargetTime.isEnabled = false
                    GimbalTargetContent.isEnabled = false
                    GimbalPIDSetButton.isEnabled = false
                    GimbalkpTextField.isEnabled = false
                    GimbalkiTextField.isEnabled = false
                    GimbalkdTextField.isEnabled = false
                    Gimbali_limitTextField.isEnabled = false
                    Gimbalout_limitTestField.isEnabled = false
                    GimbalAddTargetButton.isEnabled = false
                }
            } else if MotorSelector.selectedItem == MotorSelector.item(at: 1) {
                if let port = serialPort {
                    let command = "g_enable 0 1\r\n".data(using: String.Encoding.utf8)!
                    port.send(command)
                    GimbalMotorEnableButton.state = .on
                    GimbalRunBtn.isEnabled = false
                    GimbalTargetTime.isEnabled = false
                    GimbalTargetContent.isEnabled = false
                    GimbalPIDSetButton.isEnabled = false
                    GimbalkpTextField.isEnabled = false
                    GimbalkiTextField.isEnabled = false
                    GimbalkdTextField.isEnabled = false
                    Gimbali_limitTextField.isEnabled = false
                    Gimbalout_limitTestField.isEnabled = false
                    GimbalAddTargetButton.isEnabled = false
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
    @IBOutlet weak var DisplayModeSelector: NSPopUpButton!
    
    @IBAction func DisplayModeSelect(_ sender: Any) {
        if(DisplayModeSelector.selectedItem == DisplayModeSelector.item(at: 0)) {
            DisplayMode = .Continuous
        } else {
            DisplayMode = .Auto
        }
    }
    @IBOutlet weak var ProgressBar: NSProgressIndicator!
    enum displayMode {
        case Continuous
        case Auto
    }
    @IBAction func GimbalDataAnalysisClk(_ sender: Any) {
        if (GimbalDataEvaluateView.returnData().count > 0 && GimbalDataEvaluateView.selectedRow >= 0 && GimbalDataEvaluateView.selectedRow < GimbalDataEvaluateView.returnData().count) {
            let data = GimbalDataEvaluateView.returnData()[GimbalDataEvaluateView.selectedRow]
            GimbalkpTextField.stringValue = String(format: "%.2f", data.pidparam.kp)
            GimbalkiTextField.stringValue = String(format: "%.2f", data.pidparam.ki)
            GimbalkdTextField.stringValue = String(format: "%.2f", data.pidparam.kd)
            Gimbali_limitTextField.stringValue = String(format: "%.2f", data.pidparam.i_limit)
            Gimbalout_limitTestField.stringValue = String(format: "%.2f", data.pidparam.out_limit)
        }
        
        
    }
    var DisplayMode: displayMode = .Continuous
    var GimbalCurrentRunningErrorData = [Float]()
    
    /***--------------------Chassis Interface--------------------***/
    @IBOutlet weak var ChassisFLView: SKView!
    @IBOutlet weak var ChassisFRView: SKView!
    @IBOutlet weak var ChassisRLView: SKView!
    @IBOutlet weak var ChassisRRView: SKView!
    
    lazy var ChassisFLChart = PlotChart(size: ChassisFLView.bounds.size)
    lazy var ChassisFRChart = PlotChart(size: ChassisFRView.bounds.size)
    lazy var ChassisRLChart = PlotChart(size: ChassisRLView.bounds.size)
    lazy var ChassisRRChart = PlotChart(size: ChassisRRView.bounds.size)
    
    struct chassisRunningTrial {
        var PIDParam: PIDParams_t
        var targetVx: Float
        var targetVy: Float
        var targetW: Float
        var startTime: Int
        var MaintainTime : Int
        enum runStatus {
            case WaitForRunning
            case isRunning
            case FinishRunning
            case NotStartRunning
        }
        var RunStatus: runStatus
        
        var FLResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t
        var FRResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t
        var RLResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t
        var RRResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t
    }
    
    var ChassisRunningTrial : chassisRunningTrial? = nil
    @IBOutlet weak var ChassisTargetVx: NSTextField!
    @IBAction func ChassisVxEnterPressed(_ sender: Any) {
        self.ChassisTargetVy.becomeFirstResponder()
    }
    @IBOutlet weak var ChassisTargetVy: NSTextField!
    @IBAction func ChassisVyEnterPressed(_ sender: Any) {
        self.ChassisTargetOmega.becomeFirstResponder()
    }
    @IBOutlet weak var ChassisTargetOmega: NSTextField!
    @IBAction func ChassisWEnterPressed(_ sender: Any) {
        self.ChassisRunTime.becomeFirstResponder()
    }
    @IBOutlet weak var ChassisRunTime: NSTextField!
    @IBAction func ChassisRuntimeEnterPressed(_ sender: Any) {
        self.ChassisTargetVx.becomeFirstResponder()
    }
    @IBOutlet weak var ChassisReverseButton: NSButton!
    @IBAction func ChassisReversBtnClk(_ sender: Any) {
        if let Vx = Float(ChassisTargetVx.stringValue) {
            ChassisTargetVx.stringValue = String(format:"%.2f", -Vx)
        }
        if let Vy = Float(ChassisTargetVy.stringValue) {
            ChassisTargetVy.stringValue = String(format: "%.2f", -Vy)
        }
        if let w  = Float(ChassisTargetOmega.stringValue) {
            ChassisTargetOmega.stringValue = String(format: "%.2f", -w)
        }
    }
    @IBOutlet weak var ChassisRunButton: NSButton!
    @IBAction func ChassisRunBtnClk(_ sender: Any) {
        if(ChassisRunningTrial == nil) {
            statusInfo.stringValue = "PID Params not set"
        } else {
            guard
                let Vx = Float(ChassisTargetVx.stringValue),
                let Vy = Float(ChassisTargetVy.stringValue),
                let w  = Float(ChassisTargetOmega.stringValue),
                let Time = Float(ChassisRunTime.stringValue)
                else {statusInfo.stringValue = "Invalid Target"; return}
            
            ChassisRunningTrial?.targetVx = Vx
            ChassisRunningTrial?.targetVy = Vy
            ChassisRunningTrial?.targetW  = w
            ChassisRunningTrial?.MaintainTime = Int(Time*1000)
            ChassisRunningTrial?.RunStatus = .WaitForRunning
            
            if let port = self.serialPort {
                let command = "c_set_target \(Vx) \(Vy) \(w) \(Int(Time*1000))\r\n".data(using: String.Encoding.ascii)!
                port.send(command)
            }
            self.ChassisDisableAllPanel()
        }
    }
    @IBOutlet weak var ChassiskpTextField: NSTextField!
    @IBAction func ChassiskpTextFieldEnterPressed(_ sender: Any) {
        self.ChassiskiTextField.becomeFirstResponder()
    }
    @IBOutlet weak var ChassiskiTextField: NSTextField!
    @IBAction func ChassiskiTextFieldEnterPressed(_ sender: Any) {
        self.ChassiskdTextField.becomeFirstResponder()
    }
    @IBOutlet weak var ChassiskdTextField: NSTextField!
    @IBAction func ChassiskdTextFieldEnterPressed(_ sender: Any) {
        self.Chassisi_limitTextField.becomeFirstResponder()
    }
    @IBOutlet weak var Chassisi_limitTextField: NSTextField!
    @IBAction func Chassisi_limitTextFieldEnterPressed(_ sender: Any) {
        self.Chassisout_limitTextField.becomeFirstResponder()
    }
    @IBOutlet weak var Chassisout_limitTextField: NSTextField!
    @IBAction func Chassisout_limitTextFieldEnterPressed(_ sender: Any) {
        self.ChassisPIDSetBtnClk(sender)
        self.ChassiskpTextField.becomeFirstResponder()
    }
    @IBAction func ChassisPIDSetBtnClk(_ sender: Any) {
        guard
            let kp = Float(ChassiskpTextField.stringValue),
            let ki = Float(ChassiskiTextField.stringValue),
            let kd = Float(ChassiskdTextField.stringValue),
            let i_limit = Float(Chassisi_limitTextField.stringValue),
            let out_limit = Float(Chassisout_limitTextField.stringValue)
            else {statusInfo.stringValue = "Invalid Value"; return}
        let PIDParam = PIDParams_t(kp: kp, ki: ki, kd: kd, i_limit: i_limit, out_limit: out_limit)
        
        if let port = self.serialPort {
            let command = "c_set_params \(kp) \(ki) \(kd) \(i_limit) \(out_limit)\r\n".data(using: String.Encoding.ascii)!
            port.send(command)
        }
        
        if(ChassisRunningTrial == nil) {
            ChassisRunningTrial = chassisRunningTrial(PIDParam: PIDParam, targetVx: 0.0, targetVy: 0.0, targetW: 0.0, startTime: 0, MaintainTime: 0, RunStatus: .NotStartRunning, FLResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0), FRResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0), RLResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0), RRResult: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0))
        } else if (ChassisRunningTrial?.RunStatus == .NotStartRunning) {
            // Add the PID Param that has not Runned
            ChassisDataAnalysisView.addData(Item: ChassisPIDnEvaluateTableView.PIDnEvalData_t(pidparam: (ChassisRunningTrial?.PIDParam)!, FLAnalysis: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0), FRAnalysis: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0), RLAnalysis: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0), RRAnalysis: ChassisPIDnEvaluateTableView.MotorAnalysis_t(StdDiff: -1.0, AvgDiff: -1.0)))
            ChassisRunningTrial?.PIDParam = PIDParam
        } else {
            ChassisRunningTrial?.PIDParam = PIDParam
            ChassisRunningTrial?.RunStatus = .NotStartRunning
        }
    }
    var ChassisRevealTime = 20.0
    enum chassisRevealMode {
        case Continuous
        case Auto
    }
    var ChassisRevealMode = chassisRevealMode.Continuous
    @IBOutlet weak var ChassisModeSelector: NSPopUpButton!
    @IBAction func ChassisModeSelectorSet(_ sender: Any) {
        if ChassisModeSelector.selectedItem == ChassisModeSelector.item(at: 0) {
            ChassisRevealMode = .Continuous
        } else {
            ChassisRevealMode = .Auto
        }
    }
    @IBOutlet weak var ChassisRevealTimeTextField: NSTextField!
    @IBAction func ChassisRevealTimeSet(_ sender: Any) {
        if isPureFloat(string: ChassisRevealTimeTextField.stringValue) {
            if let timereveal = Int(ChassisRevealTimeTextField.stringValue) {
                ChassisFLChart.time_reveal = timereveal * 1000
                ChassisFRChart.time_reveal = timereveal * 1000
                ChassisRLChart.time_reveal = timereveal * 1000
                ChassisRRChart.time_reveal = timereveal * 1000
            }
        }
    }
    
    func ChassisDisableAllPanel(){
        ChassisTargetVx.isEnabled = false
        ChassisTargetVy.isEnabled = false
        ChassisTargetOmega.isEnabled = false
        ChassisRunTime.isEnabled = false
        ChassisRunButton.isEnabled = false
    }
    func ChassisEnableAllPanel(){
        ChassisTargetVx.isEnabled = true
        ChassisTargetVy.isEnabled = true
        ChassisTargetOmega.isEnabled = true
        ChassisRunTime.isEnabled = true
        ChassisRunButton.isEnabled = true
    }
    @IBAction func ChassisPIDnEvaluateViewClk(_ sender: Any) {
        var PIDParam = ChassisDataAnalysisView.getSelectedRowPID()
        ChassiskpTextField.stringValue = String(format: "%.2f", PIDParam.kp)
        ChassiskiTextField.stringValue = String(format: "%.2f", PIDParam.ki)
        ChassiskdTextField.stringValue = String(format: "%.2f", PIDParam.kd)
        Chassisi_limitTextField.stringValue = String(format: "%.2f", PIDParam.i_limit)
        Chassisout_limitTextField.stringValue = String(format: "%.2f", PIDParam.out_limit)
    }
    
    @IBOutlet weak var ChassisDataAnalysisView: ChassisPIDnEvaluateTableView!
    
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
                } else {
                    print(dividedData[0])
                    if(dividedData[0] != "!gy" && dividedData[0] != "!gp") {
                        isValidData = false
                    }
                    print(isValidData)
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
                    if ((DisplayMode == .Continuous)||((DisplayMode == .Auto) && (GimbalCurrentRunningTest?.RunStatus == .isRunning))) {
                        if(dividedData[0] == "!gy") {
                            if (GimbalCurrentRunningTest?.RunStatus == .isRunning) {
                                switch targetTableView.dataIdentifier {
                                case .YAWA:
                                    GimbalCurrentRunningErrorData.append(Float(dividedData[2])!-Float(dividedData[3])!)
                                case .YAWV:
                                    GimbalCurrentRunningErrorData.append(Float(dividedData[4])!-Float(dividedData[5])!)
                                case .PITCHV:
                                    ()
                                case .PITCHA:
                                    ()
                                }
                            }
                            yawVelocityChart.AddData(RealData_: Float(dividedData[4])!, TargetData_: Float(dividedData[5])!, Time_: Int(dividedData[1])!)
                            yawAngleChart.AddData(RealData_: Float(dividedData[2])!, TargetData_: Float(dividedData[3])!, Time_: Int(dividedData[1])!)
                            yawCurrentChart.AddData(RealData_: Float(dividedData[6])!, TargetData_: Float(dividedData[7])!, Time_: Int(dividedData[1])!)
                        } else if (dividedData[0] == "!gp") {
                            if (GimbalCurrentRunningTest?.RunStatus == .isRunning) {
                                switch targetTableView.dataIdentifier {
                                case .YAWA:()
                                case .YAWV:()
                                case .PITCHA:
                                    GimbalCurrentRunningErrorData.append(Float(dividedData[2])!-Float(dividedData[3])!)
                                case .PITCHV:
                                    GimbalCurrentRunningErrorData.append(Float(dividedData[4])!-Float(dividedData[5])!)
                                }
                            }
                            pitchVelocityChart.AddData(RealData_: Float(dividedData[4])!, TargetData_: Float(dividedData[5])!, Time_: Int(dividedData[1])!)
                            pitchAngleChart.AddData(RealData_: Float(dividedData[2])!, TargetData_: Float(dividedData[3])!, Time_: Int(dividedData[1])!)
                            pitchCurrentChart.AddData(RealData_: Float(Int(dividedData[6])!), TargetData_: Float(Int(dividedData[7])!), Time_: Int(dividedData[1])!)
                        }
                    }
                    if let gimbalrunningsession = GimbalCurrentRunningTest {
                        switch gimbalrunningsession.RunStatus {
                        case .waitForRunning:
                            GimbalCurrentRunningTest?.RunStatus = .isRunning
                            GimbalCurrentRunningTest?.startTime = Int(dividedData[1])!
                            GimbalCurrentRunningTest?.target = targetTableView.returnData()
                            GimbalRunFullTime = (GimbalCurrentRunningTest?.fullTime())!
                            GimbalCurrentRunningErrorData.removeAll()
                            if(DisplayMode == .Auto) {
                                GimbalRevealTime.stringValue = String(Int(GimbalRunFullTime/1000))
                                GimbalSetRevealTime(Any?.self)
                            }
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
                                    GimbalRunningIndex += 1
                                }
                            } else if(currentTime > GimbalRunningTag) { // Finished Running
                                // Disable Motors
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
                                    
                                    // Enable GimbalView Components
                                    self.GimbalRunBtn.isEnabled = true
                                    self.GimbalMotorEnableButton.state = .off
                                    GimbalTargetTime.isEnabled = true
                                    GimbalTargetContent.isEnabled = true
                                    MotorSelector.isEnabled = true
                                    PIDSelector.isEnabled = true
                                    GimbalPIDSetButton.isEnabled = true
                                    GimbalkpTextField.isEnabled = true
                                    GimbalkiTextField.isEnabled = true
                                    GimbalkdTextField.isEnabled = true
                                    Gimbali_limitTextField.isEnabled = true
                                    Gimbalout_limitTestField.isEnabled = true
                                    GimbalAddTargetButton.isEnabled = true
                                    self.GimbalCurrentRunningTest?.RunStatus = .RunFinished
                                    
                                    // Perform result calculation
                                    GimbalCurrentRunningTest?.Result_AvgDiff = AvgDiff(Data: GimbalCurrentRunningErrorData)
                                    GimbalCurrentRunningTest?.Result_StdDiff = StdDev(Data: GimbalCurrentRunningErrorData)
                                    GimbalDataEvaluateView.addData(DataItem: PIDnEvaluateTableView.PIDnEvalData_t(pidparam: GimbalCurrentRunningTest!.PIDParam, StandardDifference: (GimbalCurrentRunningTest?.Result_StdDiff)!, AverageDifference: (GimbalCurrentRunningTest?.Result_AvgDiff)!))
                                }
                            }
                        default: ()
                        }
                    }
                }
            } // End of Gimbal
        } else if TabViews.selectedTabViewItem == TabViews.tabViewItem(at: 2) { // Chassis View
            if let rawline = getrawline(data: data) {
                var dividedData = rawline.split(separator: ",")
                var isValidData = true
                var index = 1
                if rawline.contains("!cps") {
                    statusInfo.stringValue = "PID Params Set"
                }
                // Check Data Validation
                if(dividedData.count != 10) {
                    isValidData = false
                } else {
                    if(dividedData[0] != "!cv") {
                        isValidData = false
                    }
                }

                while (index < dividedData.count && isValidData) {
                    if(index < 2) {
                        isValidData = isPureInt(string: String(dividedData[index]))
                    } else {
                        isValidData = isPureFloat(string: String(dividedData[index]))
                    }
                    if (Float(dividedData[index]) == nil) {
                        isValidData = false
                    }
                    index += 1
                }
                if(isValidData) {
                    print(rawline)
                    let Time = Int(dividedData[1])!
                    if (ChassisRevealMode == .Continuous || (ChassisRevealMode == .Auto && ChassisRunningTrial?.RunStatus == .isRunning)) {
                        ChassisFLChart.AddData(RealData_: Float(dividedData[4])!, TargetData_: Float(dividedData[5])!, Time_: Time)
                        ChassisFRChart.AddData(RealData_: Float(dividedData[2])!, TargetData_: Float(dividedData[3])!, Time_: Time)
                        ChassisRLChart.AddData(RealData_: Float(dividedData[6])!, TargetData_: Float(dividedData[7])!, Time_: Time)
                        ChassisRRChart.AddData(RealData_: Float(dividedData[8])!, TargetData_: Float(dividedData[9])!, Time_: Time)
                    }
                   
                    
                    if let chassisRunningSession = ChassisRunningTrial {
                        switch chassisRunningSession.RunStatus {
                        case .WaitForRunning:
                            ChassisRunningTrial?.startTime = Int(dividedData[1])!
                            ChassisRunningTrial?.RunStatus = .isRunning
                            ChassisRLRunningError.removeAll()
                            ChassisRRRunningError.removeAll()
                            ChassisFLRunningError.removeAll()
                            ChassisFRRunningError.removeAll()
                            if ChassisRevealMode == .Auto {
                                ChassisRevealTimeTextField.stringValue = String(Int((ChassisRunningTrial?.MaintainTime)!)/1000)
                                ChassisRevealTimeSet(Any?.self)
                            }
                        case .isRunning:
                            ProgressBar.doubleValue = Double(Time-chassisRunningSession.startTime)/Double(chassisRunningSession.MaintainTime) * 100.0
                            if Time < chassisRunningSession.startTime + chassisRunningSession.MaintainTime {
                                ChassisFRRunningError.append(Float(dividedData[2])!-Float(dividedData[3])!)
                                ChassisFLRunningError.append(Float(dividedData[4])!-Float(dividedData[5])!)
                                ChassisRLRunningError.append(Float(dividedData[6])!-Float(dividedData[7])!)
                                ChassisRRRunningError.append(Float(dividedData[8])!-Float(dividedData[9])!)
                            } else {
                                self.ChassisEnableAllPanel()
                                ChassisRunningTrial?.FRResult.AvgDiff = AvgDiff(Data: ChassisFRRunningError)
                                ChassisRunningTrial?.FRResult.StdDiff = StdDev(Data: ChassisFRRunningError)
                                ChassisRunningTrial?.FLResult.AvgDiff = AvgDiff(Data: ChassisFLRunningError)
                                ChassisRunningTrial?.FLResult.StdDiff = StdDev(Data: ChassisFLRunningError)
                                ChassisRunningTrial?.RLResult.AvgDiff = AvgDiff(Data: ChassisRLRunningError)
                                ChassisRunningTrial?.RLResult.StdDiff = StdDev(Data: ChassisRLRunningError)
                                ChassisRunningTrial?.RRResult.AvgDiff = AvgDiff(Data: ChassisRRRunningError)
                                ChassisRunningTrial?.RRResult.StdDiff = StdDev(Data: ChassisRRRunningError)
                                ChassisDataAnalysisView.addData(Item: ChassisPIDnEvaluateTableView.PIDnEvalData_t(pidparam: (ChassisRunningTrial?.PIDParam)!, FLAnalysis: (ChassisRunningTrial?.FLResult)!, FRAnalysis: (ChassisRunningTrial?.FRResult)!, RLAnalysis: (ChassisRunningTrial?.RLResult)!, RRAnalysis: (ChassisRunningTrial?.RRResult)!))
                                ChassisRunningTrial?.RunStatus = .FinishRunning
                            }
                        case .FinishRunning:()
                        case .NotStartRunning:()
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
    
    // Data Process Method
    func StdDev(Data: Array<Float>) -> Float{
        if(Data.count == 0) {
            return 0.0
        }
        var squarsum: Float = 0.0
        for item in Data{
            squarsum += Float(pow(Double(item), 2.0))
        }
        return squarsum/Float(Data.count)
    }
    func AvgDiff(Data: Array<Float>) -> Float {
        if(Data.count == 0) {
            return 0.0
        }
        var sum: Float = 0.0
        for item in Data {
            sum += item
        }
        return sum/Float(Data.count)
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.ConnectButton.title = "Connect"
    }
}

