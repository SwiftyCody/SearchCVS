//
//  LocationInfoModel.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import Foundation
import CoreLocation
import RxSwift

struct LocationInfoModel {
    let localNetwork: KakaoLocalNetwork
    
    init(localNetwork: KakaoLocalNetwork = KakaoLocalNetwork()) {
        self.localNetwork = localNetwork
    }
    
    func getLocation(by coordinate: CLLocationCoordinate2D) -> Single<Result<LocationData, URLError>> {
        return localNetwork.getLocation(by: coordinate)
    }
    
    func documentsToCellData(_ data: [KLDocument]) -> [DetailListCellData] {
        return data.map {
            let address = $0.roadAddressName.isEmpty ? $0.addressName : $0.roadAddressName
            let point = documentToCoordinate($0)
            return DetailListCellData(placeName: $0.placeName, address: address, distance: $0.distance, point: point)
        }
    }
    
    func documentToCoordinate(_ document: KLDocument) -> CLLocationCoordinate2D {
        if let latitude = Double(document.y), let longitude = Double(document.x) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        else {
            return CLLocationCoordinate2D()
        }
    }
}
