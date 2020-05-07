//
//  MusicTrackViewController.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

private let reuseMusicDescIdentifierCell = "reuseMusicDescCell"
private let reuseMusicTrackIdentifierCell = "reuseMusicTrackCell"

// MARK: - Protocol
protocol MusicTrackDisplayLogic: class {
    // MARK: Display Methods
	func displayTrackList(viewModel: MusicTrackModel.List.ViewModel)
    func displayPlaylist(viewModel: MusicTrackModel.PlaylistData.ViewModel)
    func displayAlbum(viewModel: MusicTrackModel.AlbumData.ViewModel)
    func displayArtist(viewModel: MusicTrackModel.ArtistData.ViewModel)
    func displayCoverImage(viewModel: MusicTrackModel.CoverImage.ViewModel)
    func displayMusicDownloaded(viewModel: MusicTrackModel.FetchSound.ViewModel)
    func displayMusicPlaying(viewModel: MusicTrackModel.FetchSound.ViewModel)
    func displayMusicStopping(viewModel: MusicTrackModel.FetchSound.ViewModel)
    
    // MARK: Error Display Methods
    func displayErrorTrackList(viewModel: MusicTrackModel.List.ViewModel)
    func displayErrorPlaylist(viewModel: MusicTrackModel.PlaylistData.ViewModel)
    func displayErrorAlbum(viewModel: MusicTrackModel.AlbumData.ViewModel)
    func displayErrorArtist(viewModel: MusicTrackModel.ArtistData.ViewModel)
    func displayErrorMusicDownload(viewModel: MusicTrackModel.FetchSound.ViewModel)
    
    // MARK: Track row updates
    func displayInsertedRow(at indexPath: IndexPath)
    func displayDeletedRow(at indexPath: IndexPath)
    func displayUpdatedRow(at indexPath: IndexPath, withDisplayedTrack displayedTrack: MusicTrackModel.DisplayedTrackCell)
    func displayMovedRow(from: IndexPath, to: IndexPath, withDisplayedTrack displayedTrack: MusicTrackModel.DisplayedTrackCell)
    
    // MARK: CRUD operations
    func displayFetchedTrackRowAndConfigureCell(viewModel: MusicTrackModel.FetchListAndConfigureCell.ViewModel)
    func displayFetchedMusicDescRowAndConfigureCell(viewModel: MusicTrackModel.FetchMusicDescAndConfigureCell.ViewModel)
}

class MusicTrackViewController: UIViewController, MusicTrackDisplayLogic {
	var interactor: MusicTrackBusinessLogic?
	var router: (NSObjectProtocol & MusicTrackRoutingLogic & MusicTrackDataPassing)?
    
    var loadingView: LoadingView?
    var dispatchGroup = DispatchGroup()

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
		let interactor = MusicTrackInteractor()
		let presenter = MusicTrackPresenter()
		let router = MusicTrackRouter()
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
		
