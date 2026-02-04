//
//  AnalyticsPermutiveEvent.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 30/01/26.
//

import Permutive_iOS
import AdSupport
import AppTrackingTransparency
import UIKit



public struct PermutiveConfiguration {

    public let apiKey: String
    public let organisationId: String
    public let workspaceId: String

    public init(
        apiKey: String,
        organisationId: String,
        workspaceId: String
    ) {
        self.apiKey = apiKey
        self.organisationId = organisationId
        self.workspaceId = workspaceId
    }
}




/// Representa los distintos tipos de eventos que puedes enviar
enum AnalyticsPermutiveEvent: String {
    
    case screenView = "screen_view"
    case videoView  = "video_views"
    case playerReady = "player_ready"
    case videoLiveWatchCount = "video_live_watch_count"
    case videoVODprogress = "video_VOD_progress"
    

    /// Devuelve un mapper asociado a cada evento
    var mapper: EventMapper {
        switch self {
        case .screenView:
            return ScreenViewPermutiveMapper()
        case .videoView:
            return VideoViewPermutiveMapper()
        case .playerReady:
            return playerReadyPermutiveMapper()
        case .videoLiveWatchCount:
            return VideoLiveWatchCountPermutiveMapper()
        case .videoVODprogress:
            return VideoVODprogressPermutiveMapper()
        }
    }
}

public class AnalyticsPermutiveReportEventManager: AnalyticsProvider {
    
    private let configuration: PermutiveConfiguration

    public init(configuration: PermutiveConfiguration) {
            self.configuration = configuration
            startPermutive()
    }
    
    
    private func startPermutive() {
        
        guard let options = Options(
            apiKey: configuration.apiKey,
            organisationId: configuration.organisationId,
            workspaceId: configuration.workspaceId
        ) else {
            //assertionFailure("💥 Invalid Permutive configuration")
            return
        }

        options.logModes = LogMode.all

        Permutive.shared.start(with: options) { error in
            if let error {
                print("💥 Permutive init error: \(error)")
            } else {
                print("👽 Permutive SDK ready.")
            }
        }
    }
    
    
    
    public func logEvent(name: String, _ parameters: MetricsParam){
                
        guard let event = AnalyticsPermutiveEvent(rawValue: name) else { return }
        let mappedProperties = event.mapper.map(parameters)
        
        do {
            
            try Permutive.shared.track(event: name)
            let properties = try EventProperties(mappedProperties)

            try Permutive.shared.track(event: name, properties: properties)
            self.debugPrintEvent(name: name, params: mappedProperties)
            
        }
        catch(let error) {
            print("💥 error de logEvent PermutiveInitializer: ", error)
        }
    }
    
