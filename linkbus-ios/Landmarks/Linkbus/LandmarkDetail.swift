/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 A view showing the details for a landmark.
 */

import SwiftUI

struct LandmarkDetail: View {
    var route: Route
    
    var body: some View {
        VStack {
            //            MapView(coordinate: landmark.locationCoordinate)
            //                .edgesIgnoringSafeArea(.top)
            //                .frame(height: 300)
            //
            //            CircleImage(image: landmark.image)
            //                .offset(x: 0, y: -130)
            //                .padding(.bottom, -130)
            
            VStack(alignment: .leading) {
                Text("test")
                    .font(.title)
                
                //                HStack(alignment: .top) {
                //                    Text(landmark.park)
                //                        .font(.subheadline)
                //                    Spacer()
                //                    Text(landmark.state)
                //                        .font(.subheadline)
                //                }
            }
            .padding()
            
            Spacer()
        }
        .navigationBarTitle(Text("test"), displayMode: .inline)
    }
    
    
    struct LandmarkDetail_Previews: PreviewProvider {
        static var previews: some View {
            LandmarkDetail(route: routeData[0])
        }
    }
}

