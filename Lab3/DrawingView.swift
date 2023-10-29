import UIKit

class DrawingView: UIView {
    
    var isDot = false
    private var currentShapeType: ShapeType!
    
    private var currentPath: UIBezierPath?
    private var selectedShape: Shape?
    
    private var shapes: [Shape] = []
    private var selectedShapes: [Shape] = []
    
    private var initialPoint: CGPoint?
    
    private var currentLineWidth: CGFloat!
    private var currentLinePoints: [CGPoint] = []
    
    private var dashesArray: [CGFloat] {
        return [currentLineWidth * 3, currentLineWidth * 3]
    }
    
    private var lineArray: [CGFloat] = [0 , 0]
    
    //Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStyle()
        setupGestureRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizer()
    }
    
    //Helpers
    
    private func setupStyle() {
        backgroundColor = .clear
    }
    
    private func setupGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
    }
    
    private func setSelectedShape() {
        guard let selectedShape = selectedShape else { return }
        for shape in shapes {
            if shape.id == selectedShape.id {
                selectedShapes.append(shape)
            }
        }
    }
    
    //External access
    
    func setDrawingColor(lineWidth: CGFloat) {
        currentLineWidth = lineWidth
    }
    
    func setShapeType(_ shapeType: ShapeType) {
        currentShapeType = shapeType
    }
    
    func clearDrawing() {
        shapes.removeAll()
        setNeedsDisplay()
    }
    
    //Selectors
    
    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        switch currentShapeType {
        case .curve:
            drawCurveLine(gestureRecognizer)
        case .square:
            drawSquare(gestureRecognizer)
        case .line:
            drawStraightLine(gestureRecognizer)
        case .elipse:
            drawEllipse(gestureRecognizer)
        case .none:
            break
        case .some(.dot):
            break
        }
    }
    
    @objc private func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        
        if let shapeToFill = shapes.first(where: { $0.path.contains(point) }) {
            if shapeToFill.type == .curve { return }
            selectedShape = shapeToFill
            setNeedsDisplay()
        } else {
            if isDot {
                drawDot(gestureRecognizer)
            }
        }
    }
    
    //draw - UIView parent method
    
    override func draw(_ rect: CGRect) {
        setSelectedShape()
        
        for shape in self.shapes {
            
            if shape.isSelected {
                shape.type.color.setFill()
                shape.path.fill()
            }
            
            let mutableShape = shape
            shape.color.setStroke()
            shape.path.stroke()
            
            if let selectedShape = selectedShape {
                if shape.id == selectedShape.id {
                    mutableShape.isSelected = true
                    
                    shape.type.color.setFill()
                    shape.path.fill()
                }
            }
            for selectedShape in selectedShapes {
                if selectedShape.id == shape.id {
                    shape.type.color.setFill()
                    shape.path.fill()
                }
            }
        }
        
        if let path = currentPath {
            UIColor.black.setStroke()
            path.stroke()
        }
    }
}

//MARK: Draw shapes

extension DrawingView {
    
