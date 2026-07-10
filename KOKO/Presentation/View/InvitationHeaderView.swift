import UIKit

class InvitationHeaderView: UITableViewHeaderFooterView {

    static let reuseIdentifier = "InvitationHeaderView"

    var onToggle: (() -> Void)?

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "好友邀請"
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .kkText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let badgeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .semibold)
        l.textColor = .kkPink
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let arrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.up"))
        iv.tintColor = .kkSubText
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(count: Int, isExpanded: Bool) {
        badgeLabel.text = count > 0 ? "\(count)" : nil
        let arrowName = isExpanded ? "chevron.up" : "chevron.down"
        arrowImageView.image = UIImage(systemName: arrowName)
        UIView.animate(withDuration: 0.25) {
            self.arrowImageView.transform = isExpanded ? .identity : CGAffineTransform(rotationAngle: .pi)
        }
    }

    private func setup() {
        contentView.backgroundColor = .kkBackground

        contentView.addSubview(titleLabel)
        contentView.addSubview(badgeLabel)
        contentView.addSubview(arrowImageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            badgeLabel.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8),
            badgeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 18),
            arrowImageView.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        contentView.addGestureRecognizer(tap)
    }

    @objc private func handleTap() {
        onToggle?()
    }
}
