//
//  KakaoLocalNetworkStub.swift
//  SearchCVSTests
//
//  Created by Cody on 2022/12/05.
//

import Foundation
import CoreLocation
import RxSwift
import Stubber

@testable import SearchCVS

class KakaoLocalNetworkStub: KakaoLocalNetwork {
    override func getLocation(by coordinate: CLLocationCoordinate2D) -> Single<Result<LocationData, URLError>> {
        // 기존의 getLocation을 override
        
        return Stubber.invoke(getLocation, args: coordinate)
    }
}
