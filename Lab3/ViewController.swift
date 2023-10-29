
import UIKit

class ViewController: UIViewController {
    
    private var currentLineWidth: CGFloat! = 1.0
        
    //MARK: UI Properties
    
    private let shapeTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
        
    private lazy var toolBar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        let flexibleSpace = ShapeBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = ShapeBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 20
        
        var items = [UIBarButtonItem]()
        for a in 0..<5 {
            let squareButton = ShapeBarButtonItem()
            squareButton.delegate = self
            squareButton.shapeType = ShapeType.allCases[a]
            
            items.append(squareButton)
            items.append(fixedSpace)
        }
        items.removeLast()

        toolbar.setItems([flexibleSpace] + items + [flexibleSpace], animated: false)
        return toolbar
    }()
    
    private lazy var widthSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumTrackTintColor = UIColor.blue
        slider.maximumTrackTintColor = UIColor.lightGray
        slider.minimumValue = 1.0
        slider.maximumValue = 20.0
        slider.value = 0.0
        return slider
    }()
    
    private let setOpacityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Товщина"
        label.textColor = .black
        return label
    }()
    
    private lazy var clearButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Очистити", for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .red
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private lazy var drawingView: DrawingView = {
        let view = DrawingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    // Stacks
    
    private lazy var labelsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [setOpacityLabel, clearButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    //MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingView.setShapeType(.curve)
        drawingView.setDrawingColor(lineWidth: currentLineWidth)
        
        arrangeSubviews()
        setupViewConstraints()
        addTargets()
    }
    
    //MARK: Helpers
    
    private func addTargets() {
        clearButton.addTarget(self, action: #selector(clearButtonTapepd), for: .touchUpInside)
        widthSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
    }
    
    private func arrangeSubviews() {
        view.addSubview(toolBar)
        view.addSubview(drawingView)
        view.addSubview(labelsStack)
        view.addSubview(widthSlider)
        view.addSubview(shapeTypeLabel)
    }
    
    private func setupViewConstraints() {
        
        NSLayoutConstraint.activate([
            toolBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            drawingView.topAnchor.constraint(equalTo: labelsStack.bottomAnchor, constant: 12),
            drawingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            drawingView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -45),
            drawingView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            labelsStack.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 12),
        ])
        
        NSLayoutConstraint.activate([
            widthSlider.widthAnchor.constraint(equalToConstant: 150),
            widthSlider.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 12),
            widthSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            clearButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        NSLayoutConstraint.activate([
            shapeTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shapeTypeLabel.topAnchor.constraint(equalTo: drawingView.bottomAnchor, constant: 12)
        ])
        
    }

}

//MARK: Selectors

extension ViewController {
    
    @objc func squareButtonTapped(sender: ShapeBarButtonItem) {
        guard let shapeType = sender.shapeType else { return }
        shapeTypeLabel.text = shapeType.name
        drawingView.isDot = shapeType == .dot ? true : false
        drawingView.setShapeType(shapeType)
   }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        currentLineWidth = CGFloat(sender.value)
        drawingView.setDrawingColor(lineWidth: currentLineWidth)
     }
    
    @objc func clearButtonTapepd() {
        drawingView.clearDrawing()
    }
    
}

extension ViewController: ShapeBarButtonItemDelegate {
    
    func buttonPressed(type: ShapeType) {
        shapeTypeLabel.text = type.name
        drawingView.isDot = type == .dot ? true : false
        drawingView.setShapeType(type)
    }
    
    func buttonLongPressed(type: ShapeType) {
        let alert = UIAlertController(title: "Обрана фігура", message: type.name, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ок", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
}
