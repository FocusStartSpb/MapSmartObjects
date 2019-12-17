//
//  YandexGeocoderResponse.swift
//  MapSmartObjects
//
//  Created by Kirill Fedorov on 17.12.2019.
//  Copyright © 2019 Максим Шалашников. All rights reserved.
//

import Foundation

// MARK: - GeocoderResponse
struct GeocoderResponse: Codable {
	let response: Response
}

// MARK: - Response
struct Response: Codable {
	let geoObjectCollection: GeoObjectCollection
	
	enum CodingKeys: String, CodingKey {
		case geoObjectCollection = "GeoObjectCollection"
	}
}

// MARK: - GeoObjectCollection
struct GeoObjectCollection: Codable {
	let metaDataProperty: GeoObjectCollectionMetaDataProperty?
	let featureMember: [FeatureMember]
}

// MARK: - FeatureMember
struct FeatureMember: Codable {
	let geoObject: GeoObject
	
	enum CodingKeys: String, CodingKey {
		case geoObject = "GeoObject"
	}
}

// MARK: - GeoObject
struct GeoObject: Codable {
	let metaDataProperty: GeoObjectMetaDataProperty?
	let name: String
	let geoObjectDescription: String?
	let boundedBy: BoundedBy?
	let point: Point?
	
	enum CodingKeys: String, CodingKey {
		case metaDataProperty
		case geoObjectDescription = "description"
		case name, boundedBy
		case point = "Point"
	}
}

// MARK: - BoundedBy
struct BoundedBy: Codable {
	let envelope: Envelope?
	
	enum CodingKeys: String, CodingKey {
		case envelope = "Envelope"
	}
}

// MARK: - Envelope
struct Envelope: Codable {
	let lowerCorner, upperCorner: String?
}

// MARK: - GeoObjectMetaDataProperty
struct GeoObjectMetaDataProperty: Codable {
	let geocoderMetaData: GeocoderMetaData?
	
	enum CodingKeys: String, CodingKey {
		case geocoderMetaData = "GeocoderMetaData"
	}
}

// MARK: - GeocoderMetaData
struct GeocoderMetaData: Codable {
	let kind, text, precision: String?
	let address: Address?
	let addressDetails: AddressDetails?
	
	enum CodingKeys: String, CodingKey {
		case kind, text, precision
		case address = "Address"
		case addressDetails = "AddressDetails"
	}
}

// MARK: - Address
struct Address: Codable {
	let countryCode, postalCode, formatted: String?
	let components: [Component]?
	
	enum CodingKeys: String, CodingKey {
		case countryCode = "country_code"
		case postalCode = "postal_code"
		case formatted
		case components = "Components"
	}
}

// MARK: - Component
struct Component: Codable {
	let kind, name: String?
}

// MARK: - AddressDetails
struct AddressDetails: Codable {
	let country: Country?
	
	enum CodingKeys: String, CodingKey {
		case country = "Country"
	}
}

// MARK: - Country
struct Country: Codable {
	let addressLine, countryNameCode, countryName: String?
	let administrativeArea: AdministrativeArea?
	
	enum CodingKeys: String, CodingKey {
		case addressLine = "AddressLine"
		case countryNameCode = "CountryNameCode"
		case countryName = "CountryName"
		case administrativeArea = "AdministrativeArea"
	}
}

// MARK: - AdministrativeArea
struct AdministrativeArea: Codable {
	let administrativeAreaName: String?
	let locality: Locality?
	
	enum CodingKeys: String, CodingKey {
		case administrativeAreaName = "AdministrativeAreaName"
		case locality = "Locality"
	}
}

// MARK: - Locality
struct Locality: Codable {
	let localityName: String?
	let thoroughfare: Thoroughfare?
	
	enum CodingKeys: String, CodingKey {
		case localityName = "LocalityName"
		case thoroughfare = "Thoroughfare"
	}
}

// MARK: - Thoroughfare
struct Thoroughfare: Codable {
	let thoroughfareName: String?
	let premise: Premise?
	
	enum CodingKeys: String, CodingKey {
		case thoroughfareName = "ThoroughfareName"
		case premise = "Premise"
	}
}

// MARK: - Premise
struct Premise: Codable {
	let premiseNumber: String?
	let postalCode: PostalCode?
	
	enum CodingKeys: String, CodingKey {
		case premiseNumber = "PremiseNumber"
		case postalCode = "PostalCode"
	}
}

// MARK: - PostalCode
struct PostalCode: Codable {
	let postalCodeNumber: String?
	
	enum CodingKeys: String, CodingKey {
		case postalCodeNumber = "PostalCodeNumber"
	}
}

// MARK: - Point
struct Point: Codable {
	let pos: String?
}

// MARK: - GeoObjectCollectionMetaDataProperty
struct GeoObjectCollectionMetaDataProperty: Codable {
	let geocoderResponseMetaData: GeocoderResponseMetaData?
	
	enum CodingKeys: String, CodingKey {
		case geocoderResponseMetaData = "GeocoderResponseMetaData"
	}
}

// MARK: - GeocoderResponseMetaData
struct GeocoderResponseMetaData: Codable {
	let request, found, results: String?
}
