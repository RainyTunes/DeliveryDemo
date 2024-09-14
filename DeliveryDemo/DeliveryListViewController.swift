import UIKit
import SnapKit
import MJRefresh

class DeliveryListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var deliveries: [Delivery] = []
    private var offset = 0
    private let tableView = UITableView()
    private var isLoading = false
    private let threshold: CGFloat = 100.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTitleView()
        loadCachedDeliveries()
        fetchDeliveries()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteStatusChanged), name: .favoriteStatusChanged, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DeliveryCell.self, forCellReuseIdentifier: "DeliveryCell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))

        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            guard let self else { return }
            tableView.mj_footer?.endRefreshing()
            self.offset += 1
            print("load more offset = \(offset)")
            self.fetchDeliveries()
        })
    }

    private func setupTitleView() {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        navigationItem.titleView = titleLabel
    }

    private func loadCachedDeliveries() {
        if let cachedDeliveries = DeliveryService.shared.loadCachedDeliveries() {
            self.deliveries = cachedDeliveries
            self.tableView.reloadData()
        }
    }

    @objc private func refreshData() {
        offset = 0
        fetchDeliveries()
    }

    private func fetchDeliveries() {
        guard !isLoading else { return }
        isLoading = true
        DeliveryService.shared.fetchDeliveries(offset: offset) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.tableView.mj_header?.endRefreshing()
            switch result {
            case .success(let newDeliveries):
                if self.offset == 0 {
                    self.deliveries = newDeliveries
                } else {
                    self.deliveries.append(contentsOf: newDeliveries)
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch deliveries: \(error)")
            }
        }
    }
    
    @objc private func favoriteStatusChanged() {
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deliveries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeliveryCell", for: indexPath) as! DeliveryCell
        let delivery = deliveries[indexPath.row]
        cell.configure(with: delivery)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let delivery = deliveries[indexPath.row]
        let detailVC = DeliveryDetailViewController(delivery: delivery, deliveries: deliveries)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
