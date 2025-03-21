
import Charts
import SwiftUI

struct StatsView: View {
    @StateObject private var historyViewModel = HistoryViewModel()
    @State private var selectedOption: String = "Specify period"
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
                        Menu(selectedOption) {
                            Button("1 week") {
                                historyViewModel.filter(period: 7)
                                selectedOption = "1 week"
                            }
                            Button("1 month") {
                                historyViewModel.filter(period: 30)
                                selectedOption = "1 month"
                            }
                            Button("all") {
                                historyViewModel.resetfilter()
                                selectedOption = "all"
                            }
                        }
                        .padding()
                        .frame(minWidth: 150)
                        .foregroundColor(.textColour)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .menuStyle(ButtonMenuStyle())
                        .padding(.leading, 30)
                        Spacer()
                    }
                    .padding(.bottom)
                    Chart {
                        ForEach(historyViewModel.filteredDiaryEntries) { data in
                            LineMark(
                                x: .value("Date", data.date),
                                y: .value("happiness", data.happinessScore)
                            )
                            .lineStyle(.init(lineWidth: 2))
                        }
                    }
                    .frame(width: 330, height: 350)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day, count: 1))
                    }
                    .chartYScale(domain: 0 ... 6)
                    .chartYAxis {
                        AxisMarks(values: [1, 2, 3, 4, 5]) { _ in
                            AxisValueLabel()
                            AxisTick()
                        }
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
