//
//  RxMapView.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/04.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa

extension MKMapView: HasDelegate {}

class RxMKMapViewDelegateProxy: DelegateProxy<MKMapView, MKMapViewDelegate>, DelegateProxyType, MKMapViewDelegate {
    weak public private(set) var mapView: MKMapView?
    
    public init(mapView: ParentObject) {
        self.mapView = mapView
        super.init(parentObject: mapView,
                   delegateProxy: RxMKMapViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        register { RxMKMapViewDelegateProxy(mapView: $0) }
    }
}

public extension Reactive where Base: MKMapView {
    var delegate: DelegateProxy<MKMapView, MKMapViewDelegate> {
        RxMKMapViewDelegateProxy.proxy(for: base)
    }
    
    func setDelegate(_ delegate: MKMapViewDelegate) -> Disposable {
        RxMKMapViewDelegateProxy.installForwardDelegate(
            delegate,
            retainDelegate: false,
            onProxyForObject: self.base
        )
    }
    
    var setMapCenterPoint: Binder<CLLocationCoordinate2D> {
        return Binder(base) { base, point in
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: point, span: span)
            base.setRegion(region, animated: true)
        }
    }
    
    var didUpdateUserLocation : ControlEvent<CLLocationCoordinate2D> {
        let source = delegate
            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:didUpdate:)))
            .map { parameters in
                return (parameters[1] as? MKUserLocation)?.coordinate ?? CLLocationCoordinate2D()
            }
        
        return ControlEvent(events: source)
    }
    
    var regionDidChange: ControlEvent<CLLocationCoordinate2D> {
        let source = delegate
            .methodInvoked(#selector(MKMapViewDelegate.mapView(_:regionDidChangeAnimated:)))
            .map { parameters in
                return (parameters[0] as? MKMapView)?.centerCoordinate ?? CLLocationCoordinate2D()
            }
        
        return ControlEvent(events: source)
    }
}

