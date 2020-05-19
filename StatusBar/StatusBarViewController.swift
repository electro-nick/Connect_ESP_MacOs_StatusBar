//
//  StatusBarViewController.swift
//  StatusBar
//
//  Created by Havil on 07.05.2020.
//  Copyright © 2020 Havil. All rights reserved.
//

import Cocoa
import Network

class StatusBarViewController: NSViewController {
    
    @IBOutlet weak var nochnikMode: NSPopUpButton!
    @IBOutlet weak var nochnikColor: NSPopUpButton!
    @IBOutlet weak var slider: NSSlider!
    @IBOutlet weak var statusPower: NSTextField!
    
    var udp: UDP? = nil
    
    class func loadFromNid() -> StatusBarViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "StatusBarViewController") as! StatusBarViewController
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        udp = UDP(ip: "192.168.0.187", port: 4210, onSuccess: { stateServerHelper in
            DispatchQueue.main.async {
                if stateServerHelper?.power ?? false {
                    self.statusPower.textColor = NSColor(red: 0, green: 1, blue: 0, alpha: 1)
                    self.statusPower.stringValue = "ON"
                } else {
                    self.statusPower.textColor = NSColor(red: 1, green: 0, blue: 0, alpha: 1)
                    self.statusPower.stringValue = "OFF"
                }
            }
        })
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {_ in
            self.udp?.send(key: "getPowerState", value: "", onError: { err in
                print(err)
            })
        })
                
        nochnikMode.removeAllItems()
        nochnikMode.addItems(withTitles: [
            "Режим 1",
            "Режим 2",
            "Режим 3",
            "Режим 4",
            "Режим 5",
            "Режим 6",
            "Режим 7",
            "Режим 8",
            "Режим 9",
            "Режим 10",
            "Режим 11"]
        )
        
        nochnikColor.removeAllItems()
        nochnikColor.addItems(withTitles: [
            "Красный",
            "Зеленый",
            "Синий"]
        )
        
    }
    
    @IBAction func changeNochnikPower(_ sender: NSButton) {
        if sender.title == "Выкл" {
            sender.title = "Вкл"
            udp?.send(key: "power", value: "0", onError: { err in
                print(err)
            })
        } else {
            sender.title = "Выкл"
            udp?.send(key: "power", value: "1", onError: { err in
                print(err)
            })
        }
    }
    
    
    
    @IBAction func changeNochnikBrightness(_ sender: NSSlider) {
        udp?.send(key: "brightness", value: String(sender.intValue), onError: { err in
            print(err)
        })
    }
    
    @IBAction func changeNochnikMode(_ sender: NSPopUpButton) {
        udp?.send(key: "mode", value: String(sender.indexOfSelectedItem + 1), onError: { err in
            print(err)
        })
    }
    
    @IBAction func changeNochnikColor(_ sender: NSPopUpButton) {
        var red = 0
        var green = 0
        var blue = 0
        if sender.indexOfSelectedItem == 0 {
            red = 255
        }
        if sender.indexOfSelectedItem == 1 {
            green = 255
        }
        if sender.indexOfSelectedItem == 2 {
            blue = 255
        }
        udp?.send(key: "color", value: "\(red) \(green) \(blue)", onError: { err in
            print(err)
        })
    }
    
    
}
