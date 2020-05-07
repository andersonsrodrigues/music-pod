//
//  CategoryPlaylistViewController.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

private let segueMusicViewIdentifier = "MusicView"

// MARK: - Protocols
protocol CategoryPlaylistDisplayLogic: class {
    // MARK: Display Data
    func displayCategoryPlaylistList(viewModel: CategoryPlaylistModel.List.ViewModel)
    func displayCoverImage(viewModel: CategoryPlaylistModel.CoverImage.ViewModel)
    
    // MARK: Error Display
    func displayErrorFetchCategoryPlaylistList(viewModel: CategoryPlaylistModel.List.ViewModel)
    
    // MARK: Category Playlist row updates
    func displayInsertedRow(at: IndexPath)
    func displayDeletedRow(at: IndexPath)
    func displayUpdatedRow(at: IndexPath, withDisplayedPlaylist displayedPlaylist: CategoryPlaylistModel.DisplayedCell)
    func displayMovedRow(from: IndexPath, to: IndexPath, withDisplayedPlaylist displayedPlaylist: CategoryPlaylistModel.DisplayedCell)
    
    // MARK: CRUD operations
    func displayFetchedCategoryPlaylistListAndConfigureCell(viewModel: CategoryPlaylistModel.FetchListAndConfigureCell.ViewModel)
}

class CategoryPlaylistViewController: UIViewController, CategoryPlaylistDisplayLogic {
    var interactor: CategoryPlaylistBusinessLogic?
    var router: (NSObjectProtocol & CategoryPlaylistRoutingLogic & CategoryPlaylistDataPassing)?
    
    var loadingView: LoadingView?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = CategoryPlaylistInteractor()
        let presenter = CategoryPlaylistPresenter()
        let router = CategoryPlaylistRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = interactor?.getCategoryName()
        
        setDarkMode(collectionView: collectionView)

        initCollectionView()
        renderCollectionFlowLayout()
        
        loadingView = LoadingView(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        requestCategoryPlaylists()
    }
    
    // MARK: - Collection View
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Configuration
    
    func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        registerCells()
    }
    
    func registerCells() {
        let nib = UINib(nibName: "PlaylistCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: reuseCategoryIdentifier)
    }
    
    func configureRefreshControl () {
       collectionView.refreshControl = UIRefreshControl()
       collectionView.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
    }
        
    @objc func handleRefreshControl() {
        requestRefreshCategoryPlaylists()

       // Dismiss the refresh control.
       DispatchQueue.main.async {
          self.collectionView.refreshControl?.endRefreshing()
       }
    }
    
    // MARK: Flow Layout
    
    func renderCollectionFlowLayout() {
        let space:CGFloat = 3.0
        let dimension = calcDimensionCollectionCell(space)
        let flowLayout = UICollectionViewFlowLayout()
        
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
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
    
    // MARK: - Category List & Cover Images
    
    func requestCategoryPlaylists() {
        loadingView?.showActivityView()
        
        let request = CategoryPlaylistModel.List.Request()
        interactor?.requestCategoryPlaylistList(request: request)
    }
    
    func requestRefreshCategoryPlaylists() {
        loadingView?.showActivityView()
        
        let request = CategoryPlaylistModel.List.Request()
        interactor?.requestRefreshCategoryPlaylistList(request: request)
    }
    
    func displayCategoryPlaylistList(viewModel: CategoryPlaylistModel.List.ViewModel) {
        loadingView?.hideActivityView()
        collectionView.reloadData()
    }
    
    func displayCoverImage(viewModel: CategoryPlaylistModel.CoverImage.ViewModel) {
        let cell = viewModel.cell
        cell.activityViewImage.stopAnimating()
        cell.removeLoadingCover()
        cell.coverImage.image = viewModel.displayedEntry.cover
    }
    
    // MARK: CRUD operations
    
    func fetchCategoryPlaylistAndConfigure(_ cell: PlaylistCollectionViewCell, at indexPath: IndexPath) {
        let request = CategoryPlaylistModel.FetchListAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchCategoryPlaylistList(request: request)
    }
    
    func displayFetchedCategoryPlaylistListAndConfigureCell(viewModel: CategoryPlaylistModel.FetchListAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedPlaylist, at: viewModel.indexPath)
    }
    
    // MARK: Error Fetch Category Playlist Objects
    
    func displayErrorFetchCategoryPlaylistList(viewModel: CategoryPlaylistModel.List.ViewModel) {
        showAlertFailure(title: "Error Playlist", message: viewModel.message!)
    }
}

// MARK: - Collection View DataSource & Collection View Delegate

extension CategoryPlaylistViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return interactor!.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseCategoryIdentifier, for: indexPath) as? PlaylistCollectionViewCell else {
            preconditionFailure("Failed to load collection view cell")
        }
        
        fetchCategoryPlaylistAndConfigure(cell, at: indexPath)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactor?.provideDataToMusicViewSegue(at: indexPath)
        performSegue(withIdentifier: segueMusicViewIdentifier, sender: nil)
    }
    
    func configureCell(_ cell: PlaylistCollectionViewCell, withDisplayedCell displayedCell: CategoryPlaylistModel.DisplayedCell, at indexPath: IndexPath) {
        cell.addLoadingCover()
        if let data = displayedCell.image {
            let image = UIImage(data: data)
            cell.coverImage.image = image
            cell.removeLoadingCover()
        } else if let url = displayedCell.url {
            cell.activityViewImage.startAnimating()
            
            let request = CategoryPlaylistModel.CoverImage.Request(url: url, indexPath: indexPath, cell: cell)
            interactor?.requestCoverImage(request: request)
        }
    }
}

// MARK: - NSFetchedResultsController

extension CategoryPlaylistViewController {
    
    // MARK: Category update lifecycle
    
    func startCategoryUpdates() {
        let request = CategoryPlaylistModel.StartCategoryPlaylistUpdates.Request()
        interactor?.startCategoryPlaylistUpdates(request: request)
    }
    
    func stopCategoryUpdates() {
        let request = CategoryPlaylistModel.StopCategoryPlaylistUpdates.Request()
        interactor?.stopCategoryPlaylistUpdates(request: request)
    }
    
    // MARK: Category row updates
    
    func displayInsertedRow(at indexPath: IndexPath) {
        collectionView.insertItems(at: [indexPath])
    }
    
    func displayDeletedRow(at indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
    }
    
    func displayUpdatedRow(at: IndexPath, withDisplayedPlaylist displayedPlaylist: CategoryPlaylistModel.DisplayedCell) {
        let cell = collectionView.cellForItem(at: at) as! PlaylistCollectionViewCell
        
        configureCell(cell, withDisplayedCell: displayedPlaylist, at: at)
    }
    
    func displayMovedRow(from: IndexPath, to: IndexPath, withDisplayedPlaylist displayedPlaylist: CategoryPlaylistModel.DisplayedCell) {
        let cell = collectionView.cellForItem(at: from) as! PlaylistCollectionViewCell
        
        configureCell(cell, withDisplayedCell: displayedPlaylist, at: from)
        collectionView.moveItem(at: from, to: to)
    }
}
