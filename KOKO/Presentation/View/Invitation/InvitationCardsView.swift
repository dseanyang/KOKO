import UIKit

protocol InvitationCardsViewDelegate: AnyObject {
    func didTapInvitationCardsView()
}

class InvitationCardsView: UIView {
    weak var delegate: InvitationCardsViewDelegate?
    
    private let maxExpandedHeight: CGFloat = 276
    private let fadeLayer = CAGradientLayer()
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let bottomFadeView: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    var requiredHeight: CGFloat {

        layoutIfNeeded()

        let height =
            stackView.systemLayoutSizeFitting(
                UIView.layoutFittingCompressedSize
            ).height + 46

        return min(height, maxExpandedHeight)
    }
    
    // For collapsed state, the card placed behind to simulate stacking
    private let backgroundShadowCard: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 6
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.15
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setup() {
        backgroundColor = .hotGrey
        // The view starts with no invitation data. Hide its placeholder shadow card
        // until configure(with:isExpanded:) receives at least one invitation.
        isHidden = true
        addSubview(backgroundShadowCard)

        addSubview(scrollView)
        scrollView.addSubview(stackView)

        addSubview(bottomFadeView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        
        let scrollViewBottomConstraint = scrollView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: -20
        )
        // The parent deliberately uses a zero height while there are no invitations.
        // Allow this internal spacing constraint to yield in that state without
        // affecting the normal, visible-card layout.
        scrollViewBottomConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30),
            scrollViewBottomConstraint,

            

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),

            stackView.widthAnchor.constraint(
                equalTo: scrollView.widthAnchor,
                constant: -16 * 2
            ),

            backgroundShadowCard.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 15),
            backgroundShadowCard.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 10),
            backgroundShadowCard.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -10),
            backgroundShadowCard.heightAnchor.constraint(equalToConstant: 70),
            
            bottomFadeView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomFadeView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomFadeView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            bottomFadeView.heightAnchor.constraint(equalToConstant: 40),
        ])
        fadeLayer.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor(white: 0.95, alpha: 1).cgColor
        ]

        fadeLayer.locations = [0, 1]

        bottomFadeView.layer.addSublayer(fadeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        fadeLayer.frame = bottomFadeView.bounds
    }
    
    @objc private func handleTap() {
        delegate?.didTapInvitationCardsView()
    }
    
    func configure(with invitations: [InvitationViewData], isExpanded: Bool) {

        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }

        if invitations.isEmpty {
            isHidden = true
            return
        }

        isHidden = false

        if isExpanded {

            backgroundShadowCard.isHidden = true

            for invitation in invitations {
                let card = SingleInvitationCardView()
                card.configure(with: invitation)
                stackView.addArrangedSubview(card)
            }

        } else {
            backgroundShadowCard.isHidden = false

            let card = SingleInvitationCardView()
            card.configure(with: invitations[0])
            stackView.addArrangedSubview(card)
        }

        layoutIfNeeded()

        let contentHeight = stackView.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        ).height

        let shouldScroll = isExpanded && (contentHeight + 46 > maxExpandedHeight)

        scrollView.isScrollEnabled = shouldScroll
        bottomFadeView.isHidden = !shouldScroll
    }
}
