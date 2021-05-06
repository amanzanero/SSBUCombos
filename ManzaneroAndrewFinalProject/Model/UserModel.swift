//
//  UserModel.swift
//  ManzaneroAndrewFinalProject
//  amanzane@usc.edu
//
//  Created by Andrew Manzanero on 4/30/21.
//  amanzane@usc.edu
//

import Foundation
import Firebase

class UserModel {
    static var sharedInstance = UserModel()
    var displayName: String
    var userUID: String
    var likes: Set<String>
    private var email: String
    private var filepath: URL
    private var likesRef: CollectionReference
    
    private init() {
        displayName = ""
        userUID = ""
        likes = []
        email = ""
        likesRef = Firestore.firestore().collection("likes")
        
        let manager = FileManager.default
        let documents = manager.urls(for: .documentDirectory, in: .userDomainMask).first
        filepath = documents!.appendingPathComponent("userInfo.plist")
        print(filepath.absoluteString)
    }
    
    // saves the email to a plist in user documents
    func cacheEmail(email: String) {
        do {
            let data = try PropertyListEncoder().encode([email])
            try data.write(to: self.filepath)
            print("cached email")
        } catch {
            print(error)
        }
    }
    
    // gets the email from the plist if it exists
    func loadAndGetEmail() -> String {
        let manager = FileManager.default
        if manager.fileExists(atPath: filepath.path) {
            do {
                let fcs = try Data.init(contentsOf: filepath)
                let storedEmail = try PropertyListDecoder().decode([String].self, from: fcs)
                self.email = storedEmail.first ?? ""
                print("loaded cached email")
            } catch {
                print(error)
                print("failed to load email")
            }
        } else {
            print("no email found: loaded no email")
        }
        return email
    }
    
    // caches some user info and loads in all their likes
    func loadUserInfo(user: User, onSuccess: @escaping () -> Void) {
        displayName = user.displayName ?? ""
        userUID = user.uid
        
        reloadLikes {
            onSuccess()
        }
    }
    
    // re-fetches likes for the user
    func reloadLikes(onSuccess: @escaping () -> Void) {
        if userUID != "" {
            likesRef.whereField("likedBy", isEqualTo: userUID).getDocuments { qs, err in
                if let err = err {
                    print("error retreiving likes: \(err)")
                    return
                }
                
                self.likes = []
                for document in qs!.documents {
                    guard let comboId = document["comboId"] as? String else {
                        print("could not parse comboId \(document)")
                        continue
                    }
                    self.likes.insert(comboId)
                }
                onSuccess()
            }
        }
    }
    
    // inserts a like into firestore
    func insertLike(
        combo: Combo,
        onCompleteUserUpdate: @escaping () -> Void,
        onCompleteComboUpdate: @escaping (Combo) -> Void
    ) {
        likesRef.document().setData([
            "likedBy": userUID,
            "comboId": combo.id,
        ]) { err in
            if let err = err {
                print("error inserting like \(err)")
                return
            }
            onCompleteUserUpdate()
        }
        
        var newCombo = combo
        newCombo.likes += 1
        ComboModel.sharedInstance.save(combo: newCombo) {
            onCompleteComboUpdate(newCombo)
        }
    }
    
    // removes a like from firestore
    func removeLike(
        combo: Combo,
        onCompleteUserUpdate: @escaping () -> Void,
        onCompleteComboUpdate: @escaping (Combo) -> Void
    ) {
        likesRef.whereField("likedBy", isEqualTo: userUID).whereField("comboId", isEqualTo: combo.id).getDocuments { qs, err in
            if let err = err {
                print("error finding like to remove \(err)")
                return
            }
            let doc = qs!.documents.first
            
            if let doc = doc {
                doc.reference.delete { err in
                    if let err = err {
                        print("error finding like to remove \(err)")
                        return
                    }
                    onCompleteUserUpdate()
                }
            }
        }
        
        // clamp at zero
        var newCombo = combo
        if newCombo.likes > 0 {
            newCombo.likes -= 1
        }
        ComboModel.sharedInstance.save(combo: newCombo) {
            onCompleteComboUpdate(newCombo)
        }
    }
}
