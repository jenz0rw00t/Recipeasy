//
//  TimerPopupViewController.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-26.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import UIKit

class TimerPopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var timerPicker: UIPickerView!
    @IBOutlet weak var startTimerButton: UIButton!
    @IBOutlet weak var addTimerButton: UIButton!
    @IBOutlet weak var deleteTimerButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popupView: UIView!
    
    var selectedRecipe: Recipe!
    var isChooseTimer = true
    var noTimers = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timerPicker.delegate = self
        timerPicker.dataSource = self
        
        createTimerPickerData()
        
        let shadowRect = CGRect(x: 0, y: 0, width: popupView.bounds.width, height: popupView.bounds.height*2)
        let shadowPath = UIBezierPath(rect: shadowRect)
        popupView.layer.masksToBounds = false
        popupView.layer.shadowColor = UIColor.black.cgColor
        popupView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        popupView.layer.shadowOpacity = 0.5
        popupView.layer.shadowPath = shadowPath.cgPath
        
        if selectedRecipe.timers.count<1 {
            noTimersSetup()
        }

    }
    
    func noTimersSetup() {
        noTimers = true
        startTimerButton.isHidden = true
        deleteTimerButton.isHidden = true
    }
    
    @IBAction func startTimerButtonPressed(_ sender: Any) {
        if isChooseTimer {
            
            let tabBarBarContoller = self.presentingViewController! as! UITabBarController
            let navigationController = tabBarBarContoller.viewControllers![1] as! UINavigationController
            let timerVC = navigationController.viewControllers[0] as! TimerViewController
            
            let sec = getTimerSecondsFromPicker()
            
            if timerVC.isTimerRunning {
                Alert.showBasicOkAlert(on: self, with: "Warning", message: "The timer is already running!")
            } else {
                tabBarBarContoller.selectedIndex = 1
                self.dismiss(animated: true) {
                    let didStartTimer = timerVC.startTimerFromAnotherTab(sec: sec)
                    if !didStartTimer {
                        print("The timer didnat start!")
                    }
                }
            }
            
        } else {
            selectedRecipe.timers.append(getPickerValueInSeconds())
            isChooseTimer = true
            timerPicker.selectRow(0, inComponent: 0, animated: true)
            timerPicker.reloadAllComponents()
            noTimers = false
            startTimerButton.isHidden = false
            deleteTimerButton.isHidden = false
            startTimerButton.setTitle("Start Timer", for: .normal)
            addTimerButton.setTitle("Add Timer", for: .normal)
            titleLabel.text = "Select Timer"
        }
    }
    
    @IBAction func addTimerButtonPressed(_ sender: Any) {
        if isChooseTimer {
            isChooseTimer = false
            timerPicker.selectRow(0, inComponent: 0, animated: false)
            timerPicker.reloadAllComponents()
            titleLabel.text = "Set Timer"
            addTimerButton.setTitle("Cancel", for: .normal)
            startTimerButton.setTitle("Add Timer", for: .normal)
            startTimerButton.isHidden = false
            deleteTimerButton.isHidden = true
        } else {
            isChooseTimer = true
            timerPicker.reloadAllComponents()
            titleLabel.text = "Select Timer"
            addTimerButton.setTitle("Add Timer", for: .normal)
            startTimerButton.setTitle("Start Timer", for: .normal)
            startTimerButton.isHidden = false
            deleteTimerButton.isHidden = false
        }
        
    }
    
    @IBAction func deleteTimerButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Do you want to delete this timer?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .cancel, handler: { (_) in
            self.deleteTimer()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true)
    }
    
    func deleteTimer() {
        if selectedRecipe.timers.count>0{
            selectedRecipe.timers.remove(at: timerPicker.selectedRow(inComponent: 0))
        }
        if selectedRecipe.timers.count<1{
            noTimersSetup()
        }
        timerPicker.reloadAllComponents()
    }
    
    
    @IBAction func noSpacePressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIPicker
    
    var timerPickerData: [[String]] = [[String]]()
    
    func createTimerPickerData() {
        var hoursArray = [String]()
        var minutesArray = [String]()
        var secondsArray = [String]()
        
        for hours in 0...48 {
            hoursArray.append("\(hours) hours")
        }
        for minutes in 0...60 {
            minutesArray.append("\(minutes) min")
            secondsArray.append("\(minutes) sec")
        }
        timerPickerData = [hoursArray, minutesArray, secondsArray]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if isChooseTimer {
            return 1
        } else {
            return 3
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if isChooseTimer {
            if noTimers {
                return 1
            } else {
                return selectedRecipe.timers.count
            }
        } else {
            return timerPickerData[component].count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if isChooseTimer{
            if noTimers {
                return "No timers for this recipe!"
            } else {
                return timeForNotificationString(time: TimeInterval(selectedRecipe.timers[row]))
            }
        } else {
            return timerPickerData[component][row]
        }
    }
    
    func getTimerSecondsFromPicker() -> Int {
        return selectedRecipe.timers[timerPicker.selectedRow(inComponent: 0)]
    }
    
    func getPickerValueInSeconds() -> Int {
        let pickerHours = timerPicker.selectedRow(inComponent: 0)
        let pickerMinutes = timerPicker.selectedRow(inComponent: 1)
        let pickerSeconds = timerPicker.selectedRow(inComponent: 2)
        
        return (pickerHours*3600)+(pickerMinutes*60)+pickerSeconds
    }
    
    func timeForNotificationString(time:TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time)!
    }

}
