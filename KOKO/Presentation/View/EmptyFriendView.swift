import UIKit

class EmptyFriendView: UIView {

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
        l.textColor = .lightGrey
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subLabel: UILabel = {
        let l = UILabel()
        l.text = "與好友們一起用 KOKO 聊起來！\n還能互相收付款、發紅包喔：）"
        l.font = .systemFont(ofSize: 14, weight: .regular)
        l.textColor = .warmGrey
        l.textAlignment = .center
        l.numberOfLines = 0
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let addButtonIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "icAddFriendWhite"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = false
        return iv
    }()
    
    private let addButton: UIButton = {
        var config = UIButton.Configuration.plain()

        config.title = "加好友"
        config.baseForegroundColor = .white
        config.background.backgroundColor = .clear
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 24,
            bottom: 0,
            trailing: 24
        )

        let button = UIButton(configuration: config)

        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)

        button.layer.cornerRadius = 20
        button.layer.masksToBounds = false

        button.layer.shadowColor = UIColor.appleGreen40.cgColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let footerLabel: UILabel = {
        let l = UILabel()
        let text = "幫助好友更快找到你？設定 KOKO ID"
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.warmGrey
        ])
        let range = (text as NSString).range(of: "設定 KOKO ID")
        attr.addAttributes([
            .foregroundColor: UIColor.hotPink,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: range)
        l.attributedText = attr
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let gradientLayer = CAGradientLayer()

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

    private func setup() {
        backgroundColor = .white

        gradientLayer.colors = [
            UIColor.frogGreen.cgColor,
            UIColor.b.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        addButton.layer.insertSublayer(gradientLayer, at: 0)

        addSubview(illustrationView)
        addSubview(mainLabel)
        addSubview(subLabel)
        addSubview(addButton)
        addButton.addSubview(addButtonIcon)
        addSubview(footerLabel)

        let illustrationHeightConstraint = illustrationView.heightAnchor.constraint(
            equalToConstant: 172
        )
        // EmptyFriendView remains in the layout hierarchy when hidden. Let its
        // illustration compress if another view (such as expanded invitations)
        // leaves insufficient vertical space.
        illustrationHeightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            illustrationView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            illustrationView.centerXAnchor.constraint(equalTo: centerXAnchor),
            illustrationView.widthAnchor.constraint(equalToConstant: 245),
            illustrationHeightConstraint,

            mainLabel.topAnchor.constraint(equalTo: illustrationView.bottomAnchor, constant: 40),
            mainLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subLabel.topAnchor.constraint(equalTo: mainLabel.bottomAnchor, constant: 8),
            subLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            addButton.topAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 24),
            addButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 192),
            addButton.heightAnchor.constraint(equalToConstant: 40),
            
            addButtonIcon.centerYAnchor.constraint(equalTo: addButton.centerYAnchor),
            addButtonIcon.trailingAnchor.constraint(equalTo: addButton.trailingAnchor, constant: -8),
            addButtonIcon.widthAnchor.constraint(equalToConstant: 24),
            addButtonIcon.heightAnchor.constraint(equalToConstant: 24),

            footerLabel.topAnchor.constraint(equalTo: addButton.bottomAnchor, constant: 37),
            footerLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            footerLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -24)
        ])
    }
}
