//
//  YandexGeocoder.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 18.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation
import MapKit

typealias GeocoderResult = Result<GeocoderResponse, Error>

final class YandexGeocoder
{
	func getGeocoderAddressRequest(coordinates: CLLocationCoordinate2D) -> URL? {
		var components = URLComponents(string: Constants.baseUrl)
		components?.queryItems = [
			URLQueryItem(name: "apikey", value: Constants.apiKey),
			URLQueryItem(name: "geocode", value: "\(coordinates.longitude), \(coordinates.latitude)"),
			URLQueryItem(name: "format", value: "json"),
		]
		return components?.url
	}

	func getAdress(coordinates: CLLocationCoordinate2D, completionHandler: @escaping ((GeocoderResult) -> Void)) {
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
			do {
				let geoCoderResponse = try JSONDecoder().decode(GeocoderResponse.self, from: data)
				completionHandler(.success(geoCoderResponse))
			}
			catch {
				completionHandler(.failure(error))
			}
		}
		.resume()
	}
}
