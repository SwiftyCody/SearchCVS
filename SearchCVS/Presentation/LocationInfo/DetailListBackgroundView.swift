//
//  DetailListBackgroundView.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import RxSwift
import RxCocoa
import SnapKit
import Then

class DetailListBackgroundView: UIView {
    let disposeBag = DisposeBag()
    let statusLabel = UILabel().then {
        $0.text = """
                    🤔
                    500m 근처에 편의점이 없습니다.
                    지도 위치를 옮겨서 재검색해주세요.
                    """
        $0.textAlignment = .center
        $0.numberOfLines = 3
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: DetailListBackgroundViewModel) {
        viewModel.isStatusLabelHidden
            .emit(to: statusLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.statusLabelText
            .emit(to: statusLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        backgroundColor = .white
    }
    
    private func layout() {
        addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
