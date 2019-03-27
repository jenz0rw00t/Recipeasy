//
//  TimerViewController.swift
//  Cookbook
//
//  Created by Jens Sellén on 2019-03-20.
//  Copyright © 2019 Jens Sellén. All rights reserved.
//

import UIKit
import UserNotifications
import AVFoundation

class TimerViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var startPauseButton: UIButton!
    
    var audioPlayer = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timePicker.delegate = self
        self.timePicker.dataSource = self
        
        createPickerData()
        
        timePicker.isHidden = false
        timerLabel.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: (#selector(TimerViewController.stopTimerWhenAppEntersBackground)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: (#selector(TimerViewController.startTimerComingFromBackground)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if seconds<1{
            removeTabBarNotification()
        }
    }
    
    // MARK: - Timer funcions with help from this tutorial https://medium.com/ios-os-x-development/build-an-stopwatch-with-swift-3-0-c7040818a10f by Jen Sipila
    
    var seconds = 0
    var timer = Timer()
    var isTimerRunning = false
    var isTimerPaused = false
    
    @IBAction func startPauseButtonPressed(_ sender: Any) {
        authorizeNotifications()
        if !isTimerRunning {
            seconds = getPickerValueInSeconds()
            startSendTimerNotification(sec: seconds)
            timerLabel.text = timeForTimerString(time: TimeInterval(seconds))
            timePicker.isHidden = true
            timerLabel.isHidden = false
            runTimer()
            isTimerRunning = true
            startPauseButton.setTitle("Pause", for: UIControl.State.normal)
        } else {
            if !isTimerPaused {
                cancelNotification()
                clearSavedTimer()
                timer.invalidate()
                isTimerPaused = true
                startPauseButton.setTitle("Resume", for: UIControl.State.normal)
            } else {
                startSendTimerNotification(sec: seconds)
                runTimer()
                isTimerPaused = false
                startPauseButton.setTitle("Pause", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelTimer()
    }
    
    func startTimerFromAnotherTab(sec: Int) -> Bool {
        if isTimerRunning {
            return false
        } else {
            timePicker.isHidden = true
            timerLabel.isHidden = false
            seconds = sec
            startSendTimerNotification(sec: seconds)
            timerLabel.text = timeForTimerString(time: TimeInterval(seconds))
            runTimer()
            isTimerRunning = true
            startPauseButton.setTitle("Pause", for: UIControl.State.normal)
            return true
        }
    }
    
    func cancelTimer(){
        timer.invalidate()
        cancelNotification()
        timePicker.isHidden = false
        timerLabel.isHidden = true
        isTimerRunning = false
        isTimerPaused = false
        startPauseButton.setTitle("Start", for: UIControl.State.normal)
        clearSavedTimer()
        removeTabBarNotification()
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(TimerViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func stopTimerWhenAppEntersBackground() {
        if isTimerRunning {
            timer.invalidate()
            let pausDate = NSDate()
            UserDefaults.standard.set(pausDate, forKey: "saveDate")
        }
    }
    
    @objc func startTimerComingFromBackground(){
        guard let savedPauseDate = UserDefaults.standard.object(forKey: "saveDate") as? Date else {
            return
        }
        let difference = savedPauseDate.timeIntervalSinceNow
        seconds += Int(difference)
        if seconds>1 {
            timerLabel.text = timeForTimerString(time: TimeInterval(seconds))
            runTimer()
        } else {
            cancelTimer()
        }
    }
    
    func clearSavedTimer() {
        UserDefaults.standard.removeObject(forKey: "saveDate")
    }
    
    @objc func updateTimer() {
        if seconds<1{
            cancelTimer()
            Alert.showBasicOkAlert(on: self, with: "Timer is up!", message: "Time for the next step!")
            AudioServicesPlayAlertSound(SystemSoundID(1005))
            self.tabBarController?.tabBar.items![1].badgeColor = .green
            showTabBarNotification(text: "Timer up!")
        } else if seconds<12 {
            self.tabBarController?.tabBar.items![1].badgeColor = .red
            seconds -= 1
            timerLabel.text = timeForTimerString(time: TimeInterval(seconds))
            showTabBarNotification(text: "\(seconds)")
        } else {
            seconds -= 1
            timerLabel.text = timeForTimerString(time: TimeInterval(seconds))
        }
    }
    
    func showTabBarNotification(text:String) {
        self.tabBarController?.tabBar.items![1].badgeValue = text
    }
    
    func removeTabBarNotification() {
        self.tabBarController?.tabBar.items![1].badgeValue = nil
    }
    
    func timeForTimerString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    // MARK: - UIPicker
    
    var pickerData: [[String]] = [[String]]()
    
    func createPickerData() {
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
        pickerData = [hoursArray, minutesArray, secondsArray]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component][row]
    }
    
    func getPickerValueInSeconds() -> Int {
        let pickerHours = timePicker.selectedRow(inComponent: 0)
        let pickerMinutes = timePicker.selectedRow(inComponent: 1)
        let pickerSeconds = timePicker.selectedRow(inComponent: 2)

        return (pickerHours*3600)+(pickerMinutes*60)+pickerSeconds
    }
    
    // MARK: - Notifications
    //  Created by Markus Karlsson on 2019-03-16.
    //  Copyright © 2019 The App Factory AB. All rights reserved.
    
    private func authorizeNotifications() {
        // Fråga om tillåtelse från användaren
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if !granted {
                print("Notifications permission denied because: \(String(describing: error?.localizedDescription)).")
            }
        }
    }
    
    private func startSendTimerNotification(sec:Int) {
        let content = UNMutableNotificationContent()
        content.title = "The timer is up!"
        content.body = "Timer of "+timeForNotificationString(time: TimeInterval(sec))+" has finished!"
        content.badge = 1
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(sec), repeats: false)
        let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func timeForNotificationString(time:TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: time)!
    }

}
