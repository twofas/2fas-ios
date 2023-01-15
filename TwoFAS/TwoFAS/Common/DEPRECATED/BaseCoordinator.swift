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

import UIKit
import Common

class BaseCoordinator {
    
    var coordinatorDidFinish: Callback?
    
    private var childCoordinators: [BaseCoordinator] = []
    private(set) weak var router: RouterType!
    private weak var parentCoordinator: BaseCoordinator?
    private var isFinished = false
    
    var shouldFinishAfterLastChildFinished: Bool { true }
    
    func start() {
        preconditionFailure("This method needs to be overriden by concrete subclass.")
    }
    
    func addChild(_ coordinator: BaseCoordinator) {
        Log("addChild: \(coordinator) - \(self)")
        
        childCoordinators.append(coordinator)
        coordinator.setRouter(router)
        coordinator.didMoveToParentCoordinator(self)
    }
    
    func removeChild(_ coordinator: BaseCoordinator) {
        Log("removeChild: \(coordinator) - \(self)")
        
        if let index = childCoordinators.firstIndex(of: coordinator) {
            
            childCoordinators.remove(at: index)
            coordinator.wasRemovedFromParentCoordinator()
        } else {
            
            Log("Couldn't remove coordinator: \(coordinator). It's not a child coordinator.")
        }
    }
    
    func setRouter(_ router: RouterType) {
        
        self.router = router
    }
    
    func overrideNextRouterAnimation(animate: Bool) {
        
        router.overrideNextAnimation(animate: animate)
    }
    
    func didMoveToParentCoordinator(_ parentCoordinator: BaseCoordinator) {
         Log("didMoveToParentCoordinator: \(parentCoordinator) - \(self)")
        
        self.parentCoordinator = parentCoordinator
    }
    
    func wasRemovedFromParentCoordinator() {
        Log("wasRemovedFromParentCoordinator: \(String(describing: parentCoordinator)) - \(self)")
        parentCoordinator = nil
        router = nil
    }
    
    func childCoordinatorDidFinish(_ childCoordinator: BaseCoordinator) {
        Log("childCoordinatorDidFinish: \(childCoordinator)")
        
        removeChild(childCoordinator)
        
        if !hasChildren && shouldFinishAfterLastChildFinished {
            
            didFinish()
        }
    }
    
    func removeAllChildCoordinators() {
        Log("removeAllChildCoordinators: \(self)")
        
        childCoordinators.forEach { [weak self] coordinator in
            
            self?.removeChild(coordinator)
        }
    }
    
    func didFinish() {
        guard !isFinished else { return }
        Log("didFinish: \(self)")
        
        isFinished = true
        parentCoordinator?.childCoordinatorDidFinish(self)
        coordinatorDidFinish?()
    }
    
    var hasChildren: Bool {
        !childCoordinators.isEmpty
    }
}

extension BaseCoordinator: Equatable {
    static func == (lhs: BaseCoordinator, rhs: BaseCoordinator) -> Bool {
        lhs === rhs
    }
}

extension BaseCoordinator {
    enum AlertType {
        case error
        case info
        case custom(title: String)
    }
    
    func presentAlert(type: AlertType, text: String, didDisappear: Callback? = nil) {
        presentAlert(type: type, text: text, actionTitle: T.Commons.ok, didDisappear: didDisappear)
    }
    
    func presentAlert(type: AlertType, text: String, actionTitle: String, didDisappear: Callback? = nil) {
        let alert = createAlert(type: type, text: text, actionTitle: actionTitle, didDisappear: didDisappear)
        router.present(alert, animated: true, onPresentationFinished: nil)
    }
    
    func createAlert(
        type: AlertType,
        text: String,
        actionTitle: String,
        didDisappear: Callback? = nil
    ) -> UIViewController {
        let alert = AlertControllerDismissFlow(title: type.localizedDescription, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: T.Commons.ok, style: .cancel, handler: nil))
        alert.didDisappear = { _ in didDisappear?() }
        return alert
    }
    
    func presentChoice(
        type: AlertType,
        message: String,
        actionText: String,
        cancelText: String,
        action: @escaping Callback,
        cancel: @escaping Callback
    ) {
        
        let alert = UIAlertController(title: type.localizedDescription, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionText, style: .default) { _ in
            action()
        })
        alert.addAction(UIAlertAction(title: cancelText, style: .cancel) { _ in
            cancel()
        })
        router.present(alert, animated: true, onPresentationFinished: nil)
    }
}

extension BaseCoordinator.AlertType {
    
    var localizedDescription: String {
        
        let title: String
        
        switch self {
        case .error:
            title = T.Commons.error
        case .info:
            title = T.Commons.info
        case .custom(let titleValue):
            title = titleValue
        }
        
        return title
    }
}
