import UIKit
import SDWebImage
import SnapKit

class DeliveryDetailViewController: UIViewController {
    private var delivery: Delivery
    private let deliveries: [Delivery]
    private var currentIndex: Int
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let deliveryFeeLabel = UILabel()
    private let surchargeLabel = UILabel()
    private let fromLabel = UILabel()
    private let toLabel = UILabel()
    private let senderNameLabel = UILabel()
    private let senderPhoneLabel = UILabel()
    private let senderEmailLabel = UILabel()
    
    private let bottomControlView = UIView()
    private let previousButton = UIButton()
    private let nextButton = UIButton()
    private let favoriteButton = UIButton()

    init(delivery: Delivery, deliveries: [Delivery]) {
        self.delivery = delivery
        self.deliveries = deliveries
        self.currentIndex = deliveries.firstIndex(where: { $0.id == delivery.id }) ?? 0
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBottomControls()
        configure(with: delivery)
    }

    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(scrollView)
        view.addSubview(bottomControlView)
        scrollView.addSubview(contentView)

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(bottomControlView.snp.top)
        }

        bottomControlView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(50)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }

        [imageView, descriptionLabel, deliveryFeeLabel, surchargeLabel, fromLabel, toLabel, senderNameLabel, senderPhoneLabel, senderEmailLabel].forEach { contentView.addSubview($0) }

        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping

        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(200)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        deliveryFeeLabel.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        surchargeLabel.snp.makeConstraints { make in
            make.top.equalTo(deliveryFeeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        fromLabel.snp.makeConstraints { make in
            make.top.equalTo(surchargeLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        toLabel.snp.makeConstraints { make in
            make.top.equalTo(fromLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        senderNameLabel.snp.makeConstraints { make in
            make.top.equalTo(toLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        senderPhoneLabel.snp.makeConstraints { make in
            make.top.equalTo(senderNameLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        senderEmailLabel.snp.makeConstraints { make in
            make.top.equalTo(senderPhoneLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    private func setupBottomControls() {
        bottomControlView.backgroundColor = .white
        bottomControlView.addSubview(previousButton)
        bottomControlView.addSubview(nextButton)
        bottomControlView.addSubview(favoriteButton)

        previousButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        previousButton.addTarget(self, action: #selector(showPreviousDelivery), for: .touchUpInside)

        nextButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        nextButton.addTarget(self, action: #selector(showNextDelivery), for: .touchUpInside)

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.addTarget(self, action: #selector(toggleFavorite), for: .touchUpInside)

        previousButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        favoriteButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(44)
        }

        nextButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        updateNavigationButtons()
    }

    private func updateNavigationButtons() {
        previousButton.isEnabled = currentIndex > 0
        nextButton.isEnabled = currentIndex < deliveries.count - 1
    }

    private func configure(with delivery: Delivery) {
        self.delivery = delivery
        if let urlString = delivery.goodsPicture, let url = URL(string: urlString) {
            imageView.sd_setImage(with: url, placeholderImage: nil)
        } else {
            imageView.image = nil
        }

        descriptionLabel.attributedText = createAttributedString(title: "Description: ", content: delivery.remarks ?? "No description available")
        deliveryFeeLabel.attributedText = createAttributedString(title: "Delivery Fee: ", content: delivery.deliveryFee ?? "N/A")
        surchargeLabel.attributedText = createAttributedString(title: "Surcharge: ", content: delivery.surcharge ?? "N/A")

        if let route = delivery.route {
            fromLabel.attributedText = createAttributedString(title: "From: ", content: route.start ?? "N/A")
            toLabel.attributedText = createAttributedString(title: "To: ", content: route.end ?? "N/A")
        } else {
            fromLabel.attributedText = createAttributedString(title: "From: ", content: "N/A")
            toLabel.attributedText = createAttributedString(title: "To: ", content: "N/A")
        }

        if let sender = delivery.sender {
            senderNameLabel.attributedText = createAttributedString(title: "Sender Name: ", content: sender.name ?? "N/A")
            senderPhoneLabel.attributedText = createAttributedString(title: "Sender Phone: ", content: sender.phone ?? "N/A")
            senderEmailLabel.attributedText = createAttributedString(title: "Sender Email: ", content: sender.email ?? "N/A")
        } else {
            senderNameLabel.attributedText = createAttributedString(title: "Sender Name: ", content: "N/A")
            senderPhoneLabel.attributedText = createAttributedString(title: "Sender Phone: ", content: "N/A")
            senderEmailLabel.attributedText = createAttributedString(title: "Sender Email: ", content: "N/A")
        }

        updateFavoriteButton(with: deliveries[currentIndex])
    }

    private func createAttributedString(title: String, content: String) -> NSAttributedString {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        let contentAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSMutableAttributedString(string: title, attributes: titleAttributes)
        attributedString.append(NSAttributedString(string: content, attributes: contentAttributes))
        
        return attributedString
    }

    @objc private func toggleFavorite() {
        let isFavorite = UserDefaults.standard.bool(forKey: delivery.id)
        UserDefaults.standard.set(!isFavorite, forKey: delivery.id)
        updateFavoriteButton(with: deliveries[currentIndex])
        NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil)
    }

    private func updateFavoriteButton(with: Delivery) {
        let isFavorite = UserDefaults.standard.bool(forKey: delivery.id)
        let heartImageName = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: heartImageName), for: .normal)
        favoriteButton.tintColor = isFavorite ? .red : .systemBlue
    }

    @objc private func showPreviousDelivery() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
        configure(with: deliveries[currentIndex])
        updateNavigationButtons()
        updateFavoriteButton(with: deliveries[currentIndex])
    }

    @objc private func showNextDelivery() {
        guard currentIndex < deliveries.count - 1 else { return }
        currentIndex += 1
        configure(with: deliveries[currentIndex])
        updateNavigationButtons()
        updateFavoriteButton(with: deliveries[currentIndex])
    }
}

extension Notification.Name {
    static let favoriteStatusChanged = Notification.Name("favoriteStatusChanged")
}
