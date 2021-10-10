//
//  ProductCard.swift
//  FoodProductCard
//
//  Created by Jean-Marc Boullianne on 11/17/19.
//  Copyright © 2019 Jean-Marc Boullianne. All rights reserved.
//
import SwiftUI
import FontAwesome_swift

struct AlertCard: View {
    
    @State private var totalHeight
        //      = CGFloat.zero       // << variant for ScrollView/List
        = CGFloat.infinity   // << variant for VStack
    
    @State private var showingActionSheet = false
    
    @ObservedObject var routeController: RouteController
    
    let alertText: String
    let alertColor: Color
    let fullWidth: Bool
    let clickable: Bool
    let action: String
    
    init(alertText: String, alertColor: String, alertRgb: RGBColor, fullWidth: Bool, clickable: Bool, action: String, routeController: RouteController) {
        self.alertText = alertText
        
        let color: Color
        
        let colors = [
            "red": Color.red,
            "blue": Color.blue,
            "green": Color.green,
            "yellow": Color.yellow,
            "gray": Color.gray,
            "pink": Color.pink,
            "black": Color.black,
        ]
        
        // Use RGB when alertColor is empty
        if alertColor == "" {
            color = Color(
                red: alertRgb.red,
                green: alertRgb.green,
                blue: alertRgb.blue,
                opacity: alertRgb.opacity
            )
        } else {
            // Convert color string into Color Object
            // "red" => Color.red
            // Default to blue if color is not in array
            color = colors[alertColor] != nil ? colors[alertColor]! : Color.blue
        }
        
        
        self.alertColor = color
        self.fullWidth = fullWidth
        self.clickable = clickable
        self.action = action
        
        self.routeController = routeController
    }
    
    var body: some View {
        Group(){
            if !clickable {
                Text(alertText)
                    .foregroundColor(Color.white)
                    .padding(12)
                    .font(Font.custom("HelveticaNeue", size: 14))
                    .frame(maxWidth: self.fullWidth ? .infinity : nil, alignment: .leading)
                    .background(alertColor)
                    .cornerRadius(15)
            }
            else {
                Button(action: {
                    if (action == "webRequest") {
                        self.routeController.webRequest()
                    }
                    else if (action == "resetDate") {
                        self.routeController.resetDate()
                    }
                    else if (action == "changeDateTomorrow") {
                        let today = Date()
                        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
                        self.routeController.changeDate(selectedDate: tomorrow)
                    }
                    else if (action == "uber") {
                        
                    }
                    else if (action == "lyft") {
                        
                    }
                    else {
                        self.showingActionSheet = true
                    }
                },
                label: {
                    if (action == "uber") {
                        Text("Order Uber")
                            .foregroundColor(.white)
                            .font(Font.custom("HelveticaNeue", size: 14))
                        Text(String.fontAwesomeIcon(name: .uber))
                            .foregroundColor(.white)
                            .font(Font(UIFont.fontAwesome(ofSize: 16, style: .brands)))
                    }
                    else if (action == "lyft") {
                        Text("Order")
                            .foregroundColor(.white)
                            .font(Font.custom("HelveticaNeue", size: 14))
                        Text(String.fontAwesomeIcon(name: .lyft))
                            .foregroundColor(.white)
                            .font(Font(UIFont.fontAwesome(ofSize: 18, style: .brands)))
                    }
                    else {
                        Text(alertText)
                            .foregroundColor(.white)
                            .font(Font.custom("HelveticaNeue", size: 14))
                        if (action.contains("http")) {
                            Text(String.fontAwesomeIcon(name: .externalLinkAlt))
                                .foregroundColor(.white)
                                .font(Font(UIFont.fontAwesome(ofSize: 10, style: .solid)))
                        }
                    }
                })
                .padding(12)
                .frame(maxWidth: self.fullWidth ? .infinity : nil, alignment: .leading)
                .background(alertColor)
                .cornerRadius(15)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(Color.white, lineWidth: 1)
//                )
                //.animation(.default)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .actionSheet(isPresented: $showingActionSheet) {
            ActionSheet(title: Text(action), buttons: [
                .default(Text("Open in Browser")) { UIApplication.shared.open(URL(string: action)!) },
                .cancel()
            ])
        }
        // .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 2)
        // https://medium.com/@masamichiueta/bridging-uicolor-system-color-to-swiftui-color-ef98f6e21206
    }
    
}

//struct AlertCard_Previews: PreviewProvider {
//    static var previews: some View {
//        AlertCard(alertText: "A face mask is required to ride the CSB/SJU Link.",
//                  alertColor: "red",
//                  alertRgb: RGBColor(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.0),
//                  fullWidth: false,
//                  clickable: false,
//                  action: "",
//                  routeController: nil
//        )
//    }
//}



