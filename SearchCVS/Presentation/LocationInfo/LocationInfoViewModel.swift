//
//  LocationInfoViewModel.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/01.
//

import Foundation
import CoreLocation
import MapKit
import RxSwift
import RxCocoa

struct LocationInfoViewModel {
    let disposeBag = DisposeBag()
    
    // subviewModels
    let detailListBackgroundViewModel = DetailListBackgroundViewModel()
    
    // ViewModel -> View
    let setMapCenter: Signal<CLLocationCoordinate2D>
    let errorMessage: Signal<String>
    let mapViewNoData: Signal<String>
    let detailListCellData: Driver<[DetailListCellData]>
    let scrollToSelectedLocation: Signal<Int> // table row
    
    // ViewModel <- View
    let currentLocation = PublishRelay<CLLocationCoordinate2D>() // 사용자 위치
    let mapCenterPoint = PublishRelay<CLLocationCoordinate2D>() // 지도 중심
    let selectAnnotation = PublishRelay<MKAnnotation>()
    let mapViewError = PublishRelay<String>()
    let currentLocationButtonTapped = PublishRelay<Void>()
    let detailListItemSelected = PublishRelay<Int>()
    
    private let documentData = PublishSubject<[KLDocument]>()
    
    init(model: LocationInfoModel = LocationInfoModel()) {
        // fetch data from network
        let cvsLocationDataResult = mapCenterPoint
            .flatMapLatest(model.getLocation)
            .share()
        
        let cvsLocationDataValue = cvsLocationDataResult
            .compactMap { data -> LocationData? in
                guard case let .success(value) = data else {
                    return nil
                }
                
                return value
            }
        
        let cvsLocationDataErrorMessage = cvsLocationDataResult
            .compactMap { data -> String? in
                switch data {
                case let .failure(error):
                    return error.localizedDescription
                default:
                    return nil
                }
            }
        
        mapViewNoData = cvsLocationDataResult
            .compactMap { data -> String? in
                switch data {
                case let .success(data) where data.documents.isEmpty:
                    return """
                    🤔
                    500m 근처에 편의점이 없습니다.
                    지도 위치를 옮겨서 재검색해주세요.
                    """
                default:
                    return nil
                }
            }
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
        
        cvsLocationDataValue
            .map { $0.documents }
            .bind(to: documentData)
            .disposed(by: disposeBag)
        
        // 지도 중심 설정
        let selectDetailListItem = detailListItemSelected
            .withLatestFrom(documentData) { $1[$0] }
            .map(model.documentToCoordinate)
        
        let moveToCurrentLocation = currentLocationButtonTapped
            .withLatestFrom(currentLocation) // currentLocation을 한번이라도 받은 이후
        
        let currentMapCenter = Observable
            .merge(
                selectDetailListItem,   // 리스트에서 선택된 값이거나
                currentLocation.take(1),// 현재 위치를 최초로 받아왔거나
                moveToCurrentLocation   // 현재 위치로 이동 버튼을 눌렀거나
            )
        
        setMapCenter = currentMapCenter
            .asSignal(onErrorSignalWith: .empty())
        
        errorMessage = Observable
            .merge (
                cvsLocationDataErrorMessage,
                mapViewError.asObservable()
            )
            .asSignal(onErrorJustReturn: "잠시 후 다시 시도해주세요.")
        
        detailListCellData = documentData
            .map(model.documentsToCellData)
            .asDriver(onErrorDriveWith: .empty())
        
        documentData
            .map { !$0.isEmpty }
            .bind(to: detailListBackgroundViewModel.shouldHideStatusLabel)
            .disposed(by: disposeBag)
        
        scrollToSelectedLocation = selectAnnotation
            .map {
                if let annotaion: CVSAnnotation = $0 as? CVSAnnotation {
                    return annotaion.tag
                }
                else {
                  return 0
                }
            }
            .asSignal(onErrorJustReturn: 0)
    }
}
