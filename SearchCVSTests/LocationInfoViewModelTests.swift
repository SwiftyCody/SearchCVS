//
//  LocationInfoViewModelTests.swift
//  SearchCVSTests
//
//  Created by swiftyCody on 2022/12/14.
//

import XCTest
import Nimble
import RxSwift
import RxTest

@testable import SearchCVS
import CoreLocation

// 테스트 코드는 당연한 코드가 당연하게 동작하는가를 검증하는 것.
// 배포되기 전 문제를 사전에 발견할 수 있는 최선의 방법
// 테스트 가능한 코드를 작성하는 것 자체가 코드의 질을 높여줌.
// MVVM을 사용하는 이유 중 하나는 MVC보다 testable한 패턴이기 때문.
// 클래스 단위의 테스트가 어렵다면 메서드 단위부터 시작해 볼 것.

final class LocationInfoViewModelTests: XCTestCase {
    let disposeBag = DisposeBag()
    
    let stubNetwork = KakaoLocalNetworkStub()
    var model: LocationInfoModel!
    var viewModel: LocationInfoViewModel!
    var doc: [KLDocument]!
    
    override func setUp() {
        self.model = LocationInfoModel(localNetwork: stubNetwork)
        self.viewModel = LocationInfoViewModel(model: model)
        self.doc = cvsList
    }
    
    func testSetMapCenter() {
        let scheduler = TestScheduler(initialClock: 0)
        
        // 더미데이터의 이벤트
        let dummyDataEvent = scheduler.createHotObservable([
            .next(0, cvsList) // 0초에 cvsList(더미데이터)를 통신으로 받은 것처럼 설정
        ])
        
        let documentData = PublishSubject<[KLDocument]>()
        dummyDataEvent
            .subscribe(documentData)
            .disposed(by: disposeBag)
        
        // DetailList 아이템(셀) 탭 이벤트
        let itemSelectedEvent = scheduler.createHotObservable([
            .next(1, 0) // 1초에 0번째 셀이 선택된 것처럼 설정
        ])
        
        // 선택된 셀 row에 따른 Data 세팅
        let itemSelected = PublishSubject<Int>()
        itemSelectedEvent
            .subscribe(itemSelected)
            .disposed(by: disposeBag)
        
        let selectedItemMapPoint = itemSelected
            .withLatestFrom(documentData) { $1[0] }
            .map(model.documentToCoordinate)
        
        // 최초 현재 위치 이벤트
        let initialCoordinate = CLLocationCoordinate2D(latitude: 37.394225, longitude: 127.110341)
        
        let currentLocationEvent = scheduler.createHotObservable([
            .next(0, initialCoordinate)
        ])
        
        let initialCurrentLocation = PublishSubject<CLLocationCoordinate2D>()
        
        currentLocationEvent
            .subscribe(initialCurrentLocation)
            .disposed(by: disposeBag)
        
        // 현재 위치 버튼 탭 이벤트 (2번 탭 했다고 가정)
        let currentLocationButtonTapEvent = scheduler.createHotObservable([
            .next(2, Void()),
            .next(3, Void())
        ])
        
        let currentLocationButtonTapped = PublishSubject<Void>()
        
        currentLocationButtonTapEvent
            .subscribe(currentLocationButtonTapped)
            .disposed(by: disposeBag)
        
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(initialCurrentLocation)
        
        // merge
        let currentMapCenter = Observable
            .merge(
                selectedItemMapPoint,
                initialCurrentLocation.take(1),
                moveToCurrentLocation
            )
        
        let currentMapCenterObserver = scheduler.createObserver(Double.self)
        
        currentMapCenter
            .map { $0.latitude }
            .subscribe(currentMapCenterObserver)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        let secondCoordinate = model.documentToCoordinate(doc[0])
        
        // equal은 Equatable 프로토콜을 따라야 해서 coordinate를 비교하기 보다, coordinate의 값을 비교
        expect(currentMapCenterObserver.events).to(
            equal([
                .next(0, initialCoordinate.latitude),
                .next(1, secondCoordinate.latitude),
                .next(2, initialCoordinate.latitude),
                .next(3, initialCoordinate.latitude)
            ])
        )
    }
}
