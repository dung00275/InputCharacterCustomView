//
//  InputCharacterCustomView.swift
//  InputCharacterCustomView
//
//  Created by Dung Vu on 17/11/2021.
//
import UIKit
import RxCocoa
import RxSwift

public enum InputCharacterState {
    case focus(cursor: String)
    case empty
    case update(text: String)
}

public enum InputCharacterViewType {
    case horizontal
    case vertical
}

public protocol InputCharacterDisplay {
    func updateState(_ state: InputCharacterState)
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard 0..<count ~= index else { return nil }
        return self[index]
    }
}

public final class InputCharacterView<V: UIView>: UIView, UITextFieldDelegate where V: InputCharacterDisplay {
    public typealias CreateView = () -> V
    public typealias UpdatedText = (String) -> ()
    private lazy var textField: UITextField = .init(frame: .zero)
    private let type: InputCharacterViewType
    public var cursor: String
    private let stackView: UIStackView
    private let spacing: CGFloat
    private let sizeItem: CGSize
    private let maxCharacter: Int
    private let replaceCharacter: String
    private lazy var disposeBag = DisposeBag()
    private var views: [V] {
        stackView.arrangedSubviews.compactMap { $0 as? V }
    }
    
    public var updatedText: UpdatedText?
    public var isSecured: Bool = false
    public var text: String? {
        textField.text
    }
    
    public init(_ view: CreateView,
                type: InputCharacterViewType = .horizontal,
                maxCharacter: Int = 6,
                replaceCharacter: String? = "●",
                cursor: String = "|",
                spacing: CGFloat,
                sizeItem: CGSize,
                updatedText: UpdatedText? = nil) {
        precondition(maxCharacter > 1, "maxCharacter must be greater than 1")
        let views = (0..<maxCharacter).map { _ in view() }
        stackView = UIStackView(arrangedSubviews: views)
        self.cursor = cursor
        self.spacing = spacing
        self.sizeItem = sizeItem
        self.type = type
        self.maxCharacter = maxCharacter
        self.replaceCharacter = replaceCharacter ?? "●"
        self.updatedText = updatedText
        super.init(frame: .zero)
        visualize()
        setupRX()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    public override var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    @discardableResult
    public override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }
    
    private func visualize() {
        textField.delegate = self
        self.addSubview(textField)
        self.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.spacing = spacing
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        let sizeContainer: CGSize
        switch type {
        case .horizontal:
            stackView.axis = .horizontal
            sizeContainer = CGSize(width: sizeItem.width * CGFloat(maxCharacter) + spacing * CGFloat(maxCharacter - 1),
                                       height: sizeItem.height)
        case .vertical:
            stackView.axis = .vertical
            sizeContainer = CGSize(width: sizeItem.width,
                                       height: sizeItem.height * CGFloat(maxCharacter) + spacing * CGFloat(maxCharacter - 1))
        }
        self.widthAnchor.constraint(equalToConstant: sizeContainer.width).isActive = true
        self.heightAnchor.constraint(equalToConstant: sizeContainer.height).isActive = true
        
        let top = stackView.topAnchor.constraint(equalTo: self.topAnchor)
        let bottom = stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        let leading = stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let trailing = stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        [top, bottom, leading, trailing].forEach { $0.isActive = true }
    }
    
    private func setupRX() {
        textField.rx.text.map { $0 ?? "" }.bind { [weak self] text in
            guard let wSelf = self else {
                return
            }
            wSelf.updatedText?(text)
            let focusing = wSelf.isFirstResponder
            let characters = text.map { String($0) }
            wSelf.views.enumerated().forEach { item in
                if item.offset == text.count  {
                    item.element.updateState(focusing ? .focus(cursor: wSelf.cursor) : .empty)
                } else {
                    if let c = characters[safe: item.offset] {
                        let next = wSelf.isSecured ? wSelf.replaceCharacter : c
                        item.element.updateState(.update(text: next))
                    } else {
                        item.element.updateState(.empty)
                    }
                }
            }
        }.disposed(by: disposeBag)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        becomeFirstResponder()
    }
    
    /// Reload update UI if you want to change character replace...
    public func reloadData() {
        textField.sendActions(for: .valueChanged)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let s = (textField.text ?? "") as NSString
        let n = s.replacingCharacters(in: range, with: string)
        return n.count <= maxCharacter
    }
}
