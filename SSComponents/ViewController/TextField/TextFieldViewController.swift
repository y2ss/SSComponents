//
//  TextFieldViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/6.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class TextFieldViewController: UIViewController, SSAutoResizeTextFieldDelegate {
    
    private var nowTextField: SSAutoResizeTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        let textField = SSAutoResizeTextField.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.width * 0.8, height: 53))
        textField.center = CGPoint.init(x: UIScreen.width * 0.5, y: UIScreen.height * 0.15)
        textField.hint = "textField 1"
        textField.isDividerAnimation = true
        textField.delegate = self
        self.view.addSubview(textField)
        
        let textField2 = SSAutoResizeTextField.init(frame: CGRect.init(x: 0, y: textField.y + 53, width: textField.width, height: 76))
        textField2.centerX = UIScreen.width * 0.5
        textField2.label = "textField 2"
        textField2.isDividerAnimation = false
        textField2.delegate = self
        textField2.maxCharacterCount = 20
        textField2.isSingleLine = true
        self.view.addSubview(textField2)
        
        let textField3 = SSAutoResizeTextField.init(frame: CGRect.init(x: 0, y: textField2.y + 76, width: textField.width, height: 53))
        textField3.centerX = UIScreen.width * 0.5
        textField3.label = "textField 3"
        textField3.minVisibleLines = 0
        textField3.isHighlightLabel = true
        textField3.delegate = self
        textField3.isSingleLine = false
        textField3.isAutoComplete = false
        textField3.maxVisibleLines = 3
        textField3.isFloatingLabel = true
        self.view.addSubview(textField3)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc private func tapAction() {
        if nowTextField != nil {
            _ = nowTextField.resignFirstResponder()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: SSAutoResizeTextField) -> Bool {
        nowTextField = textField
        return true
    }
    
    func textFieldDidEndEditing(_ textField: SSAutoResizeTextField) {
        nowTextField = nil
    }
}
