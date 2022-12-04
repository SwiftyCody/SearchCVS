//
//  KLDocument.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/01.
//

import Foundation

struct KLDocument: Decodable {
    let placeName: String
    let addressName: String
    let roadAddressName: String
    let x: String
    let y: String
    let distance: String
    let placeURL: String

    enum CodingKeys: String, CodingKey {
        case x, y, distance
        case placeName = "place_name"
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case placeURL = "place_url"
    }
}
