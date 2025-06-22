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
        subscribeToViewModel()
    }
    
    private func initiailizeViewAppearance() {
        title = "Orders"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(250) // Adjust if you want fixed height
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(250)
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            section.interGroupSpacing = 12
            
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
        
//        viewModel.state
//            .debug("initial snapshot setup")
//            .asObservable()
//            .single { $0.viewState == .ready }
//            .subscribe(onNext: {[weak self] state in
//                guard let self = self else { return }
//
//                debugPrint("Should be called only once")
//                var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Order, ListItem>()
//                dataSourceSnapshot.appendSections(state.orders)
//                self.diffableDataSource.apply(dataSourceSnapshot, animatingDifferences: true)
//
//                debugPrint("Sections in: \(self.diffableDataSource.numberOfSections(in: collectionView))")
//            })
//            .disposed(by: bag)
        
        viewModel.state
            .distinctUntilChanged(\.orders)
            .drive(onNext: {[weak self] state in
                guard let self else { return }

                for order in state.orders {
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()

                    let headerListItem = ListItem.header(order)
                    sectionSnapshot.append([headerListItem])

                    let noteListItemArray = order.products.map { ListItem.item($0) }
                    sectionSnapshot.append(noteListItemArray, to: headerListItem)

                    // Expand this section by default
                    sectionSnapshot.expand([headerListItem])

                    // Apply section snapshot to main section
                    self.diffableDataSource.apply(sectionSnapshot, to: order, animatingDifferences: true)
                }
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
