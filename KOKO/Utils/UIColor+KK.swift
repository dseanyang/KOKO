import UIKit

extension UIColor {
    static let kkPink       = UIColor(red: 236/255, green: 0/255,   blue: 140/255, alpha: 1)
    static let kkBackground = UIColor(red: 246/255, green: 247/255, blue: 251/255, alpha: 1)
    static let kkText       = UIColor(red: 45/255,  green: 49/255,  blue: 72/255,  alpha: 1)
    static let kkSubText    = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
    static let kkSeparator  = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
    static let kkGreen      = UIColor(red: 86/255,  green: 179/255, blue: 11/255,  alpha: 1)

    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat( hex        & 0xFF) / 255,
            alpha: alpha
        )
    }
}
