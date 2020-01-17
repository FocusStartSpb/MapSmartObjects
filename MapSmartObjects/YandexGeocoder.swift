//
//  YandexGeocoder.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import MapKit

typealias GeocoderResult = Result<Data, Error>
typealias GeocoderResponseResult = Result<String, Error>

enum YandexGeocoder
{
	static private func getGeocoderAddressRequest(coordinates: CLLocationCoordinate2D) -> URL? {
		var components = URLComponents(string: Constants.baseUrl)
		components?.queryItems = [
			URLQueryItem(name: "apikey", value: Constants.apiKey),
			URLQueryItem(name: "geocode", value: "\(coordinates.longitude), \(coordinates.latitude)"),
			URLQueryItem(name: "format", value: "json"),
		]
		return components?.url
	}

	static private func getGeocoderRequest(coordinates: CLLocationCoordinate2D,
										   completionHandler: @escaping ((GeocoderResult) -> Void)) {
		guard let url = getGeocoderAddressRequest(coordinates: coordinates) else { return }
		URLSession.shared.dataTask(with: url) { data, response, error in
			if let error = error {
				completionHandler(.failure(error))
				return
			}
			guard let data = data,
				let response = response as? HTTPURLResponse,
				response.statusCode == 200
				else { return }
			completionHandler(.success(data))
		}
		.resume()
	}

	static func getGeoposition(coordinates: CLLocationCoordinate2D,
						completionHandler: @escaping (GeocoderResponseResult) -> Void) {
		getGeocoderRequest(coordinates: coordinates) { result in
			switch result {
			case .success(let data):
				do {
					let geocoderResponseResult = try JSONDecoder().decode(GeocoderResponse.self, from: data)
					let geocoderResult = geocoderResponseResult.response.geoObjectCollection.featureMember
					.first?.geoObject.metaDataProperty?.geocoderMetaData?.text ?? ""
					completionHandler(.success(geocoderResult))
				}
				catch {
					completionHandler(.failure(error))
				}
			case .failure(let message):
				completionHandler(.failure(message))
			}
		}
	}
}
