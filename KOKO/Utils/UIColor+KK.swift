import UIKit

extension UIColor {
    static let hotPink       = UIColor(red: 236/255, green: 0/255,   blue: 140/255, alpha: 1)
    static let kkWhite = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    static let lightGrey       = UIColor(red: 71/255,  green: 71/255,  blue: 71/255,  alpha: 1)
    static let hotGrey       = UIColor(red: 252/255, green: 252/255,   blue: 252/255, alpha: 1)
    static let warmGrey    = UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    static let veryLightGrey  = UIColor(red: 239/255, green: 239/255, blue: 239/255, alpha: 1)
    static let frogGreen      = UIColor(red: 86/255,  green: 179/255, blue: 11/255,  alpha: 1)
    static let appleGreen40      = UIColor(red: 120/255,  green: 196/255, blue: 27/255,  alpha: 1)
    static let b      = UIColor(red: 166/255,  green: 240/255, blue: 66/255,  alpha: 1)

    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red:   CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8)  & 0xFF) / 255,
            blue:  CGFloat( hex        & 0xFF) / 255,
            alpha: alpha
        )
    }
}
