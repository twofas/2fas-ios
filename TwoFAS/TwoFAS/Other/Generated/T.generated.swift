//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2023 Two Factor Authentication Service, Inc.
//  Contributed by Zbigniew Cisiński. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program. If not, see <https://www.gnu.org/licenses/>
//

// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum T {
  /// Open source licenses
  internal static let aboutLicenses = T.tr("Localizable", "about_licenses", fallback: "Open source licenses")
  /// There was a problem with your Google Drive account permissions. Try to turn the sync on and off.
  internal static let backupErrorAuth = T.tr("Localizable", "backup_error_auth", fallback: "There was a problem with your Google Drive account permissions. Try to turn the sync on and off.")
  /// An error occurred during backup decryption. Please set your password again.
  internal static let backupErrorDecryptUnknown = T.tr("Localizable", "backup_error_decrypt_unknown", fallback: "An error occurred during backup decryption. Please set your password again.")
  /// An error occurred during backup encryption. Please set your password again.
  internal static let backupErrorEncryptUnknown = T.tr("Localizable", "backup_error_encrypt_unknown", fallback: "An error occurred during backup encryption. Please set your password again.")
  /// You need an active Internet connection to sync your backup. Please turn on your network connection and try again.
  internal static let backupErrorNetwork = T.tr("Localizable", "backup_error_network", fallback: "You need an active Internet connection to sync your backup. Please turn on your network connection and try again.")
  /// Your backup is password protected. Turn it on and enter your password.
  internal static let backupErrorNoPassword = T.tr("Localizable", "backup_error_no_password", fallback: "Your backup is password protected. Turn it on and enter your password.")
  /// An error occurred during backup sync. Please restart the app after a couple of minutes and try again.
  internal static let backupErrorUnknown = T.tr("Localizable", "backup_error_unknown", fallback: "An error occurred during backup sync. Please restart the app after a couple of minutes and try again.")
  /// Your backup is password protected but provided password is incorrect. Turn it on and enter your password.
  internal static let backupErrorWrongPassword = T.tr("Localizable", "backup_error_wrong_password", fallback: "Your backup is password protected but provided password is incorrect. Turn it on and enter your password.")
  /// Automatically store and sync your backup file in the hidden folder on your Google Drive. This folder is only accessible to the 2FAS app.
  internal static let backupExplanationMsg = T.tr("Localizable", "backup_explanation_msg", fallback: "Automatically store and sync your backup file in the hidden folder on your Google Drive. This folder is only accessible to the 2FAS app.")
  /// Turn On
  internal static let backupNoticeCta = T.tr("Localizable", "backup_notice_cta", fallback: "Turn On")
  /// Maybe Later
  internal static let backupNoticeLater = T.tr("Localizable", "backup_notice_later", fallback: "Maybe Later")
  /// Turn on 2FAS Backup and keep your codes secure in Google Drive.
  internal static let backupNoticeMsg = T.tr("Localizable", "backup_notice_msg", fallback: "Turn on 2FAS Backup and keep your codes secure in Google Drive.")
  /// 2FAS Backup
  internal static let backupNoticeTitle = T.tr("Localizable", "backup_notice_title", fallback: "2FAS Backup")
  /// Google account
  internal static let backupSettingsAccountTitle = T.tr("Localizable", "backup_settings_account_title", fallback: "Google account")
  /// If you delete this file from your Google Drive, synchronization on all synchronized devices will be disabled, and tokens will remain only on this and other devices via local storage.
  internal static let backupSettingsDeleteSubtitle = T.tr("Localizable", "backup_settings_delete_subtitle", fallback: "If you delete this file from your Google Drive, synchronization on all synchronized devices will be disabled, and tokens will remain only on this and other devices via local storage.")
  /// Delete backup file from Google Drive
  internal static let backupSettingsDeleteTitle = T.tr("Localizable", "backup_settings_delete_title", fallback: "Delete backup file from Google Drive")
  /// Remove the password for your Google Drive backup file.
  internal static let backupSettingsPasswordRemoveSubtitle = T.tr("Localizable", "backup_settings_password_remove_subtitle", fallback: "Remove the password for your Google Drive backup file.")
  /// Remove password
  internal static let backupSettingsPasswordRemoveTitle = T.tr("Localizable", "backup_settings_password_remove_title", fallback: "Remove password")
  /// Secure a Google Drive backup file with a custom password.
  internal static let backupSettingsPasswordSetSubtitle = T.tr("Localizable", "backup_settings_password_set_subtitle", fallback: "Secure a Google Drive backup file with a custom password.")
  /// Set password
  internal static let backupSettingsPasswordSetTitle = T.tr("Localizable", "backup_settings_password_set_title", fallback: "Set password")
  /// Last synchronization
  internal static let backupSettingsSyncTitle = T.tr("Localizable", "backup_settings_sync_title", fallback: "Last synchronization")
  /// Cancel
  internal static let backupTurnOffCancel = T.tr("Localizable", "backup_turn_off_cancel", fallback: "Cancel")
  /// Disable Sync
  internal static let backupTurnOffCta = T.tr("Localizable", "backup_turn_off_cta", fallback: "Disable Sync")
  /// 2FA tokens will remain on this device and on your Google Drive, but will not be synced. You will also be logged out from your Google Account.
  internal static let backupTurnOffMsg1 = T.tr("Localizable", "backup_turn_off_msg1", fallback: "2FA tokens will remain on this device and on your Google Drive, but will not be synced. You will also be logged out from your Google Account.")
  /// Remember, in case of loss or damage to this device or app removal, you may not be able to recover your tokens, and you will lose access to online accounts secured by 2FA.
  internal static let backupTurnOffMsg2 = T.tr("Localizable", "backup_turn_off_msg2", fallback: "Remember, in case of loss or damage to this device or app removal, you may not be able to recover your tokens, and you will lose access to online accounts secured by 2FA.")
  /// Turning Google Drive Sync off?
  internal static let backupTurnOffTitle = T.tr("Localizable", "backup_turn_off_title", fallback: "Turning Google Drive Sync off?")
  /// Use PIN this time
  internal static let biometricDialogAuthCancel = T.tr("Localizable", "biometric_dialog_auth_cancel", fallback: "Use PIN this time")
  /// Use your biometric credential
  internal static let biometricDialogAuthSubtitle = T.tr("Localizable", "biometric_dialog_auth_subtitle", fallback: "Use your biometric credential")
  /// Authenticate
  internal static let biometricDialogAuthTitle = T.tr("Localizable", "biometric_dialog_auth_title", fallback: "Authenticate")
  /// Cancel
  internal static let biometricDialogSetupCancel = T.tr("Localizable", "biometric_dialog_setup_cancel", fallback: "Cancel")
  /// Enable authentication
  internal static let biometricDialogSetupTitle = T.tr("Localizable", "biometric_dialog_setup_title", fallback: "Enable authentication")
  /// Sorry, brand not found
  internal static let brandEmptyMsg = T.tr("Localizable", "brand_empty_msg", fallback: "Sorry, brand not found")
  /// Browser name
  internal static let browserExtensionBrowserDialog = T.tr("Localizable", "browser_extension_browser_dialog", fallback: "Browser name")
  /// 2FAS will send you PUSH notifications whenever you log in to your online services using this web browser. You will no longer need to re-type your tokens for each use.
  internal static let browserExtensionResultSuccessDescription = T.tr("Localizable", "browser_extension_result_success_description", fallback: "2FAS will send you PUSH notifications whenever you log in to your online services using this web browser. You will no longer need to re-type your tokens for each use.")
  /// 2 F A S
  internal static let cfBundleSpokenName = T.tr("Localizable", "CFBundleSpokenName", fallback: "2 F A S")
  /// Advanced
  internal static let customizationAdvanced = T.tr("Localizable", "customization_advanced", fallback: "Advanced")
  /// Change branding
  internal static let customizationChangeBrand = T.tr("Localizable", "customization_change_brand", fallback: "Change branding")
  /// Edit label
  internal static let customizationEditLabel = T.tr("Localizable", "customization_edit_label", fallback: "Edit label")
  /// Personalization
  internal static let customizationPersonalization = T.tr("Localizable", "customization_personalization", fallback: "Personalization")
  /// Request an icon
  internal static let customizationRequestIcon = T.tr("Localizable", "customization_request_icon", fallback: "Request an icon")
  /// Service Assignment
  internal static let customizationServiceAssignment = T.tr("Localizable", "customization_service_assignment", fallback: "Service Assignment")
  /// Delete
  internal static let deleteServiceCta = T.tr("Localizable", "delete_service_cta", fallback: "Delete")
  /// from your 2FAS service list.
  /// 
  /// Remember, as long as you have second-factor authentication turned on, you will not log in to %s account without this token.
  internal static func deleteServiceMsg(_ p1: UnsafePointer<CChar>) -> String {
    return T.tr("Localizable", "delete_service_msg", p1, fallback: "from your 2FAS service list.\n\nRemember, as long as you have second-factor authentication turned on, you will not log in to %s account without this token.")
  }
  /// You are deleting
  internal static let deleteServiceTitle = T.tr("Localizable", "delete_service_title", fallback: "You are deleting")
  /// Export
  internal static let exportBackupCta = T.tr("Localizable", "export_backup_cta", fallback: "Export")
  /// Export this file to keep your 2FAS tokens securely backed up. You can import it later to this or other devices using the 2FAS app.
  internal static let exportBackupMsg = T.tr("Localizable", "export_backup_msg", fallback: "Export this file to keep your 2FAS tokens securely backed up. You can import it later to this or other devices using the 2FAS app.")
  /// Export file without password
  /// (not recommended)
  internal static let exportBackupPass = T.tr("Localizable", "export_backup_pass", fallback: "Export file without password\n(not recommended)")
  /// Share
  internal static let exportBackupShareCta = T.tr("Localizable", "export_backup_share_cta", fallback: "Share")
  /// Your backup file is ready for export
  internal static let exportBackupTitle = T.tr("Localizable", "export_backup_title", fallback: "Your backup file is ready for export")
  /// Aegis
  internal static let externalimportAegis = T.tr("Localizable", "externalimport_aegis", fallback: "Aegis")
  /// You can import your tokens to 2FAS from different apps. Choose an app from the list and follow the instructions.
  internal static let externalimportDescription = T.tr("Localizable", "externalimport_description", fallback: "You can import your tokens to 2FAS from different apps. Choose an app from the list and follow the instructions.")
  /// Google Authenticator
  internal static let externalimportGoogleAuthenticator = T.tr("Localizable", "externalimport_google_authenticator", fallback: "Google Authenticator")
  /// Raivo OTP
  internal static let externalimportRaivo = T.tr("Localizable", "externalimport_raivo", fallback: "Raivo OTP")
  /// Select app
  internal static let externalimportSelectApp = T.tr("Localizable", "externalimport_select_app", fallback: "Select app")
  /// In order to sync with Google, you need to enable an Internet connection.
  internal static let gdriveInternetMsg = T.tr("Localizable", "gdrive_internet_msg", fallback: "In order to sync with Google, you need to enable an Internet connection.")
  /// Internet Connection Required
  internal static let gdriveInternetTitle = T.tr("Localizable", "gdrive_internet_title", fallback: "Internet Connection Required")
  /// We need Google Drive permission in order to save the backup files in app data.
  internal static let gdrivePermissionMsg = T.tr("Localizable", "gdrive_permission_msg", fallback: "We need Google Drive permission in order to save the backup files in app data.")
  /// Google Drive Permission
  internal static let gdrivePermissionTitle = T.tr("Localizable", "gdrive_permission_title", fallback: "Google Drive Permission")
  /// In order to revoke access to Google Drive, you need to enable the Internet connection.
  internal static let gdriveWipeInternetMsg = T.tr("Localizable", "gdrive_wipe_internet_msg", fallback: "In order to revoke access to Google Drive, you need to enable the Internet connection.")
  /// Are you sure you want to delete this group?
  internal static let groupsDeleteMsg = T.tr("Localizable", "groups_delete_msg", fallback: "Are you sure you want to delete this group?")
  /// Import
  internal static let importBackupCta = T.tr("Localizable", "import_backup_cta", fallback: "Import")
  /// You are going to import backup file with
  internal static let importBackupMsg1 = T.tr("Localizable", "import_backup_msg1", fallback: "You are going to import backup file with")
  /// The file will be synchronised with the app's service list.
  internal static let importBackupMsg2 = T.tr("Localizable", "import_backup_msg2", fallback: "The file will be synchronised with the app's service list.")
  /// Import backup from the file
  internal static let importBackupTitle = T.tr("Localizable", "import_backup_title", fallback: "Import backup from the file")
  /// Services successfully imported!
  internal static let importGaSuccess = T.tr("Localizable", "import_ga_success", fallback: "Services successfully imported!")
  /// System error! There is no system gallery app.
  internal static let intentErrorNoGalleryApp = T.tr("Localizable", "intent_error_no_gallery_app", fallback: "System error! There is no system gallery app.")
  /// Used for scanning QR-codes
  internal static let nsCameraUsageDescription = T.tr("Localizable", "NSCameraUsageDescription", fallback: "Used for scanning QR-codes")
  /// You can unlock the application using Face ID
  internal static let nsFaceIDUsageDescription = T.tr("Localizable", "NSFaceIDUsageDescription", fallback: "You can unlock the application using Face ID")
  /// PIN does not match! Please try again.
  internal static let securityErrorNoMatch = T.tr("Localizable", "security_error_no_match", fallback: "PIN does not match! Please try again.")
  /// Developer Options
  internal static let settingsDeveloperOptions = T.tr("Localizable", "settings_developer_options", fallback: "Developer Options")
  /// Please update to the newest 2FAS version to get all features and maintain a high-security level.
  internal static let updateAppMsg = T.tr("Localizable", "update_app_msg", fallback: "Please update to the newest 2FAS version to get all features and maintain a high-security level.")
  /// Update app
  internal static let updateAppTitle = T.tr("Localizable", "update_app_title", fallback: "Update app")
  /// No services added
  internal static let widgetsEmptyMsg = T.tr("Localizable", "widgets_empty_msg", fallback: "No services added")
  /// Select which services will be visible on the widget:
  internal static let widgetsSelectMsg = T.tr("Localizable", "widgets_select_msg", fallback: "Select which services will be visible on the widget:")
  /// Yes, I am sure
  internal static let widgetsWarningCta = T.tr("Localizable", "widgets_warning_cta", fallback: "Yes, I am sure")
  /// Tokens visible in the widget are not protected by your PIN code.
  /// 
  /// Are you sure you want to display your tokens in the widget?
  internal static let widgetsWarningMsg = T.tr("Localizable", "widgets_warning_msg", fallback: "Tokens visible in the widget are not protected by your PIN code.\n\nAre you sure you want to display your tokens in the widget?")
  /// WARNING!
  internal static let widgetsWarningTitle = T.tr("Localizable", "widgets_warning_title", fallback: "WARNING!")
  internal enum Android {
    /// 2FAS Auth
    internal static let appName = T.tr("Localizable", "android__app_name", fallback: "2FAS Auth")
  }
  internal enum App {
    /// 2FAS Authenticator
    internal static let name = T.tr("Localizable", "app__name", fallback: "2FAS Authenticator")
  }
  internal enum Backup {
    /// 2FAS Backup
    internal static let _2fasBackup = T.tr("Localizable", "backup__2fas_backup", fallback: "2FAS Backup")
    /// 2FAS Backup will be disabled to protect its integrity
    internal static let backupDisabledTitle = T.tr("Localizable", "backup__backup_disabled_title", fallback: "2FAS Backup will be disabled to protect its integrity")
    /// Set a password for this backup file
    internal static let backupFilePasswordTitle = T.tr("Localizable", "backup__backup_file_password_title", fallback: "Set a password for this backup file")
    /// Backup removal
    internal static let backupRemoval = T.tr("Localizable", "backup__backup_removal", fallback: "Backup removal")
    /// Can't read this file. It can be damaged, or there was an error while trying to access it. Please choose another one
    internal static let cantReadFileError = T.tr("Localizable", "backup__cant_read_file_error", fallback: "Can't read this file. It can be damaged, or there was an error while trying to access it. Please choose another one")
    /// Choose another file
    internal static let chooseAntotherFile = T.tr("Localizable", "backup__choose_antother_file", fallback: "Choose another file")
    /// Cloud Backup
    internal static let cloudBackup = T.tr("Localizable", "backup__cloud_backup", fallback: "Cloud Backup")
    /// Delete 2FAS Backup
    internal static let delete2fasBackup = T.tr("Localizable", "backup__delete_2fas_backup", fallback: "Delete 2FAS Backup")
    /// I want to delete the Backup
    internal static let deleteTitle = T.tr("Localizable", "backup__delete_title", fallback: "I want to delete the Backup")
    /// This file is encrypted. We support only unencrypted files
    internal static let encryptedFilesNotSupported = T.tr("Localizable", "backup__encrypted_files_not_supported", fallback: "This file is encrypted. We support only unencrypted files")
    /// Type in a password for this backup file to proceed with the import process
    internal static let enterPasswordTitle = T.tr("Localizable", "backup__enter_password_title", fallback: "Type in a password for this backup file to proceed with the import process")
    /// Error while exporting the file
    internal static let errorWhileExportingFile = T.tr("Localizable", "backup__error_while_exporting_file", fallback: "Error while exporting the file")
    /// Export
    internal static let export = T.tr("Localizable", "backup__export", fallback: "Export")
    /// Export backup to file
    internal static let exportToBackupFile = T.tr("Localizable", "backup__export_to_backup_file", fallback: "Export backup to file")
    /// Export to file
    internal static let exportToFile = T.tr("Localizable", "backup__export_to_file", fallback: "Export to file")
    /// File Backup
    internal static let fileBackup = T.tr("Localizable", "backup__file_backup", fallback: "File Backup")
    /// Use File Backup for offline backup of your tokens
    internal static let fileBackupOfflineTitle = T.tr("Localizable", "backup__file_backup_offline_title", fallback: "Use File Backup for offline backup of your tokens")
    /// File error!
    internal static let fileError = T.tr("Localizable", "backup__file_error", fallback: "File error!")
    /// Google Drive has been disabled by the user
    internal static let googleDriveDisabledTitle = T.tr("Localizable", "backup__google_drive_disabled_title", fallback: "Google Drive has been disabled by the user")
    /// Google Drive is not available
    internal static let googleDriveNotAvailable = T.tr("Localizable", "backup__google_drive_not_available", fallback: "Google Drive is not available")
    /// There's a problem with iCloud. Check system settings
    internal static let googleDriveProblemTitle = T.tr("Localizable", "backup__google_drive_problem_title", fallback: "There's a problem with iCloud. Check system settings")
    /// iCloud has been disabled by the user
    internal static let icloudDisabledTitle = T.tr("Localizable", "backup__icloud_disabled_title", fallback: "iCloud has been disabled by the user")
    /// iCloud is not available
    internal static let icloudNotAvailable = T.tr("Localizable", "backup__icloud_not_available", fallback: "iCloud is not available")
    /// There's a problem with iCloud. Check system settings
    internal static let icloudProblem = T.tr("Localizable", "backup__icloud_problem", fallback: "There's a problem with iCloud. Check system settings")
    /// iCloud Sync
    internal static let icloudSync = T.tr("Localizable", "backup__icloud_sync", fallback: "iCloud Sync")
    /// Import
    internal static let `import` = T.tr("Localizable", "backup__import", fallback: "Import")
    /// Import backup file
    internal static let importBackupFile = T.tr("Localizable", "backup__import_backup_file", fallback: "Import backup file")
    /// Import completed successfuly
    internal static let importCompletedSuccessfuly = T.tr("Localizable", "backup__import_completed_successfuly", fallback: "Import completed successfuly")
    /// Import file
    internal static let importFile = T.tr("Localizable", "backup__import_file", fallback: "Import file")
    /// You can import exported files on other devices with the 2FAS application
    internal static let importFileTitle = T.tr("Localizable", "backup__import_file_title", fallback: "You can import exported files on other devices with the 2FAS application")
    /// You're going to import a backup file containing
    internal static let importOtherDevices = T.tr("Localizable", "backup__import_other_devices", fallback: "You're going to import a backup file containing")
    /// Incorrect character. Use only letter A-Z, a-z, digits and special characters: -_/!#$%&+*~@?=^.,'(){}[]:;<>|
    internal static let incorrectCharacterError = T.tr("Localizable", "backup__incorrect_character_error", fallback: "Incorrect character. Use only letter A-Z, a-z, digits and special characters: -_/!#$%&+*~@?=^.,'(){}[]:;<>|")
    /// Incorrect Password
    internal static let incorrectPassword = T.tr("Localizable", "backup__incorrect_password", fallback: "Incorrect Password")
    /// Couldn't backup tokens because "%@" secret contains illegal characters. Remove it from list and try again
    internal static func incorrectSecret(_ p1: Any) -> String {
      return T.tr("Localizable", "backup__incorrect_secret", String(describing: p1), fallback: "Couldn't backup tokens because \"%@\" secret contains illegal characters. Remove it from list and try again")
    }
    /// %d new services
    internal static func newServices(_ p1: Int) -> String {
      return T.tr("Localizable", "backup__new_services", p1, fallback: "%d new services")
    }
    /// This file is in a newer format version than the one the app supports
    internal static let newerFormatNotSupported = T.tr("Localizable", "backup__newer_format_not_supported", fallback: "This file is in a newer format version than the one the app supports")
    /// Nothing to import
    internal static let noNewServices = T.tr("Localizable", "backup__no_new_services", fallback: "Nothing to import")
    /// Either this file is empty, or all the services within are already available in the app
    internal static let noNewServicesError = T.tr("Localizable", "backup__no_new_services_error", fallback: "Either this file is empty, or all the services within are already available in the app")
    /// Password
    internal static let password = T.tr("Localizable", "backup__password", fallback: "Password")
    /// Passwords don't match
    internal static let passwordsDontMatch = T.tr("Localizable", "backup__passwords_dont_match", fallback: "Passwords don't match")
    /// Repeat password
    internal static let repeatPassword = T.tr("Localizable", "backup__repeat_password", fallback: "Repeat password")
    /// Save and export
    internal static let saveAndExport = T.tr("Localizable", "backup__save_and_export", fallback: "Save and export")
    /// Save file
    internal static let saveFile = T.tr("Localizable", "backup__save_file", fallback: "Save file")
    /// RECOMMENDED: iCloud Sync keeps your tokens secure in Apple iCloud in case of loss or damage to your device. Keep it turned on.
    internal static let sectionDescription = T.tr("Localizable", "backup__section_description", fallback: "RECOMMENDED: iCloud Sync keeps your tokens secure in Apple iCloud in case of loss or damage to your device. Keep it turned on.")
    /// RECOMMENDED: Google Drive Sync keeps your tokens secure in Google Drive in case of loss or damage to your device. Keep it turned on.
    internal static let sectionDescriptionGoogle = T.tr("Localizable", "backup__section_description_google", fallback: "RECOMMENDED: Google Drive Sync keeps your tokens secure in Google Drive in case of loss or damage to your device. Keep it turned on.")
    /// %d services imported from file
    internal static func servicesImportedCount(_ p1: Int) -> String {
      return T.tr("Localizable", "backup__services_imported_count", p1, fallback: "%d services imported from file")
    }
    /// Services from the file will be merged with the ones in your app
    internal static let servicesMergeTitle = T.tr("Localizable", "backup__services_merge_title", fallback: "Services from the file will be merged with the ones in your app")
    /// To increase the protection of your backup file, please set the password
    internal static let setPasswordTitle = T.tr("Localizable", "backup__set_password_title", fallback: "To increase the protection of your backup file, please set the password")
    /// Provided phrase is too short (min. 3 char)
    internal static let toShortError = T.tr("Localizable", "backup__to_short_error", fallback: "Provided phrase is too short (min. 3 char)")
    /// You'll need a new version of the app to import the contents of this file. You can find the newest version in the App Store
    internal static let updateRequiredToImportTitle = T.tr("Localizable", "backup__update_required_to_import_title", fallback: "You'll need a new version of the app to import the contents of this file. You can find the newest version in the App Store")
    /// You'll need a new version of the app to import the contents of this file. You can find the newest version in the Google Store
    internal static let updateRequiredToImportTitle2 = T.tr("Localizable", "backup__update_required_to_import_title_2", fallback: "You'll need a new version of the app to import the contents of this file. You can find the newest version in the Google Store")
    /// User is over quota on iCloud
    internal static let userOverQuotaIcloud = T.tr("Localizable", "backup__user_over_quota_icloud", fallback: "User is over quota on iCloud")
    /// Verify PIN
    internal static let verifyPin = T.tr("Localizable", "backup__verify_pin", fallback: "Verify PIN")
    /// Warning! If you delete 2FAS Backup, you will also erase all tokens from other devices synced with this account. To preserve the tokens on other devices, please ensure that you've turned off the 2FAS Backup before the deletion
    internal static let warningIntroduction = T.tr("Localizable", "backup__warning_introduction", fallback: "Warning! If you delete 2FAS Backup, you will also erase all tokens from other devices synced with this account. To preserve the tokens on other devices, please ensure that you've turned off the 2FAS Backup before the deletion")
  }
  internal enum Browser {
    /// Do you want to share the 2FA token for 
    internal static let _2faTokenRequestContent = T.tr("Localizable", "browser__2fa_token_request_content", fallback: "Do you want to share the 2FA token for ")
    /// 2FA Token Request
    internal static let _2faTokenRequestTitle = T.tr("Localizable", "browser__2fa_token_request_title", fallback: "2FA Token Request")
    /// Add new
    internal static let addNew = T.tr("Localizable", "browser__add_new", fallback: "Add new")
    /// This Browser Extension is already paired with this device.
    internal static let alreadyPairedDescription = T.tr("Localizable", "browser__already_paired_description", fallback: "This Browser Extension is already paired with this device.")
    /// Already paired!
    internal static let alreadyPairedTitle = T.tr("Localizable", "browser__already_paired_title", fallback: "Already paired!")
    /// Browser extension
    internal static let browserExtension = T.tr("Localizable", "browser__browser_extension", fallback: "Browser extension")
    /// Browser Extensions settings
    internal static let browserExtensionSettings = T.tr("Localizable", "browser__browser_extension_settings", fallback: "Browser Extensions settings")
    /// Error while sending the code. %@
    internal static func codeFailure(_ p1: Any) -> String {
      return T.tr("Localizable", "browser__code_failure", String(describing: p1), fallback: "Error while sending the code. %@")
    }
    /// Token sent successfully!
    internal static let codeSuccessTitle = T.tr("Localizable", "browser__code_success_title", fallback: "Token sent successfully!")
    /// Contact support
    internal static let contactSupport = T.tr("Localizable", "browser__contact_support", fallback: "Contact support")
    /// The next time you use the browser extension to login to %@, you'll be asked to pair this domain again.
    internal static func deletingExtensionPairingContent(_ p1: Any) -> String {
      return T.tr("Localizable", "browser__deleting_extension_pairing_content", String(describing: p1), fallback: "The next time you use the browser extension to login to %@, you'll be asked to pair this domain again.")
    }
    /// Remove domain?
    internal static let deletingExtensionPairingTitle = T.tr("Localizable", "browser__deleting_extension_pairing_title", fallback: "Remove domain?")
    /// Are you sure you want to delete paired device?
    internal static let deletingPairedDeviceContent = T.tr("Localizable", "browser__deleting_paired_device_content", fallback: "Are you sure you want to delete paired device?")
    /// Deleting Paired Device
    internal static let deletingPairedDeviceTitle = T.tr("Localizable", "browser__deleting_paired_device_title", fallback: "Deleting Paired Device")
    /// Device nickname
    internal static let deviceName = T.tr("Localizable", "browser__device_name", fallback: "Device nickname")
    /// Forget this web browser
    internal static let forgetThisBrowser = T.tr("Localizable", "browser__forget_this_browser", fallback: "Forget this web browser")
    /// Install the 2FAS browser extension on your desktop computer
    internal static let infoDescriptionFirst = T.tr("Localizable", "browser__info_description_first", fallback: "Install the 2FAS browser extension on your desktop computer")
    /// Pair it with your 2FAS app.
    internal static let infoDescriptionSecond = T.tr("Localizable", "browser__info_description_second", fallback: "Pair it with your 2FAS app.")
    /// 2FAS Web Browser extension
    internal static let infoTitle = T.tr("Localizable", "browser__info_title", fallback: "2FAS Web Browser extension")
    /// More info:
    internal static let moreInfo = T.tr("Localizable", "browser__more_info", fallback: "More info:")
    /// https://www.2fas.com/be
    internal static let moreInfoLink = T.tr("Localizable", "browser__more_info_link", fallback: "https://www.2fas.com/be")
    /// 2fas.com/be
    internal static let moreInfoLinkTitle = T.tr("Localizable", "browser__more_info_link_title", fallback: "2fas.com/be")
    /// Name
    internal static let name = T.tr("Localizable", "browser__name", fallback: "Name")
    /// Pair with web browser
    internal static let pairWithWebBrowser = T.tr("Localizable", "browser__pair_with_web_browser", fallback: "Pair with web browser")
    /// Paired devices (web browsers)
    internal static let pairedDevicesBrowserTitle = T.tr("Localizable", "browser__paired_devices_browser_title", fallback: "Paired devices (web browsers)")
    /// List of paired domains.
    internal static let pairedDomainsListTitle = T.tr("Localizable", "browser__paired_domains_list_title", fallback: "List of paired domains.")
    /// Date paired
    internal static let pairingDate = T.tr("Localizable", "browser__pairing_date", fallback: "Date paired")
    /// This QR code wasn’t recognized, and 2FAS could not pair this device with the browser extension. Please try again.
    internal static let pairingFailedDescription = T.tr("Localizable", "browser__pairing_failed_description", fallback: "This QR code wasn’t recognized, and 2FAS could not pair this device with the browser extension. Please try again.")
    /// Pairing failed :(
    internal static let pairingFailedTitle = T.tr("Localizable", "browser__pairing_failed_title", fallback: "Pairing failed :(")
    /// 2FAS will send you a Push Notification whenever you log in to your online services using this web browser. You will no longer need to re-type your tokens for each use.
    internal static let pairingSuccessfulDescription = T.tr("Localizable", "browser__pairing_successful_description", fallback: "2FAS will send you a Push Notification whenever you log in to your online services using this web browser. You will no longer need to re-type your tokens for each use.")
    /// Pairing successful!
    internal static let pairingSuccessfulTitle = T.tr("Localizable", "browser__pairing_successful_title", fallback: "Pairing successful!")
    /// Pairing with browser
    internal static let pairingWithBrowser = T.tr("Localizable", "browser__pairing_with_browser", fallback: "Pairing with browser")
    /// To access functionality like Browser Extension application needs access to Push Notifications. You can change this setting at any time in System Settings.
    internal static let pushNotificationsContent = T.tr("Localizable", "browser__push_notifications_content", fallback: "To access functionality like Browser Extension application needs access to Push Notifications. You can change this setting at any time in System Settings.")
    /// Push Notifications
    internal static let pushNotificationsTitle = T.tr("Localizable", "browser__push_notifications_title", fallback: "Push Notifications")
    /// Browser request
    internal static let request = T.tr("Localizable", "browser__request", fallback: "Browser request")
    /// Request expired
    internal static let requestExpired = T.tr("Localizable", "browser__request_expired", fallback: "Request expired")
    /// %@ requested a 2FA token for %@. Select the service to authorize and save with this domain.
    internal static func requestSourceDescription(_ p1: Any, _ p2: Any) -> String {
      return T.tr("Localizable", "browser__request_source_description", String(describing: p1), String(describing: p2), fallback: "%@ requested a 2FA token for %@. Select the service to authorize and save with this domain.")
    }
    /// Your 2FAS app is already paired with this browser.
    internal static let resultErrorBrowserPaired = T.tr("Localizable", "browser__result_error_browser_paired", fallback: "Your 2FAS app is already paired with this browser.")
    /// Scan the QR code again
    internal static let resultErrorCta = T.tr("Localizable", "browser__result_error_cta", fallback: "Scan the QR code again")
    /// The scanned QR code has an unsupported format. Please try again.
    internal static let scanErrorDialogMsgInvalidCode = T.tr("Localizable", "browser__scan_error_dialog_msg_invalid_code", fallback: "The scanned QR code has an unsupported format. Please try again.")
    /// Unknown error when scanning QR code. Please try again.
    internal static let scanErrorDialogMsgUnknown = T.tr("Localizable", "browser__scan_error_dialog_msg_unknown", fallback: "Unknown error when scanning QR code. Please try again.")
    /// Error
    internal static let scanErrorDialogTitle = T.tr("Localizable", "browser__scan_error_dialog_title", fallback: "Error")
    /// This nickname will help you identify this device among other devices paired with the 2FAS browser extension
    internal static let thisDeviceFooter = T.tr("Localizable", "browser__this_device_footer", fallback: "This nickname will help you identify this device among other devices paired with the 2FAS browser extension")
    /// Device nickname
    internal static let thisDeviceName = T.tr("Localizable", "browser__this_device_name", fallback: "Device nickname")
    /// <UNKOWN_NAME>
    internal static let unkownName = T.tr("Localizable", "browser__unkown_name", fallback: "<UNKOWN_NAME>")
  }
  internal enum Camera {
    /// The camera is unavailable because of system overload. Try rebooting the device
    internal static let cameraUnavailableTitle = T.tr("Localizable", "camera__camera_unavailable_title", fallback: "The camera is unavailable because of system overload. Try rebooting the device")
    /// Another app uses the camera. If closing other apps don't help, then reboot the device
    internal static let cameraUsedByOtherAppTitle = T.tr("Localizable", "camera__camera_used_by_other_app_title", fallback: "Another app uses the camera. If closing other apps don't help, then reboot the device")
    /// Can't initialize the camera. Try rebooting the device
    internal static let cantInitializeCameraGeneral = T.tr("Localizable", "camera__cant_initialize_camera_general", fallback: "Can't initialize the camera. Try rebooting the device")
    /// Can't initialize camera in Split View mode. Open app in full screen and try again
    internal static let cantInitializeCameraSplitView = T.tr("Localizable", "camera__cant_initialize_camera_split_view", fallback: "Can't initialize camera in Split View mode. Open app in full screen and try again")
  }
  internal enum Color {
    /// Green
    internal static let green = T.tr("Localizable", "color__green", fallback: "Green")
    /// Indigo
    internal static let indigo = T.tr("Localizable", "color__indigo", fallback: "Indigo")
    /// Light blue
    internal static let lightBlue = T.tr("Localizable", "color__light_blue", fallback: "Light blue")
    /// Neutral
    internal static let neutral = T.tr("Localizable", "color__neutral", fallback: "Neutral")
    /// Orange
    internal static let orange = T.tr("Localizable", "color__orange", fallback: "Orange")
    /// Purple
    internal static let purple = T.tr("Localizable", "color__purple", fallback: "Purple")
    /// Red
    internal static let red = T.tr("Localizable", "color__red", fallback: "Red")
    /// Turquoise
    internal static let turquoise = T.tr("Localizable", "color__turquoise", fallback: "Turquoise")
    /// Yellow
    internal static let yellow = T.tr("Localizable", "color__yellow", fallback: "Yellow")
  }
  internal enum Commons {
    /// 2FA Authenticator (2FAS App)
    internal static let _2fas = T.tr("Localizable", "commons__2fas", fallback: "2FA Authenticator (2FAS App)")
    /// 2FAS
    internal static let _2fasToolbar = T.tr("Localizable", "commons__2fas_toolbar", fallback: "2FAS")
    /// Add
    internal static let add = T.tr("Localizable", "commons__add", fallback: "Add")
    /// Approve
    internal static let approve = T.tr("Localizable", "commons__approve", fallback: "Approve")
    /// Point your camera at the screen to capture the QR code
    internal static let cameraTitle = T.tr("Localizable", "commons__camera_title", fallback: "Point your camera at the screen to capture the QR code")
    /// Cancel
    internal static let cancel = T.tr("Localizable", "commons__cancel", fallback: "Cancel")
    /// Close
    internal static let close = T.tr("Localizable", "commons__close", fallback: "Close")
    /// Continue
    internal static let `continue` = T.tr("Localizable", "commons__continue", fallback: "Continue")
    /// Copy
    internal static let copy = T.tr("Localizable", "commons__copy", fallback: "Copy")
    /// Customize
    internal static let customize = T.tr("Localizable", "commons__customize", fallback: "Customize")
    /// Delete
    internal static let delete = T.tr("Localizable", "commons__delete", fallback: "Delete")
    /// Deny
    internal static let deny = T.tr("Localizable", "commons__deny", fallback: "Deny")
    /// Dismiss
    internal static let dismiss = T.tr("Localizable", "commons__dismiss", fallback: "Dismiss")
    /// Done
    internal static let done = T.tr("Localizable", "commons__done", fallback: "Done")
    /// Edit
    internal static let edit = T.tr("Localizable", "commons__edit", fallback: "Edit")
    /// Enter code manually
    internal static let enterCodeManually = T.tr("Localizable", "commons__enter_code_manually", fallback: "Enter code manually")
    /// Error
    internal static let error = T.tr("Localizable", "commons__error", fallback: "Error")
    /// Got it!
    internal static let gotIt = T.tr("Localizable", "commons__got_it", fallback: "Got it!")
    /// Info
    internal static let info = T.tr("Localizable", "commons__info", fallback: "Info")
    /// Next
    internal static let next = T.tr("Localizable", "commons__next", fallback: "Next")
    /// No
    internal static let no = T.tr("Localizable", "commons__no", fallback: "No")
    /// No results
    internal static let noResults = T.tr("Localizable", "commons__no_results", fallback: "No results")
    /// Notice
    internal static let notice = T.tr("Localizable", "commons__notice", fallback: "Notice")
    /// Notifications
    internal static let notifications = T.tr("Localizable", "commons__notifications", fallback: "Notifications")
    /// Off
    internal static let off = T.tr("Localizable", "commons__off", fallback: "Off")
    /// OK
    internal static let ok = T.tr("Localizable", "commons__OK", fallback: "OK")
    /// On
    internal static let on = T.tr("Localizable", "commons__on", fallback: "On")
    /// %d of %d
    internal static func pageOfPageTitle(_ p1: Int, _ p2: Int) -> String {
      return T.tr("Localizable", "commons__page_of_page_title", p1, p2, fallback: "%d of %d")
    }
    /// Rename
    internal static let rename = T.tr("Localizable", "commons__rename", fallback: "Rename")
    /// Retry
    internal static let retry = T.tr("Localizable", "commons__retry", fallback: "Retry")
    /// Save
    internal static let save = T.tr("Localizable", "commons__save", fallback: "Save")
    /// Scan QR Code
    internal static let scanQrCode = T.tr("Localizable", "commons__scan_qr_code", fallback: "Scan QR Code")
    /// Search
    internal static let search = T.tr("Localizable", "commons__search", fallback: "Search")
    /// Send
    internal static let send = T.tr("Localizable", "commons__send", fallback: "Send")
    /// Service
    internal static let service = T.tr("Localizable", "commons__service", fallback: "Service")
    /// Set
    internal static let `set` = T.tr("Localizable", "commons__set", fallback: "Set")
    /// Skip
    internal static let skip = T.tr("Localizable", "commons__skip", fallback: "Skip")
    /// The provided text is too long (max. %d chars)
    internal static func textLongTitle(_ p1: Int) -> String {
      return T.tr("Localizable", "commons__text_long_title", p1, fallback: "The provided text is too long (max. %d chars)")
    }
    /// Tokens
    internal static let tokens = T.tr("Localizable", "commons__tokens", fallback: "Tokens")
    /// Warning
    internal static let warning = T.tr("Localizable", "commons__warning", fallback: "Warning")
    /// Yes
    internal static let yes = T.tr("Localizable", "commons__yes", fallback: "Yes")
  }
  internal enum Error {
    /// Cloud backup is encrypted. Update the app to support this feature
    internal static let cloudBackupEncryptedNotSupported = T.tr("Localizable", "error__cloud_backup_encrypted_not_supported", fallback: "Cloud backup is encrypted. Update the app to support this feature")
    /// Cloud backup has been migrated to the new version. Update the app
    internal static let cloudBackupNewerVersion = T.tr("Localizable", "error__cloud_backup_newer_version", fallback: "Cloud backup has been migrated to the new version. Update the app")
    /// It appears that either you've run out of disk space now, or such an event in the past damaged the database
    internal static let outOfDiskSpace = T.tr("Localizable", "error__out_of_disk_space", fallback: "It appears that either you've run out of disk space now, or such an event in the past damaged the database")
  }
  internal enum Errors {
    /// No application that supports this link
    internal static let noApp = T.tr("Localizable", "errors__no_app", fallback: "No application that supports this link")
  }
  internal enum Extension {
    /// Approve
    internal static let approve = T.tr("Localizable", "extension__approve", fallback: "Approve")
    /// Authorize
    internal static let authorize = T.tr("Localizable", "extension__authorize", fallback: "Authorize")
    /// Cancel
    internal static let cancel = T.tr("Localizable", "extension__cancel", fallback: "Cancel")
    /// Continue to app
    internal static let continueToApp = T.tr("Localizable", "extension__continue_to_app", fallback: "Continue to app")
    /// Deny
    internal static let deny = T.tr("Localizable", "extension__deny", fallback: "Deny")
    /// Dismiss
    internal static let dismiss = T.tr("Localizable", "extension__dismiss", fallback: "Dismiss")
    /// Error
    internal static let error = T.tr("Localizable", "extension__error", fallback: "Error")
    /// There's a connection problem
    internal static let errorNoInternet = T.tr("Localizable", "extension__error_no_internet", fallback: "There's a connection problem")
    /// For Browser Extension to work, please add services to the 2FAS app
    internal static let errorNoServices = T.tr("Localizable", "extension__error_no_services", fallback: "For Browser Extension to work, please add services to the 2FAS app")
    /// Open the app and check if Browser Extension is properly paired
    internal static let errorOpenTheApp = T.tr("Localizable", "extension__error_open_the_app", fallback: "Open the app and check if Browser Extension is properly paired")
    /// Error while sending token
    internal static let errorWhileSending = T.tr("Localizable", "extension__error_while_sending", fallback: "Error while sending token")
    /// Open the app and select a service for this domain
    internal static let notPairedContent = T.tr("Localizable", "extension__not_paired_content", fallback: "Open the app and select a service for this domain")
    /// This website is not paired
    internal static let notPairedTitle = T.tr("Localizable", "extension__not_paired_title", fallback: "This website is not paired")
    /// Request sent
    internal static let requestSent = T.tr("Localizable", "extension__request_sent", fallback: "Request sent")
    /// %@ requested 2FAS token for %@
    internal static func sendQuestionContent(_ p1: Any, _ p2: Any) -> String {
      return T.tr("Localizable", "extension__send_question_content", String(describing: p1), String(describing: p2), fallback: "%@ requested 2FAS token for %@")
    }
    /// Send token?
    internal static let sendQuestionTitle = T.tr("Localizable", "extension__send_question_title", fallback: "Send token?")
    /// Please try again
    internal static let tryAgain = T.tr("Localizable", "extension__try_again", fallback: "Please try again")
  }
  internal enum Fingerprint {
    /// Confirm Fingerprint to continue.
    internal static let confirmTitle = T.tr("Localizable", "fingerprint__confirm_title", fallback: "Confirm Fingerprint to continue.")
    /// Use PIN this time
    internal static let usePinTitle = T.tr("Localizable", "fingerprint__use_pin_title", fallback: "Use PIN this time")
    /// Verifying…
    internal static let verifying = T.tr("Localizable", "fingerprint__verifying", fallback: "Verifying…")
  }
  internal enum Introduction {
    /// Choose QR code
    internal static let chooseQrCode = T.tr("Localizable", "introduction__choose_qr_code", fallback: "Choose QR code")
    /// Pair your online service account with 2FAS or import your tokens
    internal static let descriptionTitle = T.tr("Localizable", "introduction__description_title", fallback: "Pair your online service account with 2FAS or import your tokens")
    /// Export your accounts from Google Authenticator to a QR code using the "Transfer Accounts" option. Then make a screenshot and use the "Choose QR code" button below. If you're importing codes from another device, use the "Scan QR code" button instead.
    internal static let googleAuthenticatorImportProcess = T.tr("Localizable", "introduction__google_authenticator_import_process", fallback: "Export your accounts from Google Authenticator to a QR code using the \"Transfer Accounts\" option. Then make a screenshot and use the \"Choose QR code\" button below. If you're importing codes from another device, use the \"Scan QR code\" button instead.")
    /// Import 2FAS backup file
    internal static let import2fasTitle = T.tr("Localizable", "introduction__import_2fas_title", fallback: "Import 2FAS backup file")
    /// Import from Google Authenticator
    internal static let importGoogleAuthenticator = T.tr("Localizable", "introduction__import_google_authenticator", fallback: "Import from Google Authenticator")
    /// Your phone has just become a private and secured key to your online services thanks to the 2FAS app - trusted by over 3 million users worldwide.
    internal static let page1Content = T.tr("Localizable", "introduction__page_1_content", fallback: "Your phone has just become a private and secured key to your online services thanks to the 2FAS app - trusted by over 3 million users worldwide.")
    /// You are awesome!
    internal static let page1Title = T.tr("Localizable", "introduction__page_1_title", fallback: "You are awesome!")
    /// Pair 2FAS with your online services. Activate two-factor security in seconds with your QR code.
    internal static let page2Content = T.tr("Localizable", "introduction__page_2_content", fallback: "Pair 2FAS with your online services. Activate two-factor security in seconds with your QR code.")
    /// Simple
    internal static let page2Title = T.tr("Localizable", "introduction__page_2_title", fallback: "Simple")
    /// 2FAS respects and protects your privacy. This app will never collect, process, or use any of your personal data.
    internal static let page3Content = T.tr("Localizable", "introduction__page_3_content", fallback: "2FAS respects and protects your privacy. This app will never collect, process, or use any of your personal data.")
    /// Private
    internal static let page3Title = T.tr("Localizable", "introduction__page_3_title", fallback: "Private")
    /// Your tokens are stored offline via the device storage, so remember to back up your services! Use Google Drive Sync and PIN password to protect against unauthorized access and device damage.
    internal static let page4ContentAndroid = T.tr("Localizable", "introduction__page_4_content_android", fallback: "Your tokens are stored offline via the device storage, so remember to back up your services! Use Google Drive Sync and PIN password to protect against unauthorized access and device damage.")
    /// Your tokens are stored offline via the device storage, so remember to back up your services! Use iCloud Sync and a PIN password to protect against unauthorized access and device damage.
    internal static let page4ContentIos = T.tr("Localizable", "introduction__page_4_content_ios", fallback: "Your tokens are stored offline via the device storage, so remember to back up your services! Use iCloud Sync and a PIN password to protect against unauthorized access and device damage.")
    /// Secure
    internal static let page4Title = T.tr("Localizable", "introduction__page_4_title", fallback: "Secure")
    /// Pair new service
    internal static let pairNewService = T.tr("Localizable", "introduction__pair_new_service", fallback: "Pair new service")
    /// Scan QR code
    internal static let scanQrCode = T.tr("Localizable", "introduction__scan_qr_code", fallback: "Scan QR code")
    /// Start using 2FAS
    internal static let title = T.tr("Localizable", "introduction__title", fallback: "Start using 2FAS")
    /// Terms of service
    internal static let tos = T.tr("Localizable", "introduction__tos", fallback: "Terms of service")
    /// Not sure what to do?
    internal static let whatToDo = T.tr("Localizable", "introduction__what_to_do", fallback: "Not sure what to do?")
  }
  internal enum NewVersion {
    /// A new version of 2FAS is available on Google Store. Update now!
    internal static let newVersionMessageAndroid = T.tr("Localizable", "new_version__new_version_message_android", fallback: "A new version of 2FAS is available on Google Store. Update now!")
    /// A new version of 2FAS is available on AppStore. Update now!
    internal static let newVersionMessageIos = T.tr("Localizable", "new_version__new_version_message_ios", fallback: "A new version of 2FAS is available on AppStore. Update now!")
    /// New version
    internal static let newVersionTitle = T.tr("Localizable", "new_version__new_version_title", fallback: "New version")
    /// Skip this version
    internal static let skipTitle = T.tr("Localizable", "new_version__skip_title", fallback: "Skip this version")
    /// Update now
    internal static let updateAction = T.tr("Localizable", "new_version__update_action", fallback: "Update now")
    /// Update later
    internal static let updateLater = T.tr("Localizable", "new_version__update_later", fallback: "Update later")
  }
  internal enum Notifications {
    /// Would you like to add this code: %@?
    internal static func addCodeQuestionTitle(_ p1: Any) -> String {
      return T.tr("Localizable", "notifications__add_code_question_title", String(describing: p1), fallback: "Would you like to add this code: %@?")
    }
    /// Adding a new code
    internal static let addingCode = T.tr("Localizable", "notifications__adding_code", fallback: "Adding a new code")
    /// Counter Copied
    internal static let counterCopied = T.tr("Localizable", "notifications__counter_copied", fallback: "Counter Copied")
    /// Next Token Copied
    internal static let nextTokenCopied = T.tr("Localizable", "notifications__next_token_copied", fallback: "Next Token Copied")
    /// No notifications
    internal static let noNotifications = T.tr("Localizable", "notifications__no_notifications", fallback: "No notifications")
    /// Service already modified in Backup
    internal static let serviceAlreadyModifiedTitle = T.tr("Localizable", "notifications__service_already_modified_title", fallback: "Service already modified in Backup")
    /// Service already removed from Backup
    internal static let serviceAlreadyRemovedTitle = T.tr("Localizable", "notifications__service_already_removed_title", fallback: "Service already removed from Backup")
    /// Service Key Copied
    internal static let serviceKeyCopied = T.tr("Localizable", "notifications__service_key_copied", fallback: "Service Key Copied")
    /// This token is already present on the list
    internal static let tokenAlreadyAdded = T.tr("Localizable", "notifications__token_already_added", fallback: "This token is already present on the list")
    /// Token Copied
    internal static let tokenCopied = T.tr("Localizable", "notifications__token_copied", fallback: "Token Copied")
  }
  internal enum Permissions {
    /// Camera Permission
    internal static let cameraPermission = T.tr("Localizable", "permissions__camera_permission", fallback: "Camera Permission")
    /// Camera permission is required to scan QR Codes. If you want to use this feature go to Application Information -&gt; Permissions and Enable Camera.
    internal static let cameraPermissionDescription = T.tr("Localizable", "permissions__camera_permission_description", fallback: "Camera permission is required to scan QR Codes. If you want to use this feature go to Application Information -&gt; Permissions and Enable Camera.")
    /// Open Settings
    internal static let openSettings = T.tr("Localizable", "permissions__open_settings", fallback: "Open Settings")
  }
  internal enum Restore {
    /// Application restoration
    internal static let applicationRestoration = T.tr("Localizable", "restore__application_restoration", fallback: "Application restoration")
    /// Be advised that if you do not have a backup and reset the app, you will lose access to all your codes. And therefore, access to all your 2FA-secured accounts.
    internal static let backupAdvice = T.tr("Localizable", "restore__backup_advice", fallback: "Be advised that if you do not have a backup and reset the app, you will lose access to all your codes. And therefore, access to all your 2FA-secured accounts.")
    /// If you have a backup, take it easy, you'll be able to restore all your codes.
    internal static let backupTitle = T.tr("Localizable", "restore__backup_title", fallback: "If you have a backup, take it easy, you'll be able to restore all your codes.")
    /// How to restore 2FAS app?
    internal static let howToRestore = T.tr("Localizable", "restore__how_to_restore", fallback: "How to restore 2FAS app?")
    /// If you have forgotten the PIN or want to reset the 2FAS app, you have to reinstall the app.
    internal static let resetPinTitle = T.tr("Localizable", "restore__reset_Pin_title", fallback: "If you have forgotten the PIN or want to reset the 2FAS app, you have to reinstall the app.")
  }
  internal enum Security {
    /// Change PIN
    internal static let changePin = T.tr("Localizable", "security__change_pin", fallback: "Change PIN")
    /// Please confirm your new PIN
    internal static let confirmNewPin = T.tr("Localizable", "security__confirm_new_pin", fallback: "Please confirm your new PIN")
    /// Please confirm you're the device owner
    internal static let confirmYouAreDeviceOwner = T.tr("Localizable", "security__confirm_you_are_device_owner", fallback: "Please confirm you're the device owner")
    /// Create PIN
    internal static let createPin = T.tr("Localizable", "security__create_pin", fallback: "Create PIN")
    /// Disable PIN
    internal static let disablePin = T.tr("Localizable", "security__disable_pin", fallback: "Disable PIN")
    /// Please enter your current PIN
    internal static let enterCurrentPin = T.tr("Localizable", "security__enter_current_pin", fallback: "Please enter your current PIN")
    /// Please enter your new PIN
    internal static let enterNewPin = T.tr("Localizable", "security__enter_new_pin", fallback: "Please enter your new PIN")
    /// Please enter your PIN
    internal static let enterPin = T.tr("Localizable", "security__enter_pin", fallback: "Please enter your PIN")
    /// Please enter your new %s PIN
    internal static func enterYourNewPin(_ p1: UnsafePointer<CChar>) -> String {
      return T.tr("Localizable", "security__enter_your_new_pin", p1, fallback: "Please enter your new %s PIN")
    }
    /// Incorrect PIN
    internal static let incorrectPIN = T.tr("Localizable", "security__incorrect_PIN", fallback: "Incorrect PIN")
    /// PIN incorrect! Please try again
    internal static let pinErrorIncorrect = T.tr("Localizable", "security__pin_error_incorrect", fallback: "PIN incorrect! Please try again")
    /// Too many attempts. Please try again later.
    internal static let tooManyAttemptsError = T.tr("Localizable", "security__too_many_attempts_error", fallback: "Too many attempts. Please try again later.")
    /// Too many attempts. Please try after one minute
    internal static let tooManyAttemptsError2 = T.tr("Localizable", "security__too_many_attempts_error_2", fallback: "Too many attempts. Please try after one minute")
    /// Too many attempts. Please try again after %@ minutes.
    internal static func tooManyAttemptsTryAgainAfter(_ p1: Any) -> String {
      return T.tr("Localizable", "security__too_many_attempts_try_again_after", String(describing: p1), fallback: "Too many attempts. Please try again after %@ minutes.")
    }
    /// Too many attempts. Please try again %@
    internal static func tooManyAttemptsTryAgainAfterFormatter(_ p1: Any) -> String {
      return T.tr("Localizable", "security__too_many_attempts_try_again_after_formatter", String(describing: p1), fallback: "Too many attempts. Please try again %@")
    }
  }
  internal enum Settings {
    /// 10 minutes
    internal static let _10Minutes = T.tr("Localizable", "settings__10_minutes", fallback: "10 minutes")
    /// 3 minutes
    internal static let _3Minutes = T.tr("Localizable", "settings__3_minutes", fallback: "3 minutes")
    /// 5 minutes
    internal static let _5Minutes = T.tr("Localizable", "settings__5_minutes", fallback: "5 minutes")
    /// About
    internal static let about = T.tr("Localizable", "settings__about", fallback: "About")
    /// Acknowledgements
    internal static let acknowledgements = T.tr("Localizable", "settings__acknowledgements", fallback: "Acknowledgements")
    /// Advanced
    internal static let advanced = T.tr("Localizable", "settings__advanced", fallback: "Advanced")
    /// Lockout settings
    internal static let appBlocking = T.tr("Localizable", "settings__app_blocking", fallback: "Lockout settings")
    /// App security
    internal static let appSecurity = T.tr("Localizable", "settings__app_security", fallback: "App security")
    /// Backup and Synchronization
    internal static let backupAndSynchronization = T.tr("Localizable", "settings__backup_and_synchronization", fallback: "Backup and Synchronization")
    /// Biometric Authentication
    internal static let biometricAuthentication = T.tr("Localizable", "settings__biometric_authentication", fallback: "Biometric Authentication")
    /// Biometrics
    internal static let biometrics = T.tr("Localizable", "settings__biometrics", fallback: "Biometrics")
    /// Lockout time
    internal static let blockFor = T.tr("Localizable", "settings__block_for", fallback: "Lockout time")
    /// Select the time for which the app will be locked.
    /// 
    internal static let blockForFooter = T.tr("Localizable", "settings__block_for_footer", fallback: "Select the time for which the app will be locked.\n")
    /// Pairing result
    internal static let browserExtensionResultToolbarTitle = T.tr("Localizable", "settings__browser_extension_result_toolbar_title", fallback: "Pairing result")
    /// Choose topic
    internal static let chooseTopic = T.tr("Localizable", "settings__choose_topic", fallback: "Choose topic")
    /// Configure mail service and try again
    internal static let configureMailServiceTryAgain = T.tr("Localizable", "settings__configure_mail_service_try_again", fallback: "Configure mail service and try again")
    /// Developer Options
    internal static let developer = T.tr("Localizable", "settings__developer", fallback: "Developer Options")
    /// Display selected services on the Home Screen Widgets.
    internal static let displaySelectedServices = T.tr("Localizable", "settings__display_selected_services", fallback: "Display selected services on the Home Screen Widgets.")
    /// Donate to 2FAS
    internal static let donateTwofas = T.tr("Localizable", "settings__donate_twofas", fallback: "Donate to 2FAS")
    /// Donations
    internal static let donations = T.tr("Localizable", "settings__donations", fallback: "Donations")
    /// Import tokens
    internal static let externalImport = T.tr("Localizable", "settings__external_import", fallback: "Import tokens")
    /// Face ID
    internal static let faceId = T.tr("Localizable", "settings__face_id", fallback: "Face ID")
    /// General
    internal static let general = T.tr("Localizable", "settings__general", fallback: "General")
    /// Select the maximum number of unsuccessful passcode attempts before locking the application.
    /// 
    internal static let howManyAttemptsFooter = T.tr("Localizable", "settings__how_many_attempts_footer", fallback: "Select the maximum number of unsuccessful passcode attempts before locking the application.\n")
    /// Knowledge
    internal static let knowledge = T.tr("Localizable", "settings__knowledge", fallback: "Knowledge")
    /// Max failed attempts
    internal static let limitOfTrials = T.tr("Localizable", "settings__limit_of_trials", fallback: "Max failed attempts")
    /// Mail services are not available
    internal static let mailServicesNotAvailable = T.tr("Localizable", "settings__mail_services_not_available", fallback: "Mail services are not available")
    /// No limit
    internal static let noLimit = T.tr("Localizable", "settings__no_limit", fallback: "No limit")
    /// Biometric Lock
    internal static let optionFingerprint = T.tr("Localizable", "settings__option_fingerprint", fallback: "Biometric Lock")
    /// To enable Biometric Lock, you need to enable and set a PIN Code.
    internal static let optionFingerprintDescription = T.tr("Localizable", "settings__option_fingerprint_description", fallback: "To enable Biometric Lock, you need to enable and set a PIN Code.")
    /// Theme
    internal static let optionTheme = T.tr("Localizable", "settings__option_theme", fallback: "Theme")
    /// 4-digits code
    internal static let pin4Digits = T.tr("Localizable", "settings__pin_4_digits", fallback: "4-digits code")
    /// 6-digits code
    internal static let pin6Digits = T.tr("Localizable", "settings__pin_6_digits", fallback: "6-digits code")
    /// PIN code
    internal static let pinCode = T.tr("Localizable", "settings__pin_code", fallback: "PIN code")
    /// Privacy Policy
    internal static let privacyPolicy = T.tr("Localizable", "settings__privacy_policy", fallback: "Privacy Policy")
    /// Problem
    internal static let problem = T.tr("Localizable", "settings__problem", fallback: "Problem")
    /// Check out this awesome two-factor authentication app from 2FAS: https://2fas.com
    internal static let recommendation = T.tr("Localizable", "settings__recommendation ", fallback: "Check out this awesome two-factor authentication app from 2FAS: https://2fas.com")
    /// Restore
    internal static let restore = T.tr("Localizable", "settings__restore", fallback: "Restore")
    /// Security
    internal static let security = T.tr("Localizable", "settings__security", fallback: "Security")
    /// See incoming tokens on the list.
    internal static let seeIncomingTokens = T.tr("Localizable", "settings__see_incoming_tokens", fallback: "See incoming tokens on the list.")
    /// Select PIN length
    internal static let selectPinLength = T.tr("Localizable", "settings__select_pin_length", fallback: "Select PIN length")
    /// Send logs
    internal static let sendLogs = T.tr("Localizable", "settings__send_logs", fallback: "Send logs")
    /// Please enter or paste code provided by our support team
    internal static let sendLogsDescriptionEdit = T.tr("Localizable", "settings__send_logs_description_edit", fallback: "Please enter or paste code provided by our support team")
    /// Code provided by support team was autofilled. Send logs?
    internal static let sendLogsDescriptionLink = T.tr("Localizable", "settings__send_logs_description_link", fallback: "Code provided by support team was autofilled. Send logs?")
    /// Provided code has expired. Please contact support team to obtain a new one
    internal static let sendLogsErrorExpired = T.tr("Localizable", "settings__send_logs_error_expired", fallback: "Provided code has expired. Please contact support team to obtain a new one")
    /// There's no internet. Please check the connection and try again
    internal static let sendLogsErrorNoInternet = T.tr("Localizable", "settings__send_logs_error_no_internet", fallback: "There's no internet. Please check the connection and try again")
    /// Provided code is incorrect. Please double check it
    internal static let sendLogsErrorNotExists = T.tr("Localizable", "settings__send_logs_error_not_exists", fallback: "Provided code is incorrect. Please double check it")
    /// There seems to be a problem with our server. If it persists please contact our support team
    internal static let sendLogsErrorServer = T.tr("Localizable", "settings__send_logs_error_server", fallback: "There seems to be a problem with our server. If it persists please contact our support team")
    /// Operation failed
    internal static let sendLogsErrorTitle = T.tr("Localizable", "settings__send_logs_error_title", fallback: "Operation failed")
    /// We'll check them out, but it could take some time.
    internal static let sendLogsSentDescription = T.tr("Localizable", "settings__send_logs_sent_description", fallback: "We'll check them out, but it could take some time.")
    /// Logs sent
    internal static let sendLogsSentTitle = T.tr("Localizable", "settings__send_logs_sent_title", fallback: "Logs sent")
    /// Sending logs
    internal static let sendLogsTitle = T.tr("Localizable", "settings__send_logs_title", fallback: "Sending logs")
    /// Settings
    internal static let settings = T.tr("Localizable", "settings__settings", fallback: "Settings")
    /// Share the app
    internal static let shareApp = T.tr("Localizable", "settings__share_app", fallback: "Share the app")
    /// Show next token
    internal static let showNextToken = T.tr("Localizable", "settings__show_next_token", fallback: "Show next token")
    /// Suggestion
    internal static let suggestion = T.tr("Localizable", "settings__suggestion", fallback: "Suggestion")
    /// 2FAS Support
    internal static let support = T.tr("Localizable", "settings__support", fallback: "2FAS Support")
    /// Support and Share
    internal static let supportAndShare = T.tr("Localizable", "settings__support_and_share", fallback: "Support and Share")
    /// Tell a friend
    internal static let tellAFriend = T.tr("Localizable", "settings__tell_a_friend", fallback: "Tell a friend")
    /// Terms of Service
    internal static let termsOfService = T.tr("Localizable", "settings__terms_of_service", fallback: "Terms of Service")
    /// Auto
    internal static let themeOptionAuto = T.tr("Localizable", "settings__theme_option_auto", fallback: "Auto")
    /// Auto - System Settings
    internal static let themeOptionAutoSystem = T.tr("Localizable", "settings__theme_option_auto_system", fallback: "Auto - System Settings")
    /// Dark
    internal static let themeOptionDark = T.tr("Localizable", "settings__theme_option_dark", fallback: "Dark")
    /// Light
    internal static let themeOptionLight = T.tr("Localizable", "settings__theme_option_light", fallback: "Light")
    /// Block after X failed attempts:
    internal static let tooManyAttemptsHeader = T.tr("Localizable", "settings__too_many_attempts_header", fallback: "Block after X failed attempts:")
    /// Touch ID
    internal static let touchId = T.tr("Localizable", "settings__touch_id", fallback: "Touch ID")
    /// Trash
    internal static let trash = T.tr("Localizable", "settings__trash", fallback: "Trash")
    /// Trash is Empty
    internal static let trashIsEmpty = T.tr("Localizable", "settings__trash_is_empty", fallback: "Trash is Empty")
    /// Turn on the PIN code and Face ID authorization to prevent unauthorized access to your tokens on this device.
    internal static let turnPinCodeToEnableFaceid = T.tr("Localizable", "settings__turn_pin_code_to_enable_faceid", fallback: "Turn on the PIN code and Face ID authorization to prevent unauthorized access to your tokens on this device.")
    /// Turn on the PIN code and Touch ID authorization to prevent unauthorized access to your tokens on this device.
    internal static let turnPinCodeToEnableTouchid = T.tr("Localizable", "settings__turn_pin_code_to_enable_touchid", fallback: "Turn on the PIN code and Touch ID authorization to prevent unauthorized access to your tokens on this device.")
    /// App version %@
    internal static func version(_ p1: Any) -> String {
      return T.tr("Localizable", "settings__version", String(describing: p1), fallback: "App version %@")
    }
    /// Widgets
    internal static let widgets = T.tr("Localizable", "settings__widgets", fallback: "Widgets")
    /// After you enable widgets, all your tokens can be accessed without your PIN code.
    /// 
    /// Are you sure you want to enable widgets?
    internal static let widgetsTitle = T.tr("Localizable", "settings__widgets_title", fallback: "After you enable widgets, all your tokens can be accessed without your PIN code.\n\nAre you sure you want to enable widgets?")
    /// Write a review
    internal static let writeAReview = T.tr("Localizable", "settings__write_a_review", fallback: "Write a review")
  }
  internal enum Tokens {
    /// Add group
    internal static let addGroup = T.tr("Localizable", "tokens__add_group", fallback: "Add group")
    /// What service do you want to add?
    internal static let addingServiceQuestionTitle = T.tr("Localizable", "tokens__adding_service_question_title", fallback: "What service do you want to add?")
    /// Additional info
    internal static let additionalInfo = T.tr("Localizable", "tokens__additional_info", fallback: "Additional info")
    /// Advanced
    internal static let advanced = T.tr("Localizable", "tokens__advanced", fallback: "Advanced")
    /// Alert
    internal static let advancedAlert = T.tr("Localizable", "tokens__advanced_alert", fallback: "Alert")
    /// Changing advanced settings is not recommended. Do so only when your 2FA provider requires it and when you have clear instructions.
    internal static let advancedAlertDescriptionTitle = T.tr("Localizable", "tokens__advanced_alert_description_title", fallback: "Changing advanced settings is not recommended. Do so only when your 2FA provider requires it and when you have clear instructions.")
    /// Changing advanced settings is not recommended. Do so only when your 2FA provider requires it and when you have clear instructions.
    internal static let advancedSettingsFooterTitle = T.tr("Localizable", "tokens__advanced_settings_footer_title", fallback: "Changing advanced settings is not recommended. Do so only when your 2FA provider requires it and when you have clear instructions.")
    /// Algorithm
    internal static let algorithm = T.tr("Localizable", "tokens__algorithm", fallback: "Algorithm")
    /// All tokens will be moved to the group: "My tokens"
    internal static let allTokensMovedToGroupTitle = T.tr("Localizable", "tokens__all_tokens_moved_to_group_title", fallback: "All tokens will be moved to the group: \"My tokens\"")
    /// Badge color
    internal static let badgeColor = T.tr("Localizable", "tokens__badge_color", fallback: "Badge color")
    /// Brand icon
    internal static let brandIcon = T.tr("Localizable", "tokens__brand_icon", fallback: "Brand icon")
    /// Camera is unavailable
    internal static let cameraIsUnavailable = T.tr("Localizable", "tokens__camera_is_unavailable", fallback: "Camera is unavailable")
    /// CAUTION
    internal static let caution = T.tr("Localizable", "tokens__caution", fallback: "CAUTION")
    /// Change brand icon
    internal static let changeBrandIcon = T.tr("Localizable", "tokens__change_brand_icon", fallback: "Change brand icon")
    /// Change label
    internal static let changeLabel = T.tr("Localizable", "tokens__change_label", fallback: "Change label")
    /// Check if the app has proper permissions in the System Settings
    internal static let checkAppPermissions = T.tr("Localizable", "tokens__check_app_permissions", fallback: "Check if the app has proper permissions in the System Settings")
    /// Choose method
    internal static let chooseMethod = T.tr("Localizable", "tokens__choose_method", fallback: "Choose method")
    /// Token copied to clipboard!
    internal static let copiedClipboard = T.tr("Localizable", "tokens__copied_clipboard", fallback: "Token copied to clipboard!")
    /// Copy token
    internal static let copyToken = T.tr("Localizable", "tokens__copy_token", fallback: "Copy token")
    /// Counter
    internal static let counter = T.tr("Localizable", "tokens__counter", fallback: "Counter")
    /// Are you sure you want to delete the token for:
    internal static let deleteToken = T.tr("Localizable", "tokens__delete_token", fallback: "Are you sure you want to delete the token for:")
    /// Do you want to permanently delete this 2FA service?
    internal static let doYouReallyWantToRemoveAllDevices = T.tr("Localizable", "tokens__do_you_really_want_to_remove_all_devices", fallback: "Do you want to permanently delete this 2FA service?")
    /// Duplicated Service Key
    internal static let duplicatedPrivateKey = T.tr("Localizable", "tokens__duplicated_private_key", fallback: "Duplicated Service Key")
    /// Enter Service Name
    internal static let enterServiceName = T.tr("Localizable", "tokens__enter_service_name", fallback: "Enter Service Name")
    /// Add manually
    internal static let fabAddmanually = T.tr("Localizable", "tokens__fab_addmanually", fallback: "Add manually")
    /// Service added successfully. We strongly recommend that you 
    internal static let galleryAdviceContentFirst = T.tr("Localizable", "tokens__gallery_advice_content_first", fallback: "Service added successfully. We strongly recommend that you ")
    /// 
    /// If someone takes over this QR code screenshot, they will be able to get your 2FA codes to this service.
    internal static let galleryAdviceContentLast = T.tr("Localizable", "tokens__gallery_advice_content_last", fallback: "\nIf someone takes over this QR code screenshot, they will be able to get your 2FA codes to this service.")
    /// delete the QR screenshot from your gallery.
    internal static let galleryAdviceContentMiddleBold = T.tr("Localizable", "tokens__gallery_advice_content_middle_bold", fallback: "delete the QR screenshot from your gallery.")
    /// Best practice
    internal static let galleryAdviceTitle = T.tr("Localizable", "tokens__gallery_advice_title", fallback: "Best practice")
    /// Importing 2FA tokens from the Google Authenticator app
    internal static let googleAuthImport = T.tr("Localizable", "tokens__google_auth_import", fallback: "Importing 2FA tokens from the Google Authenticator app")
    /// This QR code allows importing tokens from Google Authenticator
    internal static let googleAuthImportSubtitle = T.tr("Localizable", "tokens__google_auth_import_subtitle", fallback: "This QR code allows importing tokens from Google Authenticator")
    /// Tokens will be imported.
    internal static let googleAuthImportSubtitleEnd = T.tr("Localizable", "tokens__google_auth_import_subtitle_end", fallback: "Tokens will be imported.")
    /// %d out of %d
    internal static func googleAuthOutOfTitle(_ p1: Int, _ p2: Int) -> String {
      return T.tr("Localizable", "tokens__google_auth_out_of_title", p1, p2, fallback: "%d out of %d")
    }
    /// Group
    internal static let group = T.tr("Localizable", "tokens__group", fallback: "Group")
    /// Group name:
    internal static let groupName = T.tr("Localizable", "tokens__group_name", fallback: "Group name:")
    /// HOTP
    internal static let hotp = T.tr("Localizable", "tokens__hotp", fallback: "HOTP")
    /// Yes, I want to delete this service
    internal static let iWantToDeleteThisToken = T.tr("Localizable", "tokens__i_want_to_delete_this_token", fallback: "Yes, I want to delete this service")
    /// Incorrect service key (only numbers 2 to 7, letters)
    internal static let incorrectServiceKey = T.tr("Localizable", "tokens__incorrect_service_key", fallback: "Incorrect service key (only numbers 2 to 7, letters)")
    /// Initial counter
    internal static let initialCounter = T.tr("Localizable", "tokens__initial_counter", fallback: "Initial counter")
    /// Label
    internal static let label = T.tr("Localizable", "tokens__label", fallback: "Label")
    /// Label (1 or 2 characters):
    internal static let labelCharactersTitle = T.tr("Localizable", "tokens__label_characters_title", fallback: "Label (1 or 2 characters):")
    /// Move to Trash
    internal static let moveToTrash = T.tr("Localizable", "tokens__move_to_trash", fallback: "Move to Trash")
    /// My Tokens
    internal static let myTokens = T.tr("Localizable", "tokens__my_tokens", fallback: "My Tokens")
    /// Next token copied to clipboard!
    internal static let nextCopiedClipboard = T.tr("Localizable", "tokens__next_copied_clipboard", fallback: "Next token copied to clipboard!")
    /// Next Token: %@
    internal static func nextToken(_ p1: Any) -> String {
      return T.tr("Localizable", "tokens__next_token", String(describing: p1), fallback: "Next Token: %@")
    }
    /// Next Token value
    internal static let nextTokenTitle = T.tr("Localizable", "tokens__next_token_title", fallback: "Next Token value")
    /// There is no correct QR code in the selected image. Please try a different image.
    internal static let noCorrectQrCodeFoundTitle = T.tr("Localizable", "tokens__no_correct_qr_code_found_title", fallback: "There is no correct QR code in the selected image. Please try a different image.")
    /// No QR codes found
    internal static let noQrCodesFound = T.tr("Localizable", "tokens__no_qr_codes_found", fallback: "No QR codes found")
    /// %@ added
    internal static func numAdded(_ p1: Any) -> String {
      return T.tr("Localizable", "tokens__num_added", String(describing: p1), fallback: "%@ added")
    }
    /// Number of digits
    internal static let numberOfDigits = T.tr("Localizable", "tokens__number_of_digits", fallback: "Number of digits")
    /// Can’t find a brand icon in the 2FAS app?
    internal static let orderIconDescription = T.tr("Localizable", "tokens__order_icon_description", fallback: "Can’t find a brand icon in the 2FAS app?")
    /// Request a brand icon
    internal static let orderIconLink = T.tr("Localizable", "tokens__order_icon_link", fallback: "Request a brand icon")
    /// Request a brand icon
    internal static let orderIconTitle = T.tr("Localizable", "tokens__order_icon_title", fallback: "Request a brand icon")
    /// Submit icon as a company
    internal static let orderMenuOptionCompany = T.tr("Localizable", "tokens__order_menu_option_company", fallback: "Submit icon as a company")
    /// Request icon as a user
    internal static let orderMenuOptionUser = T.tr("Localizable", "tokens__order_menu_option_user", fallback: "Request icon as a user")
    /// Select the request method
    internal static let orderMenuTitle = T.tr("Localizable", "tokens__order_menu_title", fallback: "Select the request method")
    /// OTP Authentication
    internal static let otpAuthentication = T.tr("Localizable", "tokens__otp_authentication", fallback: "OTP Authentication")
    /// Personalization
    internal static let personalization = T.tr("Localizable", "tokens__personalization", fallback: "Personalization")
    /// Pick background color:
    internal static let pickBackgroundColor = T.tr("Localizable", "tokens__pick_background_color", fallback: "Pick background color:")
    /// This QR Code takes you to the App Store
    internal static let qrCodeLeadsToAppStore = T.tr("Localizable", "tokens__qr_code_leads_to_app_store", fallback: "This QR Code takes you to the App Store")
    /// This QR Code takes you to the Google Store
    internal static let qrCodeLeadsToGoogleStore = T.tr("Localizable", "tokens__qr_code_leads_to_google_store", fallback: "This QR Code takes you to the Google Store")
    /// This QR Code does not work!
    internal static let qrDoesNotWork = T.tr("Localizable", "tokens__qr_does_not_work", fallback: "This QR Code does not work!")
    /// Point your camera to the right QR Code and scan again.
    internal static let qrPointAndScanAgain = T.tr("Localizable", "tokens__qr_point_and_scan_again", fallback: "Point your camera to the right QR Code and scan again.")
    /// Could not read the QR code from the image!
    internal static let qrReadImageFailed = T.tr("Localizable", "tokens__qr_read_image_failed", fallback: "Could not read the QR code from the image!")
    /// Try to select a different image.
    internal static let qrReadImageTryAgain = T.tr("Localizable", "tokens__qr_read_image_try_again", fallback: "Try to select a different image.")
    /// Refresh time
    internal static let refreshTime = T.tr("Localizable", "tokens__refresh_time", fallback: "Refresh time")
    /// Delete Token 
    internal static let removeForever = T.tr("Localizable", "tokens__remove_forever", fallback: "Delete Token ")
    /// Delete service forever
    internal static let removeItForever = T.tr("Localizable", "tokens__remove_it_forever", fallback: "Delete service forever")
    /// Remove this service from 2FAS app
    internal static let removeServiceFromApp = T.tr("Localizable", "tokens__remove_service_from_app", fallback: "Remove this service from 2FAS app")
    /// Removing Group
    internal static let removingGroup = T.tr("Localizable", "tokens__removing_group", fallback: "Removing Group")
    /// or
    internal static let requestIconMiddle = T.tr("Localizable", "tokens__request_icon_middle", fallback: "or")
    /// Request an icon
    internal static let requestIconPageTitle = T.tr("Localizable", "tokens__request_icon_page_title", fallback: "Request an icon")
    /// You can use Social Media or email and share this text with them:
    internal static let requestIconProviderDescription = T.tr("Localizable", "tokens__request_icon_provider_description", fallback: "You can use Social Media or email and share this text with them:")
    /// Don’t forget to tag the company’s official account!
    internal static let requestIconProviderFootnote = T.tr("Localizable", "tokens__request_icon_provider_footnote", fallback: "Don’t forget to tag the company’s official account!")
    /// Hey! I’m using the 2FAS app to log in to your service with 2FA. However, your icon is missing! You can submit your icon here: https://2fas.com/yb
    internal static let requestIconProviderMessage = T.tr("Localizable", "tokens__request_icon_provider_message", fallback: "Hey! I’m using the 2FAS app to log in to your service with 2FA. However, your icon is missing! You can submit your icon here: https://2fas.com/yb")
    /// https://2fas.com/yb
    internal static let requestIconProviderMessageLink = T.tr("Localizable", "tokens__request_icon_provider_message_link", fallback: "https://2fas.com/yb")
    /// Let the service provider know
    internal static let requestIconProviderTitle = T.tr("Localizable", "tokens__request_icon_provider_title", fallback: "Let the service provider know")
    /// and let users vote for requested icons.
    internal static let requestIconSocialDescription = T.tr("Localizable", "tokens__request_icon_social_description", fallback: "and let users vote for requested icons.")
    /// Log in to our Discord server
    internal static let requestIconSocialLink = T.tr("Localizable", "tokens__request_icon_social_link", fallback: "Log in to our Discord server")
    /// Let us know on Discord
    internal static let requestIconSocialTitle = T.tr("Localizable", "tokens__request_icon_social_title", fallback: "Let us know on Discord")
    /// Retype this token
    internal static let retypeThisToken = T.tr("Localizable", "tokens__retype_this_token", fallback: "Retype this token")
    /// Point your camera to the screen to scan the QR Code
    internal static let scanQrCodeTitle = T.tr("Localizable", "tokens__scan_qr_code_title", fallback: "Point your camera to the screen to scan the QR Code")
    /// Search service
    internal static let searchServiceTitle = T.tr("Localizable", "tokens__search_service_title", fallback: "Search service")
    /// %d sec
    internal static func second(_ p1: Int) -> String {
      return T.tr("Localizable", "tokens__second", p1, fallback: "%d sec")
    }
    /// Select from Gallery
    internal static let selectFromGallery = T.tr("Localizable", "tokens__select_from_gallery", fallback: "Select from Gallery")
    /// Select group
    internal static let selectGroup = T.tr("Localizable", "tokens__select_group", fallback: "Select group")
    /// Select Service
    internal static let selectService = T.tr("Localizable", "tokens__select_service", fallback: "Select Service")
    /// Service could not be added because Service Key is invalid. Try again.
    internal static let serviceAddError = T.tr("Localizable", "tokens__service_add_error", fallback: "Service could not be added because Service Key is invalid. Try again.")
    /// Service with this Service Key already exists. Do you want to override it?
    internal static let serviceAlreadyExists = T.tr("Localizable", "tokens__service_already_exists", fallback: "Service with this Service Key already exists. Do you want to override it?")
    /// Service Information
    internal static let serviceInformation = T.tr("Localizable", "tokens__service_information", fallback: "Service Information")
    /// Service Key
    internal static let serviceKey = T.tr("Localizable", "tokens__service_key", fallback: "Service Key")
    /// Service key from scanned code is already used in %@. You're probably scanning it again
    internal static func serviceKeyAlreadyUsedTitle(_ p1: Any) -> String {
      return T.tr("Localizable", "tokens__service_key_already_used_title", String(describing: p1), fallback: "Service key from scanned code is already used in %@. You're probably scanning it again")
    }
    /// Key contains invalid characters
    internal static let serviceKeyInvalidCharacters = T.tr("Localizable", "tokens__service_key_invalid_characters", fallback: "Key contains invalid characters")
    /// Key has an invalid format
    internal static let serviceKeyInvalidFormat = T.tr("Localizable", "tokens__service_key_invalid_format", fallback: "Key has an invalid format")
    /// Key is too short. Minimum 4 characters
    internal static let serviceKeyToShort = T.tr("Localizable", "tokens__service_key_to_short", fallback: "Key is too short. Minimum 4 characters")
    /// Service Name
    internal static let serviceName = T.tr("Localizable", "tokens__service_name", fallback: "Service Name")
    /// Unfortunately, we don't know that service. How would you like to name it?
    internal static let serviceNameUnknownTitle = T.tr("Localizable", "tokens__service_name_unknown_title", fallback: "Unfortunately, we don't know that service. How would you like to name it?")
    /// Sorry, service not found
    internal static let serviceNotFoundSearch = T.tr("Localizable", "tokens__service_not_found_search", fallback: "Sorry, service not found")
    /// Do you want to discard your changes?
    internal static let serviceUnsavedChanges = T.tr("Localizable", "tokens__service_unsaved_changes", fallback: "Do you want to discard your changes?")
    /// Unsaved changes
    internal static let serviceUnsavedChangesTitle = T.tr("Localizable", "tokens__service_unsaved_changes_title", fallback: "Unsaved changes")
    /// how Service Key
    internal static let showServiceKey = T.tr("Localizable", "tokens__show_service_key", fallback: "how Service Key")
    /// Your Service Key is protected. Please add a PIN or Fingerprint lock to see it.
    internal static let showServiceKeySetupLock = T.tr("Localizable", "tokens__show_service_key_setup_lock", fallback: "Your Service Key is protected. Please add a PIN or Fingerprint lock to see it.")
    /// You will not be able to sign in to your %@ account without this token, as long as you have second factor authentication for %@ turned on.
    internal static func signInNotPossibleTitle(_ p1: Any, _ p2: Any) -> String {
      return T.tr("Localizable", "tokens__sign_in_not_possible_title", String(describing: p1), String(describing: p2), fallback: "You will not be able to sign in to your %@ account without this token, as long as you have second factor authentication for %@ turned on.")
    }
    /// Sort by
    internal static let sortBy = T.tr("Localizable", "tokens__sort_by", fallback: "Sort by")
    /// A - Z
    internal static let sortByAToZ = T.tr("Localizable", "tokens__sort_by_a_to_z", fallback: "A - Z")
    /// Manual
    internal static let sortByManual = T.tr("Localizable", "tokens__sort_by_manual", fallback: "Manual")
    /// Z - A
    internal static let sortByZToA = T.tr("Localizable", "tokens__sort_by_z_to_a", fallback: "Z - A")
    /// This code is incorrect or not supported. Try again.
    internal static let thisQrCodeIsInavlid = T.tr("Localizable", "tokens__this_qr_code_is_inavlid", fallback: "This code is incorrect or not supported. Try again.")
    /// You won't be able to restore this token anymore.
    internal static let tokenNotPossibleToRestore = T.tr("Localizable", "tokens__token_not_possible_to_restore", fallback: "You won't be able to restore this token anymore.")
    /// Token settings
    internal static let tokenSettings = T.tr("Localizable", "tokens__token_settings", fallback: "Token settings")
    /// Services list is empty
    internal static let tokensListIsEmpty = T.tr("Localizable", "tokens__tokens_list_is_empty", fallback: "Services list is empty")
    /// TOTP
    internal static let totp = T.tr("Localizable", "tokens__totp", fallback: "TOTP")
    /// OK, let's try again
    internal static let tryAgain = T.tr("Localizable", "tokens__try_again", fallback: "OK, let's try again")
    /// Take another try with a different search term
    internal static let tryDifferentSearchTerm = T.tr("Localizable", "tokens__try_different_search_term", fallback: "Take another try with a different search term")
    /// Type Service Name
    internal static let typeServiceName = T.tr("Localizable", "tokens__type_service_name", fallback: "Type Service Name")
    /// Unlock and retype this token
    internal static let unlockAndRetypeTokenTitle = T.tr("Localizable", "tokens__unlock_and_retype_token_title", fallback: "Unlock and retype this token")
    /// Use the "+" button to add a new service
    internal static let usePlusButtonToAddTokens = T.tr("Localizable", "tokens__use_plus_button_to_add_tokens", fallback: "Use the \"+\" button to add a new service")
    /// You will be unable to sign in to your %@ account without this token as long as you have two-factor authentication for %@ enabled.
    /// 
    /// You will be unable to restore this token from 2FAS trash.
    internal static func youWillNotBeAbleToSignInToYour(_ p1: Any, _ p2: Any) -> String {
      return T.tr("Localizable", "tokens__you_will_not_be_able_to_sign_in_to_your", String(describing: p1), String(describing: p2), fallback: "You will be unable to sign in to your %@ account without this token as long as you have two-factor authentication for %@ enabled.\n\nYou will be unable to restore this token from 2FAS trash.")
    }
  }
  internal enum Voiceover {
    /// Add Group
    internal static let addGroup = T.tr("Localizable", "voiceover__add_group", fallback: "Add Group")
    /// Add Service
    internal static let addService = T.tr("Localizable", "voiceover__add_service", fallback: "Add Service")
    /// Additional info: %@
    internal static func additionalInfo(_ p1: Any) -> String {
      return T.tr("Localizable", "voiceover__additional_info", String(describing: p1), fallback: "Additional info: %@")
    }
    /// Badge color: %@
    internal static func badgeColor(_ p1: Any) -> String {
      return T.tr("Localizable", "voiceover__badge_color", String(describing: p1), fallback: "Badge color: %@")
    }
    /// Copy Service Key
    internal static let copyServiceKey = T.tr("Localizable", "voiceover__copy_service_key", fallback: "Copy Service Key")
    /// Delete button
    internal static let deleteButton = T.tr("Localizable", "voiceover__delete_button", fallback: "Delete button")
    /// Dismissing
    internal static let dismissing = T.tr("Localizable", "voiceover__dismissing", fallback: "Dismissing")
    /// Edit %@
    internal static func edit(_ p1: Any) -> String {
      return T.tr("Localizable", "voiceover__edit", String(describing: p1), fallback: "Edit %@")
    }
    /// No search results
    internal static let noSearchResults = T.tr("Localizable", "voiceover__no_search_results", fallback: "No search results")
    /// Not selected
    internal static let notSelected = T.tr("Localizable", "voiceover__not_selected", fallback: "Not selected")
    /// This field contains a hidden Secret Key. To reveal it, use the Show button. It will only work if you have set up the apps PIN for the lock screen
    internal static let revealHiddenSecretKeyButtonTitle = T.tr("Localizable", "voiceover__reveal_hidden_secret_key_button_title", fallback: "This field contains a hidden Secret Key. To reveal it, use the Show button. It will only work if you have set up the apps PIN for the lock screen")
    /// Counter with seconds left to token change
    internal static let secondsLeftCounterTitle = T.tr("Localizable", "voiceover__seconds_left_counter_title", fallback: "Counter with seconds left to token change")
    /// Only numbers 2 to 9, letters. At least 4 characters
    internal static let secretHint = T.tr("Localizable", "voiceover__secret_hint", fallback: "Only numbers 2 to 9, letters. At least 4 characters")
    /// Selected
    internal static let selected = T.tr("Localizable", "voiceover__selected", fallback: "Selected")
    /// Service deleted
    internal static let serviceDeleted = T.tr("Localizable", "voiceover__service_deleted", fallback: "Service deleted")
    /// %@ service icon
    internal static func serviceIcon(_ p1: Any) -> String {
      return T.tr("Localizable", "voiceover__service_icon", String(describing: p1), fallback: "%@ service icon")
    }
    /// Service label with name %@ and color %@
    internal static func serviceLabelWithNameAndColor(_ p1: Any, _ p2: Any) -> String {
      return T.tr("Localizable", "voiceover__service_label_with_name_and_color", String(describing: p1), String(describing: p2), fallback: "Service label with name %@ and color %@")
    }
    /// Service name: %@
    internal static func serviceName(_ p1: Any) -> String {
      return T.tr("Localizable", "voiceover__service_name", String(describing: p1), fallback: "Service name: %@")
    }
    /// Show Service Key
    internal static let showServiceKey = T.tr("Localizable", "voiceover__show_service_key", fallback: "Show Service Key")
    /// Use Sort By to set service sorting
    internal static let sortByTitle = T.tr("Localizable", "voiceover__sort_by_title", fallback: "Use Sort By to set service sorting")
    /// Loading content
    internal static let spinner = T.tr("Localizable", "voiceover__spinner", fallback: "Loading content")
    /// Token %@. Tap to copy
    internal static func tokenTapToCopy(_ p1: Any) -> String {
      return T.tr("Localizable", "voiceover__token_tap_to_copy", String(describing: p1), fallback: "Token %@. Tap to copy")
    }
    /// Use the Add Service button to add a new service
    internal static let useAddServiceButtonTitle = T.tr("Localizable", "voiceover__use_add_service_button_title", fallback: "Use the Add Service button to add a new service")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension T {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

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
