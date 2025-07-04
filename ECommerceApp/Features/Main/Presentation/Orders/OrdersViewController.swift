//
//  OrdersViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 20/06/2025.
//

import UIKit
import RxSwift
import RxCocoa

class OrdersViewController: UIViewController {
    nonisolated enum ListItem: Hashable {
        case header(Order)
        case item(Product)
    }
    
    private var collectionView: UICollectionView!
    private var diffableDataSource: UICollectionViewDiffableDataSource<Order, ListItem>!
    private var emptyMessageView: EmptyMessageView!
    
    let viewModel: OrdersViewModel
    weak var coordinator: MainCoordinator?
    
    let bag = DisposeBag()
    
    init(viewModel: OrdersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initiailizeViewAppearance()
        setupCollectionView()
        setupEmptyMessageView()
        subscribeToViewModel()
    }
    
    private func initiailizeViewAppearance() {
        title = "Orders"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .none
            configuration.showsSeparators = false
            if #available(iOS 15.0, *) {
                configuration.headerTopPadding = 10
            }
            configuration.leadingSwipeActionsConfigurationProvider = { indexPath in
                let cancelOrderAction = UIContextualAction(
                    style: .destructive,
                    title: "Cancel",
                    handler: { [weak self] _, _, handler in
                        guard let self else { return }
                        let order = viewModel.currentState.orders[indexPath.section]
                        
                        Task {
                            await viewModel.cancelOrder(order, completion:                         handler)
                        }
                    })
                return UISwipeActionsConfiguration(
                    actions: [
                        cancelOrderAction
                    ])
            }
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
            section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
            return section
        }
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.register(OrdersCollectionViewCell.self, forCellWithReuseIdentifier: OrdersCollectionViewCell.reuseIdentifier)
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        diffableDataSource = UICollectionViewDiffableDataSource<Order, ListItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .header(let order):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OrdersCollectionViewCell.reuseIdentifier, for: indexPath) as? OrdersCollectionViewCell else {
                    return UICollectionViewCell()
                }
                let disclosure = UICellAccessory.outlineDisclosure(options: .init(style: .header))
                cell.accessories = [disclosure]
                cell.configure(with: order)
                return cell
            case .item(let product):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier, for: indexPath) as? ProductCollectionViewCell else {
                    return UICollectionViewCell()
                }
                cell.configure(with: product)
                return cell
            }
        }
        
        viewModel.state
            .distinctUntilChanged(\.orders)
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                
                let orders = state.orders
                
                // Step 1: Register all sections (orders)
                var snapshot = NSDiffableDataSourceSnapshot<Order, ListItem>()
                snapshot.appendSections(orders)
                self.diffableDataSource.apply(snapshot, animatingDifferences: true)
                
                // Step 2: Apply section snapshots for each order
                for order in orders {
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
                    
                    let orderHeaderListItem = ListItem.header(order)
                    sectionSnapshot.append([orderHeaderListItem])
                    
                    let productsListItem = order.products.map { ListItem.item($0) }
                    sectionSnapshot.append(productsListItem, to: orderHeaderListItem)
                    
                    // Optionally expand the section by default
                    // sectionSnapshot.expand([orderHeaderListItem])
                    
                    self.diffableDataSource.apply(sectionSnapshot, to: order, animatingDifferences: true)
                }
            })
            .disposed(by: bag)
    }
    
    private func setupEmptyMessageView() {
        emptyMessageView = EmptyMessageView(title: "No Orders Yet", subtitle: "Place an order and it appears here")
        emptyMessageView.isHidden = true
        emptyMessageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyMessageView)
        
        NSLayoutConstraint.activate([
            emptyMessageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyMessageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyMessageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        viewModel.state
            .distinctUntilChanged(\.orders)
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                emptyMessageView.isHidden = !state.orders.isEmpty
            })
            .disposed(by: bag)
    }
    
    private func subscribeToViewModel() {
        viewModel.state
            .drive(onNext: { state in
                LoadingOverlay.hide()
                
                switch state.viewState {
                case .loading:
                    LoadingOverlay.show()
                case .error:
                    break
                case .ready:
                    break
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        viewModel.initialize()
    }
}

extension OrdersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        DefaultLogger.log(self, "Selected item: \(item)")
    }
}
