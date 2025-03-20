
import Charts
import SwiftUI

struct StatsView: View {
    @StateObject private var historyViewModel = HistoryViewModel()
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
                        Text("Statistic of your happiness for the last week")
                            .font(.system(size: 22))
                            .foregroundColor(.textColour)
                            .padding(.leading, 30)
                        Spacer()
                    }
                    HStack {
                        Menu("Specify period") {
                            Button("1 week") {
                                historyViewModel.filter(period: 7)
                            }
                            Button("1 month") {
                                historyViewModel.filter(period: 30)
                            }
                            Button("all") {
                                historyViewModel.resetfilter()
                            }
                        }
                        .padding()
                        .foregroundColor(.textColour)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .menuStyle(ButtonMenuStyle())
                        .padding(.leading, 30)
                        Spacer()
                    }
                    Chart {
                        ForEach(historyViewModel.filteredDiaryEntries) { data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("happiness", data.happinessScore)
                            )
                        }
                    }
                    .frame(width: 340, height: 350)
                    .padding(10)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 1))
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic)
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            historyViewModel.fetchAllDiaryEntries()
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

#Preview {
    StatsView()
}
