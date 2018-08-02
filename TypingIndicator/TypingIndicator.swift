//
//  TypingIndicator.swift
//  MessageKit
//
//  Created by Nathan Tannar on 2018-06-20.
//  Copyright © 2018 Nathan Tannar. All rights reserved.
//
import UIKit

/// A `UIView` subclass that maintains a mask to keep it fully circular
open class Circle: UIView {
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		layer.mask = roundedMask(corners: .allCorners, radius: bounds.height / 2)
	}
	
	open func roundedMask(corners: UIRectCorner, radius: CGFloat) -> CAShapeLayer {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		return mask
	}
	
}

/// A `UIView` subclass that holds 3 dots which can be animated
open class TypingIndicator: UIView {
	
	// MARK: - Properties
	
	/// The offset that each dot will transform by during the bounce animation
	open var bounceOffset: CGFloat = 7.5
	
	/// A convenience accessor for the `backgroundColor` of each dot
	open var dotColor: UIColor = UIColor.lightGray {
		didSet {
			dots.forEach { $0.backgroundColor = dotColor }
		}
	}
	
	/// A flag that determines if the bounce animation is added in `startAnimating()`
	open var isBounceEnabled: Bool = false
	
	/// A flag that determines if the opacity animation is added in `startAnimating()`
	open var isFadeEnabled: Bool = true
	
	/// A flag indicating the animation state
	public private(set) var isAnimating: Bool = false
	
	/// Keys for each animation layer
	private struct AnimationKeys {
		static let bounce = "typingIndicator.bounce"
		static let opacity = "typingIndicator.opacity"
	}
	
	// MARK: - Subviews
	public let stackView = UIStackView()
	
	public let dots: [Circle] = {
		return [Circle(), Circle(), Circle()]
	}()
	
	// MARK: - Initialization
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}
	
	/// Sets up the view
	private func setupView() {
		dots.forEach {
			$0.backgroundColor = dotColor
			$0.heightAnchor.constraint(equalTo: $0.widthAnchor).isActive = true
			stackView.addArrangedSubview($0)
		}
		stackView.axis = .horizontal
		stackView.alignment = .center
		stackView.distribution = .fillEqually
		addSubview(stackView)
	}
	
	// MARK: - Layout
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		stackView.frame = bounds
		stackView.spacing = bounds.width > 0 ? 5 : 0
	}
	
	// MARK: - Animation Layers
	
	/// The `CABasicAnimation` applied when `isBounceEnabled` is TRUE
	///
	/// - Returns: `CABasicAnimation`
	open func bounceAnimationLayer() -> CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "position.y")
		animation.byValue = -bounceOffset
		animation.duration = 0.5
		animation.repeatCount = .infinity
		animation.autoreverses = true
		return animation
	}
	
	/// The `CABasicAnimation` applied when `isFadeEnabled` is TRUE
	///
	/// - Returns: `CABasicAnimation`
	open func opacityAnimationLayer() -> CABasicAnimation {
		let animation = CABasicAnimation(keyPath: "opacity")
		animation.fromValue = 1
		animation.toValue = 0.5
		animation.duration = 0.5
		animation.repeatCount = .infinity
		animation.autoreverses = true
		return animation
	}
	
	// MARK: - Animation API
	
	/// Sets the state of the `TypingIndicator` to animating and applies animation layers
	open func startAnimating() {
		defer { isAnimating = true }
		guard !isAnimating else { return }
		var delay: TimeInterval = 0
		for dot in dots {
			DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
				guard let this = self else { return }
				if this.isBounceEnabled {
					dot.layer.add(this.bounceAnimationLayer(), forKey: AnimationKeys.bounce)
				}
				if this.isFadeEnabled {
					dot.layer.add(this.opacityAnimationLayer(), forKey: AnimationKeys.opacity)
				}
			}
			delay += 0.33
		}
	}
	
	/// Sets the state of the `TypingIndicator` to not animating and removes animation layers
	open func stopAnimating() {
		defer { isAnimating = false }
		guard isAnimating else { return }
		dots.forEach {
			$0.layer.removeAnimation(forKey: AnimationKeys.bounce)
			$0.layer.removeAnimation(forKey: AnimationKeys.opacity)
		}
	}
	
}
