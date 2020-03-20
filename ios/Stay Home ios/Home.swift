//
//  Map.swift
//  Stay Home ios
//
//  Created by Vishnu Ravi on 3/18/20.
//  Copyright © 2020 Stay Home. All rights reserved.
//

import SwiftUI
import MapKit
import Firebase
import SDWebImageSwiftUI
import SDWebImage

struct Home: View {
    
    @State private var centerCoordinates = CLLocationCoordinate2D()
    
    @State private var locations = [MKPointAnnotation]() // keeps track of home locations
    
    @State private var homePin = MKPointAnnotation() // pin for the home location
    
    @ObservedObject var locationManager = LocationManager()
    
    @State var firebaseDataLoaded = false
    
    @State var isAnimating = true

    @State var showInfoModal = false
    
    @State var showSpriteModal = false
    
    @State var sprites = ["pinkboi", "covid19_resting", "pinkboi", "covid19_resting", "pinkboi", "pinkboi", "pinkboi", "covid19_resting", "covid19_resting", "pinkboi"]
    
    // Shows unlocked sprites based off user level
    @State var userLevel = 2
    @State var points: Int = 0
    
    @State var currentSprite = "pinkboi"
    
    // For progress bar for next sprite unlock
    @State var progress : CGFloat = 1
    @State var outOfProgess : CGFloat = 6
    
    
    func getUnlockedSprites() -> [String] {
        var counter = 0
        var unlockedSprites : [String] = []
        
        while (counter < self.userLevel) {
            unlockedSprites.append(sprites[counter])
            counter += 1
        }
        
        let leftover = sprites.count - userLevel
        
        if leftover > 0 {
            for _ in (1...leftover) {
                unlockedSprites.append("color")
            }
        }
        
        return unlockedSprites
    }
    
