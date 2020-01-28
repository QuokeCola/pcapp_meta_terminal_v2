//
//  MainController.swift
//  Terminal
//
//  Created by 钱晨 on 2020/1/28.
//  Copyright © 2020年 钱晨. All rights reserved.
//

import Cocoa
import ORSSerial

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
            print(port.isOpen)
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
    }
    
    @IBAction func GimbalBtnClk(_ sender: Any) {
        TerminalBackGround.material = NSVisualEffectView.Material.ultraDark
        GimbalBackGround.material = NSVisualEffectView.Material.dark
        ChassisBackGround.material = NSVisualEffectView.Material.ultraDark
        TabViews.selectTabViewItem(at: 1)
    }
    
    @IBAction func ChassisBtnClk(_ sender: Any) {
        TerminalBackGround.material = NSVisualEffectView.Material.ultraDark
        GimbalBackGround.material = NSVisualEffectView.Material.ultraDark
        ChassisBackGround.material = NSVisualEffectView.Material.dark
        TabViews.selectTabViewItem(at: 2)
    }
    
    /***--------------------Terminal Interface-----------------------***/
    
    @IBAction func ShellClearBtnClk(_ sender: Any) {
        ShellView.string = ""
    }
    
    @IBAction func HelloBtnClk(_ sender: Any) {
        if let port = self.serialPort {
            let command = "hello\n\r".data(using: String.Encoding.ascii)!
            let request = ORSSerialRequest(dataToSend: command, userInfo: nil, timeoutInterval: 0.5, responseDescriptor: nil)
            port.send(request)
        }
    }
    @IBOutlet var ShellView: NSTextView!
    

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
            serialPort?.usesRTSCTSFlowControl = true
        }
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        self.ConnectButton.title = "Disconnect"
    }
    
    func serialPortWasClosed(_ serialPort: ORSSerialPort) {
        self.ConnectButton.title = "Connect"
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceiveResponse responseData: Data, to request: ORSSerialRequest) {
        if let string = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue) {
            print(string as String)
            self.ShellView.textStorage?.mutableString.append(string as String)
            self.ShellView.needsDisplay = true
        }
    }
    
    func serialPort(_ serialPort: ORSSerialPort, requestDidTimeout request: ORSSerialRequest) {
        print("Command timed out!")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            print(string as String)
            self.ShellView.textStorage?.mutableString.append(string as String)
            self.ShellView.needsDisplay = true
        }
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
        self.ConnectButton.title = "Connect"
    }
}
