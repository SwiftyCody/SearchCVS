//
//  DetailListCell.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import UIKit
import Then

class DetailListCell: UITableViewCell {
    
    let placeNameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
    }
    let addressLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.textColor = .gray
    }
    let distanceLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 12, weight: .light)
        $0.textColor = .darkGray
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(_ data: DetailListCellData) {
        placeNameLabel.text = data.placeName
        addressLabel.text = data.address
        distanceLabel.text = "\(data.distance)m"
    }
    
    private func attribute() {
        backgroundColor = .white
    }
    
    private func layout() {
        [placeNameLabel, addressLabel, distanceLabel]
            .forEach { contentView.addSubview($0) }
        
        placeNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(18)
        }
        
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(placeNameLabel.snp.bottom).offset(3)
            $0.leading.equalTo(placeNameLabel)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        distanceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }

}
