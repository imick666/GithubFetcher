//
//  MainCoordinator.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 31/05/2022.
//

import Foundation
import UIKit

protocol Coordinator {
    
    var chilCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

final class MainCoordinator: Coordinator {
    var chilCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = SearchListViewController()
        vc.title = "Github Fetcher"
        vc.viewModel = SearchListViewModel()
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.pushViewController(vc, animated: true)
    }
}
