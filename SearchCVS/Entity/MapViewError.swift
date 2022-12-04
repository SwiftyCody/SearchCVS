//
//  MapViewError.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import Foundation

enum MapViewError: Error {
    case failedUpdatingCurrentLocation
    case locationAuthorizationDenied
    
    var errorDescription: String {
        switch self {
        case .failedUpdatingCurrentLocation:
            return "현재 위치를 불러오지 못했습니다. 잠시 후 다시 시도해주세요."
        case .locationAuthorizationDenied:
            return "위치 정보를 비활성화하면 사용자의 현져 위치를 알 수 없습니다."
        }
    }
}
