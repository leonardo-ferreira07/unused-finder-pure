//
//  Extensions.swift
//  Unused Finder
//
//  Created by Leonardo Vinicius Kaminski Ferreira on 26/07/17.
//  Copyright © 2017 iOS Wizards. All rights reserved.
//

import Foundation

extension String {
    
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                substring(with: substringFrom..<substringTo)
            }
        }
    }
}
