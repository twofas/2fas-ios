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

final class PINPadCodeDots: UIView {   
    private let dotDimension: CGFloat = Theme.Metrics.PINDotDimension
    private let dotSpacing: CGFloat = 12
    
    private var dotCount: Int?
    
    private var dots: [Dot] = []
    private var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        isUserInteractionEnabled = false
    }
    
    func setDots(number dotCount: Int) {
        self.dotCount = dotCount
        stackView?.removeFromSuperview()
        dots = []
        let dotFrame = CGRect(x: 0, y: 0, width: dotDimension, height: dotDimension)
        
        for _ in 0 ..< dotCount {           
            let dot = Dot(frame: dotFrame)
            dot.translatesAutoresizingMaskIntoConstraints = false
            dots.append(dot)
        }
                
        stackView = UIStackView(arrangedSubviews: dots)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.heightAnchor.constraint(equalToConstant: dotDimension)
        ])
        
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = dotSpacing
    }
    
    func fillDots(count: Int, animated: Bool) {
        guard let dotCount else { return }
        assert(count <= dotCount)
        
        for i in 0 ..< dotCount {
            let dot = dots[i]
            
            if i < count {
                dot.full(animated: animated)
            } else {
                dot.empty(animated: animated)
            }
        }
    }
    
    func emptyDots(animated: Bool) {       
        fillDots(count: 0, animated: animated)
    }
    
    private final class Dot: UIView {       
        private var fullCircle: PINPadCircleView!
        private var emptyCircle: PINPadCircleView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        
        private func commonInit() {
            let borderWidth = Theme.Metrics.PINDotBorderWidth
            let dimension = frame.width
            
            emptyCircle = PINPadCircleView(typeOfCircle: .empty, dimension: dimension, borderWidth: borderWidth)
            fullCircle = PINPadCircleView(typeOfCircle: .full, dimension: dimension, borderWidth: borderWidth)
            
            addSubview(emptyCircle)
            addSubview(fullCircle)
            
            emptyCircle.pinToParent()
            fullCircle.pinToParent()
            
            fullCircle.alpha = 0
        }
        
        func full(animated: Bool) {
            guard animated else {
                fullCircle.alpha = 1
                return
            }
            
            UIView.animate(
                withDuration: Theme.Animations.Timing.show,
                delay: 0,
                options: [.beginFromCurrentState, Theme.Animations.Curve.show],
                animations: { self.fullCircle.alpha = 1 },
                completion: nil
            )
        }
        
        func empty(animated: Bool) {
            guard animated else {
                fullCircle.alpha = 0
                return
            }
            
            UIView.animate(
                withDuration: Theme.Animations.Timing.hide,
                delay: 0,
                options: [.beginFromCurrentState, Theme.Animations.Curve.hide],
                animations: { self.fullCircle.alpha = 0 },
                completion: nil
            )
        }
        
        override var intrinsicContentSize: CGSize { CGSize(width: frame.width, height: frame.height) }
    }
}
