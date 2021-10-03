//
//  ProductCard.swift
//  FoodProductCard
//
//  Created by Jean-Marc Boullianne on 11/17/19.
//  Copyright © 2019 Jean-Marc Boullianne. All rights reserved.
//
import SwiftUI

struct RouteCard: View {
    
    @State var showRouteSheet = false
    
    var title:String    // Product Title
    var description:String // Product Description
    var route: LbRoute! // Instance of LbRoute to use for this card
    @ObservedObject var routeController: RouteController
    
    @State var timer = "Now"
    
    @State private var totalHeight
        //      = CGFloat.zero       // << variant for ScrollView/List
        = CGFloat.infinity   // << variant for VStack
    @Environment(\.colorScheme) var colorScheme
    
    init(title:String, description:String, route:LbRoute, routeController: RouteController) {
        self.title = title
        self.description = description
        self.route = route
        
        self.routeController = routeController
        
        self.timer = "Now"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Stack bottom half of card
            VStack(alignment: .leading) {
                
                HStack(alignment: .center) {
                    Text(self.title)
                        .font(Font.custom("HelveticaNeue", size: 18))
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundColor(Color.primary)
                    //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                    //.background(Color.white)
                    Spacer()
                    
                    VStack (alignment: .leading, spacing: 0) {
                        HStack(alignment: .center) {
                            Spacer()
                            Text("Next bus")
                                .font(Font.custom("HelveticaNeue", size: 12))
                                //.font(.subheadline)
                                //.fontWeight(.regular)
                                .foregroundColor(Color.gray)
                        }
                        HStack(alignment: .center) {
                            Spacer()
                            if (route.nextBusTimer == "Departing now") {
                                let delay = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { (delay) in
                                    self.timer = "Now" // Reset
                                }
                                Text(route.nextBusTimer)
                                    .font(Font.custom("HelveticaNeue", size: 13))
                                    //.font(.footnote)
                                    .padding([.leading, .trailing], 5)
                                    .padding([.top, .bottom], 2.5)
                                    .foregroundColor(Color.white)
                                    //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                    .background((routeController.deviceOnlineStatus == "offline") ?  Color.gray : Color.red)
                                    .cornerRadius(7)
                                    .padding([.top, .bottom], 4)
                            }
                            else if (route.nextBusTimer.contains("Now")) {
                                let delay = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (delay) in
                                    self.timer = route.nextBusTimer
                                    print("executed")
                                }
                                Text(timer)
                                    .font(Font.custom("HelveticaNeue", size: 13))
                                    //.fontWeight(.medium)
                                    //.font(.footnote)
                                    .padding([.leading, .trailing], 5)
                                    .padding([.top, .bottom], 2.5)
                                    .foregroundColor(Color.white)
                                    //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                    .background((routeController.deviceOnlineStatus == "offline") ?  Color.gray : Color.green)
                                    .cornerRadius(7)
                                    .padding([.top, .bottom], 4)
                            }
                            else {
                                let delay = Timer.scheduledTimer(withTimeInterval: 0, repeats: false) { (delay) in
                                    self.timer = "Now" // Reset
                                }
                                Text(route.nextBusTimer)
                                    .font(Font.custom("HelveticaNeue", size: 13))
                                    //.fontWeight(.medium)
                                    //.font(.footnote)
                                    .padding([.leading, .trailing], 5)
                                    .padding([.top, .bottom], 2.5)
                                    .foregroundColor(Color.white)
                                    //                            .background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                    .background((routeController.deviceOnlineStatus == "offline") ?  Color.gray : Color.blue)
                                    .cornerRadius(7)
                                    .padding([.top, .bottom], 4)
                            }
                        }
                    }
                    
                    .transition(.scale)
                    .animation(.default)
                }
                .padding([.top, .bottom], 8)
                
            }
            
            
        }
        .buttonStyle(PlainButtonStyle())
        .padding(12)
        
        //https://medium.com/@masamichiueta/bridging-uicolor-system-color-to-swiftui-color-ef98f6e21206
        .background(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.systemBackground))
        //        .background(colorScheme == .dark ?
        //                        (routeController.onlineStatus == "offline") ?  Color(UIColor.gray) : Color(UIColor.secondarySystemBackground) // dark
        //                        : (routeController.onlineStatus == "offline") ? Color(UIColor.gray) : Color(UIColor.systemBackground)) // light
        .cornerRadius(15)
        //.shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
        .onTapGesture {
            self.showRouteSheet = true
        }
        .sheet(isPresented: $showRouteSheet) {
            RouteSheet(route: self.route, routeController: self.routeController)
        }
    }
    
}

// Reference: https://medium.com/@masamichiueta/bridging-uicolor-system-color-to-swiftui-color-ef98f6e21206



//struct ProductCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RouteCard(title: "Gorecki to Sexton", description: "Gorecki Center", image: Image("Smoothie_Bowl"), price: 15.00, peopleCount: 2, ingredientCount: 2, category: "5 minutes", route: LbRoute(id: 0, title: "Test", times: [LbTime](), nextBusTimer: "5 mintutes", origin: "Gorecki", originLocation: "Gorecki Center, CSB", destination: "Sexton", destinationLocation: "Sexton Commons, SJU", city: "Collegeville", state: "Minnesota", coordinates: Coordinates(longitude: 0, latitude: 0)), buttonHandler: nil)
//    }
//}

struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        
        return path
    }
}

