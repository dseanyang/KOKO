import UIKit

class InvitationCell: UITableViewCell {

    static let reuseIdentifier = "InvitationCell"
    static let rowHeight: CGFloat = 90

    private let avatarContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatar1: KKAvatarView = {
        let v = KKAvatarView(size: 40)
        v.setBorder(width: 2, color: .white)
        return v
    }()
    
    private let avatar2: KKAvatarView = {
        let v = KKAvatarView(size: 40)
        v.setBorder(width: 2, color: .white)
        return v
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .kkText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let messageLabel: UILabel = {
        let l = UILabel()
        l.text = "邀請你加入好友！"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .kkSubText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let acceptButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("接受", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.backgroundColor = .kkPink
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let declineButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("拒絕", for: .normal)
        b.setTitleColor(.kkSubText, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        b.backgroundColor = .white
        b.layer.borderWidth = 1
        b.layer.borderColor = UIColor.kkSeparator.cgColor
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .kkSeparator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with friend: Friend) {
        nameLabel.text = friend.name
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .white

        avatarContainer.addSubview(avatar2)
        avatarContainer.addSubview(avatar1)

        contentView.addSubview(avatarContainer)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(acceptButton)
        contentView.addSubview(declineButton)
        contentView.addSubview(separatorLine)

        NSLayoutConstraint.activate([
            avatarContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            avatarContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 54),
            avatarContainer.heightAnchor.constraint(equalToConstant: 40),

            avatar1.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatar1.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            avatar2.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            avatar2.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: avatarContainer.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),

            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),

            acceptButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            acceptButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            acceptButton.widthAnchor.constraint(equalToConstant: 68),
            acceptButton.heightAnchor.constraint(equalToConstant: 32),

            declineButton.trailingAnchor.constraint(equalTo: acceptButton.leadingAnchor, constant: -8),
            declineButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            declineButton.widthAnchor.constraint(equalToConstant: 68),
            declineButton.heightAnchor.constraint(equalToConstant: 32),

            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }


}
