//
//  RepositoryViewController.swift
//  GithubFetcher2.0
//
//  Created by Mickael Ruzel on 25/06/2022.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryViewController: UIViewController {
    
    // MARK: - Outlet
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repoNameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Properties

    var viewModel: RepositoryViewModel!
    private var bag = DisposeBag()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupImageView()
        bindOutput()
        // Do any additional setup after loading the view.
    }
    
    private func setupImageView() {
        userImage.layer.borderWidth = 1
        userImage.layer.masksToBounds = false
        userImage.layer.borderColor = UIColor.black.cgColor
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.clipsToBounds = true
    }
    
    // MARK: - Methodes
    
    private func bindOutput() {
        let output = viewModel.output!
        
        bag.insert(
            output.userName
                .drive(userNameLabel.rx.text),
            output.repositoryName
                .drive(repoNameLabel.rx.text),
            output.repositoryDescription
                .drive(descriptionTextView.rx.text)
        )
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(okAction)
        
        navigationController?.present(alert, animated: true)
    }
}
