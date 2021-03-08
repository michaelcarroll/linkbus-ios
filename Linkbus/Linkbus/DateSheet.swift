//
//  ChangeDateSheet.swift
//  Linkbus
//
//  Created by Alex Palumbo on 11/27/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI

struct DateSheet: View {
    @State private var selectedDate: Date
    @ObservedObject var routeController: RouteController
    @State private var showDatePicker = true
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    init(routeController: RouteController) {
        self.routeController = routeController
        if routeController.dateIsChanged {
            self._selectedDate = State<Date>(initialValue: routeController.selectedDate)
        }
        else {
            let now = Date()
            self._selectedDate = State<Date>(initialValue: now)
        }
    }
    
    private var dateProxy:Binding<Date> {
        Binding<Date>(get: {self.selectedDate }, set: {
            self.selectedDate = $0
            self.routeController.changeDate(selectedDate: self.selectedDate)
            // If this vvv is uncommeneted then date picker will collapse when a date is selected
            //self.isPresented.toggle()
            // If this vvv is uncommented then the sheet will close when a date is selected
            self.presentationMode.wrappedValue.dismiss()
            
        })
    }
    
    static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        
           
                // This VStack in charge of placing elements correctly, ScrollView won't on its own
                VStack(spacing: 14) {
                    //                    HStack {
                    //                        Text("Select Date")
                    //                            .bold()
                    //                            .font(.title)
                    //                        Spacer()
                    //                        Button(action: {
                    //                            self.presentationMode.wrappedValue.dismiss()
                    //                        }) {
                    //                            Text("Done")
                    //                        }
                    //                    }
                    VStack(alignment: .leading, spacing: 0) {
                        //                        Button(action: {
                        //                            withAnimation {
                        //                                self.showDatePicker.toggle()
                        //                            }
                        //                        }) {
                        //                            HStack{
                        //                                Text("\(self.selectedDate, formatter: Self.dateFormat)")
                        //                                Spacer()
                        //                                Image(systemName: "chevron.right.circle")
                        //                                    .imageScale(.large)
                        //                                    .rotationEffect(.degrees(showDatePicker ? 90 : 0))
                        //                                    .padding(.vertical)
                        //                            }
                        //                            .padding(.horizontal)
                        //                        }
                        if showDatePicker {
                            if #available(iOS 14.0, *) {
                                DatePicker(
                                    selection: dateProxy,
                                    in: Date()...,
                                    displayedComponents: .date,
                                    label:{ Text("Selected Date") }
                                )
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .datePickerStyle(GraphicalDatePickerStyle())
                                .padding(.horizontal)
                                //.padding(.top, 6)
                                .background((colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.secondarySystemBackground)))
                                .cornerRadius(15)
                                //.datePickerStyle(CompactDatePickerStyle())
                            } else {
                                DatePicker(
                                    selection: dateProxy,
                                    in: Date()..., // allows all dates in future, none in past
                                    displayedComponents: .date,
                                    label:{ Text("Selected Date") }
                                )
                                .labelsHidden()
                                .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                    }
                    //                    .overlay(
                    //                        RoundedRectangle(cornerRadius: 10)
                    //                            .stroke(Color.secondary, lineWidth: 1)
                    //                    )
                }
                .padding() // Padding for everything above the routes
            
        
        //.background(Color(UIColor.systemGroupedBackground)).edgesIgnoringSafeArea(.all)
    }
}

//    struct Info: View {
//        var body: some View {
//
//        }
//    }



//struct ChangeDate_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeDate()
//    }
//}
