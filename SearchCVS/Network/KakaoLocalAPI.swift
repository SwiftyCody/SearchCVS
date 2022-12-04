//
//  KakaoLocalAPI.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import Foundation
import MapKit

struct KakaoLocalAPI {
    static let scheme = "https"
    static let host = "dapi.kakao.com"
    static let path = "/v2/local/search/category.json"
    
    func getLocation(by mapPoint: CLLocationCoordinate2D) -> URLComponents {
        var components = URLComponents()
        components.scheme = KakaoLocalAPI.scheme
        components.host = KakaoLocalAPI.host
        components.path = KakaoLocalAPI.path
        
        components.queryItems = [
            URLQueryItem(name: "category_group_code", value: "CS2"),
            URLQueryItem(name: "x", value: "\(mapPoint.longitude)"),
            URLQueryItem(name: "y", value: "\(mapPoint.latitude)"),
            URLQueryItem(name: "radius", value: "500"),
            URLQueryItem(name: "sort", value: "distance")
        ]
        
        return components
    }
}
