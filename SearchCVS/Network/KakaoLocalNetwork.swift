//
//  KakaoLocalNetwork.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import RxSwift
import CoreLocation

class KakaoLocalNetwork {
    private let session: URLSession
    let api = KakaoLocalAPI()
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getLocation(by coordinate: CLLocationCoordinate2D) -> Single<Result<LocationData, URLError>> {
        guard let url = api.getLocation(by: coordinate).url else {
            return .just(.failure(URLError(.badURL)))
        }
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("KakaoAK (Developer에서 발급받은 RestAPI 키를 넣어야 합니다)", forHTTPHeaderField: "Authorization")
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let locationData = try JSONDecoder().decode(LocationData.self, from: data)
                    return .success(locationData)
                } catch {
                    return .failure(URLError(.cannotParseResponse))
                }
            }
            .catch { _ in .just(Result.failure(URLError(.cannotLoadFromNetwork))) }
            .asSingle()
    }
}
