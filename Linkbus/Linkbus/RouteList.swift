/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A view showing a list of landmarks.
 */

import SwiftUI
import Foundation
import Combine

struct RouteList: View {
    @ObservedObject var routeController: RouteController
    
    init(routeController: RouteController) {
        self.routeController = routeController
    }
    
    var body: some View {
        if #available(iOS 14.0, *) {
            LazyVStack (alignment: .leading, spacing: 12) {
                Routes(routeController: self.routeController)
            }
            .padding(.horizontal, 12)
            .transition(.scale)
            .animation(.default)
            .padding(.top, 4)
        } else {
            VStack (alignment: .leading, spacing: 12) {
                Routes(routeController: self.routeController)
            }
            .transition(.opacity)
            .animation(.default)
            //.animation(.default)
            //.transition(.opacity)
            //.listRowBackground((colorScheme == .dark ? Color(UIColor.systemBackground) : Color(UIColor.systemGray6)))
        }
    }
}

struct Routes: View {
    @ObservedObject var routeController: RouteController
    init(routeController: RouteController) {
        self.routeController = routeController
    }
    var body: some View {
        ForEach(routeController.lbBusSchedule.routes) { route in
            if (routeController.localizedDescription == "The Internet connection appears to be offline.") {
                // TODO: Get rid of the old values like image and price
                RouteCard(title: route.title, description: route.originLocation, route: route, routeController: self.routeController)
            }
            else {
                RouteCard(title: route.title, description: route.originLocation, route: route, routeController: self.routeController)
            }
        }
        // .hoverEffect(.lift)
        .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
    }
}

//struct LandmarkList_Previews: PreviewProvider {
//    static var previews: some View {
//        ForEach(["iPhone XS Max"], id: \.self) { deviceName in
//            RouteList()
//                .previewDevice(PreviewDevice(rawValue: deviceName))
//                .previewDisplayName(deviceName)
//        }
//    }
//}

// TRANSLUCENT MENU BAR TETING....
//extension UINavigationController {
//    override open func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        let appearance = UINavigationBarAppearance()
//        appearance.configureWithOpaqueBackground()
//        navigationBar.standardAppearance = appearance
//        navigationBar.compactAppearance = appearance
//        navigationBar.scrollEdgeAppearance = appearance
//    }
//}
