//
//  AddComboViewController.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/27/21.
//  amanzane@usc.edu
//

import UIKit
import CoreLocation
import Firebase

class AddComboViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    var characterID: String?
    var parentVC: ComboViewController?
    var locationManager: CLLocationManager?
    @IBOutlet weak var attackTF1: UITextField!
    @IBOutlet weak var attackTF2: UITextField!
    @IBOutlet weak var attackTF3: UITextField!
    @IBOutlet weak var attackTF4: UITextField!
    @IBOutlet weak var startPercentTF: UITextField!
    @IBOutlet weak var endPercentTF: UITextField!
    @IBOutlet weak var trueSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        attackTF1.delegate = self
        attackTF2.delegate = self
        attackTF3.delegate = self
        attackTF4.delegate = self
        
        startPercentTF.delegate = self
        endPercentTF.delegate = self
        
        // init location manager
        locationManager = CLLocationManager()
        if let locationManager = locationManager {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation() // start getting location
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager?.stopUpdatingLocation()
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            if let parent = self.parentVC {
                parent.tableview.reloadData()
                self.locationManager?.stopUpdatingLocation()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
        switch textField {
        case attackTF1:
            attackTF2.becomeFirstResponder()
            break
        case attackTF2:
            attackTF3.becomeFirstResponder()
            break
        case attackTF3:
            attackTF4.becomeFirstResponder()
            break
        case attackTF4:
            startPercentTF.becomeFirstResponder()
        case startPercentTF:
            endPercentTF.becomeFirstResponder()
            break
        default:
            textField.endEditing(true)
            break
        }
        return true
    }
    
    @IBAction func bgTapped(_ sender: Any) {
        attackTF1.endEditing(true)
        attackTF2.endEditing(true)
        attackTF3.endEditing(true)
        attackTF4.endEditing(true)
        startPercentTF.endEditing(true)
        endPercentTF.endEditing(true)
    }
    
    @IBAction func comboPostBtnTapped(_ sender: Any) {
        // performs validations for the fields
        var newCombo = Combo()
        if let characterID = characterID {
            newCombo.characterID = characterID
        } else {
            print("error! characterID doesn't exist")
            return
        }
        
        if let firstAttack = attackTF1.text {
            newCombo.moves.append(firstAttack)
        } else {
            print("no first attack")
            return
        }
        if let secondAttack = attackTF2.text, secondAttack != "" {
            newCombo.moves.append(secondAttack)
        }
        if let thirdAttack = attackTF3.text, thirdAttack != "" {
            newCombo.moves.append(thirdAttack)
        }
        if let fourthAttack = attackTF4.text, fourthAttack != "" {
            newCombo.moves.append(fourthAttack)
        }
        
        newCombo.trueCombo = trueSwitch.isOn
        
        if let startPercent = startPercentTF.text, let startPercentInt = Int(startPercent) {
            newCombo.startPercent = startPercentInt
        } else {
            print("no int value in start percent")
            return
        }
        
        if let endPercent =  endPercentTF.text, let endPercentInt = Int(endPercent) {
            newCombo.endPercent = endPercentInt
        } else {
            print("no int value in end percent")
            return
        }
        
        newCombo.submittedBy = UserModel.sharedInstance.displayName

        let onSuccess = { () in
            print("dismissing")
            self.dismiss(animated: true) {
                if let parent = self.parentVC {
                    parent.tableview.reloadData()
                }
            }
            self.locationManager?.stopUpdatingLocation()
        }
        
        // gets city and state, then saves combo
        getCity { city in
            newCombo.location = city
            ComboModel.sharedInstance.save(combo: newCombo, onSuccess: onSuccess)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    // helper function that loads city and state from lcoation manager
    func getCity(onSuccess: ((String) -> Void)?) {
        if let locationManager = locationManager, let location = locationManager.location {
            let geoCode = CLGeocoder()
            geoCode.reverseGeocodeLocation(location) { placeMarkList, error in
                if let error = error {
                    print("failed to reverse geocode \(error)")
                } else {
                    let placeArray = placeMarkList!
                    // Place details
                    let placeMark = placeArray.first
                    
                    // City
                    if let city = placeMark?.subAdministrativeArea, let state = placeMark?.administrativeArea {
                        if let onSuccess = onSuccess{ onSuccess("\(city), \(state)") }
                    }
                    else {
                        print("no city found")
                    }
                }
            }
        } else {
            print("location not available \(String(describing: locationManager?.location))")
        }
    }
}
