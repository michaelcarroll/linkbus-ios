//
//  AlertList.swift
//  Linkbus
//
//  Created by Alex Palumbo on 11/1/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI

struct AlertList: View {
    
    @ObservedObject var routeController: RouteController
    
    init(routeController: RouteController) {
        self.routeController = routeController
    }
    
    var body: some View {
        
        if #available(iOS 14.0, *) {
            VStack (alignment: .leading, spacing: 12) {
                Alerts(routeController: self.routeController)
            }
            .padding(.top, 4)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .transition(.opacity)
            .animation(.default)
            //.listRowBackground((colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGray6)))
        } else { // iOS 13
            VStack(alignment: .leading, spacing: 12){
                Alerts(routeController: self.routeController)
            }
            .transition(.opacity)
            .animation(.default)
        }
    }
}

struct Alerts: View {
    @ObservedObject var routeController: RouteController
    init(routeController: RouteController) {
        self.routeController = routeController
    }
    var body: some View {
        if (routeController.localizedDescription == "The Internet connection appears to be offline.") {
            AlertCard(alertText: "⚠️ No internet connection. Tap to retry.", alertColor: "red", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: true, clickable: true, action: "webRequest", routeController: routeController)
            AlertCard(alertText: "Or, tap here to try the bus schedule website.", alertColor: "blue", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: true, clickable: true, action: "https://apps.csbsju.edu/busschedule/", routeController: routeController)
        }
        if (routeController.deviceOnlineStatus == "back online") {
            AlertCard(alertText: "Back online. 🥳", alertColor: "blue", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: false, clickable: false, action: "", routeController: routeController)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        routeController.deviceOnlineStatus = "online"
                    }
                }
        }
        if (routeController.csbsjuApiOnlineStatus == "CsbsjuApi invalid response" || routeController.localizedDescription == "The request timed out.") {
            AlertCard(alertText: "⚠️ CSB/SJU servers appear to be offline. Tap to retry.", alertColor: "red", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: true, clickable: true, action: "webRequest", routeController: routeController)
            AlertCard(alertText: "Or, tap here to try the bus schedule website.", alertColor: "blue", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: true, clickable: true, action: "https://apps.csbsju.edu/busschedule/", routeController: routeController)
        }
        if (routeController.dateIsChanged) {
            //AlertCard(alertText: "Viewing schedule for a future date", alertColor: "blue", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: false, clickable: false, action: "", routeController: routeController)
            AlertCard(alertText: "⬅ Back to today's schedule", alertColor: "blue", alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0), fullWidth: false, clickable: true, action: "resetDate", routeController: routeController)
        }
//        let currentDate = Date()
//        let calendar = Calendar(identifier: .gregorian)
//        let hour = calendar.component(.hour, from: currentDate)
//        if (hour >= 23 && !routeController.dateIsChanged && routeController.deviceOnlineStatus != "offline") {
//            AlertCard(alertText: "View tomorrow's schedule 🌚", alertColor: "blue", alertRgb: RGBColor(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0), fullWidth: false, clickable: true, action: "changeDateTomorrow", routeController: routeController)
//        }
        ForEach(routeController.lbBusSchedule.alerts) { alert in
            if (routeController.localizedDescription == "The Internet connection appears to be offline.") {
                AlertCard(alertText: alert.text, alertColor: "gray", alertRgb: alert.rgb, fullWidth: alert.fullWidth, clickable: alert.clickable, action: alert.action, routeController: routeController)
            }
            else {
                AlertCard(alertText: alert.text, alertColor: alert.color, alertRgb: alert.rgb, fullWidth: alert.fullWidth, clickable: alert.clickable, action: alert.action, routeController: routeController)
            }
            //.transition(.opacity)
        }
//        let currentDate = Date()
//        let calendar = Calendar(identifier: .gregorian)
//        let time = calendar.dateComponents([.hour, .minute, .month, .weekday], from: currentDate)
//        if (time.hour! == 2 && time.minute! <= 45 && (time.weekday == 7 || time.weekday == 1) && time.month != 6 && time.month != 7 && time.month != 8) {
//            if (!routeController.dateIsChanged && routeController.deviceOnlineStatus != "offline") { // IMPORTANT: these alerts have a weird animation bug if allowed to appear right at app launch. Possible fix is to add routeController.initialWebRequestFinished to above if {}. Any alerts that are not dependent on network should check initialWebReuqestFinished and deviceOnlineStatus.
//                AlertCard(alertText: "The last bus has already left. Please be responsible:", alertColor: "blue", alertRgb: RGBColor(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0), fullWidth: false, clickable: false, action: "", routeController: routeController)
//                AlertCard(alertText: "", alertColor: "black", alertRgb: RGBColor(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0), fullWidth: false, clickable: true, action: "uber", routeController: routeController)
//                AlertCard(alertText: "", alertColor: "pink", alertRgb: RGBColor(red: 0.2, green: 0.2, blue: 0.2, opacity: 1.0), fullWidth: false, clickable: true, action: "lyft", routeController: routeController)
//            }
//        }
        //.listRowBackground((colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGray6)))
    }
}

//struct AlertList_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertList()
//    }
//}
