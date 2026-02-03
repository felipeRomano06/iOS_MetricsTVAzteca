//
//  Extension_Float.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 03/02/26.
//

extension Float{
    func formatSecondsToTime() -> String {
        if self == 0 { return "not-set" }
        let totalSecondsInt = Int(self)
        let hours = totalSecondsInt / 3600
        let minutes = (totalSecondsInt % 3600) / 60
        let seconds = totalSecondsInt % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    func roundedTime() -> String {
        let hour = Int(self)
        let minutes = (self - Float(hour)) * 60

        let roundedHour: Int
        let roundedMinute: Int

        switch minutes {
        case 0...15:
            roundedHour = hour
            roundedMinute = 0
        case 16...45:
            roundedHour = hour
            roundedMinute = 30
        default:
            roundedHour = (hour + 1) % 24
            roundedMinute = 0
        }

        return String(format: "%02d:%02d", roundedHour, roundedMinute)
    }

}
