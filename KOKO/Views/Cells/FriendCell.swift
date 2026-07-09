import UIKit

// MARK: - FriendCell
class FriendCell: UITableViewCell {

    static let reuseIdentifier = "FriendCell"
    static let rowHeight: CGFloat = 72

    // MARK: - UI
    private let avatarView = KKAvatarView(size: 48)

    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = UIColor(hex: 0xFABE00)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .kkText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let statusLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12, weight: .regular)
        l.textColor = .kkSubText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let transferButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("轉帳", for: .normal)
        b.setTitleColor(.kkPink, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.layer.borderWidth = 1.2
        b.layer.borderColor = UIColor.kkPink.cgColor
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let invitingButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("邀請中", for: .normal)
        b.setTitleColor(.kkSubText, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        b.layer.borderWidth = 1.2
        b.layer.borderColor = UIColor.kkSubText.cgColor
        b.layer.cornerRadius = 16
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let moreButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        b.tintColor = .kkSubText
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let rightStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let separatorLine: UIView = {
        let v = UIView()
        v.backgroundColor = .kkSeparator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()


    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Configure
    func configure(with friend: Friend, index: Int) {
        nameLabel.text = friend.name
        starImageView.isHidden = !friend.hasStarBadge

        switch friend.friendStatus {
        case .inviteSent: // Now shows up in header cards, but if it's here, hide buttons.
            transferButton.isHidden = true
            invitingButton.isHidden = true
            moreButton.isHidden = true
            statusLabel.text = "邀請送出"
        case .inviting: // Show Transfer AND Inviting
            transferButton.isHidden = false
            invitingButton.isHidden = false
            moreButton.isHidden = true
            statusLabel.text = nil
        case .completed: // Show Transfer AND More
            transferButton.isHidden = false
            invitingButton.isHidden = true
            moreButton.isHidden = false
            statusLabel.text = nil
        }
    }

    // MARK: - Setup
    private func setup() {
        selectionStyle = .none
        backgroundColor = .white

        contentView.addSubview(avatarView)
        contentView.addSubview(starImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(rightStackView)
        contentView.addSubview(separatorLine)
        
        rightStackView.addArrangedSubview(transferButton)
        rightStackView.addArrangedSubview(invitingButton)
        rightStackView.addArrangedSubview(moreButton)

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),

            starImageView.trailingAnchor.constraint(equalTo: avatarView.leadingAnchor, constant: -6),
            starImageView.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14),
            
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor, constant: -10),

            statusLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            rightStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            rightStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            transferButton.widthAnchor.constraint(equalToConstant: 64),
            transferButton.heightAnchor.constraint(equalToConstant: 32),
            
            invitingButton.widthAnchor.constraint(equalToConstant: 64),
            invitingButton.heightAnchor.constraint(equalToConstant: 32),
            
            moreButton.widthAnchor.constraint(equalToConstant: 24),
            moreButton.heightAnchor.constraint(equalToConstant: 24),

            separatorLine.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
