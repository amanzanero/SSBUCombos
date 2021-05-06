//
//  ComboModel.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/26/21.
//  amanzane@usc.edu
//
//  This file contains the singleton model that wraps Firestore
//  and exposes methods to retreive combos

import Foundation
import Firebase

class ComboModel {
    static var sharedInstance = ComboModel()
    var collectionReference: CollectionReference!
    private var cachedComboList: [Combo]
    
    private init() {
        collectionReference = Firestore.firestore().collection("combos")
        cachedComboList = []
    }
    
    // saves a combo to save to firestore
    func save(combo: Combo, onSuccess: @escaping (() -> Void)) {
        collectionReference.document(combo.id).setData(combo.toMap()) { (err) in
            if let err = err {
                print("Something bad happened: \(err)")
            } else {
                self.getByCharacter(characterID: combo.characterID) { _ in
                    onSuccess()
                }
                
            }
        }
    }

    // returns list of combos for a given characterID
    func getByCharacter(characterID: String, onSuccess: (([Combo])-> Void)?) {
        collectionReference.whereField("characterID", isEqualTo: characterID)
            .getDocuments { (qSnapshot, err) in
                if let err = err {
                    print("Something bad happened: \(err)")
                } else {
                    var combos: [Combo] = []
                    for document in qSnapshot!.documents {
                        guard let combo = Combo(dictionary: document.data())
                        else {
                            print("combo could not be parsed")
                            continue
                        }
                        combos.append(combo)
                    }
                    self.cachedComboList = combos
                    self.cachedComboList.sort { a, b in
                        return a.likes > b.likes
                    }
                    if let onSuccess = onSuccess {
                        onSuccess(combos)
                    }
                }
            }
    }
    
    // returns a cached version of the combo list to reduce network overhead
    func getCachedComboList() -> [Combo] {
        return cachedComboList
    }
}
