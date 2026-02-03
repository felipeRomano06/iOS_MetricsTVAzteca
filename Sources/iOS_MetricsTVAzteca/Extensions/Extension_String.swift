//
//  Extension_String.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 03/02/26.
//

extension String {
    func limited(to maxLength: Int, fallback: String = "not-set") -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : String(trimmed.prefix(maxLength))
    }
    
}
