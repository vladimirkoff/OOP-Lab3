
import UIKit

protocol ShapeBarButtonItemDelegate {
    func buttonPressed(type: ShapeType)
    func buttonLongPressed(type: ShapeType)
}

class ShapeBarButtonItem: UIBarButtonItem {
    
    var delegate: ShapeBarButtonItemDelegate?
    
    var shapeType: ShapeType? {
        didSet {
            button.setImage(UIImage(systemName: shapeType!.rawValue), for: .normal)
        }
    }
    
    private lazy var button: UIButton = {
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        btn.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        return btn
    }()

    override init() {
        super.init()
        addSubviews()
        addGestures()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        addGestures()
    }
    
    private func addSubviews() {
        customView = button
    }
    
    private func addGestures() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        button.addGestureRecognizer(longPressGesture)
    }
    
    private func animateButtonPress() {
        UIView.animate(withDuration: 0.1, animations: {
            self.button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95) 
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.button.transform = .identity
            }
        }
    }
    
    @objc func longPressed() {
        guard let shapeType = shapeType else { return }
        delegate?.buttonLongPressed(type: shapeType)
    }
    
    @objc func pressed() {
        guard let shapeType = shapeType else { return }
        animateButtonPress()
        delegate?.buttonPressed(type: shapeType)
    }

}
