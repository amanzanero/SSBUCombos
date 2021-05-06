//
//  Combo.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/26/21.
//  amanzane@usc.edu
//
//  This file contains the Combo information

import Foundation

struct Combo {
    var id: String
    var characterID: String
    var likes: Int
    var moves: [String]
    var trueCombo: Bool
    var startPercent: Int
    var endPercent: Int
    var submittedBy: String
    var location: String
    
    init() {
        id = UUID().uuidString
        characterID = ""
        likes = 0
        moves = []
        trueCombo = false
        startPercent = 0
        endPercent = 0
        submittedBy = ""
        location = ""
    }
    
    // This allows us to initialize from a firebase document
    init?(dictionary: [String : Any]) {
        guard let id = dictionary["id"] as? String,
              let characterID = dictionary["characterID"] as? String,
              let likes = dictionary["likes"] as? Int,
              let moves = dictionary["moves"] as? [String],
              let trueCombo = dictionary["trueCombo"] as? Bool,
              let startPercent = dictionary["startPercent"] as? Int,
              let endPercent = dictionary["endPercent"] as? Int,
              let submittedBy = dictionary["submittedBy"] as? String,
              let location = dictionary["location"] as? String else { return nil }
        
        self.id = id
        self.characterID = characterID
        self.likes = likes
        self.moves = moves
        self.trueCombo = trueCombo
        self.startPercent = startPercent
        self.endPercent = endPercent
        self.submittedBy = submittedBy
        self.location = location
    }
    
    // transform into a shape that interfaces with firestore for transmission
    func toMap() -> [String : Any] {
        return [
            "id": id,
            "characterID": characterID,
            "likes": likes,
            "moves": moves,
            "trueCombo": trueCombo,
            "startPercent": startPercent,
            "endPercent": endPercent,
            "submittedBy": submittedBy,
            "location": location
        ]
    }
}
