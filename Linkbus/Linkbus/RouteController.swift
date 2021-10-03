//
//  NetworkController.swift
//  Linkbus
//
//  Created by Michael Carroll on 8/23/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import SwiftUI
import SwiftSoup

class RouteController: ObservableObject {
    let CsbsjuApiUrl = "https://apps.csbsju.edu/busschedule/api"
    let LinkbusApiUrl = "https://us-central1-linkbus-website.cloudfunctions.net/api" // Production API
    //let LinkbusApiUrl = "https://us-central1-linkbus-website-development.cloudfunctions.net/api" // Development API
    
    var csbsjuApiResponse = BusSchedule(msg: "", attention: "", routes: [Route]())
    var linkbusApiResponse = LinkbusApi(alerts: [Alert](), routes: [RouteDetail](), schoolAlertsSettings: [SchoolAlertsSettings]())
    
    @Published var lbBusSchedule = LbBusSchedule(msg: "", attention: "", alerts: [Alert](), routes: [LbRoute]())
    @Published var refreshedLbBusSchedule = LbBusSchedule(msg: "", attention: "", alerts: [Alert](), routes: [LbRoute]())
    @Published var localizedDescription = ""
    @Published var deviceOnlineStatus = ""
    @Published var csbsjuApiOnlineStatus = ""
    
    public var webRequestInProgress = false
    public var initalWebRequestFinished = false // Used by main view
    public var webRequestIsSlow = false
    
    private var busMessages = [String]()
    private var campusAlert = ""
    private var campusAlertLink = ""
    
    public var selectedDate = Date()
    public var dateIsChanged = false;
    
    init() {
        webRequest()
    }
}

extension RouteController {
    
    /**
     Changes the selected date. Called when the date is changed on the select date view.
     */
    func changeDate(selectedDate: Date) {
        let isSelectedDateToday = Calendar.current.isDateInToday(selectedDate)
        if isSelectedDateToday {
            resetDate()
        }
        else {
        self.selectedDate = selectedDate
        print(selectedDate)
        self.dateIsChanged = true
        self.lbBusSchedule = LbBusSchedule(msg: "", attention: "", alerts: [Alert](), routes: [LbRoute]()) // see below
        webRequest() // doing a full webRequest here so that it clears the arrays, if it doesn't the animation is not smooth when switching dates. Also the extra time a full webRequest takes makes the animation more pleasant... although caching while switching days can also ruin the animation
        }
    }
    
    /**
     Resets routes and loads todays routes
     */
    func resetDate() {
        if self.dateIsChanged {
            self.lbBusSchedule.routes = []
            self.selectedDate = Date()
            self.lbBusSchedule = LbBusSchedule(msg: "", attention: "", alerts: [Alert](), routes: [LbRoute]())
            webRequest()
            dateIsChanged = false
        }
    }
    
