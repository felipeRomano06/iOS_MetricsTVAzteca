//
//  AnalyticsDispatcher.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 30/01/26.
//

import Foundation


/// Protocol that defines a generic analytics provider.
///
/// Conforming types are responsible for translating the canonical
/// `MetricsParam` model into the format required by a specific
/// analytics SDK (e.g. Firebase, Permutive, etc).
///
/// This abstraction allows the app to:
/// - Send the same event to multiple analytics platforms
/// - Swap or add providers without modifying app-level code
/// - Keep analytics logic centralized and consistent
public protocol AnalyticsProvider {
    
    
    /// Logs an analytics event to the concrete analytics platform.
    ///
    /// - Parameters:
    ///   - name: The analytics event name as defined by the business or product team.
    ///   - params: Canonical metrics model containing all shared analytics data.
    ///
    /// Each provider is responsible for:
    /// - Mapping `MetricsParam` to its own SDK-specific structure
    /// - Handling optional values safely
    /// - Deciding which fields are relevant for that platform
    func logEvent(name: String , _ params: MetricsParam)
}

/// Central dispatcher responsible for sending analytics events
/// to all configured analytics providers (Firebase, Permutive, etc).
///
/// This class acts as the single entry point for tracking metrics
/// across the app, ensuring consistent behavior and homologated data.
public final class AnalyticsDispatcher {

    // MARK: - Singleton

    /// Shared singleton instance.
    /// The dispatcher must be configured once at app startup
    /// before any tracking calls are made.
    public static let shared = AnalyticsDispatcher()

    // MARK: - Providers

    /// List of analytics providers that will receive events.
    /// This is injected during app initialization via `configure(providers:)`.
    private var providers: [AnalyticsProvider] = []
    
    // MARK: - Init

    /// Private initializer to enforce singleton usage.
    private init() {}
    
    /// Configures the dispatcher with the analytics providers to be used.
    ///
    /// This method should be called **once**, typically during app startup
    /// (e.g. AppDelegate, SceneDelegate, or a MetricsAssembly).
    ///
    /// - Parameter providers: Concrete implementations of `AnalyticsProvider`
    ///   such as Firebase, Permutive, etc.
    public func configure(providers: [AnalyticsProvider]) {
        self.providers = providers
    }

    // MARK: - Tracking API

    /// Tracks an analytics event using a pre-built `MetricsParam`.
    ///
    /// This method is ideal for:
    /// - Simple or static events
    /// - Debug or example scenarios
    /// - Cases where no transformation logic is required
    ///
    /// - Parameters:
    ///   - name: The analytics event name.
    ///   - params: Canonical metrics model shared across all providers.
    public func track( event: AnalyticsEvent, params: MetricsParam) {
        providers.forEach {
            $0.logEvent(name: event.rawValue, params)
        }
    }
    
    
    /// Tracks an analytics event using a mapper to transform
    /// a specific input model into a `MetricsParam`.
    ///
    /// This method is ideal for:
    /// - Complex events
    /// - Feature-specific models
    /// - Maintaining separation between domain models and analytics
    ///
    /// - Parameters:
    ///   - name: The analytics event name.
    ///   - input: Feature-specific input model.
    ///   - mapper: Mapper responsible for converting the input
    ///     into the canonical `MetricsParam`.
    public func track<M: MetricsMapper>( event: AnalyticsEvent, input: M.Input, mapper: M ) {
        let params: MetricsParam = mapper.map(input)

        providers.forEach {
            $0.logEvent(name: event.rawValue, params)
        }
    }
    
}


/// Objective-C bridge for the analytics system.
///
/// This class exposes a simple API that allows Objective-C code
/// to send analytics events without knowing anything about:
/// - Swift generics
/// - Metrics mappers
/// - Analytics providers
///
/// Objective-C callers only need to:
/// - Provide an event name
/// - Send a dictionary with raw parameters
/// - Specify the mapper identifier (`className`)
///
/// Internally, this bridge:
/// - Resolves the correct dictionary mapper
/// - Converts raw data into `MetricsParam`
@objc
public final class AnalyticsObjCBridge: NSObject {
    
    /// Shared singleton instance used by Objective-C callers.
    @objc
    public static let shared = AnalyticsObjCBridge()

    /// Registry of dictionary-based metrics mappers.
    ///
    /// The key represents a mapper identifier (usually the original
    /// Objective-C class or feature name).
    ///
    /// Each mapper is responsible for transforming a `[String: Any]`
    /// dictionary into a strongly typed `MetricsParam`.
    private var mappers: [String: AnyDictionaryMetricsMapper] = [:
        // "home_dict": AnyDictionaryMetricsMapper(DictionaryHomeMetricsMapper()),
        // "video_dict": AnyDictionaryMetricsMapper(DictionaryVideoMetricsMapper())
    ]

