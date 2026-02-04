//
//  MetricsModel.swift
//  iOS_MetricsTVAzteca
//
//  Created by FELIPE ROMANO RODRIGUEZ on 30/01/26.
//



/// Events supported by the analytics system.
///
/// This enum centralizes all analytics event names used across
/// different analytics providers (Firebase, Permutive, etc.),
/// avoiding hardcoded strings and reducing the risk of typos.
///
/// Each case’s `rawValue` represents the exact event name
/// sent to the analytics platforms.
public enum AnalyticsEvent: String {

    /// Triggered when a screen is displayed in the app.
    /// Commonly sent along with information about the current view.
    case screenView = "screen_view"

    /// Triggered when a video is viewed.
    /// Applies to both VOD content and live streams.
    case videoView = "video_views"

    /// Sent when the video player is fully initialized
    /// and ready to start playback.
    case playerReady = "player_ready"

    /// Video-on-demand playback progress event.
    /// Used to report playback milestones (25%, 50%, 100%, etc.).
    case videoVODProgress = "video_VOD_progress"

    /// Event used to track the number of users
    /// watching a live stream or the watch count over time.
    case videoLiveWatchCount = "video_live_watch_count"

    /// Triggered when a login banner is presented to the user.
    case loginBanner = "login_banner"

    /// Sent when a user successfully completes the login flow.
    case loginSuccess = "login_success"

    /// Sent when an error occurs during the login process.
    case loginError = "login_error"

    /// Triggered when a survey is shown to the user.
    case surveyShow = "pd_show"

    /// Sent when a survey is successfully submitted by the user.
    case surveySend = "pd_send"

    /// Sent when an error occurs while displaying or submitting a survey.
    case surveyError = "pd_error"
}




/// Transforms an arbitrary input model into a unified `MetricsParam`.
///
/// This protocol defines the **first mapping layer** of the metrics pipeline.
/// It allows different input types (domain models, dictionaries, view models,
/// Obj-C payloads, etc.) to be normalized into a single metrics contract.
///
/// Examples of inputs:
/// - Strongly typed Swift models
/// - `[String: Any]` dictionaries from Objective-C
/// - UI-related structures (screen context, video state, etc.)
///
/// This abstraction ensures that:
/// - Business/domain code never depends on analytics SDKs
/// - Analytics providers always receive a normalized metrics model
public protocol MetricsMapper {
    
    /// The input type that will be converted into `MetricsParam`.
    associatedtype Input
    
    /// Maps an input value into the unified metrics model.
    ///
    /// - Parameter input: Any input type representing event context.
    /// - Returns: A normalized `MetricsParam` instance.
    func map(_ input: Input) -> MetricsParam
}


/// Unified metrics model used across the analytics SDK.
///
/// `MetricsParam` represents a normalized, provider-agnostic
/// container for analytics metadata. All events are eventually
/// transformed into this model before being dispatched to
/// specific analytics providers (Firebase, Permutive, etc.).
///
/// This structure is intentionally flexible:
/// - All properties are optional unless strictly required
/// - It supports multiple event categories (screen, video, login, survey)
/// - It allows providers to pick only what they need
///
/// The goal is to decouple:
/// - App/business logic
/// - Event semantics
/// - Provider-specific payload formats
public struct MetricsParam {

    // MARK: - Screen / Navigation

    /// Screen name used mainly by Firebase Analytics.
    public var firebaseScreen: String?

    /// Logical section of the app (e.g. Home, Sports, Video).
    public var section: String?

    /// Distribution channel or platform context.
    public var channel: String?

    /// Program or show name.
    public var programm: String?

    // MARK: - Video

    /// Video title.
    public var videoTitle: String?

    /// Unique video identifier.
    public var videoID: String?

    /// Playlist title when applicable.
    public var playListTitle: String?

    // MARK: - User / Context

    /// ISO country code (e.g. MX, US).
    public var countryCode: String?

    /// User login status.
    public var loginStatus: LoginStatusType = .anonymous

    /// Advertising Identifier (IDFA).
    public var idfa: String?

