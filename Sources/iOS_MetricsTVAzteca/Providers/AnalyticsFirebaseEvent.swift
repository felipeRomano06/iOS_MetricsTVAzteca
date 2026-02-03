//
//  AnalyticsFirebaseEvent.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 30/01/26.
//

import FirebaseAnalytics
import AdSupport


enum AnalyticsFirebaseEvent: String {
    
    case screenView = "screen_view"
    case videoView = "video_views"
    case playerReady = "player_ready"
    case videoVODProgress = "video_VOD_progress"
    case videoLiveWatchCount = "video_live_watch_count"
    case loginBanner = "login_banner"
    case loginSuccess = "login_success"
    case loginError = "login_error"
    case surveyShow = "pd_show"
    case surveySend = "pd_send"
    case surveyError = "pd_error"
    
    
    /// Devuelve un mapper asociado a cada evento
    var mapper: EventMapper {
        switch self {
        case .screenView:
            return ScreenViewFirebaseParamBuilder()
        case .videoView:
            return VideoViewFirebaseParamBuilder()
        case .videoVODProgress:
            return VideoVODProgressFirebaseParamBuilder()
        case .videoLiveWatchCount:
            return VideoLiveWatchCountFirebaseParamBuilder()
        case .playerReady:
            return PlayerReadyFirebaseParamBuilder()
        case .loginBanner:
            return LoginBannerFirebaseParamBuilder()
        case .loginSuccess:
            return LoginSuccessFirebaseParamBuilder()
        case .loginError:
            return LoginErrorFirebaseParamBuilder()
        case .surveySend:
            return SurveyFirebaseParamBuilder()
        case .surveyShow:
            return SurveyFirebaseParamBuilder()
        case .surveyError:
            return SurveyFirebaseParamBuilder()
        
        }
    }
}

public final class AnalyticsFirebaseEventReportManager: NSObject, AnalyticsProvider {
    
    public func logEvent(name: String , _ params: MetricsParam) {
        
        guard let event = AnalyticsFirebaseEvent(rawValue: name) else { return }
        let params = event.mapper.map(params)
        debugPrintEvent(name: name, params: params)
        Analytics.logEvent(name, parameters: params)

    }
    
    private func debugPrintEvent(name: String,params: [String: AnyHashable]) {
        let separator = String(repeating: "─", count: 50)

        print("""
        
        \(separator)
        📊 Firebase Event
        ─────────────────────────────────
        🏷 Name: \(name)
        🧾 Params:
        \(params
            .sorted { $0.key < $1.key }
            .map { "   • \($0.key): \($0.value)" }
            .joined(separator: "\n"))
        \(separator)
        """)
    }

}

final class ScreenViewFirebaseParamBuilder:EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
        // parametros comunes de Firebase
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        return builder.build()
            
    }
    
}

final class VideoViewFirebaseParamBuilder:EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoStartTime:String? = param.videoStartTime?.roundedTime()
        let videoType:String = param.videoType.rawValue
        let videoDuration:String = param.videoDuration.formatSecondsToTime()
        
        
        
        return builder
            .set("video_start_time", value: videoStartTime)
            .set("video_type", value: videoType)
            .set("video_duration", value: videoDuration)
            .build()
    }
}

final class PlayerReadyFirebaseParamBuilder:EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoStartTime:String? = param.videoStartTime?.roundedTime()
        let videoType:String = param.videoType.rawValue
        let videoDuration:String = param.videoDuration.formatSecondsToTime()
        
        return builder
            .set("video_start_time", value: videoStartTime)
            .set("video_type", value: videoType)
            .set("video_duration", value: videoDuration)
            .build()
    }
    
}

final class VideoVODProgressFirebaseParamBuilder:EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoType:String = param.videoType.rawValue
        let videoDuration:String = param.videoDuration.formatSecondsToTime()
        let videoPercent:String = param.videoPercent?.rawValue ?? "not-set"
        
        return builder
            .set("video_duration", value: videoDuration)
            .set("video_type", value: videoType)
            .set("video_percent", value: videoPercent)
            .build()
    }
    
}

