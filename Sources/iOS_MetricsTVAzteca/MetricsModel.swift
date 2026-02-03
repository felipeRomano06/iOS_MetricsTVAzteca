//
//  MetricsModel.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 30/01/26.
//


protocol MetricsMapper {
    associatedtype Input
    func map(_ input: Input) -> MetricsParam
}

public struct MetricsParam {
    var firebaseScreen:String?
    var section:String?
    var channel:String?
    var programm:String?
    var videoTitle:String?
    var videoID:String?
    var playListTitle:String?
    var countryCode:String?
    var loginStatus:LoginStatusType = .anonymous
    var idfa:String?
    var im: String?
    var isRestricted: ContentRestrictiveType = .isFalse
    var videoParam:VideoMetricsParam? = nil
    var loginParam: LoginMetricsParam? = nil
    var surveyParam:SurveyMetricsParam? = nil
}

public struct SurveyMetricsParam {
    var formTitle:String = "not-set"
    var questionCount:String = "not-set"
    var formID:String = "not-set"
}

public struct LoginMetricsParam {
    var bannerType: LoginBannerType? = nil
    var loginSource: LoginSource? = nil
    var newUser: String? = nil
}

enum LoginBannerType: String {
    case fullScreen = "full"
    case modalScreen = "modal"
}

enum LoginSource: String {
    case email = "email"
    case facebook = "Facebook"
    case apple = "apple"
    case google = "Google"
}

struct VideoMetricsParam {
    var videoStartTime: Float?
    var videoType: VideoType = .vod
    var videoDuration: Float = 0
    var videoPercent:VideoPercent? = nil
    var videoTimeCount:Int? = nil
}

enum VideoPercent: String {
    case quarter = "25%"
    case half = "50%"
    case ended = "100%"
}

extension VideoPercent {
    static func from(_ value: String?) -> VideoPercent? {
        switch value {
        case "25%": return .quarter
        case "50%": return .half
        case "100%": return .ended
        default: return nil
        }
    }
}


enum VideoType: String {
    case live = "Live"
    case vod = "VOD"
}

enum LoginStatusType:String {
    case connected = "connected"
    case anonymous = "anonymous"
}

enum ContentRestrictiveType: String {
    case isFalse = "false"
    case notOptional = "not optional"
    case optional = "optional"
}

extension ContentRestrictiveType {
    static func from(_ value: Any?) -> ContentRestrictiveType {
        switch value as? String {
        case "1": return .notOptional
        case "2": return .optional
        default: return .isFalse
        }
    }
}

