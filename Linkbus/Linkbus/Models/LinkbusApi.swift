//
//  LinkbusApi.swift
//  Linkbus

//  Stucts for Linkbus API call
//
//  Created by Michael Carroll on 8/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI

struct LinkbusApi: Decodable {
    let alerts: [Alert]
    let routes: [RouteDetail]
    let schoolAlertsSettings: [SchoolAlertsSettings]
}

struct Alert: Identifiable, Decodable {
    let id: String
    let active: Bool
    let text: String
    let clickable: Bool
    let action: String
    let fullWidth: Bool
    let color: String
    let rgb: RGBColor
    let order: Int
}

struct RGBColor: Decodable {
    let red, green, blue, opacity: Double
}

struct RouteDetail: Identifiable, Decodable {
    let title, origin, originLocation, destination, destinationLocation, city, state, id, uid: String
    let routeId: Int
    let coordinates: Coordinates
}

struct Coordinates: Decodable {
    let longitude, latitude: Double
}

struct SchoolAlertsSettings: Decodable {
    let id: String
    let active: Bool
    let clickable: Bool
    let action: String
    let fullWidth: Bool
    let color: String
    let rgb: RGBColor
    let order: Int
    let msgId: Int
}