        setDarkMode(tableView: tableView)
        configTableView()
        loadingView = LoadingView(view: view)
	}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestTrackList()
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.tableView.reloadData()
        }
    }
	
	// MARK: Request methods
	
	func requestTrackList() {
        loadingView?.showActivityView()
        
        dispatchGroup.enter()
        
		let request = MusicTrackModel.List.Request()
		interactor?.requestTrackList(request: request)
	}
	
	func displayTrackList(viewModel: MusicTrackModel.List.ViewModel) {
        loadingView?.hideActivityView()
        
        dispatchGroup.leave()
	}
    
    func displayPlaylist(viewModel: MusicTrackModel.PlaylistData.ViewModel) {
        loadingView?.hideActivityView()
        
        dispatchGroup.leave()
    }
    
    func displayAlbum(viewModel: MusicTrackModel.AlbumData.ViewModel) {
        loadingView?.hideActivityView()
        
        dispatchGroup.leave()
    }
    
    func displayArtist(viewModel: MusicTrackModel.ArtistData.ViewModel) {
        loadingView?.hideActivityView()
        
        dispatchGroup.leave()
    }
    
    func displayCoverImage(viewModel: MusicTrackModel.CoverImage.ViewModel) {
        let cell = viewModel.cell
        cell.hideLoadingCover()
        
        if let image = viewModel.displayedEntry {
            cell.coverImage.image = image.cover
        } else {
            cell.coverImage.image = UIImage(named: "cover-image")
        }
    }
    
    // MARK: Fetch Methods
    
    func fetchTrackRowAndConfigure(cell: TrackTableViewCell, at indexPath: IndexPath) {
        let request = MusicTrackModel.FetchListAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchTrackRow(request: request)
    }
    
    func fetchMusicDescRowAndConfigure(cell: MusicDescTableViewCell, at indexPath: IndexPath) {
        let request = MusicTrackModel.FetchMusicDescAndConfigureCell.Request(indexPath: indexPath, cell: cell)
        interactor?.fetchMusicDetailRow(request: request)
    }
    
    // MARK: UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    func configTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "MusicDescTableViewCell", bundle: nil), forCellReuseIdentifier: reuseMusicDescIdentifierCell)
        tableView.register(UINib(nibName: "TrackTableViewCell", bundle: nil), forCellReuseIdentifier: reuseMusicTrackIdentifierCell)
    }
    
    // MARK: Display Fetched Requests
    
    func displayFetchedTrackRowAndConfigureCell(viewModel: MusicTrackModel.FetchListAndConfigureCell.ViewModel) {
        configureCellWith(viewModel.cell!, withDisplayedCell: viewModel.displayedTrack, at: viewModel.indexPath)
    }
    
    func displayFetchedMusicDescRowAndConfigureCell(viewModel: MusicTrackModel.FetchMusicDescAndConfigureCell.ViewModel) {
        configureCellWith(viewModel.cell!, withDisplayedCell: viewModel.displayedMusicDesc, at: viewModel.indexPath)
    }
    
    // MARK: Display Error Messages
    
    func displayErrorTrackList(viewModel: MusicTrackModel.List.ViewModel) {
        loadingView?.hideActivityView()
        
        showAlertFailure(title: "Error Track List", message: viewModel.error!)
    }
    
    func displayErrorPlaylist(viewModel: MusicTrackModel.PlaylistData.ViewModel) {
        loadingView?.hideActivityView()
        
        showAlertFailure(title: "Error Playlist", message: viewModel.error!)
    }
    
    func displayErrorAlbum(viewModel: MusicTrackModel.AlbumData.ViewModel) {
        loadingView?.hideActivityView()
        
        showAlertFailure(title: "Error Album", message: viewModel.error!)
    }
    
    func displayErrorArtist(viewModel: MusicTrackModel.ArtistData.ViewModel) {
        loadingView?.hideActivityView()
        
        showAlertFailure(title: "Error Artist", message: viewModel.error!)
    }
    
    // MARK: Handle Sound
    
    func requestActionMusic(at indexPath: IndexPath, cell: TrackTableViewCell) {
        let request = MusicTrackModel.FetchSound.Request(indexPath: indexPath, cell: cell)
        interactor?.requestActionOnMusic(request: request)
    }
    
    func displayMusicDownloaded(viewModel: MusicTrackModel.FetchSound.ViewModel) {
        let cell = viewModel.cell
        
        cell.hideLoading()
        
        if let index = viewModel.indexPath {
            requestActionMusic(at: index, cell: cell)
        }
    }
    
    func displayErrorMusicDownload(viewModel: MusicTrackModel.FetchSound.ViewModel) {
        let cell = viewModel.cell
        
        cell.hideLoading()
        showAlertFailure(title: "Error Music", message: viewModel.error!)
    }
    
    func displayMusicPlaying(viewModel: MusicTrackModel.FetchSound.ViewModel) {
        let cell = viewModel.cell
        
        cell.startAudioAnimation()
    }
    
    func displayMusicStopping(viewModel: MusicTrackModel.FetchSound.ViewModel) {
        let cell = viewModel.cell
        
        cell.hideLoading()
        cell.stopAudioAnimation()
    }
}

// MARK: - Table View Delegate & DataSource

extension MusicTrackViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = interactor?.count() {
            return count + 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseMusicDescIdentifierCell, for: indexPath) as! MusicDescTableViewCell
            
            fetchMusicDescRowAndConfigure(cell: cell, at: indexPath)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseMusicTrackIdentifierCell, for: indexPath) as! TrackTableViewCell
            
            let index = IndexPath(row: indexPath.row - 1, section: indexPath.section)
            fetchTrackRowAndConfigure(cell: cell, at: index)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        
        let index = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        let request = MusicTrackModel.Music.Request(indexPath: index)
        return interactor!.checkTrackToPlayMusic(request: request)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 150.0
        }
        
        return 64.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TrackTableViewCell
        let index = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        
        let request = MusicTrackModel.Music.Request(indexPath: index)
        if interactor!.checkTrackToPlayMusic(request: request) {
            cell.showLoading()
            requestActionMusic(at: index, cell: cell)
        }
    }
    
    func configureCellWith(_ cell: TrackTableViewCell, withDisplayedCell displayedCell: MusicTrackModel.DisplayedTrackCell, at indexPath: IndexPath) {
        cell.nameLabel.text = displayedCell.name
        cell.artistNameLabel.text = displayedCell.artistName
        cell.tag = indexPath.row
        
        let request = MusicTrackModel.Music.Request(indexPath: indexPath)
        if interactor!.checkTrackToPlayMusic(request: request) {
            cell.available()
        } else {
            cell.notAvailable()
        }
    }
    
    func configureCellWith(_ cell: MusicDescTableViewCell, withDisplayedCell displayedCell: MusicTrackModel.DisplayedDescCell, at indexPath: IndexPath) {
        cell.nameLabel.text = displayedCell.name
        cell.descTextView.text = displayedCell.desc
        
        if let data = displayedCell.image {
            cell.coverImage.image = UIImage(data: data) 
        } else {
            if let url = displayedCell.url {
                cell.showLoadingCover()
                
                let request = MusicTrackModel.CoverImage.Request(url: url, cell: cell, indexPath: indexPath)
                interactor?.requestCoverImage(request: request)
            }
        }
    }
}

// MARK: - NSFetchedResultsController
extension MusicTrackViewController {
    
    // MARK: Track row updates
    func displayInsertedRow(at indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func displayDeletedRow(at indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func displayUpdatedRow(at indexPath: IndexPath, withDisplayedTrack displayedTrack: MusicTrackModel.DisplayedTrackCell) {
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
    
    func displayMovedRow(from: IndexPath, to: IndexPath, withDisplayedTrack displayedTrack: MusicTrackModel.DisplayedTrackCell) {
        tableView.moveRow(at: from, to: to)
    }
}
