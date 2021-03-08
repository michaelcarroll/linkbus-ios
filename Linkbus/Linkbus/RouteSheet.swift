//
//  RouteSheet.swift
//  Linkbus
//
//  Created by Michael Carroll on 8/25/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI

struct RouteSheet: View {
    @Environment(\.presentationMode) var presentationMode
    var route: LbRoute!
    
    @State private var totalHeight
        //      = CGFloat.zero       // << variant for ScrollView/List
        = CGFloat.infinity   // << variant for VStack
    
    @ObservedObject var routeController: RouteController
    
    init(route:LbRoute, routeController: RouteController) {
        self.route = route
        //UIScrollView.appearance().bounces = false
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = .clear
        UINavigationBar.appearance().backgroundColor = .clear
        
        self.routeController = routeController
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                RoundedRectangle(cornerRadius: CGFloat(5.0) / 2.0)
                    .frame(width: 60, height: 4)
                    .foregroundColor(Color(UIColor.systemGray2))
                    .padding([.top], 10)
                    .padding([.bottom], 5)
                
                ScrollView {
                    
                    VStack(alignment: .leading) {
                        
                        //                        RouteCard(title: route.title, description: route.originLocation, image: Image("Smoothie_Bowl"), price: 15.00, peopleCount: 2, ingredientCount: 2, category: "5 minutes", route: route, routeController: self.routeController, buttonHandler: nil)
                        //                            .transition(.scale)
                        //                            .animation(.easeInOut)
                        
                        // origin
                        HStack(alignment: .firstTextBaseline) {
                            Image(uiImage: UIImage(systemName: "smallcircle.fill.circle")!) //stop.circle.fill looks ok
                                .renderingMode(.template)
                                //.foregroundColor(Color(red: 43/255, green: 175/255, blue: 187/255))
                                .foregroundColor(Color.blue)
                                //.font(.subheadline) //weight: .ultralight))
                                .font(.system(size: 25))
                                .padding(.leading)
                            
                            
                            Text(route.origin)
                                .font(.system(size: 25))
                                .padding(.leading)
                            
                            Spacer()
                        }
                        .padding([.top], 5)
                        
                        //origin location
                        HStack(alignment: .firstTextBaseline) {
                            //dash indent?
                            //                    Image(uiImage: UIImage(systemName: "smallcircle.fill.circle")!)//systemName: "smallcircle.fill.circle") //stop.circle.fill looks ok
                            //                        .font(.headline)
                            //                        .padding(.leading)
                            Text("Pickup from " + route.originLocation)
                                .font(.system(size: 14))
                                .padding(.leading, 45) //fix
                                .padding(.leading)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        .padding([.bottom], 5)
                        
                        // ellipses
                        HStack(alignment: .firstTextBaseline) {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.degrees(90.0))
                                .font(.system(size: 20))
                                .padding(.leading)
                                .foregroundColor(Color.gray)
                        }
                        .padding([.top, .bottom], 5)
                        
                        // destination
                        HStack(alignment: .firstTextBaseline) {
                            Image(uiImage: UIImage(systemName: "mappin.circle.fill")!)
                                .renderingMode(.template)
                                //.foregroundColor(Color(red: 43/255, green: 175/255, blue: 187/255))
                                .foregroundColor(Color.blue)
                                //.font(.headline)
                                .font(.system(size: 25))
                                .padding(.leading)
                            Text(route.destination)
                                //.font(.title)
                                .font(.system(size: 25))
                                .padding(.leading)
                            Spacer()
                        }
                        .padding([.top], 5)
                        
                        //destination location
                        HStack(alignment: .lastTextBaseline) {
                            //                    Image(uiImage: UIImage(systemName: "smallcircle.fill.circle")!)//systemName: "smallcircle.fill.circle") //stop.circle.fill looks ok
                            //                        .font(.headline)
                            //                        .padding(.leading)
                            Text("Dropoff at " + route.destinationLocation)
                                //.font(.subheadline)
                                .font(.system(size: 14))
                                .padding(.leading, 45) //fix
                                .padding(.leading)
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                        
                    }
                    .padding(12)
                    
                    
                    Spacer()
                    
                    
                    
                    //Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        // route times
                        HStack(alignment: .lastTextBaseline) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(route.times, id: \.self) { time in
                                    HStack {
                                        if (route.nextBusTimer == "Departing now" && time.current) {
                                            Text(time.timeString)
                                                .font(Font.custom("HelveticaNeue", size: 12))
                                                .padding([.leading, .trailing], 10)
                                                .padding([.top, .bottom], 5)
                                                .foregroundColor(Color.white)
                                                //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                                .background(Color.red)
                                                .cornerRadius(7)
                                                .padding([.bottom], 5)
                                        }
                                        else if (route.nextBusTimer.contains("Now") && time.current) {
                                            Text(time.timeString)
                                                .font(Font.custom("HelveticaNeue", size: 12))
                                                .padding([.leading, .trailing], 10)
                                                .padding([.top, .bottom], 5)
                                                .foregroundColor(Color.white)
                                                //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                                .background(Color.green)
                                                .cornerRadius(7)
                                                .padding([.bottom], 5)
                                        }
                                        else if (routeController.localizedDescription == "The Internet connection appears to be offline.") ||
                                                    (routeController.csbsjuApiOnlineStatus == "CsbsjuApi invalid response") {
                                            Text(time.timeString)
                                                .font(Font.custom("HelveticaNeue", size: 12))
                                                .padding([.leading, .trailing], 10)
                                                .padding([.top, .bottom], 5)
                                                .foregroundColor(Color.white)
                                                //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                                .background(Color.gray)
                                                .cornerRadius(7)
                                                .padding([.bottom], 5)
                                        }
                                        else {
                                            Text(time.timeString)
                                                .font(Font.custom("HelveticaNeue", size: 12))
                                                .padding([.leading, .trailing], 10)
                                                .padding([.top, .bottom], 5)
                                                .foregroundColor(Color.white)
                                                //.background(Color(red: 43/255, green: 175/255, blue: 187/255))
                                                .background(Color.blue)
                                                .cornerRadius(7)
                                                .padding([.bottom], 5)
                                        }
                                        Spacer()
                                    }
                                }
//                                Button(action: { }, label: {
//                                    Text("View tomorrow's schedule")
//                                        .foregroundColor(.white)
//                                        .padding(12)
//                                        .font(Font.custom("HelveticaNeue", size: 14))
//                                        .frame(alignment: .leading)
//                                        .background(Color.green)
//                                        .cornerRadius(15)
//                                })
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(12)
                            .padding(.leading)
                        }
                        .padding(.leading)
                        .padding([.bottom], 5)
                        .transition(.opacity)
                        
                        
                        
                    }
                    .transition(.slide)
                    
                }
                
                
                .navigationBarTitle("", displayMode: .inline)
                .navigationBarHidden(true)
                
            }
            //.background(Color(UIColor.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
        }
        
    }
}



struct RouteSheet_Previews: PreviewProvider {
    static var previews: some View {
        RouteSheet(route: LbRoute(id: 0, title: "Gorecki to Sexton", times: [LbTime](), nextBusTimer: "5 minutes", origin: "Gorecki", originLocation: "Gorecki Center, CSB", destination: "Sexton", destinationLocation: "Sexton Commons, SJU", city: "Collegeville", state: "Minnesota", coordinates: Coordinates(longitude: 0, latitude: 0)), routeController: RouteController())
    }
}

