//
//  Pokemon.swift
//  pokedex
//
//  Created by Ray Elliott on 2/3/16.
//  Copyright © 2016 Crossway. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String?
    private var _type: String?
    private var _defense: String?
    private var _height: String?
    private var _weight: String?
    private var _attack: String?
    private var _nextEvolutionTxt: String?
    private var _nextEvolutionId: String?
    private var _nextEvolutionLevel: String?
    private var _pokemonUrl: String!
    private var _moves = [Dictionary<String, String>]()
    
    var description: String! {
        if let desc = _description {
            return desc
        }
        return ""
    }
    
    var type: String! {
        if let type = _type {
            return type
        }
        return ""
    }
    
    var defense: String! {
        if let defense = _defense {
            return defense
        }
        return ""
    }
    
    var height: String! {
        if let height = _height {
            return height
        }
        return ""
    }
    
    var weight: String! {
        if let weight = _weight {
            return weight
        }
        return ""
    }
    
    var attack: String! {
        if let attack = _attack {
            return attack
        }
        return ""
    }
    
    var nextEvolutionTxt: String! {
        if let nextEvolutionTxt = _nextEvolutionTxt {
            return nextEvolutionTxt
        }
        return ""
    }
    
    var nextEvolutionId: String! {
        if let nextEvolutionId = _nextEvolutionId {
            return nextEvolutionId
        }
        return ""
    }
    
    var nextEvolutionLevel: String! {
        if let nextEvolutionLevel = _nextEvolutionLevel {
            return nextEvolutionLevel
        }
        return ""
    }
    
    var name: String! {
        if let name = _name {
            return name.capitalizedString
        }
        return ""
    }
    
    var pokedexId: Int! {
        return _pokedexId
    }
    
    var moves: [Dictionary<String, String>] {
        return _moves
    }
    
    init(name: String, pokedexId: Int) {
        _name = name
        _pokedexId = pokedexId
        
        _pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        
        let url = NSURL(string: _pokemonUrl)!
        Alamofire.request(.GET, url).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                if let height = dict["height"] as? String {
                    self._height = height
                }
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                if let types = dict["types"] as? [Dictionary<String, String>] where types.count > 0 {
                    if let name = types[0]["name"] {
                        self._type = name.capitalizedString
                    }
                    if types.count > 1 {
                        for var x = 1; x < types.count; x++ {
                            if let name = types[x]["name"] {
                                self._type! += "/\(name.capitalizedString)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                if let evoArr = dict["evolutions"] as? [Dictionary<String, AnyObject>] where evoArr.count > 0 {
                    //Can't support mega pokemon right now but api still has mega data
                    if let to = evoArr[0]["to"] as? String where to.rangeOfString("mega") == nil {
                        if let uri = evoArr[0]["resource_uri"] as? String {
                            let num = uri.stringByReplacingOccurrencesOfString("/api/v1/pokemon/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
                            self._nextEvolutionId = num
                            self._nextEvolutionTxt = to
                            if let level = evoArr[0]["level"] as? Int {
                                self._nextEvolutionLevel = "\(level)"
                            }
                        }
                    }
                }
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                    if let descUrl = descArr[0]["resource_uri"] {
                        Alamofire.request(.GET, NSURL(string: "\(URL_BASE)\(descUrl)")!).responseJSON { response in
                            let result = response.result
                            if let descDict = result.value as? Dictionary<String, AnyObject> {
                                if let description = descDict["description"] as? String {
                                    self._description = description
                                }
                            }
                            completed()
                        }
                    } else {
                        self._description = ""
                        completed()
                    }
                }
                if let movesArr = dict["moves"] as? [Dictionary<String, AnyObject>] where movesArr.count > 0 {
                    for var i = 0; i < movesArr.count; i++ {
                        if let moveUri = movesArr[i]["resource_uri"] {
                            let num = moveUri.stringByReplacingOccurrencesOfString("/api/v1/move/", withString:  "").stringByReplacingOccurrencesOfString("/", withString: "")
                            Alamofire.request(.GET, NSURL(string: "\(URL_BASE)\(moveUri)")!).responseJSON { response in
                                let result = response.result
                                if let moveDict = result.value as? Dictionary<String, AnyObject> {
                                     if let moveName = moveDict["name"] as? String, moveAccuracy = moveDict["accuracy"] as? Int, movePower = moveDict["power"] as? Int, moveDesc = moveDict["description"] as? String {
                                        var newMoveDict = Dictionary<String, String>()
                                        newMoveDict["id"] = num
                                        newMoveDict["name"] = moveName
                                        newMoveDict["accuracy"] = "\(moveAccuracy)"
                                        newMoveDict["power"] = "\(movePower)"
                                        newMoveDict["description"] = moveDesc
                                        self._moves.append(newMoveDict)
                                    }
                                }
                                completed()
                            }
                        }
                    }
                }
                
                
            }
        }
        
    }
    
}