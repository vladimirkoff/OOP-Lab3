
import UIKit

class Shape {
    let path: UIBezierPath
    let type: ShapeType
    let color: UIColor
    let id: String
    var isSelected: Bool
    
    init(path: UIBezierPath, type: ShapeType, color: UIColor, id: String, isSelected: Bool) {
        self.path = path
        self.type = type
        self.color = color
        self.id = id
        self.isSelected = isSelected
    }
}

class CurveLine: Shape {}
class Straight: Shape {}
class Ellipse: Shape {}
class Rectangle: Shape {}
class Dot: Shape {}