    /// Internal media or integration identifier.
    public var im: String?

    /// Indicates whether the content is restricted.
    public var isRestricted: ContentRestrictiveType = .isFalse

    // MARK: - Nested Contexts

    /// Additional video-related metrics.
    public var videoParam: VideoMetricsParam?

    /// Login-related metrics.
    public var loginParam: LoginMetricsParam?

    /// Survey-related metrics.
    public var surveyParam: SurveyMetricsParam?

    // MARK: - Initializer

    /// Creates a new `MetricsParam` instance.
    ///
    /// All parameters are optional except those explicitly required
    /// to ensure sane defaults for analytics consistency.
    public init(
        firebaseScreen: String? = nil,
        section: String? = nil,
        channel: String? = nil,
        programm: String? = nil,
        videoTitle: String? = nil,
        videoID: String? = nil,
        playListTitle: String? = nil,
        countryCode: String? = nil,
        loginStatus: LoginStatusType = .anonymous,
        idfa: String? = nil,
        im: String? = nil,
        isRestricted: ContentRestrictiveType = .isFalse,
        videoParam: VideoMetricsParam? = nil,
        loginParam: LoginMetricsParam? = nil,
        surveyParam: SurveyMetricsParam? = nil
    ) {
        self.firebaseScreen = firebaseScreen
        self.section = section
        self.channel = channel
        self.programm = programm
        self.videoTitle = videoTitle
        self.videoID = videoID
        self.playListTitle = playListTitle
        self.countryCode = countryCode
        self.loginStatus = loginStatus
        self.idfa = idfa
        self.im = im
        self.isRestricted = isRestricted
        self.videoParam = videoParam
        self.loginParam = loginParam
        self.surveyParam = surveyParam
    }
}


/// Parámetros de métricas relacionados con encuestas (surveys).
/// Se utiliza para trackear información básica de un formulario presentado al usuario.
public struct SurveyMetricsParam {

    /// Título del formulario o encuesta.
    /// Ejemplo: "Encuesta de satisfacción"
    public var formTitle: String = "not-set"

    /// Número total de preguntas del formulario.
    /// Se maneja como `String` para mantener compatibilidad con proveedores de analytics.
    public var questionCount: String = "not-set"

    /// Identificador único del formulario o encuesta.
    public var formID: String = "not-set"

    /// Inicializador designado para construir métricas de encuesta.
    /// - Parameters:
    ///   - formTitle: Título del formulario.
    ///   - questionCount: Número de preguntas.
    ///   - formID: Identificador del formulario.
    public init(
        formTitle: String,
        questionCount: String,
        formID: String
    ) {
        self.formTitle = formTitle
        self.questionCount = questionCount
        self.formID = formID
    }
}


/// Parámetros de métricas relacionados con el flujo de login.
/// Se usa para complementar eventos de autenticación.
public struct LoginMetricsParam {

    /// Tipo de banner o presentación usada para el login.
    public var bannerType: LoginBannerType? = nil

    /// Fuente desde la cual el usuario inició sesión.
    public var loginSource: LoginSource? = nil

    /// Indica si el usuario es nuevo.
    /// Generalmente valores como "true" / "false" o "yes" / "no".
    public var newUser: String? = nil

    /// Inicializador flexible para métricas de login.
    /// Todos los parámetros son opcionales para permitir uso parcial.
    /// - Parameters:
    ///   - bannerType: Tipo de banner de login.
    ///   - loginSource: Fuente del login.
    ///   - newUser: Indica si es un usuario nuevo.
    public init(
        bannerType: LoginBannerType? = nil,
        loginSource: LoginSource? = nil,
        newUser: String? = nil
    ) {
        self.bannerType = bannerType
        self.loginSource = loginSource
        self.newUser = newUser
    }
}


/// Tipos de presentación visual del banner de login.
public enum LoginBannerType: String {

    /// Banner en pantalla completa.
    case fullScreen = "full"

    /// Banner presentado como modal.
    case modalScreen = "modal"
}


/// Origen desde el cual el usuario realizó el login.
public enum LoginSource: String {

