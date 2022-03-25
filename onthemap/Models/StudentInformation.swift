//
//  StudentInformation.swift
//  onthemap
//
//  Created by Shir Bar Lev on 18/07/2021.
//

import Foundation

struct StudentInformation: Codable {
    let objectId: String
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Float
    let longitude: Float
    let createdAt: String
    let updatedAt: String
}

struct StudentInformationArray: Codable {
    let results: [StudentInformation]
}
