import UIKit
import Combine

class FriendListViewController: UIViewController {

    // MARK: - Dependencies
    private let viewModel: FriendListViewModel
    private let dataSource = FriendTableDataSource()
    private let delegate = FriendTableDelegate()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Search animation state (purely UI, not business logic)
    private var isSearchExpanded = false

    private var contentView: FriendListView {
        return view as! FriendListView
    }

    // MARK: - Init (ViewModel injected externally)
    init(viewModel: FriendListViewModel) {
        self.viewModel = viewModel
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
        viewModel.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationController?.navigationBar.isHidden = true
    }

    private func setupDelegates() {
        contentView.delegate = self
        contentView.tableView.dataSource = dataSource
        contentView.tableView.delegate = delegate
        contentView.searchTextField.delegate = self
        contentView.invitationCardsView.delegate = self
        contentView.searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
        contentView.refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    // MARK: - Binding (Combine)

    private func bindViewModel() {
        viewModel.$state
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.render(state)
            }
            .store(in: &cancellables)
    }

    // MARK: - Pure render function: VC knows nothing except the ViewState

    private func render(_ state: FriendListViewState) {
        renderHeader(state)
        renderInvitation(state)
        renderSearch(state)
        renderList(state)
        renderError(state)
    }

    private func renderHeader(_ state: FriendListViewState) {
        if let profile = state.profile {
            contentView.avatarView.isHidden = false
            contentView.nameLabel.text = profile.name
            contentView.kokoIdLabel.text = profile.kokoIdText
            contentView.pinkDot.isHidden = !state.showKokoIdDot
            contentView.hideUserLoading()
        } else {
            contentView.avatarView.isHidden = true
            contentView.showUserLoading()
        }
    }

    private func renderInvitation(_ state: FriendListViewState) {
        contentView.invitationCardsView.configure(
            with: state.invitations,
            isExpanded: state.isInvitationExpanded
        )
    }

    private func renderSearch(_ state: FriendListViewState) {
        if state.showSearchBar {
            contentView.searchBarContainerView.isHidden = false
            contentView.searchBarHeightConstraint?.constant = contentView.searchBarHeight + 12
        } else {
            contentView.searchBarContainerView.isHidden = true
            contentView.searchBarHeightConstraint?.constant = 0
        }
    }

    private func renderList(_ state: FriendListViewState) {
        if state.invitingBadgeCount > 0 {
            contentView.friendsBadgeLabel.text = "\(state.invitingBadgeCount)"
            contentView.friendsBadgeLabel.isHidden = false
        } else {
            contentView.friendsBadgeLabel.isHidden = true
        }

        if state.isListLoading {
            contentView.showLoading()
            contentView.tableView.isHidden = true
            contentView.emptyFriendView.isHidden = true
            contentView.refreshControl.endRefreshing()
        } else {
            contentView.hideLoading()
            contentView.refreshControl.endRefreshing()
            contentView.emptyFriendView.isHidden = !state.showEmptyView
            contentView.tableView.isHidden = state.showEmptyView

            if !state.showEmptyView {
                dataSource.update(friends: state.displayedFriends)
                contentView.tableView.reloadData()
            }
        }
    }

    private func renderError(_ state: FriendListViewState) {
        if let errorMessage = state.error {
            showError(errorMessage)
        }
    }

    // MARK: - Actions

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "錯誤", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }

    @objc private func handleRefresh() {
        viewModel.refresh()
    }

    @objc private func searchTextChanged(_ textField: UITextField) {
        viewModel.updateSearch(textField.text ?? "")
    }

    // MARK: - Search Bar Animations (pure UI, no business logic)

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

            self.contentView.avatarView.alpha = 0
            self.contentView.nameLabel.alpha = 0
            self.contentView.kokoIdLabel.alpha = 0
            self.contentView.kokoIdArrow.alpha = 0
            self.contentView.pinkDot.alpha = 0

            self.contentView.invitationCardsView.alpha = 0
            self.contentView.tabContainerView.alpha = 0

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
        viewModel.updateSearch("")
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
