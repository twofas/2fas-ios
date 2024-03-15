// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
internal typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
internal enum Asset {
  internal static let aboutLogo = ImageAsset(name: "AboutLogo")
  internal static let addCategory = ImageAsset(name: "AddCategory")
  internal static let addServiceIconPlaceholder = ImageAsset(name: "AddServiceIconPlaceholder")
  internal static let guidesIcon = ImageAsset(name: "guidesIcon")
  internal static let imageIcon = ImageAsset(name: "imageIcon")
  internal static let keybordIcon = ImageAsset(name: "keybordIcon")
  internal static let alertIcon = ImageAsset(name: "AlertIcon")
  internal static let authRequestQuestion = ImageAsset(name: "AuthRequestQuestion")
  internal static let deleteSettingsIcon = ImageAsset(name: "DeleteSettingsIcon")
  internal static let backupDeleted = ImageAsset(name: "backupDeleted")
  internal static let backupSettingsIcon = ImageAsset(name: "backupSettingsIcon")
  internal static let barsBackground = ImageAsset(name: "BarsBackground")
  internal static let bracket = ImageAsset(name: "Bracket")
  internal static let aboutExtension = ImageAsset(name: "AboutExtension")
  internal static let pairingAlreadyPaired = ImageAsset(name: "PairingAlreadyPaired")
  internal static let pairingBackgroundOval1 = ImageAsset(name: "PairingBackgroundOval1")
  internal static let pairingBackgroundOval2 = ImageAsset(name: "PairingBackgroundOval2")
  internal static let pairingFailed = ImageAsset(name: "PairingFailed")
  internal static let pairingOval0 = ImageAsset(name: "PairingOval0")
  internal static let pairingOval1 = ImageAsset(name: "PairingOval1")
  internal static let pairingOval2 = ImageAsset(name: "PairingOval2")
  internal static let pairingOval3 = ImageAsset(name: "PairingOval3")
  internal static let pairingOval4 = ImageAsset(name: "PairingOval4")
  internal static let pairingSuccessful = ImageAsset(name: "PairingSuccessful")
  internal static let cloudBackup = ImageAsset(name: "CloudBackup")
  internal static let copyIcon = ImageAsset(name: "CopyIcon")
  internal static let deleteCodeButton = ImageAsset(name: "DeleteCodeButton")
  internal static let deleteForeverIcon = ImageAsset(name: "DeleteForeverIcon")
  internal static let deleteIcon = ImageAsset(name: "DeleteIcon")
  internal static let deleteScreenIcon = ImageAsset(name: "DeleteScreenIcon")
  internal static let deleteSmallIcon = ImageAsset(name: "DeleteSmallIcon")
  internal static let dragDropToken = ImageAsset(name: "DragDropToken")
  internal static let dragHandles = ImageAsset(name: "DragHandles")
  internal static let emptyNotifications = ImageAsset(name: "EmptyNotifications")
  internal static let emptyScreenBackground = ImageAsset(name: "EmptyScreenBackground")
  internal static let emptyScreenIcon = ImageAsset(name: "EmptyScreenIcon")
  internal static let emptyScreenSearch = ImageAsset(name: "EmptyScreenSearch")
  internal static let errorIcon = ImageAsset(name: "ErrorIcon")
  internal static let exportBackup = ImageAsset(name: "exportBackup")
  internal static let fileError = ImageAsset(name: "fileError")
  internal static let importBackup = ImageAsset(name: "importBackup")
  internal static let externalImportAegis = ImageAsset(name: "ExternalImportAegis")
  internal static let externalImportAndOTP = ImageAsset(name: "ExternalImportAndOTP")
  internal static let externalImportAuthenticatorPro = ImageAsset(name: "ExternalImportAuthenticatorPro")
  internal static let externalImportGoogleAuth = ImageAsset(name: "ExternalImportGoogleAuth")
  internal static let externalImportIconAegis = ImageAsset(name: "ExternalImportIconAegis")
  internal static let externalImportIconAndOTP = ImageAsset(name: "ExternalImportIconAndOTP")
  internal static let externalImportIconAuthenticatorPro = ImageAsset(name: "ExternalImportIconAuthenticatorPro")
  internal static let externalImportIconLastPass = ImageAsset(name: "ExternalImportIconLastPass")
  internal static let externalImportIconRaivo = ImageAsset(name: "ExternalImportIconRaivo")
  internal static let externalImportLastPass = ImageAsset(name: "ExternalImportLastPass")
  internal static let externalImportRavio = ImageAsset(name: "ExternalImportRavio")
  internal static let externalmportIconGoogleAuth = ImageAsset(name: "ExternalmportIconGoogleAuth")
  internal static let externalLinkIcon = ImageAsset(name: "ExternalLinkIcon")
  internal static let gaImport0 = ImageAsset(name: "gaImport0")
  internal static let gaImport1 = ImageAsset(name: "gaImport1")
  internal static let gaImport2 = ImageAsset(name: "gaImport2")
  internal static let collapseGroup = ImageAsset(name: "CollapseGroup")
  internal static let expandGroup = ImageAsset(name: "ExpandGroup")
  internal static let guide2fasType = ImageAsset(name: "guide_2fas_type")
  internal static let guideAccount = ImageAsset(name: "guide_account")
  internal static let guideAppButton = ImageAsset(name: "guide_app_button")
  internal static let guideGears = ImageAsset(name: "guide_gears")
  internal static let guidePhoneQr = ImageAsset(name: "guide_phone_qr")
  internal static let guidePushNotification = ImageAsset(name: "guide_push_notification")
  internal static let guideRetype = ImageAsset(name: "guide_retype")
  internal static let guideSecretKey = ImageAsset(name: "guide_secret_key")
  internal static let guideWebAccount1 = ImageAsset(name: "guide_web_account_1")
  internal static let guideWebAccount2 = ImageAsset(name: "guide_web_account_2")
  internal static let guideWebButton = ImageAsset(name: "guide_web_button")
  internal static let guideWebMenu = ImageAsset(name: "guide_web_menu")
  internal static let guideWebPhone = ImageAsset(name: "guide_web_phone")
  internal static let guideWebUrl = ImageAsset(name: "guide_web_url")
  internal static let iconArrowLeft = ImageAsset(name: "IconArrowLeft")
  internal static let infoIcon = ImageAsset(name: "InfoIcon")
  internal static let introductionBackground = ImageAsset(name: "IntroductionBackground")
  internal static let introductionEmptyHeader = ImageAsset(name: "IntroductionEmptyHeader")
  internal static let introductionGAImport = ImageAsset(name: "IntroductionGAImport")
  internal static let introductionLogo = ImageAsset(name: "IntroductionLogo")
  internal static let introductionPage0 = ImageAsset(name: "IntroductionPage0")
  internal static let introductionPage1 = ImageAsset(name: "IntroductionPage1")
  internal static let introductionPage2 = ImageAsset(name: "IntroductionPage2")
  internal static let logoGrid = ImageAsset(name: "LogoGrid")
  internal static let naviIconAdd = ImageAsset(name: "NaviIconAdd")
  internal static let naviIconAddFirst = ImageAsset(name: "NaviIconAddFirst")
  internal static let naviSortIcon = ImageAsset(name: "NaviSortIcon")
  internal static let navibarNewsIcon = ImageAsset(name: "NavibarNewsIcon")
  internal static let navibarNewsIconBadge = ImageAsset(name: "NavibarNewsIconBadge")
  internal static let notificationFeatures = ImageAsset(name: "NotificationFeatures")
  internal static let notificationNews = ImageAsset(name: "NotificationNews")
  internal static let notificationTips = ImageAsset(name: "NotificationTips")
  internal static let notificationUpdates = ImageAsset(name: "NotificationUpdates")
  internal static let notificationYoutube = ImageAsset(name: "NotificationYoutube")
  internal static let openGallery = ImageAsset(name: "OpenGallery")
  internal static let passwordHide = ImageAsset(name: "PasswordHide")
  internal static let passwordReveal = ImageAsset(name: "PasswordReveal")
  internal static let permissionsPushNotifications = ImageAsset(name: "PermissionsPushNotifications")
  internal static let radioDeselected = ImageAsset(name: "RadioDeselected")
  internal static let radioSelected = ImageAsset(name: "RadioSelected")
  internal static let radioSelectionDeselected = ImageAsset(name: "RadioSelectionDeselected")
  internal static let radioSelectionSelected = ImageAsset(name: "RadioSelectionSelected")
  internal static let refreshTokenCounter = ImageAsset(name: "RefreshTokenCounter")
  internal static let requestProvider = ImageAsset(name: "RequestProvider")
  internal static let requestSocial = ImageAsset(name: "RequestSocial")
  internal static let shareIcon = ImageAsset(name: "ShareIcon")
  internal static let warningSmall = ImageAsset(name: "WarningSmall")
  internal static let resetShield = ImageAsset(name: "ResetShield")
  internal static let revealIcon = ImageAsset(name: "RevealIcon")
  internal static let scanErrorAppStore = ImageAsset(name: "scanErrorAppStore")
  internal static let scanErrorDuplicateError = ImageAsset(name: "scanErrorDuplicateError")
  internal static let scanErrorGeneralError = ImageAsset(name: "scanErrorGeneralError")
  internal static let selectFromGalleryAdviceIcon = ImageAsset(name: "SelectFromGalleryAdviceIcon")
  internal static let settingsAbout = ImageAsset(name: "SettingsAbout")
  internal static let settingsActiveSearch = ImageAsset(name: "SettingsActiveSearch")
  internal static let settingsAppearance = ImageAsset(name: "SettingsAppearance")
  internal static let settingsArrow = ImageAsset(name: "SettingsArrow")
  internal static let settingsBrowserExtension = ImageAsset(name: "SettingsBrowserExtension")
  internal static let settingsChangePIN = ImageAsset(name: "SettingsChangePIN")
  internal static let settingsContactUs = ImageAsset(name: "SettingsContactUs")
  internal static let settingsDisablePIN = ImageAsset(name: "SettingsDisablePIN")
  internal static let settingsDonate = ImageAsset(name: "SettingsDonate")
  internal static let settingsExport = ImageAsset(name: "SettingsExport")
  internal static let settingsExternalImport = ImageAsset(name: "SettingsExternalImport")
  internal static let settingsFAQ = ImageAsset(name: "SettingsFAQ")
  internal static let settingsImport = ImageAsset(name: "SettingsImport")
  internal static let settingsInfo = ImageAsset(name: "SettingsInfo")
  internal static let settingsNextToken = ImageAsset(name: "SettingsNextToken")
  internal static let settingsPIN = ImageAsset(name: "SettingsPIN")
  internal static let settingsPrivacyPolicy = ImageAsset(name: "SettingsPrivacyPolicy")
  internal static let settingsTOC = ImageAsset(name: "SettingsTOC")
  internal static let settingsTellFriend = ImageAsset(name: "SettingsTellFriend")
  internal static let settingsTouchID = ImageAsset(name: "SettingsTouchID")
  internal static let settingsTrash = ImageAsset(name: "SettingsTrash")
  internal static let settingsValut = ImageAsset(name: "SettingsValut")
  internal static let settingsWidget = ImageAsset(name: "SettingsWidget")
  internal static let settingsWriteReview = ImageAsset(name: "SettingsWriteReview")
  internal static let trashEmptyIcon = ImageAsset(name: "TrashEmptyIcon")
  internal static let widgetWarningIcon = ImageAsset(name: "WidgetWarningIcon")
  internal static let shadowLine = ImageAsset(name: "ShadowLine")
  internal static let smallQRCodeIcon = ImageAsset(name: "SmallQRCodeIcon")
  internal static let socialDiscord = ImageAsset(name: "social_discord")
  internal static let socialFacebook = ImageAsset(name: "social_facebook")
  internal static let socialGithub = ImageAsset(name: "social_github")
  internal static let socialLinkedin = ImageAsset(name: "social_linkedin")
  internal static let socialReddit = ImageAsset(name: "social_reddit")
  internal static let socialTwitter = ImageAsset(name: "social_twitter")
  internal static let socialYoutube = ImageAsset(name: "social_youtube")
  internal static let socialLargeDiscord = ImageAsset(name: "SocialLargeDiscord")
  internal static let socialLargeGithub = ImageAsset(name: "SocialLargeGithub")
  internal static let socialLargeTwitter = ImageAsset(name: "SocialLargeTwitter")
  internal static let socialLargeYoutube = ImageAsset(name: "SocialLargeYoutube")
  internal static let startScreenCircle = ImageAsset(name: "StartScreenCircle")
  internal static let successIcon = ImageAsset(name: "SuccessIcon")
  internal static let tabBarIconServicesActive = ImageAsset(name: "TabBarIconServicesActive")
  internal static let tabBarIconServicesInactive = ImageAsset(name: "TabBarIconServicesInactive")
  internal static let tabBarIconSettingsActive = ImageAsset(name: "TabBarIconSettingsActive")
  internal static let tabBarIconSettingsInactive = ImageAsset(name: "TabBarIconSettingsInactive")
  internal static let tokenPlaceholder = ImageAsset(name: "TokenPlaceholder")
  internal static let warningIcon = ImageAsset(name: "WarningIcon")
  internal static let warningIconLarge = ImageAsset(name: "WarningIconLarge")
  internal static let iconRequestCompany = ImageAsset(name: "iconRequestCompany")
  internal static let iconRequestUser = ImageAsset(name: "iconRequestUser")
  internal static let notificationEditIcon = ImageAsset(name: "notificationEditIcon")
  internal static let orderIconFrame = ImageAsset(name: "orderIconFrame")
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

internal struct ImageAsset {
  internal fileprivate(set) var name: String

  #if os(macOS)
  internal typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  internal typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  internal var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  internal func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  internal var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

internal extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
internal extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
