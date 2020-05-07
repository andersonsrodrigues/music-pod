//
//  HomeViewController.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

private let reuseHomeIdentifier = "reuseHomeCell"
private let segueHomeToMusicView = "MusicView"

// MARK: - Protocol
protocol HomeDisplayLogic: class {
    // MARK: Display Data
    func displayTopArtists(viewModel: HomeModel.TopArtists.ViewModel)
    func displayNewRelease(viewModel: HomeModel.NewRelease.ViewModel)
    func displayFeaturedPlaylist(viewModel: HomeModel.FeaturePlaylists.ViewModel)
    func displayCoverImage(viewModel: HomeModel.CoverImage.ViewModel)

    // MARK: Error Display
    func displayErrorFetchTopArtists(viewModel: HomeModel.TopArtists.ViewModel)
    func displayErrorFetchNewRelease(viewModel: HomeModel.NewRelease.ViewModel)
    func displayErrorFetchFeaturedPlaylist(viewModel: HomeModel.FeaturePlaylists.ViewModel)
    
    // MARK: Home update lifecycle
    func displayStartHomeUpdates(viewModel: HomeModel.StartHomeUpdates.ViewModel)
    func displayStopHomeUpdates(viewModel: HomeModel.StopHomeUpdates.ViewModel)
    
    // MARK: CRUD operations
    func displayFetchedArtistsAndConfigureCell(viewModel: HomeModel.FetchTopArtistAndConfigureCell.ViewModel)
    func displayFetchedAlbumsAndConfigureCell(viewModel: HomeModel.FetchNewReleaseAndConfigureCell.ViewModel)
    func displayFetchedPlaylistsAndConfigureCell(viewModel: HomeModel.FetchFeaturePlaylistsAndConfigureCell.ViewModel)
}

class HomeViewController: UITableViewController, HomeDisplayLogic {
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
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
        let interactor = HomeInteractor()
        let presenter = HomePresenter()
        let router = HomeRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: - Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
        
        navigationItem.title = "Recommendations"
        
