//
//  CartViewController.swift
//  ECommerceApp
//
//  Created by Ademola Fadumo on 22/06/2025.
//

import UIKit
import RxSwift
import RxCocoa

class CartViewController: UIViewController {
    nonisolated enum Section {
        case main
    }
    
    private var collectionView: UICollectionView!
    private var placeOrderButton: DefaultButton!
    
    private var diffableDataSource: UICollectionViewDiffableDataSource<Section, Product>!
    
    let viewModel: CartViewModel
    weak var coordinator: MainCoordinator?
    
    let bag = DisposeBag()
    
    init(viewModel: CartViewModel) {
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
        setupPlaceOrderButton()
        subscribeToViewModel()
    }
    
    private func initiailizeViewAppearance() {
        title = "Cart"
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
        collectionView.register(ProductCollectionViewCell.self, forCellWithReuseIdentifier: ProductCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
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
        
        viewModel.state
            .distinctUntilChanged(\.cart)
            .drive(onNext: { [weak self] state in
                guard let self else { return }

                var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
                snapshot.appendSections([.main])
                snapshot.appendItems(state.cart?.products ?? [], toSection: .main)
                diffableDataSource.apply(snapshot, animatingDifferences: true)
            })
            .disposed(by: bag)
    }
    
    private func setupPlaceOrderButton() {
        placeOrderButton = DefaultButton()
        placeOrderButton.button.setTitle("Place Order", for: .normal)
        placeOrderButton.button.addTarget(self, action: #selector(placeOrderButtonTapped), for: .primaryActionTriggered)
        placeOrderButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeOrderButton)
        
        NSLayoutConstraint.activate([
            placeOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            placeOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            placeOrderButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 24),
            placeOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
        ])
        
        viewModel.state
            .distinctUntilChanged(\.cart)
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                placeOrderButton.isEnabled = !(state.cart?.products.isEmpty ?? false)
            })
            .disposed(by: bag)
    }

    private func subscribeToViewModel() {
        viewModel.state
            .do(onNext: { [weak self] state in
                guard let self else { return }
                if state.viewState == .placeOrder {
                    if state.processingState == .success {
                        coordinator?.router.pop()
                    }
                }
            })
            .drive(onNext: { state in
                LoadingOverlay.hide()
                
                switch state.viewState {
                case .loading:
                    LoadingOverlay.show()
                case .placeOrder:
                    if state.processingState == .processing {
                        LoadingOverlay.show()
                    }
                    
                    if state.processingState == .success {
                        let id = state.placedOrder?.id.uuidString.prefix(8) ?? ""
                        Toast.show(type: .success, message: "Order #\(id) placed successfully")
                    }
                    
                    if state.processingState == .failure {
                        Toast.show(type: .error, message: state.failureMessage ?? "")
                    }
                case .error:
                    Toast.show(type: .error, message: state.failureMessage ?? "")
                default:
                    break
                }
            })
            .disposed(by: bag)
        
        viewModel.initialize()
    }

    @objc private func placeOrderButtonTapped() {
        Task {
            await viewModel.placeOrder()
        }
    }
}

extension CartViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = diffableDataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        DefaultLogger.log(self, "Selected item: \(item)")
    }
}
