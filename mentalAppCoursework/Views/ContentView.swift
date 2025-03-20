import SwiftUI

struct ContentView: View {
    var body: some View {
        // bottom navigation
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                        .foregroundColor(.titleColour)
                    Text("Home")
                        .foregroundColor(.titleColour)
                }
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        .foregroundColor(.titleColour)
                    Text("History")
                        .foregroundColor(.titleColour)
                }
            StatsView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(.titleColour)
                    Text("Stats")
                        .foregroundColor(.titleColour)
                }
            WalksView()
                .tabItem {
                    Image(systemName: "map.fill")
                        .foregroundColor(.titleColour)
                    Text("Walks")
                        .foregroundColor(.titleColour)
                }
            GalleryView()
                .tabItem {
                    Image(systemName: "photo.fill")
                        .foregroundColor(.titleColour)
                    Text("Galery")
                        .foregroundColor(.titleColour)
                }
        }
    }
}

#Preview {
    ContentView()
}
