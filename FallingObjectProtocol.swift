//
//  FallingObjectProtocol.swift
//  MatchOnDemand
//
//  Created by Yanbing Peng on 11/03/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

import Foundation

protocol FallingObjectProtocol{
    
    var objectAttributes : [String:String] { set get }
    
    func setOjectColor(newColor:String)
    
    func setObjectNumber(newNumber:Int)
}