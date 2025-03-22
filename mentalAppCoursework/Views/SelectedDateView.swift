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
                        // date
                        Text(date, format: .dateTime.day().month().year())
                            .foregroundColor(.titleColour)
                            .padding()
                    }

                    ZStack {
                        // logo
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
                            VStack(spacing: 10) {
                                HStack {
                                    Text("That day you felt:")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)
                                    Spacer()
                                }
                                .frame(maxWidth: 350, alignment: .leading)
                                .padding(.bottom)
                                HStack {
                                    Text("\(historyViewModel.specificDiaryEntry?.feelings ?? "no data")")
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: 350, alignment: .leading)
                                .background(Color.white)
                                .cornerRadius(10)
                            }

                            VStack {
                                HStack {
                                    Text("That day you rated your happiness:")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)
                                        .fixedSize(horizontal: true, vertical: false)
                                    Spacer()
                                }
                                .padding()
                                let rate = historyViewModel.specificDiaryEntry?.happinessScore ?? 0

                                HStack {
                                    // star rate
                                    ForEach(0 ..< rate) { _ in
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 21))
                                            .foregroundColor(.yellow)
                                    }
                                }
                            }
                            .padding()
                        } else {
                            VStack { // text if no data was found for that date
                                Text("No data available for that period.")
                                    .font(.system(size: 22))
                                    .foregroundColor(.textColour)
                            }
                            .padding()
                        }
                        HStack {
                            Text("That day you looked:")
                                .font(.system(size: 22))
                                .foregroundColor(.textColour)
                                .fixedSize(horizontal: true, vertical: false)
                            Spacer()
                        }
                        .padding(.horizontal, 35)
                        // image
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
                                VStack { // text if no image was found for that date
                                    Text("No image found")
                                        .font(.system(size: 22))
                                        .foregroundColor(.textColour)
                                }
                                .padding()
                            }
                        }
                    }
                }
                .offset(y: -320)
            }
            // fetch diary entry
            .onAppear {
                historyViewModel.fetchSpecififcDate(date: date)
                imageURL = FileManagementService.shared.getPhotoForSelectedDate(date)
            }
            // forget diary entry to prevent infinite loop of opening this page
            .onDisappear {
                historyViewModel.specificDiaryEntry = nil
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
}

#Preview {
    let today = Date()
    var calendar = Calendar.current
    let selectedDate = calendar.date(bySettingHour: 10, minute: 0, second: 0, of: today) ?? today
    SelectedDateView(date: today)
}
