//
//  This file is part of the 2FAS iOS app (https://github.com/twofas/2fas-ios)
//  Copyright © 2026 Two Factor Authentication Service, Inc.
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

import UIKit
import Common
import Data

@Observable
final class GoogleImportPresenter {
    var scannedCount: Int = 0
    var totalCount: Int = 0
    var isComplete: Bool = false

    var showBatchError = false
    var alreadyScanned = false

    private var isShowingSummary = false
    private var viewAppeared = false
    
    var scannedList: [Bool] {
        var list: [Bool] = Array(repeating: false, count: totalCount)
        pages.forEach { key, _ in
            if key < list.count {
                list[key] = true
            }
        }
        return list
    }

    private let flowController: GoogleImportFlowControlling
    private let interactor: GoogleImportModuleInteracting

    private var batchID: Int
    private var pages: [Int: [Code]] = [:]
    private var importableCodes: [Code] = []

    init(
        flowController: GoogleImportFlowControlling,
        interactor: GoogleImportModuleInteracting,
        data: GoogleScanData
    ) {
        self.flowController = flowController
        self.interactor = interactor
        self.batchID = data.batchID
        self.totalCount = data.size
        add(data)
    }
}

extension GoogleImportPresenter {
    func handleScanWithCamera() {
        flowController.toCamera()
    }

    func handleScanFromGallery() {
        flowController.toGallery()
    }

    func handleViewAppeared() {
        viewAppeared = true
        if isComplete {
            prepareSummary()
        }
    }

    func beginSummary() -> (importable: Int, total: Int)? {
        guard !isShowingSummary else { return nil }
        isShowingSummary = true
        let codes = collectedCodes
        importableCodes = interactor.filterImportableCodes(codes)
        return (importableCodes.count, codes.count)
    }

    func handleScannedBatch(_ data: GoogleScanData?) {
        guard let data else { return }
        add(data)
    }

    func handleImport() {
        guard !importableCodes.isEmpty else {
            flowController.close()
            return
        }
        AppEventLog(.importGoogleAuth)
        interactor.addCodes(importableCodes)
        flowController.toImportSummary(count: importableCodes.count)
    }

    func handleClose() {
        flowController.close()
    }
    
    func handleOnlyScanned() {
        prepareSummary()
    }
}

private extension GoogleImportPresenter {
    var collectedCodes: [Code] {
        pages.sorted { $0.key < $1.key }.flatMap { $0.value }
    }

    func add(_ data: GoogleScanData) {
        if data.batchID != batchID {
            showBatchError = true
            return
        }
        if pages[data.index] != nil {
            alreadyScanned = true
            return
        }
        pages[data.index] = data.codes
        scannedCount = pages.count
        isComplete = scannedCount >= totalCount

        if isComplete, viewAppeared {
            prepareSummary()
        }
    }

    func prepareSummary() {
        guard let params = beginSummary() else { return }
        flowController.toSummary(importableCount: params.importable, totalCount: params.total)
    }
}
