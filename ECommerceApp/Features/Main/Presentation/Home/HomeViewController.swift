//
//  HomeViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 16/06/2025.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    nonisolated enum Section {
        case main
    }
    
    private var fab: HomeFloatingActionButton!
    private var collectionView: UICollectionView!
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, Product>!
    
    let viewModel: HomeViewModel
    weak var coordinator: MainCoordinator?
    
    let bag = DisposeBag()
    
    init(viewModel: HomeViewModel) {
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
        setupFAB()
        subscribeToViewModel()
    }
    
    private func initiailizeViewAppearance() {
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(logoutButtonTapped)),
            UIBarButtonItem(image: UIImage(systemName: "list.clipboard"), style: .plain, target: self, action: #selector(ordersButtonTapped))
        ]
        
        setupCartBarButtonItem()
    }
    
    private func setupCartBarButtonItem() {
        let cartBarButtonItem = BadgeBarButtonItem(image: UIImage(systemName: "cart")!, target: self, action: #selector(cartButtonTapped))
        navigationItem.rightBarButtonItems?.append(cartBarButtonItem)
        
        viewModel.state
            .distinctUntilChanged(\.cart)
            .drive(onNext: { state in
                cartBarButtonItem.badgeValue = state.cart?.products.count ?? 0
            })
            .disposed(by: bag)
    }
    
    private func setupFAB() {
        fab = HomeFloatingActionButton(primaryActionTapped: floatingActionButtonTapped)
        fab.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(fab)
        
        NSLayoutConstraint.activate([
            fab.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
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
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        diffableDataSource = UICollectionViewDiffableDataSource<Section, Product>(collectionView: collectionView) { collectionView, indexPath, product in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ProductCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: product)
            return cell
        }
        
        var previousProducts: [Product] = []
        
        viewModel.state
            .distinctUntilChanged(\.products)
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                
                let currentProducts = state.products

                // Diffing
                let inserted = currentProducts.filter { !previousProducts.contains($0) }
                previousProducts = currentProducts

                var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
                snapshot.appendSections([.main])
                snapshot.appendItems(currentProducts, toSection: .main)
                diffableDataSource.apply(snapshot, animatingDifferences: true)

                // Scroll to the first inserted item if any
                if let firstInserted = inserted.first,
                   let index = currentProducts.firstIndex(of: firstInserted) {
                    let indexPath = IndexPath(item: index, section: 0)
                    collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
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
    
    @objc private func logoutButtonTapped() {
        viewModel.logout()
        coordinator?.navigateToLogin()
    }
    
    @objc private func cartButtonTapped() {
        coordinator?.navigateToCart()
    }
    
    @objc private func ordersButtonTapped() {
        coordinator?.navigateToOrders()
    }
    
    private func floatingActionButtonTapped() {
        coordinator?.navigateToAddProduct()
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        DefaultLogger.log(self, "Selected item: \(item)")
        viewModel.addToCart(item)
    }
}
