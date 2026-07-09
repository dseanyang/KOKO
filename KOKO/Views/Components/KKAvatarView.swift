import UIKit

/// Unified avatar component
class KKAvatarView: UIView {
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "imgFriendsList")
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.clipsToBounds = true
        return iv
    }()
    
    // MARK: - Init
    init(size: CGFloat) {
        super.init(frame: .zero)
        setup(size: size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Setup
    private func setup(size: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = size / 2
        clipsToBounds = true
        
        widthAnchor.constraint(equalToConstant: size).isActive = true
        heightAnchor.constraint(equalToConstant: size).isActive = true
        
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    // MARK: - Configuration Methods
    func setImage(image: UIImage?) {
        imageView.image = image ?? UIImage(named: "imgFriendsList")
    }
    
    func setBorder(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}
