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

import Foundation
import Common
import Token
import Storage

final class TokensPresenter {
    enum State {
        case normal
        case edit
    }
    
    private var currentState: State = .normal
    private var searchPhrase: String?
    private var isSearching = false
    private var changeRequriesTokenRefresh = false
    private var serviceWasCreated: ServiceData?
    
    weak var view: TokensViewControlling?
    
    private let interactor: TokensModuleInteracting
    private let flowController: TokensPlainFlowControlling
    
    var isMainOnlyCategory: Bool { interactor.isMainOnlyCategory }
    
    init(flowController: TokensPlainFlowControlling, interactor: TokensModuleInteracting) {
        self.flowController = flowController
        self.interactor = interactor
        
        interactor.linkAction = { [weak self] in self?.handleLinkAction($0) }
    }
    
    deinit {
        interactor.stopCounters()
    }
}

extension TokensPresenter {
    // MARK: - Sort Type
    var isSortingEnabled: Bool {
        interactor.isSortingEnabled
    }
    
    var count: Int { interactor.count }
    
    var selectedSortType: SortType {
        interactor.selectedSortType
    }
    
    func handleSetSortType(_ sortType: SortType) {
        Log("TokensPresenter - handleSetSortType: \(sortType)")
        interactor.setSortType(sortType)
    }
    
    // MARK: - App events
    
    func viewWillAppear() {
        Log("TokensPresenter - viewWillAppear")
        interactor.sync()
        appActiveActions()
    }
    
    func handleAppDidBecomeActive() {
        Log("TokensPresenter - handleAppDidBecomeActive")
        appActiveActions()
    }
    
    func handleAppBecomesInactive() {
        Log("TokensPresenter - handleAppBecomesInactive")
        interactor.stopCounters()
    }
    
    // MARK: - External Actions
    
    func handleSectionsUpdated() {
        reloadData()
    }
    
    func handleNewData() {
        changeRequriesTokenRefresh = true
        reloadData()
    }
    
    func handleLinkAction(_ linkAction: TokensLinkAction) {
        Log("TokensPresenter - handleLinkAction")
        switch linkAction {
        case .codeAlreadyExists: flowController.toCodeAlreadyExists()
        case .shouldAddCode(let descriptionText): flowController.toShowShouldAddCode(with: descriptionText)
        case .sendLogs(let auditID): flowController.toSendLogs(auditID: auditID)
        case .newData: handleNewData()
        case .shouldRename(let currentName, let secret):
            flowController.toShouldRenameService(currentName: currentName, secret: secret)
        case .serviceWasCreaded(let serviceData):
            flowController.toServiceWasCreated(serviceData)
        }
    }
    
    func handleRenameService(newName: String, secret: Secret) {
        Log("TokensPresenter - handleRenameService")
        interactor.renameService(newName: newName, secret: secret)
        handleNewData()
    }
    
    func handleCancelRenaming(secret: Secret) {
        Log("TokensPresenter - handleCancelRenaming")
        interactor.cancelRenaming(secret: secret)
    }
    
    func handleClearStoredCode() {
        Log("TokensPresenter - handleClearStoredCode")
        interactor.clearStoredCode()
    }
    
    func handleAddStoredCode() {
        Log("TokensPresenter - handleAddStoredCode")
        interactor.addStoredCode()
        handleNewData()
    }
    
    func handleExternalAction(_ actions: Set<TokensExternalAction>) {
        Log("TokensPresenter - handleExternalAction")
        if actions.contains(.newData) {
            handleNewData()
        }
        if let data = actions.first(where: { $0.addedServiceData != nil }) {
            self.serviceWasCreated = data.addedServiceData
            handleNewData()
        }
        if actions.contains(.finishedFlow) {
            guard let serviceWasCreated else { return }
            flowController.toServiceWasCreated(serviceWasCreated)
            self.serviceWasCreated = nil
        }
        if actions.contains(.sync) {
            interactor.sync()
        }
    }
    
    func handleServicesWereUpdated(modified: [Secret]?, deleted: [Secret]?) {
        interactor.servicesWereUpdated()
        handleNewData()
    }
    
    // MARK: - Actions
    func handleShowCamera() {
        Log("TokensPresenter - handleShowCamera")
        interactor.checkCameraPermission { [weak self] value in
            if value {
                Log("TokensPresenter - toShowCamera")
                self?.flowController.toShowCamera()
            } else {
                Log("TokensPresenter - toCameraNotAvailable")
                self?.flowController.toCameraNotAvailable()
            }
        }
    }
    
    func handleImportExternalFile() {
        Log("TokensPresenter - handleImportExternalFile")
        flowController.toFileImport()
    }
    
    func handleShowHelp() {
        Log("TokensPresenter - handleShowHelp")
        flowController.toHelp()
    }
    
