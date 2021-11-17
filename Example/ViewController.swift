//
//  ViewController.swift
//  Example
//
//  Created by Dung Vu on 17/11/2021.
//

import UIKit

protocol LoadXibProtocol {
    static func loadXib() -> Self
}

extension LoadXibProtocol where Self: UIView {
    static func loadXib() -> Self {
        let xibFile = "\(self)"
        let nib = UINib(nibName: xibFile, bundle: nil)
        guard let result = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Please check \(xibFile)")
        }
        return result
    }
}
extension UIView: LoadXibProtocol {}

class ViewController: UIViewController {
    @IBOutlet var containerView: UIView!
    var inputCharacterView: InputCharacterView<CharacterView>?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let inputView  = InputCharacterView<CharacterView>.init({
            return CharacterView.loadXib()
        }, spacing: 5, sizeItem: CGSize(width: 55, height: 55))
        inputView.isSecured = true
        containerView.addSubview(inputView)
        inputView.translatesAutoresizingMaskIntoConstraints  = false
        let top = inputView.topAnchor.constraint(equalTo: containerView.topAnchor)
        let bottom = inputView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let leading = inputView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let trailing = inputView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        [top, bottom, leading, trailing].forEach { $0.isActive = true }
        self.inputCharacterView = inputView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputCharacterView?.becomeFirstResponder()
    }
}

