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

                    Image("appLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 300, alignment: .topLeading)
                        .padding(.bottom, 40)
                    Spacer()
                }

                if homeViewModel.hasSubmitted {
                    VStack {
                        Text("You already submitted your day")
                            .foregroundColor(.textColour)
                    }
                } else {
                    VStack {
                        VStack(spacing: 10) {
                            HStack {
                                Text("\(homeViewModel.username) , tell me how you feel today")
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

                            HStack(spacing: 40) {
                                ForEach(1 ..< 6, id: \.self) { star in
                                    Button(action: {
                                        homeViewModel.rating = star
                                    }) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(homeViewModel.rating >= star ? .yellow : .textColour)
                                            .font(.system(size: 21))
                                    }
                                }

                                if homeViewModel.rating > 0 {
                                    Image(systemName: "checkmark")
                                }
                            }

                            Text("Take a selfie of your today's emotion")
                                .font(.system(size: 22))
                                .foregroundColor(.textColour)
                                .padding()
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
                            }
                            if capturedImage != nil {
                                Image(systemName: "checkmark")
                            }

                            ZStack {
                                Button(action: {}) { Text("Save") }

                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .bold()
                                    .padding(12)
                                    .background(.buttonColour)
                                    .cornerRadius(7)
                                    .shadow(radius: 5)
                            }
                            .offset(y: 40)
                        }
                    }
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                    .padding(.top, 70)
                }
            }
        }
        .onAppear {
            if !hasActionBeenPerformed {
                homeViewModel.findUserName()
                hasActionBeenPerformed = true
            }
        }
    }
}

#Preview {
    HomeView()
}
