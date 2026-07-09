import UIKit

// MARK: - FriendListViewController
class FriendListViewController: UIViewController {

    // MARK: - Properties
    private let viewModel: FriendListViewModel
    private var isSearchExpanded = false
    private var isRefreshing = false
    private let scenario: FriendScenario
    
    private var contentView: FriendListView {
        return view as! FriendListView
    }

    // MARK: - Init
    init(scenario: FriendScenario) {
        self.scenario = scenario
        self.viewModel = FriendListViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func loadView() {
        view = FriendListView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        setupNavigationBar()
        setupDelegates()
        bindViewModel()
        viewModel.loadData(scenario: scenario)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Navigation Bar Setup
    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }
    
    private func setupDelegates() {
        contentView.delegate = self
        contentView.tableView.dataSource = self
        contentView.tableView.delegate = self
        contentView.searchTextField.delegate = self
        contentView.invitationCardsView.delegate = self
        contentView.searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        contentView.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    // MARK: - ViewModel Binding
    private func bindViewModel() {
        viewModel.onUpdate = { [weak self] in
            self?.updateUI()
        }
        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
        
        viewModel.onUserLoadingChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.contentView.showUserLoading()
            } else {
                self.contentView.hideUserLoading()
            }
        }
        
        viewModel.onLoadingChanged = { [weak self] isLoading in
            guard let self else { return }
            if isLoading {
                self.contentView.tableView.isHidden = true
                self.contentView.emptyFriendView.isHidden = true
                if self.isRefreshing {
                    // Pull to refresh uses its own spinner
                } else {
                    self.contentView.showLoading()
                }
            } else {
                self.contentView.hideLoading()
                if self.isRefreshing {
                    self.contentView.refreshControl.endRefreshing()
                    self.isRefreshing = false
                }
            }
        }
    }

    // MARK: - Update UI
    private func updateUI() {
        // Update profile info
        if let user = viewModel.user {
            contentView.avatarView.isHidden = false
            contentView.nameLabel.text = user.name
            if viewModel.currentScenario == .noFriends {
                contentView.kokoIdLabel.text = "設定 KOKO ID"
                contentView.pinkDot.isHidden = false
            } else {
                contentView.kokoIdLabel.text = "KOKO ID : \(user.kokoid)"
                contentView.pinkDot.isHidden = true
            }
        }

        let hasFriends = viewModel.hasFriends
        let hasInvites = viewModel.hasInvitations
        
        contentView.invitationCardsView.configure(with: viewModel.invitations, isExpanded: viewModel.isInvitationExpanded)

        // Update friends badge: count of status=2 (邀請中) friends in the main list
        let invitingCount = viewModel.friends.filter { $0.friendStatus == .inviting }.count
        if invitingCount > 0 {
            contentView.friendsBadgeLabel.text = "\(invitingCount)"
            contentView.friendsBadgeLabel.isHidden = false
        } else {
            contentView.friendsBadgeLabel.isHidden = true
        }

        // If list is loading, do not show empty view or table view prematurely
        contentView.emptyFriendView.isHidden = hasFriends || hasInvites || viewModel.isListLoading
        contentView.tableView.isHidden = (!hasFriends && !hasInvites) || viewModel.isListLoading

        if viewModel.currentScenario == .noFriends {
            contentView.searchBarContainerView.isHidden = true
            contentView.searchBarHeightConstraint?.constant = 0
        } else {
            contentView.searchBarContainerView.isHidden = false
            contentView.searchBarHeightConstraint?.constant = contentView.searchBarHeight + 12
        }

        if !contentView.tableView.isHidden {
            contentView.tableView.reloadData()
        }
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Actions
    @objc private func handleRefresh() {
        isRefreshing = true
        viewModel.refresh()
    }

    @objc private func searchTextChanged(_ textField: UITextField) {
        viewModel.searchText = textField.text ?? ""
    }

    // MARK: - Search Bar Animation (Bonus #2)
    private func expandSearchBar() {
        guard !isSearchExpanded else { return }
        isSearchExpanded = true

        contentView.cancelButtonWidthConstraint?.isActive = false
        contentView.cancelButtonWidthConstraint = contentView.cancelSearchButton.widthAnchor.constraint(equalToConstant: 44)
        contentView.cancelButtonWidthConstraint?.isActive = true

        contentView.addFriendsButtonWidthConstraint?.isActive = false
        contentView.addFriendsButtonWidthConstraint = contentView.addFriendsButton.widthAnchor.constraint(equalToConstant: 0)
        contentView.addFriendsButtonWidthConstraint?.isActive = true
        
        // Capture current height of invitationCardsView before collapsing
        let cardsHeight = contentView.invitationCardsView.frame.height
        contentView.invitationCardsHeightConstraint?.isActive = false
        contentView.invitationCardsHeightConstraint = contentView.invitationCardsView.heightAnchor.constraint(equalToConstant: 0)
        contentView.invitationCardsHeightConstraint?.isActive = true
        _ = cardsHeight // suppress warning

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.contentView.cancelSearchButton.alpha = 1
            self.contentView.addFriendsButton.alpha = 0
            
            // Fade out the inner elements instead of the whole header
            self.contentView.avatarView.alpha = 0
            self.contentView.nameLabel.alpha = 0
            self.contentView.kokoIdLabel.alpha = 0
            self.contentView.kokoIdArrow.alpha = 0
            self.contentView.pinkDot.alpha = 0

            self.contentView.invitationCardsView.alpha = 0
            self.contentView.tabContainerView.alpha = 0
            
            // Shrink header to nav bar height (54) so the nav buttons remain visible
            self.contentView.headerHeightConstraint?.constant = 54
            self.contentView.tabHeightConstraint?.constant = 0
            self.contentView.layoutIfNeeded()
        }
    }

