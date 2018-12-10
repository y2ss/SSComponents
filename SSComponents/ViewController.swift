//
//  ViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView!
    private var textfield: UITextField!
    private let dataSource = [
        "Calendar",
        "SwipeCard",
        "DragBadge",
        "Transition",
        "Button",
        "EmitterAnimation",
        "Progress",
        "TextField",
        "ImagePicker",
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RippleTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RippleTableViewCell
        cell.rippleColor = UIColor.SSStyle
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.navigationController?.pushViewController(CalendarViewController(), animated: true)
            break
        case 1:
            self.navigationController?.pushViewController(SwipeCardViewController(), animated: true)
            break
        case 2:
            self.navigationController?.pushViewController(DragBadgeViewController(), animated: true)
            break
        case 3:
            self.navigationController?.present(TransitionViewController(), animated: true, completion: nil)
            break
        case 4:
            self.navigationController?.pushViewController(ButtonViewController(), animated: true)
            break
        case 5:
            self.navigationController?.pushViewController(EmitterAnimationViewController(), animated: true)
            break
        case 6:
            self.navigationController?.pushViewController(ProgressViewController(), animated: true)
            break
        case 7:
            self.navigationController?.pushViewController(TextFieldViewController(), animated: true)
            break
        case 8:
            self.navigationController?.present(SSImagePickerController(), animated: true, completion: nil)
            break
        default:
            break
        }
    }
}


extension UIColor {
    static let SSStyle: UIColor = UIColor(red: 0.20392156862745098, green: 0.596078431372549, blue: 0.8588235294117647, alpha: 1)
}