    private func drawDot(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        let dotSize: CGFloat = currentLineWidth
        
        let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x - dotSize/2, y: point.y - dotSize/2, width: dotSize, height: dotSize))
        let dot = Dot(path: dotPath, type: .dot, color: .black, id: UUID().uuidString, isSelected: false)
        dot.isSelected = true
        shapes.append(dot)
        setNeedsDisplay()
    }
    
    
    private func drawSquare(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            initialPoint = point
            
            currentPath = UIBezierPath()
            currentPath?.lineWidth = currentLineWidth
            currentPath?.lineCapStyle = .square
            currentPath?.lineJoinStyle = .miter
            currentPath?.move(to: point)
            setNeedsDisplay()
        case .changed:
            if let path = currentPath, let start = initialPoint {
                path.removeAllPoints()
                path.lineWidth = currentLineWidth
                path.lineCapStyle = .square
                path.lineJoinStyle = .miter
                
                let minX = min(start.x, point.x)
                let minY = min(start.y, point.y)
                let maxX = max(start.x, point.x)
                let maxY = max(start.y, point.y)
                
                let width = abs(point.x - start.x) * 1.01
                let height = abs(point.y - start.y) * 1.01
                
                let squareRect = CGRect(x: point.x - width / 2, y: point.y - height / 2, width: maxX - minX, height: maxY - minY)
                
                path.move(to: CGPoint(x: squareRect.minX, y: squareRect.minY))
                path.addLine(to: CGPoint(x: squareRect.maxX, y: squareRect.minY))
                path.addLine(to: CGPoint(x: squareRect.maxX, y: squareRect.maxY))
                path.addLine(to: CGPoint(x: squareRect.minX, y: squareRect.maxY))
                path.close()
                setNeedsDisplay()
                setDash(set: true, for: path)
            }
        case .ended:
            if let path = currentPath {
                shapes.append(Rectangle(path: path, type: .square, color: .black, id: UUID().uuidString, isSelected: false))
                currentPath = nil
                initialPoint = nil
                setDash(set: false, for: path)
                setNeedsDisplay()
            }
        default:
            break
        }
    }
    
    private func setDash(set: Bool, for path: UIBezierPath) {
        let dashed = set ? dashesArray : lineArray
        path.setLineDash(dashed, count: dashed.count, phase: 0)
    }
    
    private func drawStraightLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            initialPoint = point
            
            currentPath = UIBezierPath()
            currentPath?.lineWidth = currentLineWidth
            currentPath?.lineCapStyle = .round
            currentPath?.lineJoinStyle = .round
            currentPath?.move(to: point)
            setNeedsDisplay()
        case .changed:
            if let path = currentPath {
                path.removeAllPoints()
                path.lineWidth = currentLineWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                path.move(to: initialPoint ?? .zero)
                path.addLine(to: point)
                setDash(set: true, for: path)
                setNeedsDisplay()
            }
        case .ended:
            if let path = currentPath {
                shapes.append(Straight(path: path, type: .line, color: .black, id: UUID().uuidString, isSelected: false))
                setDash(set: false, for: path)
                currentPath = nil
                initialPoint = nil
                setNeedsDisplay()
            }
        default:
            break
        }
    }
    
    private func drawCurveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            currentPath = UIBezierPath()
            currentPath?.move(to: point)
            currentPath?.lineWidth = currentLineWidth != nil ? currentLineWidth : 1.0
            setNeedsDisplay()
        case .changed:
            currentPath?.addLine(to: point)
            setDash(set: true, for: currentPath!)
            setNeedsDisplay()
        case .ended:
            if let path = currentPath {
                let shape = CurveLine(path: path, type: currentShapeType, color: .black, id: UUID().uuidString, isSelected: false)
                shapes.append(shape)
                setDash(set: false, for: path)
                currentPath = nil
                setNeedsDisplay()
            }
        default:
            break
        }
    }
    
    private func drawEllipse(_ gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: self)
        
        switch gestureRecognizer.state {
        case .began:
            initialPoint = point
            
            currentPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 0, height: 0))
            currentPath?.lineWidth = currentLineWidth
            currentPath?.lineCapStyle = .round
            currentPath?.lineJoinStyle = .round
            setNeedsDisplay()
        case .changed:
            if let path = currentPath, let start = initialPoint {
                let minX = min(start.x, point.x)
                let minY = min(start.y, point.y)
                let maxX = max(start.x, point.x)
                let maxY = max(start.y, point.y)
                
                let newEllipseRect = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
                path.removeAllPoints()
                path.append(UIBezierPath(ovalIn: newEllipseRect))
                setDash(set: true, for: path)
                setNeedsDisplay()
            }
        case .ended:
            if let path = currentPath {
                shapes.append(Ellipse(path: path, type: .elipse, color: .black, id: UUID().uuidString, isSelected: false))
                currentPath = nil
                initialPoint = nil
                setDash(set: false, for: path)
                setNeedsDisplay()
            }
        default:
            break
        }
    }
    
}
