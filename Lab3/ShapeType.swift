
import UIKit

enum ShapeType: String, CaseIterable {
    case dot = "dot.square"
    case curve = "alternatingcurrent"
    case square = "square"
    case line = "line.diagonal"
    case elipse = "oval"
    
    var name: String {
        switch self {
        case .curve:
            return "Крива"
        case .square:
            return "Квадрат"
        case .line:
            return "Пряма"
        case .elipse:
            return "Еліпс"
        case .dot:
            return "Крапка"
        }
    }
    
    var color: UIColor {
        switch self {
        case .curve:
            return .black
        case .square:
            return .gray
        case .line:
            return .black
        case .elipse:
            return .systemOrange
        case .dot:
            return .black
        }
    }
}