    private func collapseSearchBar() {
        guard isSearchExpanded else { return }
        isSearchExpanded = false

        contentView.cancelButtonWidthConstraint?.isActive = false
        contentView.cancelButtonWidthConstraint = contentView.cancelSearchButton.widthAnchor.constraint(equalToConstant: 0)
        contentView.cancelButtonWidthConstraint?.isActive = true
        
        contentView.addFriendsButtonWidthConstraint?.isActive = false
        contentView.addFriendsButtonWidthConstraint = contentView.addFriendsButton.widthAnchor.constraint(equalToConstant: 36)
        contentView.addFriendsButtonWidthConstraint?.isActive = true
        
        // Remove the zero-height override so cards can expand back to natural size
        contentView.invitationCardsHeightConstraint?.isActive = false
        contentView.invitationCardsHeightConstraint = nil

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.contentView.cancelSearchButton.alpha = 0
            self.contentView.addFriendsButton.alpha = 1
            
            self.contentView.avatarView.alpha = 1
            self.contentView.nameLabel.alpha = 1
            self.contentView.kokoIdLabel.alpha = 1
            self.contentView.kokoIdArrow.alpha = 1
            self.contentView.pinkDot.alpha = 1
            
            self.contentView.invitationCardsView.alpha = 1
            self.contentView.tabContainerView.alpha = 1
            
            self.contentView.headerHeightConstraint?.constant = self.contentView.headerHeight
            self.contentView.tabHeightConstraint?.constant = 46
            self.contentView.layoutIfNeeded()
        }
    }
}

// MARK: - FriendListViewDelegate
extension FriendListViewController: FriendListViewDelegate {
    func didTapCancelSearch() {
        contentView.searchTextField.text = ""
        viewModel.searchText = ""
        contentView.searchTextField.resignFirstResponder()
    }
    
    func didTapBackground() {
        contentView.searchTextField.resignFirstResponder()
    }
}

// MARK: - InvitationCardsViewDelegate
extension FriendListViewController: InvitationCardsViewDelegate {
    func didTapInvitationCardsView() {
        viewModel.toggleInvitationExpanded()
        updateUI() // directly update the UI to toggle the card expansion
    }
}

// MARK: - UITextFieldDelegate
extension FriendListViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        expandSearchBar()
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        collapseSearchBar()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension FriendListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredFriends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendCell.reuseIdentifier, for: indexPath) as! FriendCell
        cell.configure(with: viewModel.filteredFriends[indexPath.row], index: indexPath.row)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return FriendCell.rowHeight
    }
}
