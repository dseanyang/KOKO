import UIKit

protocol FriendListViewDelegate: AnyObject {
    func didTapCancelSearch()
    func didTapBackground()
}

class FriendListView: UIView {
    
    weak var delegate: FriendListViewDelegate?
    
    // MARK: - Properties
    let headerHeight: CGFloat = 166
    let searchBarHeight: CGFloat = 44
    var headerHeightConstraint: NSLayoutConstraint?
    var cancelButtonWidthConstraint: NSLayoutConstraint?
    var addFriendsButtonWidthConstraint: NSLayoutConstraint?
    var tabHeightConstraint: NSLayoutConstraint?
    var invitationCardsHeightConstraint: NSLayoutConstraint?
    var searchBarHeightConstraint: NSLayoutConstraint?

    // MARK: - UI Components
    
    let atmButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "icNavPinkWithdraw"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let transferButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "icNavPinkTransfer"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    let scanButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "icNavPinkScan"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    let profileHeaderView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let avatarView: KKAvatarView = {
        let v = KKAvatarView(size: 52)
        v.setImage(image: UIImage(named: "imgFriendsFemaleDefault"))
        v.isHidden = true
        return v
    }()

    let userSpinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .kkPink
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 18, weight: .bold)
        l.textColor = .kkText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let kokoIdLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .kkSubText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    let kokoIdArrow: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .kkSubText
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let pinkDot: UIView = {
        let v = UIView()
        v.backgroundColor = .kkPink
        v.layer.cornerRadius = 4
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let invitationCardsView: InvitationCardsView = {
        let v = InvitationCardsView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let tabContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let friendsTabButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("好友", for: .normal)
        b.setTitleColor(.kkPink, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    let chatTabButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("聊天", for: .normal)
        b.setTitleColor(.kkSubText, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15, weight: .regular)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    let tabIndicator: UIView = {
        let v = UIView()
        v.backgroundColor = .kkPink
        v.layer.cornerRadius = 2
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let tabSeparator: UIView = {
        let v = UIView()
        v.backgroundColor = .kkSeparator
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Tab badges
    let friendsBadgeLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = .kkPink
        l.textAlignment = .center
        l.layer.cornerRadius = 9
        l.clipsToBounds = true
        l.isHidden = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    let chatBadgeLabel: UILabel = {
        let l = UILabel()
        l.text = "99+"
        l.font = .systemFont(ofSize: 11, weight: .semibold)
        l.textColor = .white
        l.backgroundColor = .kkPink
        l.textAlignment = .center
        l.layer.cornerRadius = 9
        l.clipsToBounds = true
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    // MARK: - Add Friends Button
    let addFriendsButton: UIButton = {
        let b = UIButton(type: .custom)
        b.setImage(UIImage(named: "icBtnAddFriends"), for: .normal)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    let searchBarContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .kkBackground
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    let searchTextField: UITextField = {
        let tf = UITextField()
        tf.attributedPlaceholder = NSAttributedString(
            string: "  想轉一筆給誰呢？",
            attributes: [.foregroundColor: UIColor.kkSubText]
        )
        tf.textColor = .kkText
        tf.tintColor = .kkPink
        tf.font = .systemFont(ofSize: 14)
        tf.backgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
        tf.layer.cornerRadius = 10
        tf.clearButtonMode = .always
        tf.returnKeyType = .search
        let iconView = UIImageView(frame: CGRect(x: 8, y: 8, width: 18, height: 18))
        iconView.image = UIImage(systemName: "magnifyingglass")
        iconView.tintColor = .kkSubText
        iconView.contentMode = .scaleAspectFit
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        paddingView.addSubview(iconView)
        tf.leftView = paddingView
        tf.leftViewMode = .always
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    let cancelSearchButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("取消", for: .normal)
        b.setTitleColor(.kkPink, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 15)
        b.alpha = 0
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = .kkBackground
        tv.separatorStyle = .none
        tv.showsVerticalScrollIndicator = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(InvitationCell.self, forCellReuseIdentifier: InvitationCell.reuseIdentifier)
        tv.register(FriendCell.self, forCellReuseIdentifier: FriendCell.reuseIdentifier)
        tv.register(InvitationHeaderView.self, forHeaderFooterViewReuseIdentifier: InvitationHeaderView.reuseIdentifier)
        return tv
    }()

    lazy var refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.tintColor = .kkPink
        return rc
    }()

    lazy var emptyFriendView: EmptyFriendView = {
        let v = EmptyFriendView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - List Loading Spinner
    let listSpinner: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .kkPink
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white

        profileHeaderView.addSubview(atmButton)
        profileHeaderView.addSubview(transferButton)
        profileHeaderView.addSubview(scanButton)
        profileHeaderView.addSubview(avatarView)
        profileHeaderView.addSubview(nameLabel)
        profileHeaderView.addSubview(kokoIdLabel)
        profileHeaderView.addSubview(kokoIdArrow)
        profileHeaderView.addSubview(pinkDot)
        profileHeaderView.addSubview(userSpinner)

        tabContainerView.addSubview(friendsTabButton)
        tabContainerView.addSubview(chatTabButton)
        tabContainerView.addSubview(tabIndicator)
        tabContainerView.addSubview(tabSeparator)
        tabContainerView.addSubview(friendsBadgeLabel)
        tabContainerView.addSubview(chatBadgeLabel)

        cancelButtonWidthConstraint = cancelSearchButton.widthAnchor.constraint(equalToConstant: 0)
        cancelButtonWidthConstraint?.isActive = true
        addFriendsButtonWidthConstraint = addFriendsButton.widthAnchor.constraint(equalToConstant: 36)
        addFriendsButtonWidthConstraint?.isActive = true
        searchBarContainerView.addSubview(searchTextField)
        searchBarContainerView.addSubview(addFriendsButton)
        searchBarContainerView.addSubview(cancelSearchButton)

        addSubview(profileHeaderView)
        addSubview(invitationCardsView)
        addSubview(tabContainerView)
        addSubview(searchBarContainerView)
        addSubview(tableView)
        addSubview(emptyFriendView)
        addSubview(listSpinner)

        tableView.refreshControl = refreshControl

        cancelSearchButton.addTarget(self, action: #selector(cancelSearchTapped), for: .touchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)

        setupConstraints()
    }

    private func setupConstraints() {
        let safeTop = safeAreaLayoutGuide.topAnchor

        headerHeightConstraint = profileHeaderView.heightAnchor.constraint(equalToConstant: headerHeight)
        tabHeightConstraint = tabContainerView.heightAnchor.constraint(equalToConstant: 46)

        NSLayoutConstraint.activate([
            // Profile header
            profileHeaderView.topAnchor.constraint(equalTo: safeTop),
            profileHeaderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            profileHeaderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerHeightConstraint!,

            // Nav buttons (Top left and right)
            atmButton.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 16),
            atmButton.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 12),
            atmButton.widthAnchor.constraint(equalToConstant: 24),
            atmButton.heightAnchor.constraint(equalToConstant: 24),

            transferButton.leadingAnchor.constraint(equalTo: atmButton.trailingAnchor, constant: 16),
            transferButton.centerYAnchor.constraint(equalTo: atmButton.centerYAnchor),
            transferButton.widthAnchor.constraint(equalToConstant: 24),
            transferButton.heightAnchor.constraint(equalToConstant: 24),

            scanButton.trailingAnchor.constraint(equalTo: profileHeaderView.trailingAnchor, constant: -16),
            scanButton.centerYAnchor.constraint(equalTo: atmButton.centerYAnchor),
            scanButton.widthAnchor.constraint(equalToConstant: 24),
            scanButton.heightAnchor.constraint(equalToConstant: 24),

            // Avatar (Right side)
            avatarView.trailingAnchor.constraint(equalTo: profileHeaderView.trailingAnchor, constant: -20),
            avatarView.topAnchor.constraint(equalTo: profileHeaderView.topAnchor, constant: 54),
            avatarView.widthAnchor.constraint(equalToConstant: 52),
            avatarView.heightAnchor.constraint(equalToConstant: 52),

            // User Spinner
            userSpinner.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 30),
            userSpinner.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            // Profile Info (Left side)
            nameLabel.leadingAnchor.constraint(equalTo: profileHeaderView.leadingAnchor, constant: 24),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 4),

            kokoIdLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            kokoIdLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            
            kokoIdArrow.leadingAnchor.constraint(equalTo: kokoIdLabel.trailingAnchor, constant: 4),
            kokoIdArrow.centerYAnchor.constraint(equalTo: kokoIdLabel.centerYAnchor),
            kokoIdArrow.widthAnchor.constraint(equalToConstant: 8),
            kokoIdArrow.heightAnchor.constraint(equalToConstant: 12),
            
            pinkDot.leadingAnchor.constraint(equalTo: kokoIdArrow.trailingAnchor, constant: 12),
            pinkDot.centerYAnchor.constraint(equalTo: kokoIdLabel.centerYAnchor),
            pinkDot.widthAnchor.constraint(equalToConstant: 8),
            pinkDot.heightAnchor.constraint(equalToConstant: 8),

            // Invitation Cards
            invitationCardsView.topAnchor.constraint(equalTo: profileHeaderView.bottomAnchor),
            invitationCardsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            invitationCardsView.trailingAnchor.constraint(equalTo: trailingAnchor),

            // Tab container
            tabContainerView.topAnchor.constraint(equalTo: invitationCardsView.bottomAnchor),
            tabContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabHeightConstraint!,

            friendsTabButton.leadingAnchor.constraint(equalTo: tabContainerView.leadingAnchor, constant: 36),
            friendsTabButton.centerYAnchor.constraint(equalTo: tabContainerView.centerYAnchor),

            chatTabButton.leadingAnchor.constraint(equalTo: friendsTabButton.trailingAnchor, constant: 36),
            chatTabButton.centerYAnchor.constraint(equalTo: tabContainerView.centerYAnchor),

            // Friends badge: top-right of friendsTabButton
            friendsBadgeLabel.leadingAnchor.constraint(equalTo: friendsTabButton.trailingAnchor, constant: 2),
            friendsBadgeLabel.centerYAnchor.constraint(equalTo: friendsTabButton.centerYAnchor, constant: -8),
            friendsBadgeLabel.heightAnchor.constraint(equalToConstant: 18),
            friendsBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),

            // Chat badge: top-right of chatTabButton
            chatBadgeLabel.leadingAnchor.constraint(equalTo: chatTabButton.trailingAnchor, constant: 2),
            chatBadgeLabel.centerYAnchor.constraint(equalTo: chatTabButton.centerYAnchor, constant: -8),
            chatBadgeLabel.heightAnchor.constraint(equalToConstant: 18),
            chatBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 28),

            tabIndicator.topAnchor.constraint(equalTo: friendsTabButton.bottomAnchor, constant: 4),
            tabIndicator.centerXAnchor.constraint(equalTo: friendsTabButton.centerXAnchor),
            tabIndicator.widthAnchor.constraint(equalToConstant: 20),
            tabIndicator.heightAnchor.constraint(equalToConstant: 4),

            tabSeparator.leadingAnchor.constraint(equalTo: tabContainerView.leadingAnchor),
            tabSeparator.trailingAnchor.constraint(equalTo: tabContainerView.trailingAnchor),
            tabSeparator.bottomAnchor.constraint(equalTo: tabContainerView.bottomAnchor),
            tabSeparator.heightAnchor.constraint(equalToConstant: 0.5),

            // Search bar
            searchBarContainerView.topAnchor.constraint(equalTo: tabContainerView.bottomAnchor),
            searchBarContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBarContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        searchBarHeightConstraint = searchBarContainerView.heightAnchor.constraint(equalToConstant: searchBarHeight + 12)
        searchBarHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: searchBarContainerView.leadingAnchor, constant: 20),
            searchTextField.trailingAnchor.constraint(equalTo: addFriendsButton.leadingAnchor, constant: -8),
            searchTextField.centerYAnchor.constraint(equalTo: searchBarContainerView.centerYAnchor),
            searchTextField.heightAnchor.constraint(equalToConstant: searchBarHeight),

            addFriendsButton.trailingAnchor.constraint(equalTo: cancelSearchButton.leadingAnchor, constant: -8),
            addFriendsButton.centerYAnchor.constraint(equalTo: searchBarContainerView.centerYAnchor),
            addFriendsButton.heightAnchor.constraint(equalToConstant: 36),

            cancelSearchButton.trailingAnchor.constraint(equalTo: searchBarContainerView.trailingAnchor, constant: -12),
            cancelSearchButton.centerYAnchor.constraint(equalTo: searchBarContainerView.centerYAnchor),

            // Table view
            tableView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // Empty view
            emptyFriendView.topAnchor.constraint(equalTo: searchBarContainerView.bottomAnchor, constant: 30),
            emptyFriendView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emptyFriendView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emptyFriendView.bottomAnchor.constraint(equalTo: bottomAnchor),

            listSpinner.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            listSpinner.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
    }
    
    // MARK: - List Spinner Control
    func showLoading() {
        listSpinner.startAnimating()
    }

    func hideLoading() {
        listSpinner.stopAnimating()
    }
    
    // MARK: - User Spinner Control
    func showUserLoading() {
        userSpinner.startAnimating()
        nameLabel.isHidden = true
        kokoIdLabel.isHidden = true
        kokoIdArrow.isHidden = true
    }
    
    func hideUserLoading() {
        userSpinner.stopAnimating()
        nameLabel.isHidden = false
        kokoIdLabel.isHidden = false
        kokoIdArrow.isHidden = false
    }

    // MARK: - Actions
    @objc private func cancelSearchTapped() {
        delegate?.didTapCancelSearch()
    }
    
    @objc private func dismissKeyboard() {
        delegate?.didTapBackground()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension FriendListView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
    }
}
import UIKit

protocol InvitationCardsViewDelegate: AnyObject {
    func didTapInvitationCardsView()
}

class InvitationCardsView: UIView {
    weak var delegate: InvitationCardsViewDelegate?
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    // For collapsed state, the card placed behind to simulate stacking
    private let backgroundShadowCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 6
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.1
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private var emptyHeightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        addSubview(backgroundShadowCard)
        addSubview(stackView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            
            backgroundShadowCard.topAnchor.constraint(equalTo: stackView.topAnchor, constant: 15),
            backgroundShadowCard.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 10),
            backgroundShadowCard.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -10),
            backgroundShadowCard.heightAnchor.constraint(equalToConstant: 70)
        ])
        
        emptyHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
    }
    
    @objc private func handleTap() {
        delegate?.didTapInvitationCardsView()
    }
    
    func configure(with invitations: [Friend], isExpanded: Bool) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if invitations.isEmpty {
            isHidden = true
            emptyHeightConstraint.isActive = true
            return
        }
        isHidden = false
        emptyHeightConstraint.isActive = false
        
        if isExpanded {
            backgroundShadowCard.isHidden = true
            for friend in invitations {
                let card = SingleInvitationCardView()
                card.configure(with: friend)
                stackView.addArrangedSubview(card)
            }
        } else {
            // Shadow behind the single card is slightly smaller to show depth
            backgroundShadowCard.isHidden = false
            let card = SingleInvitationCardView()
            card.configure(with: invitations[0])
            stackView.addArrangedSubview(card)
        }
    }
}

// MARK: - SingleInvitationCardView
class SingleInvitationCardView: UIView {
    private let avatarView = KKAvatarView(size: 40)
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .kkText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let messageLabel: UILabel = {
        let l = UILabel()
        l.text = "邀請你成為好友：）"
        l.font = .systemFont(ofSize: 13, weight: .regular)
        l.textColor = .kkSubText
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let acceptButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "checkmark"), for: .normal)
        b.tintColor = .kkPink
        b.backgroundColor = .white
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.kkPink.cgColor
        b.layer.cornerRadius = 15
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()
    
    private let declineButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.tintColor = .kkSubText
        b.backgroundColor = .white
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor.kkSubText.cgColor
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
        layer.shadowRadius = 4
        
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
    
    func configure(with friend: Friend) {
        nameLabel.text = friend.name
    }
}
