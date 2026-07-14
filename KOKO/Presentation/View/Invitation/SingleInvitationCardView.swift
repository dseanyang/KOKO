import UIKit

class SingleInvitationCardView: UIView {
    private let avatarView = KKAvatarView(size: 40)
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .lightGrey
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let messageLabel: UILabel = {
        let l = UILabel()
        l.text = "邀請你成為好友：）"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .warmGrey
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let acceptButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "btnFriendsAgree")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.backgroundColor = .white
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.hotPink.cgColor
        b.layer.cornerRadius = 15
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let declineButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(named: "btnFriendsDelet")?.withRenderingMode(.alwaysOriginal), for: .normal)
        b.backgroundColor = .white
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.warmGrey.cgColor
        b.layer.cornerRadius = 15
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 6
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        
        addSubview(avatarView)
        addSubview(nameLabel)
        addSubview(messageLabel)
        addSubview(acceptButton)
        addSubview(declineButton)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 70),
            
            avatarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            avatarView.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 15),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            declineButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15),
            declineButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            declineButton.widthAnchor.constraint(equalToConstant: 30),
            declineButton.heightAnchor.constraint(equalToConstant: 30),
            
            acceptButton.trailingAnchor.constraint(equalTo: declineButton.leadingAnchor, constant: -15),
            acceptButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            acceptButton.widthAnchor.constraint(equalToConstant: 30),
            acceptButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    func configure(with viewData: InvitationViewData) {
        nameLabel.text = viewData.name
    }
}
