//
//  DetailListBackgroundViewModel.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import RxSwift
import RxCocoa

struct DetailListBackgroundViewModel {
    // ViewModel -> View
    let isStatusLabelHidden: Signal<Bool>
    let statusLabelText: Signal<String>
    
    // ViewModel <- View, Outside
    let shouldHideStatusLabel = PublishSubject<Bool>()
    let shouldChangeStatusLabelText = PublishSubject<String>()
    
    init() {
        isStatusLabelHidden = shouldHideStatusLabel
            .asSignal(onErrorJustReturn: true)
        
        statusLabelText = shouldChangeStatusLabelText
            .asSignal(onErrorJustReturn: """
                    🤔
                    500m 근처에 편의점이 없습니다.
                    지도 위치를 옮겨서 재검색해주세요.
                    """)
    }
}
