//
//  CharacterModel.swift
//  ManzaneroAndrewFinalProject
//
//  Created by Andrew Manzanero on 4/26/21.
//  amanzane@usc.edu
//
//  This file contains the singleton model to access characters

import Foundation
import Firebase

class CharacterModel {
    static var sharedInstance = CharacterModel()
    var characters: [Character]!
    
    // initalizer opens character plist and loads + caches character data
    private init() {
        print("loading characters...")
        do {
            if let url = Bundle.main.url(forResource: "characters", withExtension: "plist") {
                let fcs = try Data.init(contentsOf: url)
                let chars = try PropertyListDecoder().decode([Character].self, from: fcs)
                self.characters = chars
                print("loaded characters")
            }
        } catch {
            self.characters = []
            print(error)
        }
    }
    
    // returns list of characters
    func getAllCharacters() -> [Character] {
        return characters
    }

    // returns character at index
    func at(index: Int) -> Character {
        return self.characters[index]
    }
    
    // returns length of array
    func count() -> Int {
        return self.characters.count
    }
    
    // takes character name and returns matching ID if it exists
    func getIDByName(_ name: String) -> String? {
        for character in characters {
            if character.name.lowercased() == name.lowercased() {
                return character.characterID
            }
        }
        return nil
    }
    
    
    func getNameByID(ID: String) -> String? {
        for character in characters {
            if character.characterID == ID {
                return character.name
            }
        }
        return nil
    }
    
}