    func handleShowSortSelection() {
        Log("TokensPresenter - handleShowSortSelection")
        flowController.toShowSortTypes(selectedSortOption: interactor.selectedSortType) { [weak self] selectedValue in
            self?.interactor.setSortType(selectedValue)
            self?.reloadData()
        }
    }
    
    func handleTokensScreenIsVisible() {
        if interactor.isActiveSearchEnabled && showSearchBar {
            view?.showKeyboard()
        }
    }
    
    // MARK: - Search
    
    var showSearchBar: Bool {
        count > 1 && currentState == .normal
    }
    
    func handleSetSearchPhrase(_ phrase: String) {
        Log("TokensPresenter - handleSetSearchPhrase")
        self.searchPhrase = phrase
        isSearching = true
        reloadData()
    }
    
    func handleClearSearchPhrase() {
        Log("TokensPresenter - handleClearSearchPhrase")
        self.searchPhrase = nil
        isSearching = false
        reloadData()
    }
    
    // MARK: - Menu
    
    var enableMenu: Bool { currentState == .normal }
    
    func handleMenuEnded() {
        view?.unlockBars()
    }
    
    // MARK: - Drag & Drop
    
    var shouldAddCustomPreview: Bool { currentState == .normal }
    var canDragAndDrop: Bool { currentState == .edit && !isSearching && !interactor.isSortingEnabled }
    var enableDragAndDropOnStart: Bool { UIDevice.isiPad }
    
    func handleDragItem(for serviceData: ServiceData) -> UIDragItem? {
        let itemProvider = NSItemProvider(object: itemProviderObject(for: serviceData))
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = serviceData
        
        return dragItem
    }
    
    func handleStartDrag() {
        view?.lockBars()
    }
    
    func handleDropSessionDidEnd() {
        view?.unlockBars()
    }
    
    // MARK: - State change
    
    func handleEnterEditMode() {
        Log("TokensPresenter - handleEnterEditMode")
        setCurrentState(.edit)
    }
    
    func handleLeaveEditMode() {
        Log("TokensPresenter - handleLeaveEditMode")
        setCurrentState(.normal)
        view?.unlockBars()
    }
    
    func handleUserTapped(on serviceData: ServiceData) {
        Log("TokensPresenter - handleUserTapped")
        switch currentState {
        case .edit:
            Log("TokensPresenter - handleUserTapped - edit")
            flowController.toShowEditingService(with: serviceData, freshlyAdded: false, gotoIconEdit: false)
        case .normal:
            Log("TokensPresenter - handleUserTapped - normal")
            handleCopyToken(from: serviceData)
        }
    }
    
    func handleMoveService(_ serviceData: ServiceData, from: IndexPath, to: IndexPath, newSection: SectionData?) {
        guard currentState == .edit, from != to else { return }
        interactor.moveService(
            serviceData,
            from: from,
            to: to,
            newSection: newSection
        )
        
        handleDropSessionDidEnd()
        
        reloadData()
    }
    
    // MARK: - Sections
    
    func handleShowSectionCreation() {
        Log("TokensPresenter - handleShowSectionCreation")
        flowController.toCreateSection { [weak self] name in
            self?.interactor.createSection(with: name)
            self?.reloadData()
        }
    }
    
    func handleAddSection(with name: String) {
        Log("TokensPresenter - handleAddSection")
        interactor.createSection(with: name)
        reloadData()
    }
    
    func handleToggleCollapseAction(with section: GridSection) {
        interactor.toggleCollapseSection(section)
        reloadData()
    }
    
    func handleMoveDown(_ section: GridSection) {
        Log("TokensPresenter - handleMoveDown")
        interactor.moveDown(section)
        reloadData()
    }
    
    func handleMoveUp(_ section: GridSection) {
        Log("TokensPresenter - handleMoveUp")
        interactor.moveUp(section)
        reloadData()
    }
    
    func handleRename(_ section: GridSection, with title: String) {
        Log("TokensPresenter - handleRename")
        interactor.rename(section, with: title)
        reloadData()
    }
    
    func handleShowSectionDeleteQuestion(_ section: GridSection) {
        Log("TokensPresenter - handleShowSectionDeleteQuestion")
        flowController.toAskDeleteSection { [weak self] in
            Log("TokensPresenter - handleShowSectionDeleteQuestion - deleting")
            self?.interactor.delete(section)
            self?.reloadData()
        }
    }

    // MARK: - Services
    
    func handleAddService() {
        Log("TokensPresenter - handleAddService")
        interactor.checkCameraPermission { [weak self] permission in
            Log("TokensPresenter - handleAddService - toShowSelectAddingMethod")
            self?.flowController.toShowSelectAddingMethod(isCameraAvailable: permission)
        }
    }
    