    /**
     Fetches routes from CSB/SJU API and updates the routes.
     */
    func routesWebRequest() {
        self.refreshedLbBusSchedule.routes = []
        // Grab the most up to date routes
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        fetchCsbsjuApi { apiResponse in
            DispatchQueue.main.async {
                if apiResponse != nil {
                    self.csbsjuApiResponse = apiResponse!
                    self.csbsjuApiOnlineStatus = "online"
                } else {
                    self.csbsjuApiOnlineStatus = "CsbsjuApi invalid response"
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.processRoutes()
            self.lbBusSchedule.routes = self.refreshedLbBusSchedule.routes
        }
    }
    
    func webRequest() {
        
        if webRequestInProgress == false {
            // Show the loading indicator after the Linkbus API takes more than 1 second to respond
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
                if self.webRequestInProgress {
                    print("Web request is taking more than a second")
                    self.webRequestIsSlow = true
                }
            }
            
            webRequestInProgress = true
            self.localizedDescription = "default"
            
            csbsjuApiResponse = BusSchedule(msg: "", attention: "", routes: [Route]())
            linkbusApiResponse = LinkbusApi(alerts: [Alert](), routes: [RouteDetail](), schoolAlertsSettings: [SchoolAlertsSettings]())
            refreshedLbBusSchedule = LbBusSchedule(msg: "", attention: "", alerts: [Alert](), routes: [LbRoute]())
            
            // TODO: Load CSB/SJU API as one group and our API plus daily message requests as another group.
            // We can then display routes when they load and displays alerts after, once they load.
            // Route data from our API can be injected into routes after the fact.
            
            let dispatchGroup = DispatchGroup()
            
            // CSBSJU API
            dispatchGroup.enter()
            fetchCsbsjuApi { apiResponse in
                DispatchQueue.main.async {
                    if apiResponse != nil {
                        self.csbsjuApiResponse = apiResponse!
                        self.csbsjuApiOnlineStatus = "online"
                    } else {
                        self.csbsjuApiOnlineStatus = "CsbsjuApi invalid response"
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Daily message alert
            // Website does not always have a message
            dispatchGroup.enter()
            fetchBusMessage { response in
                DispatchQueue.main.async {
                    if response != nil {
                        self.busMessages = response!
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Campus alert
            dispatchGroup.enter()
            fetchCampusAlert { response in
                DispatchQueue.main.async {
                    if response != nil {
                        self.processCampusAlert(data: response!)
                    }
                    dispatchGroup.leave()
                }
            }
            
            // Linkbus API that connects to website
            dispatchGroup.enter()
            fetchLinkbusApi { apiResponse in
                DispatchQueue.main.async {
                    if apiResponse != nil {
                        self.linkbusApiResponse = apiResponse!
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.processRoutesAndAlerts()
            }
        }
        
    }
    
    func fetchCsbsjuApi(completionHandler: @escaping (BusSchedule?) -> Void) {
        var urlString = ""
        if self.dateIsChanged {
            // Format date object into string e.g. 10/23/20
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            let formattedDate = formatter.string(from: selectedDate)
            // Add date to URL
            urlString = CsbsjuApiUrl + "?date=" + formattedDate
        } else {
            urlString = CsbsjuApiUrl
        }
        let url = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    self.localizedDescription = error.localizedDescription
                    print("Localized desc:" + self.localizedDescription)
                    self.deviceOnlineStatus = "offline"
                    self.webRequestInProgress = false
                    self.webRequestIsSlow = false
                }
                print("Error with fetching bus schedule from CSBSJU API: \(error)")
                return
            }
            else {
                DispatchQueue.main.async {
                    if self.deviceOnlineStatus == "offline" {
                        self.deviceOnlineStatus = "back online"
                    }
                    else if self.deviceOnlineStatus == "back online" {
                        self.deviceOnlineStatus = "online"
                    }
                    else {
                        self.deviceOnlineStatus = "online"
                    }
                    self.localizedDescription = "no error"
                    
                }
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                DispatchQueue.main.async {
                    self.csbsjuApiOnlineStatus = "CsbsjuApi invalid response"
                }
                return
            }
            do {
                let apiResponse = try JSONDecoder().decode(BusSchedule.self, from: data!)
                completionHandler(apiResponse)
            } catch {
                print("Error decoding CSB/SJU API!")
                completionHandler(nil)
            }
        })
        task.resume()
    }
    
    /**
     Fetches the bus schedule website html that contains the bus message, seen here  https://apps.csbsju.edu/busschedule/
     After fetching the data, processBusMessage() is called to parse the data into just the bus message string.
     - Parameter completionHandler: The callback function to be executed on successful fetching of website html.
     
     - Returns: calls completion handler with bus message as argument or returns nill on error.
     */
    func fetchBusMessage(completionHandler: @escaping ([String]?) -> Void) {
        let url = URL(string: "https://apps.csbsju.edu/busschedule/default.aspx")
        // Create request
        var request = URLRequest(url: url!)
        // Set http method
        request.httpMethod = "POST"
        // Add body (form data)
        var postString = ""
        // Allows for date to be changed. We probably won't ever want to use this.
        //        let specifyData = false
        //        if specifyData {
        //            let date = "9/20/2020"
        //            let dateEncoded = date.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        //            postString += "ctl00%24BodyContent%24BusSchedule%24SelectedDate=" + dateEncoded!
        //        }
        postString += "&__VIEWSTATE=%2FwEPDwUJMjUxNjA1NzE0ZBgGBUpjdGwwMCRCb2R5Q29udGVudCRCdXNTY2hlZHVsZSRSZXBlYXRlclRvZGF5Um91dGVzJGN0bDAyJEdyaWRWaWV3VG9kYXlUaW1lcw88KwAMAQgCAWQFSmN0bDAwJEJvZHlDb250ZW50JEJ1c1NjaGVkdWxlJFJlcGVhdGVyVG9kYXlSb3V0ZXMkY3RsMDQkR3JpZFZpZXdUb2RheVRpbWVzDzwrAAwBCAIBZAVKY3RsMDAkQm9keUNvbnRlbnQkQnVzU2NoZWR1bGUkUmVwZWF0ZXJUb2RheVJvdXRlcyRjdGwwMSRHcmlkVmlld1RvZGF5VGltZXMPPCsADAEIAgFkBUpjdGwwMCRCb2R5Q29udGVudCRCdXNTY2hlZHVsZSRSZXBlYXRlclRvZGF5Um91dGVzJGN0bDAzJEdyaWRWaWV3VG9kYXlUaW1lcw88KwAMAQgCAWQFSmN0bDAwJEJvZHlDb250ZW50JEJ1c1NjaGVkdWxlJFJlcGVhdGVyVG9kYXlSb3V0ZXMkY3RsMDAkR3JpZFZpZXdUb2RheVRpbWVzDzwrAAwBCAIBZAVKY3RsMDAkQm9keUNvbnRlbnQkQnVzU2NoZWR1bGUkUmVwZWF0ZXJUb2RheVJvdXRlcyRjdGwwNSRHcmlkVmlld1RvZGF5VGltZXMPPCsADAEIAgFkWGh%2B6w%2BaUlr4YOYVCBNBCh%2FBBLI%3D"
        postString += "&__VIEWSTATEGENERATOR=9BAD42EF"
        postString += "&__EVENTVALIDATION=%2FwEdAAJuu0YtVtaTDWfPQnmvmzb0LRHL%2FnpThEIWeX7N%2BkLIDZtqPuTRCdRUPrjcObmvVnKFIOev"
        postString += "&__ASYNCPOST=true"
        request.httpBody = postString.data(using: .utf8)
        // Add headers
        request.setValue("Delta=true", forHTTPHeaderField: "X-MicrosoftAjax")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        request.setValue("Mozilla/5.0 (Android 8.0)", forHTTPHeaderField: "User-Agent")
        // Create url session to send request
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching daily message: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            // Process HTML into data we care about, the "daily message"
            let dailyMessage = self.processBusMessage(data: data!)
            completionHandler(dailyMessage)
        })
        task.resume()
    }
    
    /**
     Processes the daily message website HTML into just the Bus message string.
     - Parameter data: The fetched bus schedule website HTML.
     
     - Returns: Bus message string or empty string.
     */
    func processBusMessage(data: Data) -> [String] {
        // Use regex to parse HTML for daily message within p tag
//        print("processBusMessage")
//        print(data)
        let dataString = String(decoding: data, as: UTF8.self)
//        let end = dataString.prefix(500)
        let dataSubString = String(dataString.prefix(500))
//        print(dataSubString)
        var busMessages = [String]()
        do {
            let doc: Document = try SwiftSoup.parse(dataSubString)
            let link: Elements = try doc.select("p")
//            print("OUT:")
            for element in link {
                busMessages.append(try element.text())
            }
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
        return busMessages
//        let pattern = #"TodayMsg"><p>([^<]*)<\/p>"#
//        let regex = try? NSRegularExpression(pattern: pattern)
//        let searchRange = NSRange(location: 0, length: dataString.utf16.count)
//        if let match = regex?.firstMatch(in: dataString, options: [], range: searchRange) {
//            if let secondRange = Range(match.range(at: 1), in: dataString) {
//                let dailyMessage = String(dataString[secondRange])
//                return dailyMessage
//            }
//        }
        // Return empty string if regex does not work
//        return ""
    }

    /**
     Fetches the csbsju.com html and parses into the campus alert message text and link
     - Parameter completionHandler:The callback function to be executed on successful fetching of website html.
     
     - Returns: calls completion handler with campus alert as argument or returns on error.
     */
    func fetchCampusAlert(completionHandler: @escaping (Data?) -> Void) {
        let url = URL(string: "https://csbsju.edu/")
        // Create request
        let request = URLRequest(url: url!)
        // Create url session to send request
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching daily message: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                DispatchQueue.main.async {
                    self.deviceOnlineStatus = "offline"
                    self.csbsjuApiOnlineStatus = "CsbsjuApi invalid response" // adding this to the campus alert fetch since if csbsju.edu is down the bus api likely is too, for some reason this isn't hit in the fetchCsbsjuApi method during a timeout
                    
                }
                return
            }
            // Process HTML into data we care about, the "daily message"
            completionHandler(data)
        })
        task.resume()
    }

    /**
     Processes the csbaju.com html into the campus alert text and link strings.
     - Parameter data: The fetched bus schedule website HTML.
     */
    func processCampusAlert(data: Data) -> Void {
        // Use regex to parse HTML
        let dataString = String(decoding: data, as: UTF8.self)
        let pattern = #"CampusAlert"><h5>(?><a href="([^"]+?)"[^>]*?>([^<]+?)<|([^<]+?)<)"#
        // Capture both text and link or just text if no link
        var regex: NSRegularExpression
            do {
                regex = try NSRegularExpression(pattern: pattern)
            } catch {
                return
            }
        let searchRange = NSRange(location: 0, length: dataString.utf16.count)
        let matches = regex.matches(in: dataString, options: [], range: searchRange)
        guard let match = matches.first else { return }
        if match.numberOfRanges > 2 {
            let lastRangeIndex = match.numberOfRanges - 2
            // Two groups captured
            if lastRangeIndex > 1 {
                // 1st capture group: Link of Campus Alert
                var capturedGroupIndex = match.range(at: 1)
                var matchedString = (dataString as NSString).substring(with: capturedGroupIndex)
                self.campusAlertLink = matchedString
                // 2st capture group: Text of Campus Alert
                capturedGroupIndex = match.range(at: 2)
                matchedString = (dataString as NSString).substring(with: capturedGroupIndex)
                self.campusAlert = matchedString
            // One goup captured
            } else {
                // 1st capture group: Text of Campus Alert
                let capturedGroupIndex = match.range(at: 1)
                let matchedString = (dataString as NSString).substring(with: capturedGroupIndex)
                self.campusAlert = matchedString
            }
        }
    }
    
    /**
     Fetches the Linkbus API json data including the alerts and additional route info.
     - Parameter completionHandler: The callback function to be executed on successful fetching of API json data.
     
     - Returns: calls completion handler with the API response as argument or returns nill on error.
     */
    func fetchLinkbusApi(completionHandler: @escaping (LinkbusApi?) -> Void) {
        let url = URL(string: LinkbusApiUrl)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching bus schedule from Linkbus API: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error with the response, unexpected status code: \(String(describing: response))")
                return
            }
            do {
                let apiResponse = try JSONDecoder().decode(LinkbusApi.self, from: data!)
                completionHandler(apiResponse)
            } catch {
                print("Error decoding Linkbus API!")
                completionHandler(nil)
            }
        })
        task.resume()
    }
    
    func processRoutesAndAlerts() {
        //print(apiBusSchedule.routes?.count)
        //let busSchedule = BusSchedule(msg: apiBusSchedule.msg!, attention: apiBusSchedule.attention!, routes: apiBusSchedule.routes!)
        
        // Store msg and attention from the CSB/SJU API
        // We're not using either of these curretly
        if(csbsjuApiResponse.msg != nil){
            refreshedLbBusSchedule.msg = csbsjuApiResponse.msg!
        }
        else { refreshedLbBusSchedule.msg = "" }
        if(csbsjuApiResponse.attention != nil){
            refreshedLbBusSchedule.attention = csbsjuApiResponse.attention!
        }
        // Already set to empty string, see refreshedLbBusSchedule declaration
        else { refreshedLbBusSchedule.attention = "" }
        
        // Create all the alerts
        processAlerts()
        
        // Create all the routes
        processRoutes()
        
        // Set the bus routes and alert data to the newly refreshed data
        lbBusSchedule = refreshedLbBusSchedule
        
        //        if (lbBusSchedule.routes.count > 0) {
        //            var iterator = lbBusSchedule.routes[0].times.makeIterator()
        //            while let time = iterator.next() {
        //                print(time.timeString)
        //            }
        //        }
        
        self.webRequestInProgress = false
        self.webRequestIsSlow = false
        // Only change this once
        if(!self.initalWebRequestFinished){
            self.initalWebRequestFinished = true
        }
    }
    
    /**
     Creates all the alerts
     */
    func processAlerts() {
//        print("processAlerts")
        for apiAlert in linkbusApiResponse.alerts {
            if (apiAlert.active) {
                refreshedLbBusSchedule.alerts.append(apiAlert)
            }
        }
        
        // Adds Campus Alert and Bus Message alerts
        addSchoolMessageAlerts()
        
        // Order the alerts
        refreshedLbBusSchedule.alerts = refreshedLbBusSchedule.alerts.sorted(by: { $0.order < $1.order });
    }
    
    /**
     Creates alerts out of the campus alert and bus message if they are valid.
     */
    func addSchoolMessageAlerts() {
        if linkbusApiResponse.schoolAlertsSettings.count == 2 {
            // Create alert from bus message
            // Only add alert if message is not empty string and is valid
            if self.busMessages.count > 0 {
                // Find the setting which has msgId 0 meaning bus message settings
                let index = linkbusApiResponse.schoolAlertsSettings.firstIndex(where: {$0.msgId == 0})
                let busMessageSettings = linkbusApiResponse.schoolAlertsSettings[index!]
                // Only render if active
                if(busMessageSettings.active) {
                    print("Bus messages:")
                    var i = 1;
                    for message in self.busMessages {
                        print(message)
                        // Make sure the message has a length greater than 5 and less than 70
                        if message.count > 10 && message.count < 70 {
                            // Create alert using website settings
//                            print(busMessageSettings.id)
//                            print(busMessageSettings.order)
                            let dailyMessageAlert = Alert(id: busMessageSettings.id+String(i), active: busMessageSettings.active, text: message,
                                                      clickable: busMessageSettings.clickable, action: busMessageSettings.action,
                                                      fullWidth: busMessageSettings.fullWidth, color: busMessageSettings.color,
                                                      rgb: busMessageSettings.rgb, order: busMessageSettings.order - i)
                            refreshedLbBusSchedule.alerts.append(dailyMessageAlert)
                        }
                        i += 1;
                    }
                }
            }
            
            // Create alert from campus alert
            // Only add alert if message is not empty string and is valid
            if self.campusAlert != "" && self.campusAlert.firstIndex(of: ">") == nil  && self.campusAlert.firstIndex(of: "<") == nil && self.campusAlert.count < 100 {
                // Find the setting which has msgId 1 meaning campus alert settings
                let index = linkbusApiResponse.schoolAlertsSettings.firstIndex(where: {$0.msgId == 1})
                let campusAlertSettings = linkbusApiResponse.schoolAlertsSettings[index!]
                // Only render if active
                if(campusAlertSettings.active) {
                    // If link was found then add action to alert
                    var action = ""
                    var clickable = false
                    if(self.campusAlertLink != "") {
                        action = self.campusAlertLink
                        clickable = true
                    }
                    // Create alert using website settings
//                    print(campusAlertSettings.order)
                    let campusAlertAlert = Alert(id: campusAlertSettings.id, active: campusAlertSettings.active, text: self.campusAlert,
                                              clickable: clickable, action: action,
                                              fullWidth: campusAlertSettings.fullWidth, color: campusAlertSettings.color,
                                              rgb: campusAlertSettings.rgb, order: campusAlertSettings.order)
                    refreshedLbBusSchedule.alerts.append(campusAlertAlert)
                }
            } else {
                print("Bad campus alert")
            }
        }
    }
    
    /**
     Creates all the routes from CSB/SJU API
     */
    func processRoutes() {
//        print("processRoutes")
        if (!csbsjuApiResponse.routes!.isEmpty) {
            for apiRoute in csbsjuApiResponse.routes! {
                var tempRoute = LbRoute(id: 0, title: "", times: [LbTime](), nextBusTimer: "", origin: "", originLocation: "", destination: "", destinationLocation: "", city: "", state: "", coordinates: Coordinates(longitude: 0, latitude: 0))
                tempRoute.id = apiRoute.id!
                tempRoute.title = apiRoute.title!
                var tempTimes = [LbTime]()
                
                var tempId = 0
                for apiTime in apiRoute.times! {
                    // process new time structure
                    if (apiTime.start != "") {
                        // There two aren't being used
                        let isoStartDate = apiTime.start
                        let isoEndDate = apiTime.end
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy h:mm:ss a"
                        dateFormatter.timeZone = TimeZone(identifier: "America/Central")
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        let startDate = dateFormatter.date(from:isoStartDate!)!
                        let endDate = dateFormatter.date(from:isoEndDate!)!
                        
                        // current time - 1 min so that a bus at 5:30:00 still appears in app if currentTime is 5:30:01
                        let calendar = Calendar.current
                        let date = Date()
                        let currentDate = calendar.date(byAdding: .minute, value: -1, to: date)
                        if (endDate >= currentDate!) { // make sure end date is not in the past, if true skip add
                            
                            var current = false
                            if (startDate <= Date()) {
                                current = true
                            }
                            
                            let textFormatter = DateFormatter()
                            textFormatter.dateFormat = "h:mm a"
                            
                            let timeString: String = (textFormatter.string(from: startDate) + " - " + (textFormatter.string(from: endDate)))
                            
                            tempId+=1
                            tempTimes.append(LbTime(id: tempId, startDate: startDate, endDate: endDate, timeString: timeString, hasStart: true, lastBusClass: apiTime.lbc!, ss: apiTime.ss!, current: current))
                        }
                    } else {
                        let isoDate = apiTime.end
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy h:mm:ss a"
                        dateFormatter.timeZone = TimeZone(identifier: "America/Central")
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        let endDate = dateFormatter.date(from:isoDate!)!
                        let startDate = endDate
                        
                        // current time + 1 min so that a bus at 5:30:00 still appears in app if currentTime is 5:30:01
                        let calendar = Calendar.current
                        let date = Date()
                        let currentDate = calendar.date(byAdding: .minute, value: -1, to: date)
                        
                        if (endDate >= currentDate!) { // make sure end date is not in the past, if true skip add
                            
                            var current = false
                            if (startDate <= Date()) {
                                current = true
                            }
                            
                            let textFormatter = DateFormatter()
                            textFormatter.dateFormat = "h:mm a"
                            
                            let timeString: String = (textFormatter.string(from: endDate))
                            
                            
                            tempId+=1
                            tempTimes.append(LbTime(id: tempId, startDate: startDate, endDate: endDate, timeString: timeString, hasStart: false, lastBusClass: apiTime.lbc!, ss: apiTime.ss!, current: current))
                        }
                    }
                }
                
                if (tempTimes.count > 0) {
                    
                    tempRoute.times = tempTimes
                    
                    // TODO: add in Linkbus API route data
                    if let i = linkbusApiResponse.routes.firstIndex(where: {$0.routeId == tempRoute.id}) {
                        tempRoute.origin = linkbusApiResponse.routes[i].origin
                        tempRoute.originLocation = linkbusApiResponse.routes[i].originLocation
                        tempRoute.destination = linkbusApiResponse.routes[i].destination
                        tempRoute.destinationLocation = linkbusApiResponse.routes[i].destinationLocation
                        tempRoute.city = linkbusApiResponse.routes[i].city
                        tempRoute.state = linkbusApiResponse.routes[i].state
                        tempRoute.coordinates = linkbusApiResponse.routes[i].coordinates
                    }
//                    print(linkbusApiResponse.routes)
                    
                    // next bus timer logic:
                    
                    let nextBusStart = tempRoute.times[0].startDate
                    let nextBusEnd = tempRoute.times[0].endDate
                    
                    //https://stackoverflow.com/a/41640902
                    let formatter = DateComponentsFormatter()
                    formatter.unitsStyle = .full
                    formatter.allowedUnits = [.month, .day, .hour, .minute]
                    formatter.maximumUnitCount = 2   // often, you don't care about seconds if the elapsed time is in months, so you'll set max unit to whatever is appropriate in your case
                    let timeDifference = formatter.string(from: Date(), to: nextBusStart.addingTimeInterval(60))! //adds 60 seconds to round up
                    var nextBusTimer: String
                    
                    if (nextBusStart != nextBusEnd) && (Date() > nextBusStart) && (Date() < nextBusEnd) { // in a range
                        //                    if Date() >= nextBusEnd {
                        //                        nextBusTimer = "Departing now"
                        //                    }
                        //else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "h:mm a"
                        dateFormatter.timeZone = TimeZone(identifier: "America/Central")
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                        let nextBusTime = dateFormatter.string(from: nextBusEnd)
                        nextBusTimer = "Now until " + nextBusTime
                        //}
                    }
                    else if (timeDifference == "0 minutes" || Date() >= nextBusEnd) {
                        nextBusTimer = "Departing now"
                    }
                    else { // no range
                        nextBusTimer = timeDifference
                    }
                    tempRoute.nextBusTimer = nextBusTimer
                    
                    refreshedLbBusSchedule.routes.append(tempRoute)
                }
            }
        }
    } // End processRoutes()
}
