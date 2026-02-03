//
//  AnalyticsDispatcher.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 30/01/26.
//

import Foundation


public protocol AnalyticsProvider {
    func logEvent(name: String , _ params: MetricsParam)
}

public final class AnalyticsDispatcher {

    // MARK: - Singleton
    public static let shared = AnalyticsDispatcher()

    // MARK: - Providers
    private var providers: [AnalyticsProvider] = []
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Configuration (solo una vez)
    public func configure(providers: [AnalyticsProvider]) {
        self.providers = providers
    }

    // MARK: - Public API
    
    func track<M: MetricsMapper>( name: String, input: M.Input, mapper: M ) {
            let params = mapper.map(input)

            providers.forEach {
                $0.logEvent(name: name, params)
            }
        }
    
}


@objc public final class AnalyticsObjCBridge: NSObject {

    @objc public static let shared = AnalyticsObjCBridge()

    private let mappers: [String: AnyDictionaryMetricsMapper] = [:
           // "home_dict": AnyDictionaryMetricsMapper(DictionaryHomeMetricsMapper()),
           // "video_dict": AnyDictionaryMetricsMapper(DictionaryVideoMetricsMapper())
        ]

    @objc public func track(
        eventName: String,
        params: [String: Any],
        className :String
    ) {
        
        guard let mapper = mappers[className] else {
            print("❌ error: clase no registrada \(className)")
            return
        }
        let metrics = mapper.map(params)
        
        AnalyticsDispatcher.shared.track(
            name: eventName,
            input: metrics,
            mapper: PassthroughMetricsMapper()
        )
    }
}


final class AnyDictionaryMetricsMapper {

    private let _map: ([String: Any]) -> MetricsParam

    init<M: MetricsMapper>(_ mapper: M) where M.Input == [String: Any] {
        self._map = mapper.map
    }

    func map(_ input: [String: Any]) -> MetricsParam {
        _map(input)
    }
}

struct PassthroughMetricsMapper: MetricsMapper {
    func map(_ input: MetricsParam) -> MetricsParam { input }
}


final class DictionaryBuilder {
    private var result: [String: AnyHashable] = [:]
    
    @discardableResult
    func set(_ key: String, value: Any?) -> Self {
        if let value = value as? AnyHashable {
            result[key] = value
        }
        return self
    }
    
    func build() -> [String: AnyHashable] {
        result
    }
}

protocol EventMapper {
    func map(_ input: MetricsParam) -> [String: AnyHashable]
}
