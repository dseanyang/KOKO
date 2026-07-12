import UIKit

/// Owns the app-wide navigation bar appearance and the actions shown above the main tabs.
final class MainNavigationController: UINavigationController, UINavigationControllerDelegate {

    private let atmButton = makeNavigationButton(named: "icNavPinkWithdraw")
    private let transferButton = makeNavigationButton(named: "icNavPinkTransfer")
    private let scanButton = makeNavigationButton(named: "icNavPinkScan")

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        navigationBar.prefersLargeTitles = false
        configureNavigationBarAppearance()
        updateNavigationBar(for: topViewController)
    }

    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        updateNavigationBar(for: viewController, animated: animated)
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .hotGrey
        appearance.shadowColor = .clear

        navigationBar.standardAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.tintColor = .hotPink
        view.backgroundColor = .hotGrey
    }

    private func updateNavigationBar(for viewController: UIViewController?, animated: Bool = false) {
        guard let mainTabBarController = viewController as? MainTabBarController else {
            setNavigationBarHidden(true, animated: animated)
            return
        }

        mainTabBarController.navigationItem.hidesBackButton = true
        mainTabBarController.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(customView: atmButton),
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            UIBarButtonItem(customView: transferButton)
        ]
        mainTabBarController.navigationItem.leftBarButtonItems?[1].width = 20
        mainTabBarController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: scanButton)
        setNavigationBarHidden(false, animated: animated)
    }

    private static func makeNavigationButton(named imageName: String) -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        return button
    }
}
