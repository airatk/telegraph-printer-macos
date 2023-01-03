//
//  Extensions.swift
//  TelegraphPrinter
//
//  Created by Airat K on 3/1/2023.
//

import Foundation


extension String {

    func split(regex pattern: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: pattern) else { return [] }

        let nsSelf = self as NSString  // Needed for compatibility with NSRange
        let selfRange = NSRange(location: 0, length: nsSelf.length)
        let substitutedSeparator = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(in: self, range: selfRange, withTemplate: substitutedSeparator)
        
        return modifiedString.components(separatedBy: substitutedSeparator)
    }
}
