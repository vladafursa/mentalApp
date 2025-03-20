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
                    Image("appLogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 300, alignment: .topLeading)
                        .padding(.bottom, 40)
                    Spacer()
                }
                VStack {
                    HStack {
                        Text("Choose the day you want to remember")
                            .font(.system(size: 22))
                            .foregroundColor(.textColour)
                            .padding(.leading, 30)
                        Spacer()
                    }
                    VStack {
                        DatePicker(
                            "Start Date",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .datePickerStyle(.graphical)
                    }
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(25)
                    .onChange(of: date) { _ in
                        showSelectedDateView = true
                    }

                    NavigationLink(
                        destination: SelectedDateView(date: date)

                    ) { Text("Go to Diary")
                        .padding()
                        .foregroundColor(.blue)
                    }

                    Button("Download history") {}
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .bold()
                        .padding(12)
                        .background(.buttonColour)
                        .cornerRadius(7)
                        .shadow(radius: 5)
                }
            }
        }
        .onAppear {
            Task {
                // await firestoreService.fetchAndPrintNotes()
            }
        }
    }
}

#Preview {
    HistoryView()
}
