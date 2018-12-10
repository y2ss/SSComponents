//
//  SSFloatingButton.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/3.
//  Copyright © 2018年 y2ss. All rights reserved.
//

@objc protocol SSRippleButtonDelegate: class, NSObjectProtocol {
    @objc optional func rotationStarted(_ button: SSRippleButton)
    @objc optional func rotationCompleted(_ button: SSRippleButton)
}

class SSRippleButton: UIButton {
    
    enum type {
        case raised
        case flat
        case floating
        case floatingRotation
    }
    
    weak var delegate: SSRippleButtonDelegate?
    var type: type = .raised {
        didSet {
            setupButtonType()
        }
    }
    var isRotated: Bool = true {
        didSet {
            self.rotate()
        }
    }
    var rippleColor: UIColor = UIColor(white: 0.5, alpha: 1) {
        willSet {
            mdLayer.effectColor = newValue
        }
    }
    var imageNormal: UIImage? {
        willSet {
            if btImage == nil {
                btImage = UIImageView.init(image: newValue)
                if imageSize != nil {
                    adjuestImageSize()
                } else {
                    btImage?.contentMode = .center
                    btImage?.frame = self.bounds
                }
                btImage?.clipsToBounds = false
                self.addSubview(btImage!)
            }
        }
    }
    var imageRotated: UIImage?
    var imageSize: CGFloat? {
        didSet {
            adjuestImageSize()
        }
    }
    
    private lazy var mdLayer: SSRippleLayer = {
        let layer = SSRippleLayer.init(superView: self)
        layer.effectColor = rippleColor
        layer.rippleScaleRatio = 1
        return layer
    }()
    private var btImage: UIImageView?
    
    override var isEnabled: Bool {
        didSet {
            setupButtonType()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLayer()
    }
    
    init(frame: CGRect, type: type, rippleColor: UIColor? = nil) {
        super.init(frame: frame)
        self.type = type
        initLayer()
        if let rippleColor = rippleColor {
            self.rippleColor = rippleColor
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayer() {
        if backgroundColor == nil {
            self.backgroundColor = UIColor(hex: 0xD6D6D6)
        }
        self.layer.cornerRadius = 2.5
        self.imageView?.clipsToBounds = false
        self.imageView?.contentMode = .center
        setupButtonType()
    }
    
    private func setupButtonType() {
        if self.isEnabled {
            switch self.type {
            case .raised:
                mdLayer.isEnableElevation = true
                mdLayer.restingElevation = 2
                break
            case .flat:
                mdLayer.isEnableElevation = false
                self.backgroundColor = UIColor.clear
                break
            case .floating:
                let size = min(self.bounds.width, self.bounds.height)
                self.layer.cornerRadius = size * 0.5
                mdLayer.restingElevation = 6
                mdLayer.isEnableElevation = true
                break
            case .floatingRotation:
                let size = min(self.bounds.width, self.bounds.height)
                self.layer.cornerRadius = size * 0.5
                mdLayer.restingElevation = 6
                mdLayer.isEnableElevation = true
                break
            }
        } else {
            mdLayer.isEnableElevation = false
        }
    }
    
    private func adjuestImageSize() {
        guard let imageSize = imageSize, let btImage = btImage else { return }
        let x = self.bounds.width * 0.5
        let y = self.bounds.height * 0.5
        let b = CGRect.init(x: x - imageSize * 0.5, y: y - imageSize * 0.5, width: imageSize, height: imageSize)
        btImage.contentMode = .scaleAspectFit
        btImage.frame = b
    }
    
    private func rotate() {
        guard let btImage = btImage else { return }
        let duration: TimeInterval = 0.3
        if imageNormal == nil || imageRotated == nil {
            if !isRotated {
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: .init(rawValue: 0),
                               animations: {
                                btImage.transform = CGAffineTransform.init(rotationAngle: .pi * 0.25)
                }) { flag in
                    self.isRotated = true
                    self.delegate?.rotationCompleted?(self)
                }
                delegate?.rotationStarted?(self)
            } else {
                UIView.animate(withDuration: duration,
                               delay: 0,
                               options: .init(rawValue: 0),
                               animations: {
                                btImage.transform = CGAffineTransform.init(rotationAngle: 0)
                }) { flag in
                    self.isRotated = false
                    self.delegate?.rotationCompleted?(self)
                }
            }
        } else {
            if !isRotated {
                UIView.animate(withDuration: duration * 0.5, delay: 0, options: .init(rawValue: 0), animations: {
                    btImage.alpha = 0
                }) { flag in
                    UIView.animate(withDuration: duration * 0.5, animations: {
                        btImage.alpha = 1
                    })
                }
                UIView.animate(withDuration: duration * 0.5,
                               delay: 0,
                               options: .init(rawValue: 0),
                               animations: {
                    btImage.transform = CGAffineTransform.init(rotationAngle: .pi * 0.25)
                }) { flag in
                    btImage.image = self.imageRotated!
                    btImage.transform = CGAffineTransform.init(rotationAngle: -.pi * 0.5)
                    UIView.animate(withDuration: duration * 0.5, animations: {
                        btImage.transform = CGAffineTransform.init(rotationAngle: 0)
                    }, completion: { flag in
                        self.isRotated = true
                        self.delegate?.rotationCompleted?(self)
                    })
                }
                delegate?.rotationStarted?(self)
            } else {
                UIView.animate(withDuration: duration * 0.5,
                               delay: 0,
                               options: .init(rawValue: 0),
                               animations: {
                    btImage.alpha = 0
                }) { flag in
                    UIView.animate(withDuration: duration * 0.5, animations: {
                        btImage.alpha = 1
                    })
                }
                UIView.animate(withDuration: duration * 0.5,
                               delay: 0,
                               options: .init(rawValue: 0),
                               animations: {
                    btImage.transform = CGAffineTransform.init(rotationAngle: -.pi * 0.25)
                }) { flag in
                    btImage.image = self.imageNormal!
                    btImage.transform = CGAffineTransform.init(rotationAngle: .pi * 0.5)
                    UIView.animate(withDuration: duration * 0.5, animations: {
                        btImage.transform = CGAffineTransform.init(rotationAngle: 0)
                    }, completion: { flag in
                        self.isRotated = false
                        self.delegate?.rotationCompleted?(self)
                    })
                }
                delegate?.rotationStarted?(self)
            }
        }
    }
}
