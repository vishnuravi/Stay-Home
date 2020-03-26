//
//  ForgotPasswordView.swift
//  Stay Home ios
//
//  Created by Rahul Sompuram on 3/25/20.
//  Copyright © 2020 Stay Home. All rights reserved.
//

import SwiftUI

struct ForgotPasswordView: View {
    @State var email: String = ""
    @State var goBackView: Bool = false
    
    var body: some View {
        Group {
            if (self.goBackView) {
                SignInView()
            } else {
                ZStack {
                    Color.init(red: 78/255, green: 89/255, blue: 140/255)
                    .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        HStack {
                            Button(action: {
                                self.goBackView.toggle()
                                }){
                                    Image(systemName: "arrow.left")
                                        .resizable()
                                        .font(Font.title.weight(.bold))
                                        .foregroundColor(Color(red: 240/255, green: 176/255, blue: 175/255))
                                        .frame(width: 20, height: 20).padding()
                            }
                            Spacer()
                        }
                        Spacer()
                        
                        VStack {
                            Text("Forgot your password?").font(.custom("AvenirNext-Bold", size: 24)).foregroundColor(Color.white)
                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
                            Text("Enter your email so we can find your account.").font(.custom("AvenirNext-Regular", size: 16)).foregroundColor(Color.white)
                            .padding(EdgeInsets(top: 0, leading: 15, bottom: 15, trailing: 15))
                        }
                        
                        
                        TextFieldWithLine(placeholder: "Email", text: $email, isSecure:  false).foregroundColor(Color.white).padding(25)
                        
                        Button(action: {
                            // TODO
                        }) {
                            Text("Done")
                                .font(.custom("AvenirNext-Medium", size: 20))
                                .padding()
                                .frame(width: 300, height: 50, alignment: .center)
                                .background(Color(red: 240/255, green: 176/255, blue: 175/255))
                                .foregroundColor(.white)
                                .border(Color(red: 240/255, green: 176/255, blue: 175/255), width: 1)
                                .cornerRadius(25)
                                .shadow(radius: 10)
                        }.padding()
                        
                        Spacer()
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
