//
//  StudentListViewController.swift
//  onthemap
//
//  Created by Shir Bar Lev on 26/03/2022.
//

import Foundation
import UIKit

let callViewIdentifier = "onTheMapCV"

class StudentListViewController: StudentsViewsBaseClass, UITableViewDelegate, UITableViewDataSource {
    // MARK: Variables & Constants
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    // MARK: UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.studentInfoHandler.studentLocations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let studentAtIndexPath = self.studentInfoHandler.studentLocations?[indexPath.row]
        var userCellView = tableView.dequeueReusableCell(withIdentifier: callViewIdentifier)
        
        // create the cell if there isn't an existing one
        if userCellView == nil {
            userCellView = UITableViewCell(style: .subtitle, reuseIdentifier: callViewIdentifier)
        }
        
        // set up the cell's content
        var cellContent = userCellView?.defaultContentConfiguration()
        cellContent?.text = "\(studentAtIndexPath?.firstName ?? "") \(studentAtIndexPath?.lastName ?? "")"
        cellContent?.secondaryText = studentAtIndexPath?.mediaURL
        
        userCellView?.contentConfiguration = cellContent
        
        return userCellView!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userURL = self.studentInfoHandler.studentLocations?[indexPath.row].mediaURL ?? ""
        self.navigateToUserURL(userURL: userURL)
    }
}
