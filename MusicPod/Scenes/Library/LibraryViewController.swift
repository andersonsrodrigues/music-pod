//
//  LibraryViewController.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 13/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

private let reuseLibraryIdentifier = "reuseLibraryCell"
private let segueLibraryToMusicView = "MusicView"

// MARK: - Protocol
protocol LibraryDisplayLogic: class {
    // MARK: Display Data
    func displayPlaylistList(viewModel: LibraryModel.PlaylistList.ViewModel)
    func displayAlbumList(viewModel: LibraryModel.AlbumList.ViewModel)
    func displayCoverImage(viewModel: LibraryModel.CoverImage.ViewModel)
    
    // MARK: Error Display
    func displayErrorPlaylistList(viewModel: LibraryModel.PlaylistList.ViewModel)
    func displayErrorAlbumList(viewModel: LibraryModel.AlbumList.ViewModel)
    
    // MARK: Library update lifecycle
    func displayStartLibraryUpdates(viewModel: LibraryModel.StartLibraryUpdates.ViewModel)
    func displayStopLibraryUpdates(viewModel: LibraryModel.StopLibraryUpdates.ViewModel)
    func displayInsertedRow(at: IndexPath)
    func displayDeletedRow(at: IndexPath)
    func displayUpdatedRow(at: IndexPath, as type: LibrarySegmentKey, withDisplayedLibrary displayedLibrary: LibraryModel.DisplayedCell)
    func displayMovedRow(from: IndexPath, to: IndexPath, as type: LibrarySegmentKey, withDisplayedLibrary displayedLibrary: LibraryModel.DisplayedCell)
    
    // MARK: CRUD operations
    func displayFetchedPlaylistAndConfigureCell(viewModel: LibraryModel.FetchPlaylistAndConfigureCell.ViewModel)
    func displayFetchedAlbumAndConfigureCell(viewModel: LibraryModel.FetchAlbumAndConfigureCell.ViewModel)
}

class LibraryViewController: UIViewController, LibraryDisplayLogic {
    var interactor: LibraryBusinessLogic?
    var router: (NSObjectProtocol & LibraryRoutingLogic & LibraryDataPassing)?
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setup() {
        let viewController = self
        let interactor = LibraryInteractor()
        let presenter = LibraryPresenter()
        let router = LibraryRouter()
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
        
        navigationItem.title = "Music"
        
        setDarkMode(tableView: tableView)
        setupTableView()
        
        loadingView = LoadingView(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        handleSegmentControlStatus()
    }
    
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Table View Setup
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "LibraryTableViewCell", bundle: nil), forCellReuseIdentifier: reuseLibraryIdentifier)
        
        configureRefreshControl()
    }
    
    func configureRefreshControl () {
       tableView.refreshControl = UIRefreshControl()
       tableView.refreshControl?.addTarget(self, action:
                                          #selector(handleRefreshControl),
                                          for: .valueChanged)
    }
    
    // MARK: - UISegmentControl
    var segmentIndex = 0
    
    @objc func handleRefreshControl() {
        switch segmentIndex {
        case 0:
            refreshAlbumObjectsFromServer()
        case 1:
            refreshPlaylistObjectsFromServer()
        default:
            break
        }

       // Dismiss the refresh control.
       DispatchQueue.main.async {
          self.tableView.refreshControl?.endRefreshing()
       }
    }
    
    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        segmentIndex = sender.selectedSegmentIndex
        
        handleSegmentControlStatus()
    }
    
    func handleSegmentControlStatus() {
        switch segmentIndex {
        case 0:
            fetchObjectsFromPlaylistResults()
        case 1:
            fetchObjectsFromAlbumResults()
        default:
            break
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Fetch List of Musics
    
    func fetchObjectsFromPlaylistResults() {
        loadingView?.showActivityView()
        
        let request = LibraryModel.PlaylistList.Request()
        interactor?.requestPlaylistList(request: request)
    }
    
    func fetchObjectsFromAlbumResults() {
        loadingView?.showActivityView()
        
        let request = LibraryModel.AlbumList.Request()
        interactor?.requestAlbumList(request: request)
    }
    
    // MARK: Refresh Objects
    func refreshAlbumObjectsFromServer() {
        loadingView?.showActivityView()
        
        let request = LibraryModel.AlbumList.Request()
        interactor?.requestRefreshAlbumList(request: request)
    }
    
    func refreshPlaylistObjectsFromServer() {
        loadingView?.showActivityView()
        
        let request = LibraryModel.PlaylistList.Request()
        interactor?.requestRefreshPlaylistList(request: request)
    }
    
    // MARK: Fetch and Configure
    
    func fetchAlbumAndConfigure(_ cell: LibraryTableViewCell, at indexPath: IndexPath) {
        let request = LibraryModel.FetchAlbumAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchAlbumAndConfigureCell(request: request)
    }
    
    func fetchPlaylistAndConfigure(_ cell: LibraryTableViewCell, at indexPath: IndexPath) {
        let request = LibraryModel.FetchPlaylistAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchPlaylistAndConfigureCell(request: request)
    }
    
    // MARK: Display List & Cover Image
    
    func displayAlbumList(viewModel: LibraryModel.AlbumList.ViewModel) {
        tableView.reloadData()
        loadingView?.hideActivityView()
    }
    
    func displayPlaylistList(viewModel: LibraryModel.PlaylistList.ViewModel) {
        tableView.reloadData()
        loadingView?.hideActivityView()
    }
    
    func displayCoverImage(viewModel: LibraryModel.CoverImage.ViewModel) {
        let cell = viewModel.cell
        cell.activityViewImage.stopAnimating()
        cell.removeLoadingCover()
        cell.coverImage.image = viewModel.displayedEntry.cover
    }
    
    // MARK: Error Display
    
    func displayErrorAlbumList(viewModel: LibraryModel.AlbumList.ViewModel) {
        showAlertFailure(title: "Error Library Album", message: viewModel.message!)
    }
    
    func displayErrorPlaylistList(viewModel: LibraryModel.PlaylistList.ViewModel) {
        showAlertFailure(title: "Error Library Playlist", message: viewModel.message!)
    }
    
    // MARK: CRUD operations
    
    func displayFetchedAlbumAndConfigureCell(viewModel: LibraryModel.FetchAlbumAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedAlbum, as: .album, at: viewModel.indexPath)
    }
    
    func displayFetchedPlaylistAndConfigureCell(viewModel: LibraryModel.FetchPlaylistAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedPlaylist, as: .playlist, at: viewModel.indexPath)
    }
}