    var body: some View {
        
        ZStack {
            ZStack {
                
                if(self.locationManager.lastLocation != nil && self.firebaseDataLoaded){
                    MapView(homeCoordinates: $locationManager.homeCoordinates, lastLocation: $locationManager.lastLocation, annotations: locations, homePin: homePin)
                        .saturation(0)
                        .edgesIgnoringSafeArea(.vertical)
                }else{
                    Text("Getting your location...").font(.custom("AvenirNext-Medium", size: 18))
                }
                
                VStack{
                    
                    // Virus guy button
                    HStack{
                        Button(action: {
                            self.showInfoModal.toggle()
                        }) {
                            Image(systemName: "info.circle.fill").renderingMode(.original).resizable().frame(width: 25, height: 25, alignment: .center)
                            .padding(25)
                            .shadow(radius: 10)
                        }.sheet(isPresented: self.$showInfoModal) {
                            MoreInfoModal()
                        }
                        
                        Spacer()
                
                        Button(action: {
                            self.showSpriteModal.toggle()
                        }) {
                        Image("pinkboi").renderingMode(.original).resizable().frame(width: 75, height: 75, alignment: .center)
                            .padding(25)
                            .shadow(radius: 10)
                        }
                    }
                    
                    // Change home button
                    VStack {
                        Spacer()
                        Text(self.locationManager.isHome != nil ? (self.locationManager.isHome! ? "You're home" : "You're not home") : "")
                            .font(.custom("AvenirNext-Bold", size: 18))
                            .frame(width: 300, height: 50, alignment: .center)
                        HStack {
                            Button(action: {
                                if let lastLocation = self.locationManager.lastLocation {
                                    // set home to the most recent location
                                    self.locationManager.homeCoordinates = lastLocation
                                    
                                    // push new home location to firebase
                                    var ref: DatabaseReference!
                                    ref = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid)
                                    ref.child("HomeLat").setValue(lastLocation.coordinate.latitude)
                                    ref.child("HomeLong").setValue(lastLocation.coordinate.longitude)
                    
                                    // set home pin
                                    let newHomePin = MKPointAnnotation()
                                    newHomePin.coordinate = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
                                    self.homePin = newHomePin
                                    
                                }
                            }) {
                                Text(self.locationManager.homeCoordinates == nil ? "Set Home" : "Change Home")
                            }
                            .font(.custom("AvenirNext-Medium", size: 20))
                            .padding()
                            .frame(width: 300, height: 50, alignment: .center)
                            .background(Color(red: 240/255, green: 176/255, blue: 175/255))
                            .foregroundColor(.white)
                            .border(Color(red: 240/255, green: 176/255, blue: 175/255), width: 1)
                            .cornerRadius(25)
                            .shadow(radius: 10)
                        }
                        Spacer().frame(height: 50)
                    }
                }
            }.blur(radius: self.showSpriteModal ? 20 : 0).animation(.easeOut)
                .onAppear {
                    self.showSpriteModal = false
            }
            
            Color(red: 89/255, green: 123/255, blue: 235/255).edgesIgnoringSafeArea(.all).opacity(self.showSpriteModal ? 0.5 : 0)
            .animation(.easeOut)
         
            if (self.showSpriteModal) {
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("my points").font(.custom("AvenirNext-Medium", size: 24)).foregroundColor(Color.white).padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5))
                            Text("\(self.points)").font(.custom("AvenirNext-Bold", size: 32)).foregroundColor(Color.white).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                        }.padding()
                        Spacer()
                        Button(action: {
                                self.showSpriteModal.toggle()
                            }){
                                Image(systemName: "xmark")
                                    .resizable()
                                    .font(Font.title.weight(.heavy))
                                    .foregroundColor(Color(red: 78/255, green: 89/255, blue: 140/255))
                                    .frame(width: 20, height: 20).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 25))
                        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 25))
                    }
                    VStack(alignment: .center) {
                        WebImage(url: URL(string: "https://user-images.githubusercontent.com/1212163/77207404-a65b5780-6acf-11ea-948b-bebf01692194.gif"), isAnimating: $isAnimating)
                        .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                        .placeholder(Image(systemName: "photo")) // Placeholder Image
                        .placeholder {
                            Rectangle().foregroundColor(.gray)
                        }
                        .indicator(.activity) // Activity Indicator
                        .animation(.easeInOut(duration: 0.5)) // Animation Duration
                        .transition(.fade) // Fade Transition
                        .scaledToFit()
                        .frame(width: 150, height: 150, alignment: .center)
                        
                         Text("COVID Cody").font(.custom("AvenirNext-Bold", size: 22)).foregroundColor(Color.white)
                         Text("Stay home and flatten the curve!").font(.custom("AvenirNext-Medium", size: 20)).foregroundColor(Color.white)
                    }
                    
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(getUnlockedSprites(), id: \.self) { sprite in
                                Group {
                                    if (sprite == "color") {
                                        Color(red: 78/255, green: 89/255, blue: 140/255).frame(width: 75, height: 75).opacity(0.5).cornerRadius(8).padding()
                                    } else {
                                        Button(action: {
                                            self.currentSprite = sprite
                                        }) {
                                        Image(sprite).renderingMode(.original).resizable().frame(width: 75, height: 75, alignment: .center)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        Text("100,000 points until next sprite unlock").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(Color(red: 78/255, green: 89/255, blue: 140/255)).padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        ProgressBar(progress: .constant(self.progress/self.outOfProgess), width: 300, height: 15)
                    }.padding()
                    
                    Spacer()
                }
            }
        }.onAppear {
            // check firebase for existing home location
            let ref = Database.database().reference().child("Users").child(Auth.auth().currentUser!.uid)
            ref.observeSingleEvent(of: .value) { (snapshot) in
                var homeLat: Double = 0.0
                var homeLong: Double = 0.0
                
                if let hlat = snapshot.childSnapshot(forPath: "HomeLat").value as? Double {
                    homeLat = hlat
                }
                if let hlong = snapshot.childSnapshot(forPath: "HomeLong").value as? Double {
                    homeLong = hlong
                }
                
                if (homeLat != 0 && homeLong != 0){
                    // if home coordinates exist in firebase, set them locally.
                    self.locationManager.homeCoordinates = CLLocation(latitude: homeLat, longitude: homeLong)
                    
                    // add a pin for the new home location
                    let newHomePin = MKPointAnnotation()
                    newHomePin.coordinate = CLLocationCoordinate2D(latitude: homeLat, longitude: homeLong)
                    self.homePin = newHomePin
                }
                
                self.firebaseDataLoaded = true
            }
            
            ref.child("Points").observe(.value) { (snapshot) in
                if let points = snapshot.value as? Int {
                    self.points = points
                }
            }
        }
    }
}

struct ProgressBar: View {
    @Binding var progress: CGFloat
    var width: CGFloat
    var height: CGFloat
    var barColor: Color?
    var bgColor: Color?

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(self.bgColor ?? Color.white)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(self.barColor ?? Color(red: 78/255, green: 89/255, blue: 140/255))
                    .frame(width: self.progress*geometry.size.width, height: geometry.size.height)
            }
        }
            .frame(width: width, height: height)
    }

}
