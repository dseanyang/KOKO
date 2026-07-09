import UIKit

// MARK: - EmptyFriendView
class EmptyFriendView: UIView {

    // MARK: - UI
    private let illustrationView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "imgFriendsEmpty"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let mainLabel: UILabel = {
        let l = UILabel()
        l.text = "就從加好友開始吧：）"
        l.font = .systemFont(ofSize: 21, weight: .semibold)
        l.textColor = .kkText
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subLabel: UILabel = {
        let l = UILabel()
        l.text = "與好友們一起用 KOKO 聊起來！\n還能互相收付款、發紅包喔：）"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .kkSubText
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let addButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setTitle("加好友", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.setImage(UIImage(named: "icAddFriendWhite"), for: .normal)
        b.semanticContentAttribute = .forceRightToLeft
        b.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        
        // Gradient background simulation
        b.backgroundColor = UIColor(red: 140/255, green: 200/255, blue: 50/255, alpha: 1)
        b.layer.cornerRadius = 20
        b.layer.shadowColor = UIColor(red: 140/255, green: 200/255, blue: 50/255, alpha: 1).cgColor
        b.layer.shadowOpacity = 0.5
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        b.layer.shadowRadius = 8
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let footerLabel: UILabel = {
        let l = UILabel()
        let text = "幫助好友更快找到你？設定 KOKO ID"
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.kkSubText
        ])
        let range = (text as NSString).range(of: "設定 KOKO ID")
        attr.addAttributes([
            .foregroundColor: UIColor.kkPink,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: range)
        l.attributedText = attr
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let gradientLayer = CAGradientLayer()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = addButton.bounds
        gradientLayer.cornerRadius = 20
    }

    // MARK: - Setup
    private func setup() {
        backgroundColor = .white

        // Apply real gradient
        gradientLayer.colors = [
            UIColor(red: 86/255, green: 179/255, blue: 11/255, alpha: 1).cgColor,
            UIColor(red: 166/255, green: 204/255, blue: 66/255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        addButton.layer.insertSublayer(gradientLayer, at: 0)

        addSubview(illustrationView)
        addSubview(mainLabel)
        addSubview(subLabel)
        addSubview(addButton)
        addSubview(footerLabel)

        NSLayoutConstraint.activate([
            illustrationView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            illustrationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            illustrationView.widthAnchor.constraint(equalToConstant: 245),
            illustrationView.heightAnchor.constraint(equalToConstant: 172),

            mainLabel.topAnchor.constraint(equalTo: illustrationView.bottomAnchor, constant: 40),
            mainLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 8),
            subLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            addButton.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 25),
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 192),
            addButton.heightAnchor.constraint(equalToConstant: 40),

            footerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            footerLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