final class VideoLiveWatchCountFirebaseParamBuilder: EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoStartTime:String? = param.videoStartTime?.roundedTime()
        let videoType:String = param.videoType.rawValue
        let videoTimeCount: Int = param.videoTimeCount ?? 0
       
        return builder
            .set("video_start_time", value: videoStartTime)
            .set("video_type", value: videoType)
            .set("video_time_count", value: videoTimeCount)
            .build()
    }
}

final class LoginBannerFirebaseParamBuilder: EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.loginParam else { return builder.build() }
        
        let bannerType:String = param.bannerType?.rawValue ?? "not-set"
        
        
        return DictionaryBuilder()
            .set("login_banner_type", value: bannerType)
            .build()
    }
}

final class LoginSuccessFirebaseParamBuilder: EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.loginParam else { return builder.build() }
        
        let bannerType:String = param.bannerType?.rawValue ?? "not-set"
        let loginSource: String = param.loginSource?.rawValue ?? "not-set"
        let newUser: String = param.newUser ?? "not-set"
        
        return DictionaryBuilder()
            .set("login_banner_type", value: bannerType)
            .set("login_source", value: loginSource)
            .set("new_user", value: newUser)
            .build()
    }
}

final class LoginErrorFirebaseParamBuilder: EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.loginParam else { return builder.build() }
        
        let bannerType:String = param.bannerType?.rawValue ?? "not-set"
        let loginSource: String = param.loginSource?.rawValue ?? "not-set"
        
        return DictionaryBuilder()
            .set("login_banner_type", value: bannerType)
            .set("login_source", value: loginSource)
            .build()
    }
}

final class SurveyFirebaseParamBuilder: EventMapper, FirebaseBaseMapper {
    
    func map(_ input: MetricsParam) -> [String : AnyHashable] {
        
        let builder = DictionaryBuilder()
                
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.surveyParam else { return builder.build() }
        
        let formTitle:String = param.formTitle
        let questionCount: String = param.questionCount
        let formID: String = param.formID
        
        return DictionaryBuilder()
            .set("form_title", value: formTitle)
            .set("question_count", value: questionCount)
            .set("form_id", value: formID)
            .build()
    }
    
}

protocol FirebaseBaseMapper {
    func commonParams(from input: MetricsParam) -> [String: AnyHashable]
}

extension FirebaseBaseMapper {
    
    func commonParams(from input: MetricsParam) -> [String: AnyHashable] {
        let screeName:String = input.firebaseScreen ?? "not-set"
        var screenClass:String = "not-set"
        let channel:String = input.channel ?? "not-set"
        let program:String = input.programm ?? "not-set"
        let section:String = input.section ?? "not-set"
        let videoTitle:String = input.videoTitle?.limited(to: 100) ?? "not-set"
        let videoID: String = input.videoID ?? "not-set"
        let loginStatus:String = input.loginStatus.rawValue
        let playlistTitle:String = input.playListTitle ?? "not-set"
        let country:String = input.countryCode ?? "not-set"
        let advertisingIdentifier:String = input.idfa ?? "not-set"
        let isRestricted = input.isRestricted.rawValue
        let im:String = input.im ?? "not-set"
        
        // Screen Class (firebase)
        if let topVC = UIApplication.shared.topMostViewController() {
            screenClass = String(describing: type(of: topVC))
        }
        
        return DictionaryBuilder()
            .set(AnalyticsParameterScreenName, value: screeName)
            .set(AnalyticsParameterScreenClass, value: screenClass)
            .set("section", value: section)
            .set("channel", value: channel)
            .set("program", value: program)
            .set("video_title", value: videoTitle)
            .set("video_id", value: videoID)
            .set("playlist_title", value: playlistTitle)
            .set("login_status", value: loginStatus)
            .set("im", value: im)
            .set("country_code", value: country)
            .set("apple_phone_idfa", value: advertisingIdentifier)
            .set("isRestricted", value: isRestricted)
            .build()
    }
}







