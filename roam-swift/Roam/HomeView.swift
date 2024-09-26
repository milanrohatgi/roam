import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CarpoolViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else if viewModel.carpools.isEmpty {
                    Text("No carpool requests found in your groups")
                } else {
                    List(viewModel.carpools) { carpool in
                        VStack(alignment: .leading) {
                            Text(carpool.title)
                                .font(.headline)
                            Text("\(carpool.origin) to \(carpool.destination)")
                                .font(.subheadline)
                            Text("Date: \(carpool.dateTime, style: .date)")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle("Group Carpool Requests")
            .onAppear {
                viewModel.fetchGroupCarpools()
            }
        }
    }
}
