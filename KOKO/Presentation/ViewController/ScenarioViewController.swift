import UIKit


class ScenarioViewController: UIViewController {

    private let logoLabel: UILabel = {
        let l = UILabel()
        l.text = "KOKO"
        l.font = .systemFont(ofSize: 36, weight: .black)
        l.textColor = .hotPink
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "好友列表"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textColor = .lightGrey
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "請選擇要展示的情境"
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .warmGrey
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kkWhite
        navigationController?.navigationBar.isHidden = true
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    private func setupUI() {
        // Background gradient
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.hotPink.withAlphaComponent(0.08).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)

        // Header area
        let headerStack = UIStackView(arrangedSubviews: [logoLabel, titleLabel, subtitleLabel])
        headerStack.axis = .vertical
        headerStack.alignment = .center
        headerStack.spacing = 8
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerStack)

        // Scenario cards
        view.addSubview(stackView)
        for scenario in FriendScenario.allCases {
            stackView.addArrangedSubview(makeScenarioCard(scenario))
        }

        NSLayoutConstraint.activate([
            headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

            stackView.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 48),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    private func makeScenarioCard(_ scenario: FriendScenario) -> UIView {
        let card = UIControl()
        card.backgroundColor = .white
        card.layer.cornerRadius = 16
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.tag = scenario.rawValue
        card.addTarget(self, action: #selector(scenarioTapped(_:)), for: .touchUpInside)
        card.translatesAutoresizingMaskIntoConstraints = false
        card.heightAnchor.constraint(equalToConstant: 80).isActive = true


        // Title
        let titleLabel = UILabel()
        titleLabel.text = scenario.title
        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .lightGrey
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // Description
        let descLabel = UILabel()
        descLabel.text = scenario.description
        descLabel.font = .systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor = .warmGrey
        descLabel.translatesAutoresizingMaskIntoConstraints = false

        // Chevron
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .warmGrey
        chevron.translatesAutoresizingMaskIntoConstraints = false

        // Text stack
        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(textStack)
        card.addSubview(chevron)

        NSLayoutConstraint.activate([

            textStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            textStack.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            chevron.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            chevron.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14)
        ])

        // Touch animation
        card.addTarget(self, action: #selector(cardTouchDown(_:)), for: .touchDown)
        card.addTarget(self, action: #selector(cardTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])

        return card
    }

    @objc private func scenarioTapped(_ sender: UIControl) {
        guard let scenario = FriendScenario(rawValue: sender.tag) else { return }
        let vc = MainTabBarController(scenario: scenario)
        navigationController?.navigationBar.isHidden = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func cardTouchDown(_ sender: UIControl) {
        UIView.animate(withDuration: 0.12) {
            sender.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
    }

    @objc private func cardTouchUp(_ sender: UIControl) {
        UIView.animate(withDuration: 0.12) {
            sender.transform = .identity
        }
    }
}
