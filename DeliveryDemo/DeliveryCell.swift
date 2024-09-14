import UIKit
import SDWebImage
import SnapKit

class DeliveryCell: UITableViewCell {
    private let goodsImageView = UIImageView()
    private let descriptionLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteImageView = UIImageView()
    private let fromLabel = UILabel()
    private let toLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        contentView.addSubview(goodsImageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(favoriteImageView)
        contentView.addSubview(fromLabel)
        contentView.addSubview(toLabel)

        goodsImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(60)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.leading.equalTo(goodsImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteImageView.snp.leading).offset(-10)
            make.top.equalToSuperview().offset(10)
        }

        priceLabel.snp.makeConstraints { make in
            make.leading.equalTo(goodsImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteImageView.snp.leading).offset(-10)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(5)
        }

        fromLabel.snp.makeConstraints { make in
            make.leading.equalTo(goodsImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteImageView.snp.leading).offset(-10)
            make.top.equalTo(priceLabel.snp.bottom).offset(5)
        }

        toLabel.snp.makeConstraints { make in
            make.leading.equalTo(goodsImageView.snp.trailing).offset(10)
            make.trailing.equalTo(favoriteImageView.snp.leading).offset(-10)
            make.top.equalTo(fromLabel.snp.bottom).offset(5)
            make.bottom.equalToSuperview().offset(-10)
        }

        favoriteImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
    }

    func configure(with delivery: Delivery) {
        descriptionLabel.text = delivery.remarks ?? "No description available"
        let deliveryFee = delivery.deliveryFee ?? "$0.00"
        let surcharge = delivery.surcharge ?? "$0.00"
        priceLabel.text = "\(deliveryFee) + \(surcharge)"
        if let urlString = delivery.goodsPicture, let url = URL(string: urlString) {
            goodsImageView.sd_setImage(with: url, placeholderImage: nil)
        } else {
            goodsImageView.image = nil
        }

        let isFavorite = UserDefaults.standard.bool(forKey: delivery.id)
        let heartImageName = isFavorite ? "heart.fill" : "heart"
        favoriteImageView.image = UIImage(systemName: heartImageName)
        favoriteImageView.tintColor = isFavorite ? .red : .gray

        if let route = delivery.route {
            fromLabel.text = "From: \(route.start ?? "N/A")"
            toLabel.text = "To: \(route.end ?? "N/A")"
        } else {
            fromLabel.text = "From: N/A"
            toLabel.text = "To: N/A"
        }
    }
}
