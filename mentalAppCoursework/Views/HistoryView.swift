//
//  HistoryView.swift
//  mobile_implementation_coursework
//
//  Created by Влада Фурса on 30.01.25.
//

import SwiftUI
import UIKit

struct HistoryView: View {
    @State private var date = Date()
    @State private var showSelectedDateView: Bool = false
    @StateObject private var historyViewModel = HistoryViewModel()
    @State private var showPDF = false
    @State private var pdfURL: URL?
    var body: some View {
        NavigationView {
            ZStack {
                Color("backgroundColour")
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    // logo
                    Image("appLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 300, alignment: .topLeading)
                        .padding(.bottom, 75)
                    Spacer()
                }
                .padding(.bottom, 30)
                VStack {
                    VStack {
                        // title
                        Text("Choose the day you want to remember")
                            .font(.system(size: 22))
                            .foregroundColor(.textColour)
                            .multilineTextAlignment(.center) // Центрирование строк текста
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    .padding(.top, 35)
                    VStack {
                        // calendar
                        DatePicker(
                            "Start Date",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(.horizontal, 25)
                    // assign a variable tapped day
                    .onChange(of: date) { _ in
                        showSelectedDateView = true
                    }
                    VStack(spacing: 12) {
                        NavigationLink(
                            destination: SelectedDateView(date: date)

                        ) { Text("Go to Diary")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding(12)
                            .background(.buttonColour)
                            .cornerRadius(7)
                            .shadow(radius: 5)
                        }
                        .padding()
                        Button("Download history") {
                            historyViewModel.CreatePDF()
                        }
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .bold()
                        .padding(12)
                        .background(.buttonColour)
                        .cornerRadius(7)
                        .shadow(radius: 5)
                    }
                    .frame(maxWidth: 215)
                }
            }
        }
        // load diary entries for download pdf function
        .onAppear {
            historyViewModel.fetchAllDiaryEntries()
        }
        // alerts
        .alert(isPresented: $historyViewModel.showAlert) {
            Alert(
                title: Text(historyViewModel.alertTitle ?? "Error"),
                message: Text(historyViewModel.alertMessage ?? "Can't load the data"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    HistoryView()
}
