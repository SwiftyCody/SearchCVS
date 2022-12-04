//
//  LocationInfoViewController.swift
//  SearchCVS
//
//  Created by swiftyCody on 2022/11/30.
//

import UIKit
import CoreLocation
import MapKit
import RxSwift
import RxCocoa
import SwiftUI
import SnapKit
import Then

class LocationInfoViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    lazy var locationManager = CLLocationManager().then {
        $0.delegate = self
    }
    
    lazy var mapView = MKMapView().then {
        $0.delegate = self
        $0.setUserTrackingMode(.followWithHeading, animated: true)
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.394225, longitude: 127.110341),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        $0.setRegion(defaultRegion, animated: false)
    }
    
    let currentLocationButton = UIButton().then {
        $0.setImage(UIImage(systemName: "scope"), for: .normal)
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
    }
    
    lazy var detailList = UITableView().then {
        $0.register(DetailListCell.self, forCellReuseIdentifier: "DetailListCell")
        $0.separatorStyle = .none
        $0.backgroundView = self.detailListBackgroundView
    }
    
    let detailListBackgroundView = DetailListBackgroundView()
    
    let viewModel = LocationInfoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        bind(viewModel)
        attribute()
        layout()
    }
    
    func bind(_ viewModel: LocationInfoViewModel) {
        detailListBackgroundView.bind(viewModel.detailListBackgroundViewModel)
        
        viewModel.setMapCenter
            .emit(to: mapView.rx.setMapCenterPoint)
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .emit(to: viewModel.detailListBackgroundViewModel.shouldChangeStatusLabelText)
            .disposed(by: disposeBag)
        
        viewModel.detailListCellData
            .drive(detailList.rx.items) { tv, row, data in
                let cell = tv.dequeueReusableCell(withIdentifier: "DetailListCell", for: IndexPath(row: row, section: 0)) as! DetailListCell
                
                cell.setData(data)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.detailListCellData
            .map { $0.compactMap { $0.point }}
            .drive(self.rx.addAnnotationViews)
            .disposed(by: disposeBag)
        
        viewModel.scrollToSelectedLocation
            .emit(to: self.rx.showSelectedLocation)
            .disposed(by: disposeBag)
        
        detailList.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.detailListItemSelected)
            .disposed(by: disposeBag)
        
        currentLocationButton.rx.tap
            .bind(to: viewModel.currentLocationButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        title = "🏪내 주변 편의점🔍"
        view.backgroundColor = .white
        
    }
    
    private func layout() {
        [mapView, currentLocationButton, detailList]
            .forEach { view.addSubview($0) }
        
        mapView.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.snp.centerY).offset(100)
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.bottom.equalTo(detailList.snp.top).offset(-12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(40)
        }
        
        detailList.snp.makeConstraints {
            $0.centerX.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view)
            $0.top.equalTo(mapView.snp.bottom)
        }
    }
}

extension LocationInfoViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let location = userLocation.location {
            viewModel.currentLocation.accept(location.coordinate)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        viewModel.mapCenterPoint.accept(mapView.centerCoordinate)
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        viewModel.selectAnnotation.accept(annotation)
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        viewModel.mapViewError.accept(error.localizedDescription)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? CVSAnnotation {
                let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "CVSAnnotation")
                view.image = UIImage(systemName: "pin.circle.fill")
                return view
            }
            return nil
        }
}

extension LocationInfoViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse, .notDetermined:
            return
        default:
            viewModel.mapViewError.accept(MapViewError.locationAuthorizationDenied.localizedDescription)
            return
        }
    }
}

extension Reactive where Base: MKMapView {
    var setMapCenterPoint: Binder<CLLocationCoordinate2D> {
        return Binder(base) { base, point in
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: point, span: span)
            base.setRegion(region, animated: true)
        }
    }
}

extension Reactive where Base: LocationInfoViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            let alertController = UIAlertController(title: "문제가 발생했습니다.",
                                                    message: message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "확인", style: .default))
            base.present(alertController, animated: true)
        }
    }
    
    var showSelectedLocation: Binder<Int> {
        return Binder(base) { base, row in
            let indexPath = IndexPath(row: row, section: 0)
            base.detailList.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    
    var addAnnotationViews: Binder<[CLLocationCoordinate2D]> {
        return Binder(base) { base, coordiantes in
            let items = coordiantes
                .enumerated()
                .map { offset, coordiante in
                    let annotation = CVSAnnotation(coordinate: coordiante)
                    annotation.tag = offset
                    return annotation
                }
            
            base.mapView.removeAnnotations(base.mapView.annotations)
            base.mapView.addAnnotations(items)
        }
    }
}

// MARK: for Preview

struct ViewController_Previews: PreviewProvider {
    static var previews: some View {
        LocationInfoViewControllerRepresentable()
    }
}

struct LocationInfoViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = LocationInfoViewController()
        
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
}
