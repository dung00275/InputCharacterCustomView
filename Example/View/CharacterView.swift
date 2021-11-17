//
//  CharacterView.swift
//  Example
//
//  Created by Dung Vu on 17/11/2021.
//

import UIKit

final class CharacterView: UIView, InputCharacterDisplay {
    @IBOutlet var lblText: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
    }
    
    func updateState(_ state: InputCharacterState) {
        lblText?.layer.removeAllAnimations()
        switch state {
        case .focus(let cursor):
            lblText?.text = cursor
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.red.cgColor
            let t = CABasicAnimation(keyPath: "opacity")
            t.fromValue = 0
            t.toValue = 1
            t.duration = 1
            t.repeatCount = .infinity
            self.lblText?.layer.add(t, forKey: nil)
        case .empty:
            lblText?.text = ""
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.gray.cgColor
        case .update(let text):
            lblText?.text = text
            self.layer.borderWidth = 1
            self.layer.borderColor = UIColor.gray.cgColor
        }
    }
}