    /// Login mediante correo electrónico.
    case email = "email"

    /// Login mediante Facebook.
    case facebook = "Facebook"

    /// Login mediante Apple.
    case apple = "apple"

    /// Login mediante Google.
    case google = "Google"
}


/// Parámetros de métricas relacionados con la reproducción de video.
/// Se utiliza para trackear eventos de inicio, progreso y finalización.
public struct VideoMetricsParam {

    /// Tiempo (en segundos) en el que inició la reproducción del video.
    /// Útil para medir latencia o retrasos al iniciar playback.
    public var videoStartTime: Float?

    /// Tipo de video reproducido (VOD o Live).
    /// Por defecto se considera VOD.
    public var videoType: VideoType = .vod

    /// Duración total del video en segundos.
    /// Para transmisiones en vivo puede mantenerse en 0.
    public var videoDuration: Float = 0

    /// Porcentaje de avance del video alcanzado por el usuario.
    /// Se usa normalmente en eventos de progreso.
    public var videoPercent: VideoPercent? = nil

    /// Tiempo acumulado de reproducción en segundos.
    /// Puede utilizarse para métricas de engagement.
    public var videoTimeCount: Int? = nil

    /// Inicializador implícito.
    /// Permite construir el objeto usando valores por defecto.
    public init() {}
}


/// Representa hitos de avance del video expresados en porcentaje.
/// Se utiliza comúnmente para eventos de progreso.
public enum VideoPercent: String {

    /// El usuario alcanzó el 25% del video.
    case quarter = "25%"

    /// El usuario alcanzó el 50% del video.
    case half = "50%"

    /// El usuario terminó el 100% del video.
    case ended = "100%"
}

/// Utilidades para convertir valores externos a `VideoPercent`.
extension VideoPercent {

    /// Convierte un `String` en su equivalente `VideoPercent`.
    /// Útil cuando el valor proviene de fuentes dinámicas
    /// como diccionarios, JSON o bridges Objective-C.
    ///
    /// - Parameter value: Valor en formato string (ej. "25%", "50%", "100%").
    /// - Returns: El `VideoPercent` correspondiente o `nil` si no coincide.
    static func from(_ value: String?) -> VideoPercent? {
        switch value {
        case "25%": return .quarter
        case "50%": return .half
        case "100%": return .ended
        default: return nil
        }
    }
}

/// Tipo de contenido de video reproducido.
public enum VideoType: String {

    /// Transmisión en vivo.
    case live = "Live"

    /// Video bajo demanda.
    case vod = "VOD"
}


/// Representa el estado de autenticación del usuario
/// al momento de enviar un evento de analytics.
public enum LoginStatusType: String {

    /// Usuario autenticado (sesión iniciada).
    case connected = "connected"

    /// Usuario no autenticado o anónimo.
    case anonymous = "anonymous"
}


/// Indica si un contenido tiene restricciones
/// y el nivel de obligatoriedad del acceso.
public enum ContentRestrictiveType: String {

    /// El contenido no tiene restricciones.
    case isFalse = "false"

    /// El contenido es restringido y requiere acción obligatoria.
    case notOptional = "not optional"

    /// El contenido es restringido pero el acceso es opcional.
    case optional = "optional"
}


/// Utilidades para construir un `ContentRestrictiveType`
/// a partir de valores dinámicos (ej. diccionarios, JSON u Obj-C).
extension ContentRestrictiveType {

    /// Convierte un valor genérico en su tipo de restricción correspondiente.
    ///
    /// Reglas de conversión:
    /// - "1" → contenido restringido obligatorio
    /// - "2" → contenido restringido opcional
    /// - cualquier otro valor → sin restricción
    ///
    /// - Parameter value: Valor dinámico recibido desde fuentes externas.
    /// - Returns: El `ContentRestrictiveType` correspondiente.
    static func from(_ value: Any?) -> ContentRestrictiveType {
        switch value as? String {
        case "1":
            return .notOptional
        case "2":
            return .optional
        default:
            return .isFalse
        }
    }
}


