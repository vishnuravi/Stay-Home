//
//  SpriteModal.swift
//  Stay Home ios
//
//  Created by Rahul Sompuram on 3/21/20.
//  Copyright © 2020 Stay Home. All rights reserved.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI
import SDWebImage


struct SpriteModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var userData: UserDataViewModel
    
    let pointsPerLevel = 50000
    static let url = "https://rahulsompuram.github.io/Stay-Home/"
    
    @State var isAnimating = true
    
    @State var pointBonus: Double = 0
    
    @State var sprites = ["pinkboi", "soapboi", "maskboi", "gloveboi", "sanitizer", "Window", "TP", "Sir_Six_Feet", "Juiceboi", "lungs"]
    
    @State var spriteDict = ["1": ["name": "pinkboi", "gif": url + "pinkboi.gif", "nickname": "Viral Vince", "desc": "Together we can beat germs like me!"],
                             "2": ["name": "soapboi", "gif": url + "soapboi.gif", "nickname": "Soapy Sam", "desc": "Soap and water is extremely effective. Wash your hands!"],
                             "3": ["name": "maskboi", "gif": url + "maskboi.gif", "nickname": "Facemask Frank", "desc": "These guys can help prevent the viral spread if used properly."],
                             "4": ["name": "gloveboi", "gif": url + "gloveboi.gif", "nickname": "Hands Hans", "desc": "Keeping your hands off of your face keeps the virus off too."],
                             "5": ["name": "sanitizer", "gif": url + "sanitizer.gif", "nickname": "Sanitizer Suzy", "desc": "You've seen this one on the news."],
                             "6": ["name": "Window", "gif": url + "Window.gif", "nickname": "Window Windy", "desc": "Open windows to improve ventilation!"],
                             "7": ["name": "TP", "gif": url + "TP.gif", "nickname": "T.P.", "desc": "The way some people buy toilet paper...you gotta wonder what goes on in the bathroom!"],
                             "8": ["name": "Sir_Six_Feet", "gif": url + "Sir_Six_Feet.gif", "nickname": "Sir Six Feet", "desc": "If you have to go out, maintain safe distance of 6 feet!"],
                             "9": ["name": "Juiceboi", "gif": url + "Juiceboi.gif", "nickname": "Juice Jésus", "desc": "Vitamin C and staying hydrated keeps your immune system healthy!"],
                             "10": ["name": "lungs", "gif": url + "lungs.gif", "nickname": "Lisa & Larry", "desc": "These superheros keep the wind in your sails. STAY home to keep them protected!"]
    ]
    @State var reverseDict = ["pinkboi": 1, "soapboi": 2, "maskboi": 3, "gloveboi": 4, "sanitizer": 5, "Window": 6, "TP": 7, "Sir_Six_Feet": 8, "Juiceboi": 9, "lungs": 10]
    
    // For progress bar for next sprite unlock
    @State var progress : CGFloat = 1
    @State var outOfProgess : CGFloat = 6
    
    func getUnlockedSprites() -> [String] {
        guard let user = self.userData.user else { return [] }
        
        var counter = 0
        var unlockedSprites : [String] = []
        var levelCounter = user.level + 1
        
        while (counter < user.level && counter < 10) {
            unlockedSprites.append(sprites[counter])
            counter += 1
        }
        
        let leftover = sprites.count - user.level
        
        if leftover > 0 {
            for _ in (1...leftover) {
                unlockedSprites.append("Level \(levelCounter)")
                levelCounter += 1
            }
        }
        
        return unlockedSprites
    }
    
    
    // tap gesture for sprite
    var tapSprite: some Gesture {
        TapGesture(count: 1)
            .onEnded {
                // toggle +1 on
                self.plusOneActive.toggle()
                
                if let user = self.userData.user {
                    
                    let rand = Int.random(in: 0 ..< 10)
                    if (rand == 0) {
                        self.pointBonus = 25
                    } else {
                        self.pointBonus = 10
                    }
                    
                    let ref = Database.database().reference()
                    ref.child("Users").child(Auth.auth().currentUser!.uid).child("Points").setValue(user.points + self.pointBonus)
                    ref.child("Users").child(Auth.auth().currentUser!.uid).child("unredeemedPoints").setValue(user.unredeemedPoints + self.pointBonus)
                    ref.child("Leaderboard").child(user.username).setValue(Int(user.points + self.pointBonus))
                }
                
                // wait 0.5s then toggle +1 off
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.plusOneActive.toggle()
                }
                
        }
    }
    
    @State var plusOneActive = false
    
    var body: some View {
        ZStack {
            Color.init(red: 78/255, green: 89/255, blue: 140/255).edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("my points").font(.custom("AvenirNext-Medium", size: 24)).foregroundColor(Color.white).padding(EdgeInsets(top: 0, leading: 5, bottom: 10, trailing: 5))
                        Text("\(Int(self.userData.user?.points ?? 0))").font(.custom("AvenirNext-Bold", size: 32)).foregroundColor(Color.white).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5))
                    }.padding()
                    Spacer()
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }){
                        Image(systemName: "xmark")
                            .resizable()
                            .font(Font.title.weight(.heavy))
                            .foregroundColor(Color(red: 240/255, green: 176/255, blue: 175/255))
                            .frame(width: 20, height: 20).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 25))
                    }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 25))
                }
                VStack(alignment: .center) {
                    ZStack{
                        VStack{
                            Text("+\(Int(self.pointBonus))")
                                .foregroundColor(Color(red: 240/255, green: 176/255, blue: 175/255))
                                .offset(x: self.plusOneActive ? -15: 0, y: self.plusOneActive ? -50: 0)
                                .scaleEffect(self.plusOneActive ? 2 : 0)
                                .animation(Animation.spring(response: 0.5, dampingFraction: 1.0, blendDuration: 0).delay(Double(0.0)))
                                .padding()
                            Spacer()
                        }
                            
                            WebImage(url: URL(string: self.spriteDict["\(self.userData.user?.level ?? 1)"]!["gif"]!), isAnimating: $isAnimating)
                                .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
                                .placeholder(Image(systemName: "photo")) // Placeholder Image
                                .placeholder {
                                    Circle().foregroundColor(Color(red: 89/255, green: 123/255, blue: 235/255))
                            }
                                .indicator(.activity) // Activity Indicator
                                .animation(.easeInOut(duration: 0.5)) // Animation Duration
                                .transition(.fade) // Fade Transition
                                .scaledToFit()
                                .frame(width: 150, height: 150, alignment: .center)
                                .gesture(tapSprite)
                        
                    }
                    
                    VStack(alignment: .center) {
                        Text(self.spriteDict["\(self.userData.user?.level ?? 1)"]!["nickname"]!).font(.custom("AvenirNext-Bold", size: 22)).foregroundColor(Color.white)
                        HStack {
                            Spacer()
                            Text(self.spriteDict["\(self.userData.user?.level ?? 1)"]!["desc"]!).font(.custom("AvenirNext-Medium", size: 16)).foregroundColor(Color.white).multilineTextAlignment(.center)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Unlocked\nSprites").font(.custom("AvenirNext-Bold", size: 14)).foregroundColor(Color(red: 89/255, green: 123/255, blue: 235/255)).padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 5))
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(getUnlockedSprites(), id: \.self) { sprite in
                                Group {
                                    if (sprite.contains("Level")) {
                                        ZStack {
                                            Color(red: 89/255, green: 123/255, blue: 235/255).frame(width: 75, height: 75).opacity(0.5).cornerRadius(8).padding()
                                            Text(sprite).font(.custom("AvenirNext-Bold", size: 14)).foregroundColor(Color.white)
                                        }
                                    } else {
                                        Image(sprite).renderingMode(.original).resizable().frame(width: 75, height: 75, alignment: .center)
                                    }
                                }
                            }
                        }
                    }
                }
                
                
                Spacer()
                
                VStack(alignment: .center) {
                    if (self.userData.user?.pointsToNextLevel == 999999999) {
                        Text("All current levels are unlocked!").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(Color(red: 89/255, green: 123/255, blue: 235/255)).padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        ProgressBar(progress: .constant(CGFloat(1.0)), width: 300, height: 15)
                    } else {
                        Text("\(self.userData.user?.pointsToNextLevel ?? 0) points until next sprite unlock").font(.custom("AvenirNext-Bold", size: 18)).foregroundColor(Color(red: 89/255, green: 123/255, blue: 235/255)).padding(EdgeInsets(top: 0, leading: 0, bottom: 5, trailing: 0))
                        ProgressBar(progress: .constant(1 - CGFloat(self.userData.user?.pointsToNextLevel ?? 0) / CGFloat(self.pointsPerLevel)), width: 300, height: 15)
                    }
                }.padding()
                
                Spacer()
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
                    .foregroundColor(self.barColor ?? Color(red: 89/255, green: 123/255, blue: 235/255))
                    .frame(width: self.progress*geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(width: width, height: height)
    }
    
}