// MARK: - Table View Data Source & Delegate
extension LibraryViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentIndex {
        case 0:
            return interactor!.count(as: .playlist)
        case 1:
            return interactor!.count(as: .album)
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseLibraryIdentifier, for: indexPath) as! LibraryTableViewCell
        
        if segmentIndex == 0 {
            fetchPlaylistAndConfigure(cell, at: indexPath)
        } else if segmentIndex == 1 {
            fetchAlbumAndConfigure(cell, at: indexPath)
        }
        
        return cell
    }
    
    func configureCell(_ cell: LibraryTableViewCell, withDisplayedCell displayedCell: LibraryModel.DisplayedCell, as style: LibrarySegmentKey, at indexPath: IndexPath) {
        cell.nameLabel.text = displayedCell.name
        cell.subNameLabel.text = displayedCell.desc
        
        if let data = displayedCell.image {
            let image = UIImage(data: data)
            cell.coverImage.image = image
            cell.removeLoadingCover()
        } else if let url = displayedCell.url {
            cell.activityViewImage.startAnimating()
            cell.coverImage.image = UIImage(named: "cover-playlist")
            let request = LibraryModel.CoverImage.Request(url: url, type: style, cell: cell, indexPath: indexPath)
            interactor?.requestCoverImage(request: request)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if segmentIndex == 0 {
            interactor?.provideDataToMusicView(at: indexPath, as: .playlist)
        } else if segmentIndex == 1 {
            interactor?.provideDataToMusicView(at: indexPath, as: .album)
        }
        
        performSegue(withIdentifier: segueLibraryToMusicView, sender: self)
    }
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110.0
    }
}

// MARK: - NSFetchedResultsController
extension LibraryViewController {
    
    // MARK: Library update lifecycle
    
    func displayStartLibraryUpdates(viewModel: LibraryModel.StartLibraryUpdates.ViewModel) {
        tableView.beginUpdates()
    }
    
    func displayStopLibraryUpdates(viewModel: LibraryModel.StopLibraryUpdates.ViewModel) {
        tableView.endUpdates()
    }
    
    // MARK: Library row updates
    
    func displayInsertedRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func displayDeletedRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func displayUpdatedRow(at indexPath: IndexPath, as type: LibrarySegmentKey, withDisplayedLibrary displayedLibrary: LibraryModel.DisplayedCell) {
        let cell = tableView.cellForRow(at: indexPath) as! LibraryTableViewCell
        
        configureCell(cell, withDisplayedCell: displayedLibrary, as: type, at: indexPath)
    }
    
    func displayMovedRow(from: IndexPath, to: IndexPath, as type: LibrarySegmentKey, withDisplayedLibrary displayedLibrary: LibraryModel.DisplayedCell) {
        let cell = tableView.cellForRow(at: from) as! LibraryTableViewCell
        
        configureCell(cell, withDisplayedCell: displayedLibrary, as: type, at: from)
        tableView.moveRow(at: from, to: to)
    }
}
