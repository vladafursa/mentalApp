//
//  SelectedDateView.swift
//  mobile_implementation_coursework
//
//  Created by Влада Фурса on 13.03.25.
//

import SwiftUI

struct SelectedDateView: View {
    @State private var imageURL: URL?
    var date: Date
    @StateObject private var historyViewModel = HistoryViewModel()
    var body: some View {
        ZStack {
            Color("backgroundColour")
                .edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack {
                    HStack {
                        Spacer()
                        Text(date, format: .dateTime.day().month().year())
                            .foregroundColor(.titleColour)
                            .padding()
                    }

                    ZStack {
                        Image("appLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 300, alignment: .topLeading)
                            .padding(.bottom, 40)
                    }
                    .offset(y: -60)
                    Spacer()
                }
                ZStack {
                    VStack {
                        if historyViewModel.specificDiaryEntry != nil {
                            VStack {
                                HStack {
                                    Text("That day you felt")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)
                                    Spacer()
                                }
                                .padding()
                                HStack {
                                    Text("\(historyViewModel.specificDiaryEntry?.feelings ?? "no data")")
                                    Spacer()
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                            .padding()
                            VStack {
                                HStack {
                                    Text("That day you rated your happiness")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)

                                    Spacer()
                                }
                                .padding()
                                let rate = historyViewModel.specificDiaryEntry?.happinessScore ?? 0

                                HStack {
                                    ForEach(0 ..< rate) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 21))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding()
                        } else {
                            Text("No data available for that period")
                        }

                        if let imageURL = imageURL {
                            if FileManager.default.fileExists(atPath: imageURL.path) {
                                if let image = UIImage(contentsOfFile: imageURL.path) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 300, height: 300)
                                        .padding()
                                }
                            } else {
                                Text("No image found")
                                    .font(.system(size: 20))
                                    .foregroundColor(.textColour)
                                    .padding(.leading, 30)
                            }
                        }
                    }
                }
                .offset(y: -320)
            }

            .onAppear {
                historyViewModel.fetchSpecififcDate(date: date)
                imageURL = FileManagementService.shared.getPhotoForSelectedDate(date)
            }
            .onDisappear {
                historyViewModel.specificDiaryEntry = nil
            }
            .alert(isPresented: $historyViewModel.showAlert) {
                Alert(
                    title: Text(historyViewModel.alertTitle ?? "Error"),
                    message: Text(historyViewModel.alertMessage ?? "Can't load the data"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    let today = Date()
    var calendar = Calendar.current
    let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
    SelectedDateView(date: today)
}
