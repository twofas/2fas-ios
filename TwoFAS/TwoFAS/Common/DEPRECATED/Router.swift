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

import UIKit.UINavigationController
import UIKit.UIViewController
import Common

protocol RouterType: AnyObject, PresentableType {
    
    var rootViewController: UIViewController? { get }
    
    // The completion blocks in the `setRootModule` and `push` methods are triggered upon the completion of the modules lifecycle
    func setRoot(_ module: PresentableType, animated: Bool, hideBar: Bool, completion: Callback?)
    func setAfterRoot(_ module: PresentableType, animated: Bool, completion: Callback?)
    func push(_ module: PresentableType, animated: Bool, completion: Callback?)
    func push(_ module: PresentableType, animated: Bool)
    func popToRootViewController(animated: Bool)
    func popToOneAferRoot(animated: Bool)
    func popLastViewController(animated: Bool)
    func popLast(_ module: PresentableType, animated: Bool)
    func popTo(_ module: PresentableType, animated: Bool)
    func present(_ module: PresentableType, animated: Bool, onPresentationFinished: Callback?)
    func dismiss(animated: Bool, completion: Callback?)
    func overrideNextAnimation(animate: Bool)
}

final class Router: NSObject, RouterType {
    
    private let navigationController: UINavigationController
    private var completions: [UIViewController: Callback]
    private var overrideAnimation: Bool?
    
    var rootViewController: UIViewController? {
        navigationController.viewControllers.first
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        completions = [:]
        super.init()
        
        self.navigationController.delegate = self
    }
    
    // MARK: - Root
    
    func setAfterRoot(_ module: PresentableType, animated: Bool, completion: Callback? = nil) {
        let animated = animateValue(passedValue: animated)
        let count = navigationController.viewControllers.count
        
        // swiftlint:disable empty_count
        if count == 0 || count == 1 {
            
            setRoot(module, animated: animated, hideBar: false, completion: nil)
            return
        }
        
        let removedRange = 1..<count
        var all = navigationController.viewControllers
        let vcs = navigationController.viewControllers[removedRange]
        for c in completions {
            
            if vcs.contains(c.key) {
                
                c.value()
                completions.removeValue(forKey: c.key)
            }
        }
        
        add(completion, for: module)
        all.removeSubrange(removedRange)
        all.append(module.toPresent())
        navigationController.setViewControllers(all, animated: animated)
    }
    
    func setRoot(
        _ module: PresentableType,
        animated: Bool = false,
        hideBar: Bool = false,
        completion: Callback? = nil
    ) {
        
        let animated = animateValue(passedValue: animated)
        // Call all completions so all coordinators can be deallocated
        runAllCompletions()
        
        add(completion, for: module)
        navigationController.setViewControllers([module.toPresent()], animated: animated)
        navigationController.isNavigationBarHidden = hideBar
    }
    
    // MARK: - Push and pop
    
    func push(_ module: PresentableType, animated: Bool = true, completion: Callback? = nil) {
        
        let animated = animateValue(passedValue: animated)
        let controller = module.toPresent()
        
        guard (controller is UINavigationController) == false
        else { fatalError("Can't push Navigation Controller onto stack") }
        
        add(completion, for: module)
        navigationController.pushViewController(controller, animated: animated)
    }
    
    func push(_ module: PresentableType, animated: Bool) {
        
        let animated = animateValue(passedValue: animated)
        push(module, animated: animated, completion: nil)
    }
    
    func popToRootViewController(animated: Bool = true) {
        
        let animated = animateValue(passedValue: animated)
        // Fix for iOS 14 bug - disapperaring TabBar
        navigationController.topViewController?.hidesBottomBarWhenPushed = false
        if let controllers = navigationController.popToRootViewController(animated: animated) {
            
            controllers.forEach { runCompletion(for: $0) }
        }
    }
    
    func popToOneAferRoot(animated: Bool) {
        let count = navigationController.viewControllers.count
        let second = 2
        
        guard count >= second else {
            Log(">>>>> Can't go beyond stack on popToOneAfterRoot!")
            return
        }
        
        let goTo = navigationController.viewControllers[1]
        popTo(goTo.toPresent(), animated: animated)
    }
    
    func popLastViewController(animated: Bool = true) {
        
        let animated = animateValue(passedValue: animated)
        if let controller = navigationController.popViewController(animated: animated) {
            
            runCompletion(for: controller)
        }
    }
    
    func popLast(_ module: PresentableType, animated: Bool = true) {
        
        let animated = animateValue(passedValue: animated)
        if navigationController.viewControllers.last == module.toPresent(),
           
           let controller = navigationController.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }
    
    func popTo(_ module: PresentableType, animated: Bool = true) {
        
        let animated = animateValue(passedValue: animated)
        if let controllers = navigationController.popToViewController(module.toPresent(), animated: animated) {
            
            controllers.forEach { runCompletion(for: $0) }
        }
    }
    
    func overrideNextAnimation(animate: Bool) {
        
        overrideAnimation = animate
    }
    
    // MARK: - Present
    
    func present(
        _ module: PresentableType,
        animated: Bool = true,
        onPresentationFinished completion: Callback?
    ) {
        
        let animated = animateValue(passedValue: animated)
        navigationController.present(module.toPresent(), animated: animated, completion: completion)
    }
    
    func dismiss(animated: Bool, completion: Callback?) {
        
        let animated = animateValue(passedValue: animated)
        navigationController.dismiss(animated: animated, completion: completion)
    }
    
    // MARK: - Private
    
    private func add(_ completion: Callback?, for module: PresentableType) {
        
        guard let completion else { return }
        completions[module.toPresent()] = completion
    }
    
    private func runCompletion(for controller: UIViewController) {
        
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
    
    private func runAllCompletions() {
        
        completions.forEach { $0.value() }
        completions.removeAll()
    }
    
    private func animateValue(passedValue: Bool) -> Bool {
        
        guard let override = overrideAnimation else { return passedValue }
        overrideAnimation = nil
        return override
    }
    
    // MARK: PresentableType
    
    func toPresent() -> UIViewController {
        navigationController
    }
}

extension Router: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // Ensure the view controller is popping
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from)
        else { return }
        guard !navigationController.viewControllers.contains(fromViewController) else { return }
        
        runCompletion(for: fromViewController)
    }
}