    private func debugPrintEvent(name: String,params: [String: AnyHashable]) {
        let separator = String(repeating: "─", count: 50)

        print("""
        
        \(separator)
        📊 Permutive Event
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

    func setIdentity(im: String?){
        
        var aliases:[Alias] = []

        guard let im = im else {
            print("Permutive: No IM to set")
            return
        }

        print("Permutive: IM - ", im)

        aliases.append(Alias(tag: "IM", identity: im))

        self.setIDFA()

        do {

            try Permutive.shared.setIdentities(aliases: aliases)

            print("Permutive: Identity set: ", im)
        }
        catch   {
            print("Permutive: ERROR on setIdentities")
        }
    }
    
    func setIDFA() {
        
        if #available(macOS 11.0, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                
                if status == .authorized {
                    let aliasIDFA = ASIdentifierManager.shared().advertisingIdentifier
                    
                    do {
                        // This will add an alias to your permutive identity with the tag "idfa" and the value set to the IDFA token
                        try Permutive.shared.setIdentityForIDFA(aliasIDFA)
                        print("Permutive: set IDFA success")
                    } catch let error {
                        // This would happen if the IDFA is set to all zeroes or was otherwise invalid
                        // A zero IDFA usually means tracking access is revoked
                        print("Permutive: unable to set IDFA \(error.localizedDescription)")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
}

// MARK: - Events Mapper

final class ScreenViewPermutiveMapper: EventMapper, PermutiveBaseMapper {
    func map(_ input: MetricsParam) -> [String: AnyHashable] {
        
       
        let builder = DictionaryBuilder()
        // parametros comunes de Firebase
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        let section: String = input.section ?? "not-set"
        let videoTitle: String = input.videoTitle?.limited(to: 100) ?? "not-set"
        let loginStatus:String = input.loginStatus.rawValue
        let playListTitle:String = input.playListTitle ?? "not-set"
        
        
        return DictionaryBuilder()
            .set("section", value: section)
            .set("video_title", value: videoTitle)
            .set("login_status", value: loginStatus)
            .set("playlist_title", value: playListTitle)
            .build()
    }
}

final class VideoViewPermutiveMapper: EventMapper, PermutiveBaseMapper {
    func map(_ input: MetricsParam) -> [String: AnyHashable] {
        
        let builder = DictionaryBuilder()
        // parametros comunes de Firebase
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoStartTime:String? = param.videoStartTime?.roundedTime()
        let videoType:String = param.videoType.rawValue
        let videoDuration:String = param.videoDuration.formatSecondsToTime()
            
        return DictionaryBuilder()
            
            .set("video_duration", value: videoDuration)
            .set("video_start_time", value: videoStartTime)
            .set("video_type", value: videoType)
            .build()
    }
}

final class VideoLiveWatchCountPermutiveMapper: EventMapper, PermutiveBaseMapper {
    func map(_ input: MetricsParam) -> [String: AnyHashable] {
        
        let builder = DictionaryBuilder()
        // parametros comunes de Firebase
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoDuration: String = param.videoDuration.formatSecondsToTime()
        let videoStartTime: String? = param.videoStartTime?.roundedTime()
        let videoTimeCount: Int = param.videoTimeCount ?? 0
        
        return DictionaryBuilder()
            .set("video_duration", value: videoDuration)
            .set("video_start_time", value: videoStartTime)
            .set("video_time_count", value: videoTimeCount)
            .build()
    }
}

final class VideoVODprogressPermutiveMapper: EventMapper, PermutiveBaseMapper {
    func map(_ input: MetricsParam) -> [String: AnyHashable] {
        
        let builder = DictionaryBuilder()
        // parametros comunes de Firebase
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoDuration: String = param.videoDuration.formatSecondsToTime()
        let videoStartTime: String? = param.videoStartTime?.roundedTime()
        let videoPercent: String = param.videoPercent?.rawValue ?? "not-set"
       
        return DictionaryBuilder()
            .set("video_duration", value: videoDuration)
            .set("video_start_time", value: videoStartTime)
            .set("video_percent", value: videoPercent)
            .build()
    }
}

final class playerReadyPermutiveMapper: EventMapper, PermutiveBaseMapper {
    func map(_ input: MetricsParam) -> [String: AnyHashable] {
        
        let builder = DictionaryBuilder()
        // parametros comunes de Firebase
        commonParams(from: input).forEach {
            builder.set($0.key, value: $0.value)
        }
        
        guard let param = input.videoParam else { return builder.build() }
        
        let videoDuration: String = param.videoDuration.formatSecondsToTime()
        let videoStartTime: String? = param.videoStartTime?.roundedTime()
        let videoType: String = param.videoType.rawValue
        
        return DictionaryBuilder()
            .set("video_duration", value: videoDuration)
            .set("video_start_time", value: videoStartTime)
            .set("video_type", value: videoType)
            .build()
    }
}

protocol PermutiveBaseMapper {
    func commonParams(from input: MetricsParam) -> [String: AnyHashable]
}

extension PermutiveBaseMapper {
    
    func commonParams(from input: MetricsParam) -> [String: AnyHashable] {
        let screeName:String = input.firebaseScreen ?? "not-set"
        var screenClass:String = "not-set"
        let channel:String = input.channel ?? "not-set"
        let program:String = input.programm ?? "not-set"
        let videoTitle:String = input.videoTitle?.limited(to: 100) ?? "not-set"
        let playlistTitle:String = input.playListTitle ?? "not-set"
        
        if let topVC = UIApplication.shared.topMostViewController() {
            screenClass = String(describing: type(of: topVC))
        }
        
        return DictionaryBuilder()
            .set("firebase_screen", value: screeName)
            .set("firebase_screen_class", value: screenClass)
            .set("channel", value: channel)
            .set("program", value: program)
            .set("video_title", value: videoTitle)
            .set("playlist_title", value: playlistTitle)
            .build()
    }
}
