//
//  HomeView.swift
//  mobile_implementation_coursework
//
//  Created by Влада Фурса on 24.01.25.
//

import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import UIKit

struct HomeView: View {
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?
    @State private var hasActionBeenPerformed = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColour")
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Spacer()
                        Text(Date.now, format: .dateTime.day().month().year())
                            .foregroundColor(.titleColour)
                            .padding()
                    }
                    ZStack {
                        //logo
                        Image("appLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 300, alignment: .topLeading)
                            .padding(.bottom, 40)
                    }
                    .offset(y: -60)
                    Spacer()
                }
                .padding(.bottom, 20)
                if homeViewModel.hasSubmitted {
                    VStack {//text if the action was already performed
                        Text("You already submitted your day")
                            .foregroundColor(.textColour)
                    }
                } else {
                    VStack {
                        VStack(spacing: 20) {
                            HStack {//greeting of user
                                Text("\(homeViewModel.username), tell me how you feel today")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                                    .padding(.leading, 30)
                                Spacer()
                            }
                            HStack {
                                TextEditor(text: $homeViewModel.feelings)
                                    .padding()
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .frame(width: 340, height: 150)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .padding()
//showing that field is inputted
                                if !homeViewModel.feelings.isEmpty {
                                    let removedWhitespacesFeelongs = homeViewModel.feelings.filter { !$0.isWhitespace }
                                    if !removedWhitespacesFeelongs.isEmpty {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                            HStack {
                                Text("Rate your happiness")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                                    .padding(.leading, 30)
                                    .padding(.bottom, 2)
                                Spacer()
                            }

                            HStack(spacing: 40) {//star rate
                                ForEach(1 ..< 6, id: \.self) { star in
                                    Button(action: {
                                        homeViewModel.rating = star
                                    }) {//change of colour depending on tap
                                        Image(systemName: "star.fill")
                                            .foregroundColor(homeViewModel.rating >= star ? .yellow : .textColour)
                                            .font(.system(size: 21))
                                    }
                                }
//showing that field is inputted
                                if homeViewModel.rating > 0 {
                                    Image(systemName: "checkmark")
                                }
                            }

                            Text("Take a selfie of your today's emotion")
                                .font(.system(size: 22))
                                .foregroundColor(.textColour)
                                .padding(.leading, 15)
                                .fixedSize(horizontal: true, vertical: false)
                                .padding(.bottom)
                            Button("Take a photo") { isShowingCamera = true
                            }

                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .padding(12)
                            .background(.buttonColour)
                            .cornerRadius(7)
                            .shadow(radius: 5)
                            .sheet(isPresented: $isShowingCamera) {
                                CameraView(capturedImage: $capturedImage)
                            }//showing that field is inputted
                            if capturedImage != nil {
                                Image(systemName: "checkmark")
                            }

                            ZStack {
                                Button(action: {
                                    if capturedImage == nil{
                                        homeViewModel.showPhotoAlert()
                                    }else{
                                       if  !homeViewModel.checkInput(){
                                            homeViewModel.addEntry()
                                            FileManagementService.shared.savePhoto(capturedImage!)
                                        }
                                    }
                                   
                                      
                                }) { Text("Save") }
                                    .frame(maxWidth: 112)
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(12)
                                    .background(.buttonColour)
                                    .cornerRadius(7)
                                    .shadow(radius: 5)
                            }
                            .offset(y: 25)
                        }
                    }//to close keyboard when tapping anything other than textfield
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
        }
        .onAppear {
            //check if the data was already submitted
            homeViewModel.checkIfSubmitted()
            //check if the name was already retrieved to not infinetely reload the page
            if !hasActionBeenPerformed {
                homeViewModel.findUserName()
                hasActionBeenPerformed = true
            }
        }
         .alert(isPresented: $homeViewModel.showAlert) {
             Alert(
                 title: Text(homeViewModel.alertTitle ?? "Missing Information"),
                 message: Text(homeViewModel.alertMessage ?? "Please fill out all fields and take a photo before submitting."),
                 dismissButton: .default(Text("OK"))
             )
         }
         
    }
}

#Preview {
    HomeView()
}