    /// Tracks an analytics event coming from Objective-C code.
    ///
    /// - Parameters:
    ///   - eventName: Name of the analytics event to be tracked.
    ///   - params: Raw dictionary containing event parameters.
    ///   - className: Mapper identifier used to resolve the correct mapper.
    ///
    /// If no mapper is registered for the given `className`,
    /// the event is ignored and an error is logged.
    ///
    /// The mapped result is forwarded to the shared `AnalyticsDispatcher`
    /// using a passthrough mapper since the metrics are already normalized.
        
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
        
        guard let event = AnalyticsEvent(rawValue: eventName) else {
            print( "❌ error: event no registrado \(eventName)")
            return
        }
        
        AnalyticsDispatcher.shared.track(
            event: event,
            input: metrics,
            mapper: PassthroughMetricsMapper()
        )
    }
}


/// Type-erased wrapper for `MetricsMapper` implementations
/// whose input is a `[String: Any]` dictionary.
///
/// This class allows storing heterogeneous `MetricsMapper`
/// implementations in a single collection, as long as they:
/// - Accept `[String: Any]` as input
/// - Produce a `MetricsParam` as output
///
/// It is mainly used by the Objective-C bridge, where:
/// - Input data comes as dictionaries
/// - Generic constraints cannot be expressed in Objective-C
///
/// Internally, the mapper logic is stored as a closure.
final class AnyDictionaryMetricsMapper {

    /// Closure that performs the mapping from raw dictionary
    /// to a strongly typed `MetricsParam`.
    private let _map: ([String: Any]) -> MetricsParam

    /// Creates a type-erased mapper from any `MetricsMapper`
    /// that accepts `[String: Any]` as input.
    ///
    /// - Parameter mapper: Concrete mapper implementation.
    init<M: MetricsMapper>(_ mapper: M) where M.Input == [String: Any] {
        self._map = mapper.map
    }

    /// Maps a raw dictionary into a `MetricsParam`.
    ///
    /// - Parameter input: Raw key-value dictionary.
    /// - Returns: Normalized metrics model used by the analytics system.
    func map(_ input: [String: Any]) -> MetricsParam {
        _map(input)
    }
}


/// A `MetricsMapper` that performs no transformation.
///
/// This mapper simply returns the input `MetricsParam` as-is.
/// It is useful when the metrics model is already fully
/// constructed and no additional mapping logic is required.
///
/// Common use cases:
/// - Direct tracking from Swift code
/// - Reusing the same `track` pipeline without branching logic
/// - Objective-C bridges that already normalized the data
struct PassthroughMetricsMapper: MetricsMapper {
    /// Returns the input metrics without modification.
    ///
    /// - Parameter input: A fully constructed `MetricsParam`.
    /// - Returns: The same `MetricsParam` instance.
    func map(_ input: MetricsParam) -> MetricsParam { input }
}


/// A fluent builder for creating dictionaries used in analytics payloads.
///
/// This builder allows conditional insertion of values while keeping
/// the call site clean and readable. Only values that conform to
/// `AnyHashable` are added to the resulting dictionary.
///
/// Common use cases:
/// - Building analytics parameters
/// - Avoiding multiple `if let` blocks
/// - Creating dictionaries from optional values
final class DictionaryBuilder {
    
    /// Internal storage for the dictionary being built.
    private var result: [String: AnyHashable] = [:]
    
    /// Adds a value to the dictionary if it is non-nil and hashable.
    ///
    /// - Parameters:
    ///   - key: The dictionary key.
    ///   - value: An optional value to be inserted.
    /// - Returns: The same builder instance, allowing chaining.
    @discardableResult
    func set(_ key: String, value: Any?) -> Self {
        if let value = value as? AnyHashable {
            result[key] = value
        }
        return self
    }
    
    /// Builds and returns the final dictionary.
    ///
    /// - Returns: A dictionary containing all inserted key-value pairs.
    func build() -> [String: AnyHashable] {
        result
    }
}


/// Transforms a `MetricsParam` model into a dictionary payload
/// suitable for a specific analytics provider.
///
/// Each implementation of this protocol is responsible for:
/// - Selecting which fields are relevant
/// - Adapting naming conventions (snake_case, camelCase, etc.)
/// - Converting values to provider-compatible formats
///
/// Examples:
/// - FirebaseEventMapper
/// - PermutiveEventMapper
/// - CustomBackendEventMapper
protocol EventMapper {
    
    /// Maps a `MetricsParam` into a provider-specific dictionary.
    ///
    /// - Parameter input: The unified metrics model.
    /// - Returns: A dictionary ready to be sent to an analytics SDK.
    func map(_ input: MetricsParam) -> [String: AnyHashable]
}
