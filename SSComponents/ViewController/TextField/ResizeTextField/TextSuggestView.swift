//
//  TextSuggestView.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/5.
//  Copyright © 2018年 y2ss. All rights reserved.
//


class TextSuggestView: UIButton {

    var suggestionDict = [String]()
    private var suggestionOpts = [String]()
    
    private lazy var tableView: SuggestTableView = {
        let tableView = SuggestTableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.separatorStyle = .none
        return tableView
    }()
    private weak var textField: SSAutoResizeTextField?
    private lazy var popupHolder: UIView = {
        let view = UIView()
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize.init(width: 0, height: 2.5)
        return view
    }()
    private var keyboardHeight: Float = 0
    
    private let CellIdentifier = "CellIdentifier"
    
    init(textField: SSAutoResizeTextField) {
        super.init(frame: CGRect.zero)
        
        self.textField = textField
        self.addSubview(popupHolder)
        popupHolder.addSubview(tableView)
        
        self.addSelfToMainWindow()
        self.isHidden = true
        self.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func btnClick(_ sender: UIButton) {
        self.isHidden = true
    }
    
    private func addSelfToMainWindow() {
        if let rootView = UIWindow.mainView {
            self.translatesAutoresizingMaskIntoConstraints = false
            self.frame = rootView.bounds
            rootView.addSubview(self)
            let viewDict = [
                "view": self
            ]
            let hconstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewDict)
            let vconstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: .init(rawValue: 0), metrics: nil, views: viewDict)
            rootView.addConstraints(hconstraints)
            rootView.addConstraints(vconstraints)
        }
    }
    
    private func getSuperView(_ view: UIView) -> UIView? {
        var temp: UIView? = view
        while (temp != nil && temp?.superview != nil) {
            temp = temp?.superview
        }
        return temp
    }
    
    private func registerNotification() {
        NotificationCenter.default.do {
            $0.addObserver(self, selector: #selector(keyboardShowed(_:)), name: UITextField.keyboardDidShowNotification, object: nil)
            $0.addObserver(self, selector: #selector(keyboardWillHidden(_:)), name: UITextField.keyboardWillHideNotification, object: nil)
        }
    }
    
    @objc private func keyboardShowed(_ noti: Notification) {
        if let info = noti.userInfo {
            if let rect = info[UITextField.keyboardFrameBeginUserInfoKey] as? CGRect {
                keyboardHeight = Float(rect.height)
            }
        }
    }
    
    @objc private func keyboardWillHidden(_ noti: Notification) {
        keyboardHeight = 0
    }
    
    func textView(_ textField: SSAutoResizeTextField, didChangeText text: String) {
        guard let _textField = self.textField else { return }
        if _textField.isAutoComplete {
            if text.count >= 1 {
                searchSuggestionOptionWithSubString(text)
                if suggestionOpts.count >= 1 {
                    tableView.reloadData()
                    calculateFrame()
                    self.isHidden = false
                    return
                }
            }
        }
        self.isHidden = true
    }
    
    private func searchSuggestionOptionWithSubString(_ subString: String) {
        suggestionOpts.removeAll()
        
        for sug in suggestionDict {
            let range = (sug as NSString).range(of: subString, options: .caseInsensitive)
            if range.location == 0 {
                suggestionOpts.append(sug)
            }
        }
    }
    
    private func calculateFrame() {
        guard let textField = textField else { return }
        
        let textFieldFrame = textField.convert(textField.bounds, to: self)
        let contentSize = tableView.contentSize
        let spaceToTop = textFieldFrame.y
        let spaceToBottom = self.bounds.height - CGFloat(keyboardHeight) - (textFieldFrame.y + textFieldFrame.height)
        var x, y, width, height: CGFloat
        if spaceToBottom < contentSize.height && spaceToTop > spaceToBottom {
            x = textFieldFrame.x
            width = textFieldFrame.width
            if spaceToTop > contentSize.height {
                y = spaceToTop - contentSize.height
                height = contentSize.height
            } else {
                y = 0
                height = spaceToTop
            }
        } else {
            x = textFieldFrame.x
            y = textFieldFrame.y + textFieldFrame.height
            width = textFieldFrame.width
            height = min(spaceToBottom, contentSize.height)
        }
        let frame = CGRect(x: x, y: y, width: width, height: height)
        popupHolder.frame = frame
        tableView.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension TextSuggestView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestionOpts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier, for: indexPath) as! RippleTableViewCell
        cell.textLabel?.font = textField?.inputTextFont ?? UIFont.systemFont(ofSize: 15)
        cell.textLabel?.adjustsFontSizeToFitWidth = false
        cell.textLabel?.text = suggestionOpts[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textField?.text = suggestionOpts[indexPath.row]
        self.isHidden = true
    }
}

class SuggestTableView: UITableView {
    var font: UIFont = UIFont.systemFont(ofSize: 15)
    
    private func setup() {
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 8
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2.5)
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    init() {
        super.init(frame: CGRect.zero, style: .plain)
    }
}
