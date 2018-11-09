//
//  UIScreen.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/9.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIScreen {
    
    class var size: CGSize {
        return UIScreen.main.bounds.size
    }
    
    class var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    class var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    class var orientationSize: CGSize {
        let isLand = UIApplication.shared.statusBarOrientation == .landscapeLeft
            || UIApplication.shared.statusBarOrientation == .landscapeRight
        return isLand ? CGSize(width: self.height, height: self.width) : self.size
    }
    
    class var orientationWidth: CGFloat {
        return self.orientationSize.width
    }
    
    class var orientationHeight: CGFloat {
        return self.orientationSize.height
    }
    
    class var dpiSize: CGSize {
        return CGSize(width: self.width * UIScreen.main.scale, height: self.height * UIScreen.main.scale)
    }

}
