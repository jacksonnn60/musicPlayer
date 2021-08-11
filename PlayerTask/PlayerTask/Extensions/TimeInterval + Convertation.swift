//
//  TimeInterval + Convertation.swift
//  TimeInterval + Convertation
//
//  Created by Jackie basss on 09.08.2021.
//

import Foundation

extension TimeInterval{
    
    func convertToMusicTimeFormat() -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        
        let formattedString = formatter.string(from: TimeInterval(self))!
        
        if formattedString.contains(":") {
            return formattedString
        } else {
            if formattedString.count < 2 {
                return "0:" + "0\(formattedString)"
            }
        }
        return "0:" + formattedString
    }
    
    func convertToFloat() -> Float {
        let timeString = self.convertToMusicTimeFormat()
        let digitalArray = timeString.split(separator: ":")
        
        var stringFloatFormat = ""
        
        if digitalArray.count > 1 {
            stringFloatFormat = digitalArray[0] + "." + digitalArray[1]
        } else {
            stringFloatFormat = "0.0"
        }
        
        return Float(stringFloatFormat)!
    }
}
