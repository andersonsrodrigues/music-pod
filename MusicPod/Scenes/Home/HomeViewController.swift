//
//  HomeViewController.swift
//  MusicPod
//
//  Created by Anderson Soares Rodrigues on 26/03/20.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

let reuseHomeIdentifier = "reuseHomeCell"

protocol HomeDisplayLogic: class {
    func displayTopArtists(viewModel: Home.TopArtists.ViewModel)
    func displayNewRelease(viewModel: Home.NewRelease.ViewModel)
    func displayFeaturedPlaylist(viewModel: Home.FeaturePlaylists.ViewModel)
}

class HomeViewController: UITableViewController, HomeDisplayLogic {
    var interactor: HomeBusinessLogic?
    var router: (NSObjectProtocol & HomeRoutingLogic & HomeDataPassing)?
    
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
        
        setupDarkMode()
        fetchPlaylists()
    }
    
    // MARK: Setup
    
    func setupDarkMode() {
        view.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
        
        navigationController!.navigationBar.barStyle = .black
        navigationController!.navigationBar.isTranslucent = true
        navigationController!.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController!.navigationBar.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        
        tableView.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)
    }
    
    // MARK: - Table View
    
    var sections = [
        ["key": "recommendation", "title": "Top Artists"],
        ["key": "new", "title": "New songs added"],
        ["key": "featured", "title": "Featured Playlists"]
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

        if currentSection == "recommendation" || currentSection == "new" {
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
    
    // MARK: - Playlists
    
    var topArtists = [Artist]()
    var newRelease = [Album]()
    var featurePlaylists = [PlaylistSimplified]()
    
    func fetchPlaylists() {
        interactor?.requestLastPlaylists()
        interactor?.requestNewRelease()
        interactor?.requestNewRelease()
    }
    
    func displayTopArtists(viewModel: Home.TopArtists.ViewModel) {
        topArtists = viewModel.artists
        tableView.reloadData()
    }
    
    func displayNewRelease(viewModel: Home.NewRelease.ViewModel) {
        newRelease = viewModel.releases
        tableView.reloadData()
    }
    
    func displayFeaturedPlaylist(viewModel: Home.FeaturePlaylists.ViewModel) {
        featurePlaylists = viewModel.playlists
        tableView.reloadData()
    }
}

// MARK: - Collection View
extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let currentSection = sections[collectionView.tag]["key"]
        
        switch currentSection {
        case "recommendation":
            return topArtists.count
        case "featured":
            return featurePlaylists.count
        case "new":
            return newRelease.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseHorizontalPlaylistIdentifier, for: indexPath) as! HorizontalPlaylistCollectionViewCell
        let currentSection = sections[collectionView.tag]["key"]
        
        if currentSection == "recommendation" {
            cell.nameLabel.text = topArtists[indexPath.row].name
            
            if let image = topArtists[indexPath.row].images, let url = image.first?.url {
                APIService.downloadPosterImage(path: url) { data, error in
                    guard let data = data else {
                        fatalError("There's no data to present")
                        return
                    }

                    let image = UIImage(data: data)
                    cell.coverImage.image = image
                }
            }
        } else if currentSection == "featured" {
            cell.nameLabel.text = featurePlaylists[indexPath.row].name
            
            if let image = featurePlaylists[indexPath.row].images, let url = image.first?.url {
                APIService.downloadPosterImage(path: url) { data, error in
                    guard let data = data else {
                        fatalError("There's no data to present")
                        return
                    }

                    let image = UIImage(data: data)
                    cell.coverImage.image = image
                }
            }
        } else if currentSection == "new" {
            cell.nameLabel.text = newRelease[indexPath.row].name
            
            if let image = newRelease[indexPath.row].images, let url = image.first?.url {
                APIService.downloadPosterImage(path: url) { data, error in
                    guard let data = data else {
                        fatalError("There's no data to present")
                        return
                    }

                    let image = UIImage(data: data)
                    cell.coverImage.image = image
                }
            }
        }
        
        cell.backgroundColor = #colorLiteral(red: 0.145080179, green: 0.1451074183, blue: 0.1450739205, alpha: 1)

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let currentSection = sections[collectionView.tag]["key"]
        
        selectedRow = indexPath.row
        
        if currentSection == "recommendation" {
            performSegue(withIdentifier: segueFromHomeToArtist, sender: self)
        } else if currentSection == "featured" {
            performSegue(withIdentifier: segueFromHomeToPlaylist, sender: self)
        } else if currentSection == "new" {
            performSegue(withIdentifier: segueFromHomeToAlbum, sender: self)
        }
    }
}
