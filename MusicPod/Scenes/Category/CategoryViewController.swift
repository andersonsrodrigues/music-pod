//
//  CategoryViewController.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

private let segueCategoryPrepare = "CategoryPlaylist"

// MARK: - Protocol
protocol CategoryDisplayLogic: class {
    // MARK: Display Data
    func displayCategoryList(viewModel: CategoryModel.List.ViewModel)
    func displayCoverImage(viewModel: CategoryModel.CoverImage.ViewModel)
    
    // MARK: Error Display
    func displayErrorFetchCategoryList(viewModel: CategoryModel.List.ViewModel)
    
    // MARK: Category row updates
    func displayInsertedRow(at: IndexPath)
    func displayDeletedRow(at: IndexPath)
    func displayUpdatedRow(at: IndexPath, withDisplayedCategory displayedCategory: CategoryModel.DisplayedCell)
    func displayMovedRow(from: IndexPath, to: IndexPath, withDisplayedCategory displayedCategory: CategoryModel.DisplayedCell)
    
    // MARK: CRUD operations
    func displayFetchedCategoryListAndConfigureCell(viewModel: CategoryModel.FetchListAndConfigureCell.ViewModel)
}

class CategoryViewController: UICollectionViewController, CategoryDisplayLogic {
    var interactor: CategoryBusinessLogic?
    var router: (NSObjectProtocol & CategoryRoutingLogic & CategoryDataPassing)?
    
    var loadingView: LoadingView?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setup()
    {
        let viewController = self
        let interactor = CategoryInteractor()
        let presenter = CategoryPresenter()
        let router = CategoryRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Category"
        
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        setDarkMode(collectionView: collectionView)

        registerCells()
        renderCollectionFlowLayout()
        configureRefreshControl()
        loadingView = LoadingView(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        requestCategories()
    }
    
    // MARK: - Category List & Cover Images
    
    func requestCategories() {
        loadingView!.showActivityView()
        
        let request = CategoryModel.List.Request()
        interactor?.requestCategoryList(request: request)
    }
    
    func requestRefreshCategories() {
        loadingView!.showActivityView()
        
        let request = CategoryModel.List.Request()
        interactor?.requestRefreshCategoryList(request: request)
    }
    
    func displayCategoryList(viewModel: CategoryModel.List.ViewModel) {
        loadingView!.hideActivityView()
        collectionView.reloadData()
    }
    
    func displayCoverImage(viewModel: CategoryModel.CoverImage.ViewModel) {
        let cell = viewModel.cell
        cell.activityViewImage.stopAnimating()
        cell.removeLoadingCover()
        cell.coverImage.image = viewModel.displayedEntry.cover
    }
    
    // MARK: Fetch Category Objects
    
    func fetchCategoryListAndConfigure(_ cell: CategoryCollectionViewCell, at indexPath: IndexPath) {
        let request = CategoryModel.FetchListAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchCategoryList(request: request)
    }
    
    func displayFetchedCategoryListAndConfigureCell(viewModel: CategoryModel.FetchListAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedCategory, at: viewModel.indexPath)
    }
    
    // MARK: Error Fetch Category Objects
    
    func displayErrorFetchCategoryList(viewModel: CategoryModel.List.ViewModel) {
        showAlertFailure(title: "Error Category", message: viewModel.message!)
    }
    
    // MARK: - Collection View Controller
    
    func registerCells() {
        let nib = UINib(nibName: "CategoryCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: reuseCategoryIdentifier)
    }
    
    func configureRefreshControl () {
       collectionView.refreshControl = UIRefreshControl()
       collectionView.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
    }
        
    @objc func handleRefreshControl() {
        requestRefreshCategories()

       // Dismiss the refresh control.
       DispatchQueue.main.async {
          self.collectionView.refreshControl?.endRefreshing()
       }
    }
    
    // MARK: UI Helper Methods
    
    func renderCollectionFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = calcDimensionCollectionCell(space)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        
        collectionView.collectionViewLayout = flowLayout
    }
    
    func calcDimensionCollectionCell(_ space: CGFloat) -> CGFloat{
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        var dimension = (width - (2 * space)) / 2.0
        
        if width > height {
            dimension = (height - (2 * space)) / 2.0
        }
        
        return dimension
    }
    
    func renderData(_ data: Data, with imageView: UIImageView) {
        let image = UIImage(data: data)
        imageView.image = image
    }
}

// MARK: - UICollectionViewDataSource

extension CategoryViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interactor!.count()
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCategoryIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            preconditionFailure("Failed to load collection view cell")
        }
        
        fetchCategoryListAndConfigure(cell, at: indexPath)
        
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactor?.provideDataStoreToRouter(at: indexPath)
        performSegue(withIdentifier: segueCategoryPrepare, sender: self)
    }
    
    func configureCell(_ cell: CategoryCollectionViewCell, withDisplayedCell displayedCell: CategoryModel.DisplayedCell, at indexPath: IndexPath) {
        cell.addLoadingCover()
        cell.nameLabel.text = displayedCell.name
        
        if let data = displayedCell.image {
            let image = UIImage(data: data)
            cell.coverImage.image = image
            cell.removeLoadingCover()
        } else if let url = displayedCell.url {
            cell.activityViewImage.startAnimating()
            
            let request = CategoryModel.CoverImage.Request(url: url, cell: cell, indexPath: indexPath)
            interactor?.requestCoverImage(request: request)
        }
    }
}


// MARK: - NSFetchedResultsController

extension CategoryViewController {
    
    // MARK: Category update lifecycle
    
    func startCategoryUpdates() {
        let request = CategoryModel.StartCategoryUpdates.Request()
        interactor?.startCategoryUpdates(request: request)
    }
    
    func stopCategoryUpdates() {
        let request = CategoryModel.StopCategoryUpdates.Request()
        interactor?.stopCategoryUpdates(request: request)
    }
    
    // MARK: Category row updates
    
    func displayInsertedRow(at indexPath: IndexPath) {
        collectionView.insertItems(at: [indexPath])
    }
    
    func displayDeletedRow(at indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
    }
    
    func displayUpdatedRow(at indexPath: IndexPath, withDisplayedCategory displayedCategory: CategoryModel.DisplayedCell) {
        let cell = collectionView.cellForItem(at: indexPath) as! CategoryCollectionViewCell
        
        configureCell(cell, withDisplayedCell: displayedCategory, at: indexPath)
    }
    
    func displayMovedRow(from: IndexPath, to: IndexPath, withDisplayedCategory displayedCategory: CategoryModel.DisplayedCell) {
        let cell = collectionView.cellForItem(at: from) as! CategoryCollectionViewCell
        
        configureCell(cell, withDisplayedCell: displayedCategory, at: from)
        collectionView.moveItem(at: from, to: to)
    }
}