        if #available(iOS 13.0, *) {
            navigationController!.navigationBar.prefersLargeTitles = true
        }
        
        setDarkMode(tableView: tableView)
        loadingView = LoadingView(view: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchMusics()
    }
    
    // MARK: - Table View
    
    var sections = [
        ["key": HomeSectionKeys.recommendation.rawValue, "title": "Top Artists"],
        ["key": HomeSectionKeys.new.rawValue, "title": "New songs added"],
        ["key": HomeSectionKeys.featured.rawValue, "title": "Featured Playlists"]
    ]
    var storedOffsets = [Int: CGFloat]()
    
    /// Table View Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]["title"]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseHomeIdentifier, for: indexPath)
        
        return cell
    }
    
    /// Table View Delegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? HorizontalPlaylistTableViewCell else { return }
        
        let currentSection = sections[indexPath.section]["key"]
        
        tableViewCell.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)

        if currentSection == HomeSectionKeys.recommendation.rawValue || currentSection == HomeSectionKeys.new.rawValue {
            tableViewCell.setCollectionViewDataSourceDelegate(self, forSection: indexPath.section, direction: .horizontal)
        } else {
            tableViewCell.setCollectionViewDataSourceDelegate(self, forSection: indexPath.section, direction: .vertical)
        }
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let tableViewCell = cell as? HorizontalPlaylistTableViewCell else { return }

        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)

        let label = UILabel()
        label.frame = CGRect.init(x: 16, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = sections[section]["title"]
        label.font = UIFont.boldSystemFont(ofSize: 22.0)
        label.textColor = .white
        label.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        
        headerView.addSubview(label)

        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    // MARK: - Fetch Musics
    
    func fetchMusics() {
        loadingView!.showActivityView()
        interactor?.requestTopArtistisAndTracks()
        interactor?.requestNewRelease()
        interactor?.requestFeaturePlaylists()
    }
    
    func displayTopArtists(viewModel: HomeModel.TopArtists.ViewModel) {
        tableView.reloadData()
        loadingView!.hideActivityView()
    }
    
    func displayNewRelease(viewModel: HomeModel.NewRelease.ViewModel) {
        tableView.reloadData()
        loadingView!.hideActivityView()
    }
    
    func displayFeaturedPlaylist(viewModel: HomeModel.FeaturePlaylists.ViewModel) {
        tableView.reloadData()
        loadingView!.hideActivityView()
    }
    
    func displayCoverImage(viewModel: HomeModel.CoverImage.ViewModel) {
        let cell = viewModel.cell
        cell.activityViewImage.stopAnimating()
        cell.removeLoadingCover()
        cell.coverImage.image = viewModel.displayedEntry.cover
    }
    
    // MARK: Fetch Object
    
    func fetchArtistsAndConfigure(_ cell: HorizontalPlaylistCollectionViewCell, at indexPath: IndexPath) {
        let request = HomeModel.FetchTopArtistAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchTopArtistAndConfigureCell(request: request)
    }
    
    func fetchAlbumsAndConfigure(_ cell: HorizontalPlaylistCollectionViewCell, at indexPath: IndexPath) {
        let request = HomeModel.FetchNewReleaseAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchNewReleaseAndConfigureCell(request: request)
    }
    
    func fetchPlaylistsAndConfigure(_ cell: HorizontalPlaylistCollectionViewCell, at indexPath: IndexPath) {
        let request = HomeModel.FetchFeaturePlaylistsAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchFeaturePlaylistAndConfigureCell(request: request)
    }
    
    func displayFetchedArtistsAndConfigureCell(viewModel: HomeModel.FetchTopArtistAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedArtist, as: .recommendation, at: viewModel.indexPath)
    }
    
    func displayFetchedAlbumsAndConfigureCell(viewModel: HomeModel.FetchNewReleaseAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedAlbum, as: .new, at: viewModel.indexPath)
    }
    
    func displayFetchedPlaylistsAndConfigureCell(viewModel: HomeModel.FetchFeaturePlaylistsAndConfigureCell.ViewModel) {
        configureCell(viewModel.cell!, withDisplayedCell: viewModel.displayedPlaylist, as: .featured, at: viewModel.indexPath)
    }
    
    // MARK: Error Fetch Object
    
    func displayErrorFetchTopArtists(viewModel: HomeModel.TopArtists.ViewModel) {
        showAlertFailure(title: "Error Top Artists", message: viewModel.message!)
        dismiss(animated: true, completion: nil)
    }
    
    func displayErrorFetchNewRelease(viewModel: HomeModel.NewRelease.ViewModel) {
        showAlertFailure(title: "Error New Release", message: viewModel.message!)
        dismiss(animated: true, completion: nil)
    }
    
    func displayErrorFetchFeaturedPlaylist(viewModel: HomeModel.FeaturePlaylists.ViewModel) {
        showAlertFailure(title: "Error Featured Playlists", message: viewModel.message!)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Collection View
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[collectionView.tag]["key"]
        switch currentSection {
        case HomeSectionKeys.recommendation.rawValue:
            return interactor!.count(as: .recommendation)
        case HomeSectionKeys.featured.rawValue:
            return interactor!.count(as: .featured)
        case HomeSectionKeys.new.rawValue:
            return interactor!.count(as: .new)
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseHorizontalPlaylistIdentifier, for: indexPath) as! HorizontalPlaylistCollectionViewCell
        let currentSection = sections[collectionView.tag]["key"]

        if currentSection == "recommendation" {
            fetchArtistsAndConfigure(cell, at: indexPath)
        } else if currentSection == "featured" {
            fetchPlaylistsAndConfigure(cell, at: indexPath)
        } else if currentSection == "new" {
            fetchAlbumsAndConfigure(cell, at: indexPath)
        }

        return cell
    }
    
    func configureCell(_ cell: HorizontalPlaylistCollectionViewCell, withDisplayedCell displayedCell: HomeModel.DisplayedCell, as style: HomeSectionKeys, at indexPath: IndexPath) {
        cell.addLoadingCover()
        cell.nameLabel.text = displayedCell.name
        
        if let data = displayedCell.image {
            let image = UIImage(data: data)
            cell.coverImage.image = image
            cell.removeLoadingCover()
        } else if let url = displayedCell.url {
            cell.activityViewImage.startAnimating()
            
            let request = HomeModel.CoverImage.Request(url: url, type: style, indexPath: indexPath, cell: cell)
            interactor?.requestCoverImage(request: request)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentSection = sections[collectionView.tag]["key"]
        
        if currentSection == "recommendation" {
            interactor?.provideDataToMusicView(at: indexPath, as: .recommendation)
        } else if currentSection == "featured" {
            interactor?.provideDataToMusicView(at: indexPath, as: .featured)
        } else if currentSection == "new" {
            interactor?.provideDataToMusicView(at: indexPath, as: .new)
        }
        
        performSegue(withIdentifier: segueHomeToMusicView, sender: self)
    }
}

// MARK: - NSFetchedResultsController
extension HomeViewController {
    
    // MARK: Home update lifecycle
    
    func displayStartHomeUpdates(viewModel: HomeModel.StartHomeUpdates.ViewModel) {
        tableView.beginUpdates()
    }
    
    func displayStopHomeUpdates(viewModel: HomeModel.StopHomeUpdates.ViewModel) {
        tableView.endUpdates()
    }
}
