//
//  SearchViewController.swift
//  MusicPod
//
//  Created by Anderson Rodrigues on 15/04/2020.
//  Copyright (c) 2020 Anderson Soares Rodrigues. All rights reserved.
//

import UIKit

private let reuseSearchResultIdentifierCell = "reuseSearchResultCell"
private let segueSearchToMusicView = "MusicView"

// MARK: - Protocol
protocol SearchDisplayLogic: class {
    // MARK: Display Data
	func displaySearchList(viewModel: SearchModel.List.ViewModel)
    func displayCoverImage(viewModel: SearchModel.CoverImage.ViewModel)
    
    // MARK: Error Display
    func displayErrorSearchList(viewModel: SearchModel.List.ViewModel)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
	var interactor: SearchBusinessLogic?
	var router: (NSObjectProtocol & SearchRoutingLogic & SearchDataPassing)?
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
		let interactor = SearchInteractor()
		let presenter = SearchPresenter()
		let router = SearchRouter()
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
        
		navigationItem.title = "Search"
        
        if #available(iOS 13.0, *) {
            navigationController!.navigationBar.prefersLargeTitles = true
        }
        
        setDarkMode(tableView: tableView)
        
        initTableView()
        configSearchBar()
        loadingView = LoadingView(view: self.view)
	}
	
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Init
    
    func initTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "SearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: reuseSearchResultIdentifierCell)
    }
    
    // MARK: - UISearchBar
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: Init
    
    func configSearchBar() {
        searchBar.delegate = self
        searchBar.barStyle = .black
    }
    
	// MARK: - Fetch Search Results
	
    var result = [SearchModel.DisplayedCell]()
    
    func requestSearchList(_ q: String) {
		let request = SearchModel.List.Request(query: q)
		interactor?.requestSearch(request: request)
	}
	
    func displaySearchList(viewModel: SearchModel.List.ViewModel) {
        result = viewModel.displayedEntries
        tableView.reloadData()
    }
    
    func displayCoverImage(viewModel: SearchModel.CoverImage.ViewModel) {
        let cell = viewModel.cell
        cell.activityViewImage.stopAnimating()
        cell.removeLoadingCover()
        cell.coverImage.image = viewModel.displayedEntry.cover
    }
    
    // MARK: Error Display
    
    func displayErrorSearchList(viewModel: SearchModel.List.ViewModel) {
//        showAlertFailure(title: "Error Search", message: viewModel.message!)
    }
}

// MARK: - Table View Data Source & Table View Delegate

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseSearchResultIdentifierCell, for: indexPath) as! SearchResultTableViewCell
        let data = result[indexPath.row]
        
        configureCell(cell, withDisplayedCell: data, at: indexPath)
        
        return cell
    }
    
    func configureCell(_ cell: SearchResultTableViewCell, withDisplayedCell displayedCell: SearchModel.DisplayedCell, at indexPath: IndexPath) {
        cell.nameLabel.text = displayedCell.name
        cell.typeLabel.text = displayedCell.type.capitalized
        
        if let data = displayedCell.image {
            let image = UIImage(data: data)
            cell.coverImage.image = image
            cell.removeLoadingCover()
        } else if let url = displayedCell.url {
            cell.activityViewImage.startAnimating()
            cell.coverImage.image = UIImage(named: "cover-playlist")
            let request = SearchModel.CoverImage.Request(url: url, cell: cell, indexPath: indexPath)
            interactor?.requestCoverImage(request: request)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = result[indexPath.row]
        
        interactor?.provideDataToMusicView(with: item)
        performSegue(withIdentifier: segueSearchToMusicView, sender: self)
    }
    
    // MARK: Delegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestSearchList(searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
}
