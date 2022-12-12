//
//  LocationInformationModelTests.swift
//  SearchCVSTests
//
//  Created by Cody on 2022/12/13.
//

import XCTest
import Nimble

@testable import SearchCVS

final class LocationInformationModelTests: XCTestCase {
    let stubNetwork = KakaoLocalNetworkStub()
    
    var doc: [KLDocument]!
    var model: LocationInfoModel!
    
    
    override func setUp() {
        // 기초 설정
        self.model = LocationInfoModel(localNetwork: stubNetwork)
        self.doc = cvsList
    }
    
    func testDocumentsToCellData() {
        
        let cellData = model.documentsToCellData(doc) // 실제 모델의 값
        let placeName = doc.map { $0.placeName } // dummy 값
        
        let address = cellData[1].address // 실제 모델의 값
        let roadAddressName = doc[1].roadAddressName // dummy 값
        
        expect(cellData.map { $0.placeName}).to(
            equal(placeName),
            description: "DetailListCellData의 placeName은 document의 placeName입니다."
        )
        
        expect(address).to(equal(roadAddressName), description: "KLDocument의 roadAddressName이 빈 값이 아닐 경우 roadAddress가 cellData에 전달됩니다.")
    }

}