    func handleEditService(_ serviceData: ServiceData) {
        Log("TokensPresenter - handleEditService")
        flowController.toShowEditingService(with: serviceData, freshlyAdded: false, gotoIconEdit: false)
    }
    
    func handleDeleteService(_ serviceData: ServiceData) {
        Log("TokensPresenter - handleDeleteService")
        flowController.toDeleteService(serviceData: serviceData)
    }
    
    func handleCopyToken(from serviceData: ServiceData) {
        Log("TokensPresenter - handleCopyToken")
        interactor.copyToken(from: serviceData)
    }
    
    // MARK: - Timer and Counter support
    
    func handleRegisterTOTP(_ consumer: TokenTimerConsumer) {
        interactor.registerTOTP(consumer)
    }
    
    func handleRemoveTOTP(_ consumer: TokenTimerConsumer) {
        interactor.removeTOTP(consumer)
    }
    
    func handleRegisterHOTP(_ consumer: TokenCounterConsumer) {
        interactor.registerHOTP(consumer)
    }
    
    func handleRemoveHOTP(_ consumer: TokenCounterConsumer) {
        interactor.removeHOTP(consumer)
    }
    
    func handleEnableHOTPCounter(for secret: Secret) {
        interactor.enableHOTPCounter(for: secret)
    }
}

private extension TokensPresenter {
    func appActiveActions() {
        updateEditStateButton()
        changeDragAndDropIfNecessary(enable: false)
        changeRequriesTokenRefresh = true
        reloadData()
        interactor.handleURLIfNecessary()
    }
    
    func updateEditStateButton() {
        switch currentState {
        case .edit:
            view?.updateEditState(using: mapCancelState(hasServices: interactor.hasServices))
        case .normal:
            view?.updateEditState(using: mapEditState(hasServices: interactor.hasServices))
        }
    }
    
    func setCurrentState(_ currentState: State) {
        self.currentState = currentState
        
        updateEditStateButton()
        
        switch currentState {
        case .normal:
            changeDragAndDropIfNecessary(enable: false)
            changeRequriesTokenRefresh = true
            reloadData()
            interactor.sync()
            
        case .edit:
            changeDragAndDropIfNecessary(enable: true)
            reloadData()
        }
    }
    
    func changeDragAndDropIfNecessary(enable: Bool) {
        guard interactor.isiPhone else { return }
        if enable {
            view?.enableDragging()
        } else {
            view?.disableDragging()
        }
    }
    
    func itemProviderObject(for serviceData: ServiceData) -> NSItemProviderWriting {
        if currentState == .edit {
            return serviceData.summarizeDescription as NSString
        } else {
            let provider = GridViewItemProviderWriting(serviceData: serviceData)
            provider.tokenForService = { [weak self] in
                self?.interactor.copyTokenValue(from: serviceData) ?? T.Commons.error
            }
            return provider
        }
    }
    
    func reloadData() {
        let currentServices = interactor.categoryData
        interactor.fetchData(phrase: searchPhrase)
        let newServices = interactor.categoryData
        
        if interactor.hasServices {
            view?.updateAddIcon(using: mapButtonStateFor(currentState, isFirst: false))
            view?.showList()
            
            if Set<CategoryData>(currentServices) != Set<CategoryData>(newServices) || changeRequriesTokenRefresh {
                interactor.reloadTokens()
            }
            updateEditStateButton()

            let snapshot = interactor.createSnapshot(state: currentState.transform, isSearching: isSearching)
            view?.reloadData(newSnapshot: snapshot)
        } else {
            if !isSearching && currentState == .edit {
                setCurrentState(.normal)
            }
            view?.updateAddIcon(using: mapButtonStateFor(currentState, isFirst: !isSearching))
            interactor.stopCounters()
            updateEditStateButton()

            if isSearching {
                view?.showSearchEmptyScreen()
            } else {
                view?.showEmptyScreen()
            }
            view?.reloadData(newSnapshot: interactor.emptySnapshot)
        }
                
        changeRequriesTokenRefresh = false
    }
    
    func mapButtonStateFor(_ currentState: State, isFirst: Bool) -> TokensViewControllerAddState {
        switch (currentState, isFirst) {
        case (.edit, _):
            return .none
        case (.normal, true):
            return .firstTime
        case (.normal, false):
            return .normal
        }
    }
    
    func mapCancelState(hasServices: Bool) -> TokensViewControllerEditState {
        if hasServices {
            return .cancel
        } else {
            return .none
        }
    }
    
    func mapEditState(hasServices: Bool) -> TokensViewControllerEditState {
        if hasServices {
            return .edit
        } else {
            return .none
        }
    }
}

private extension TokensPresenter.State {
    var transform: TokensModuleInteractorState {
        switch self {
        case .normal: return .normal
        case .edit: return .edit
        }
    }
}
