//
//  AppSwiftInterface.swift
//  IosSampleSwift
//
//  Created by Jeremy FAIVRE on 24/01/2018.
//  Copyright © 2018 Your Company. All rights reserved.
//

import UIKit

/** Swift interface */
public class AppSwiftInterface: NSObject {
    
    /** Define a last name for helloSwift */
    @objc public var lastName: String?
    
    /** Say hello to name */
    @objc public func helloSwift(_ name: String) -> Void {
        
        if let lastName = self.lastName {
            print("HelloSwift \(name) \(lastName)")
        } else {
            print("HelloSwift \(name)")
        }
        
    } //helloSwift

} //AppSwiftInterface
