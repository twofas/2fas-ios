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
import CoreData

struct CoreDataMigrationStep {
    let sourceModel: NSManagedObjectModel
    let destinationModel: NSManagedObjectModel
    let mappingModel: NSMappingModel
    
    // MARK: Init
    
    init(
        sourceVersion: CoreDataMigrationVersion,
        destinationVersion: CoreDataMigrationVersion,
        momdSubdirectory: String,
        bundle: Bundle
    ) {
        let sourceModel = NSManagedObjectModel.managedObjectModel(
            forResource: sourceVersion.rawValue,
            momdSubdirectory: momdSubdirectory,
            bundle: bundle
        )
        let destinationModel = NSManagedObjectModel.managedObjectModel(
            forResource: destinationVersion.rawValue,
            momdSubdirectory: momdSubdirectory,
            bundle: bundle
        )
        
        guard let mappingModel = CoreDataMigrationStep.mappingModel(
            fromSourceModel: sourceModel,
            toDestinationModel: destinationModel
        ) else {
            fatalError("Expected modal mapping not present")
        }
        
        self.sourceModel = sourceModel
        self.destinationModel = destinationModel
        self.mappingModel = mappingModel
    }
    
    // MARK: - Mapping
    
    private static func mappingModel(
        fromSourceModel sourceModel: NSManagedObjectModel,
        toDestinationModel destinationModel: NSManagedObjectModel
    ) -> NSMappingModel? {
        guard let customMapping = customMappingModel(
            fromSourceModel: sourceModel,
            toDestinationModel: destinationModel
        ) else {
            return inferredMappingModel(fromSourceModel: sourceModel, toDestinationModel: destinationModel)
        }
        
        return customMapping
    }
    
    private static func inferredMappingModel(
        fromSourceModel sourceModel: NSManagedObjectModel,
        toDestinationModel destinationModel: NSManagedObjectModel
    ) -> NSMappingModel? {
         
        try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
    }
    
    private static func customMappingModel(
        fromSourceModel sourceModel: NSManagedObjectModel,
        toDestinationModel destinationModel: NSManagedObjectModel
    ) -> NSMappingModel? {
        NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel)
    }
}

extension NSManagedObjectModel {
    static func managedObjectModel(
        forResource resource: String,
        momdSubdirectory: String,
        bundle: Bundle
    ) -> NSManagedObjectModel {
        guard let url = bundle.url(forResource: resource, withExtension: "mom", subdirectory: momdSubdirectory) else {
            fatalError("unable to find model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("unable to load model in bundle")
        }
        
        return model
    }
}
