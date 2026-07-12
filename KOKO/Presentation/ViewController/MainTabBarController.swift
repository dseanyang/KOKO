import UIKit

class MainTabBarController: UITabBarController {
    
    private let koButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "icTabbarHome")
        config.background.backgroundColor = .clear

        let b = UIButton(configuration: config)

        b.configurationUpdateHandler = { button in
            guard var config = button.configuration else { return }

            config.image = UIImage(named: "icTabbarHome")
            button.configuration = config
        }

        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private var initialScenario: FriendScenario

    init(scenario: FriendScenario) {
        self.initialScenario = scenario
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCenterButton()
    }

    private func setupTabBar() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = .hotPink
        tabBar.unselectedItemTintColor = .warmGrey
        
        // Remove default top line
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        // Add custom shadow
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.05
        tabBar.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBar.layer.shadowRadius = 4
        
        // VCs
        let moneyVC = UIViewController()
        moneyVC.view.backgroundColor = .white
        moneyVC.tabBarItem = UITabBarItem(
            title: "錢錢",
            image: UIImage(named: "icTabbarProducts"),
            tag: 0)
        
        // Assemble the full dependency chain here (Composition Root)
        let friendRepo = FriendRepository()
        let userRepo = UserRepository()
        let getFriendsUseCase = GetFriendListUseCase(friendRepository: friendRepo)
        let getUserUseCase = GetUserUseCase(userRepository: userRepo)
        let friendsVM = FriendListViewModel(
            getFriendListUseCase: getFriendsUseCase,
            getUserUseCase: getUserUseCase,
            scenario: initialScenario
        )
        let friendsVC = FriendListViewController(viewModel: friendsVM)
        let friendsItem = UITabBarItem(
            title: "朋友",
            image: UIImage(named: "icTabbarFriends"),tag: 1)
        friendsVC.tabBarItem = friendsItem
        
        let koVC = UIViewController()
        koVC.tabBarItem = UITabBarItem(title: "", image: nil, tag: 2)
        koVC.tabBarItem.isEnabled = false // Let button handle it
        
        let accountVC = UIViewController()
        accountVC.view.backgroundColor = .white
        accountVC.tabBarItem = UITabBarItem(
            title: "記帳",
            image: UIImage(named: "icTabbarManage"),
            tag: 3)
        
        let settingsVC = UIViewController()
        settingsVC.view.backgroundColor = .white
        settingsVC.tabBarItem = UITabBarItem(
            title: "設定",
            image: UIImage(named: "icTabbarSetting"),
            tag: 4)
        
        viewControllers = [moneyVC, friendsVC, koVC, accountVC, settingsVC]
        selectedIndex = 1 // Friends tab
    }
    
    private func setupCenterButton() {
        view.addSubview(koButton)
        let buttonSize: CGFloat = 68
        koButton.layer.cornerRadius = buttonSize / 2
        
        NSLayoutConstraint.activate([
            koButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            koButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor, constant: 20),
            koButton.widthAnchor.constraint(equalToConstant: buttonSize),
            koButton.heightAnchor.constraint(equalToConstant: buttonSize)
        ])
        
        // Ensure button goes above the tab bar
        view.bringSubviewToFront(koButton)
    }
    
}
