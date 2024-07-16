import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @State private var isOnboardingViewActive: Bool = true
    
    var body: some View {
        ZStack {
            Button(action: {
                // Handle restart action
                // Perform segue to next view controller
                NotificationCenter.default.post(name: NSNotification.Name("RestartSegue"), object: nil)
            }) {
                // Text("Start")
            }
            if isLoggedIn {
                NewSwift()
            } else if isOnboardingViewActive {
                LaunchView(isOnboardingViewActive: $isOnboardingViewActive)
            } else {
                secondOnboarding()
            }
        }
        .onAppear {
            // Example of checking login state when ContentView appears
            isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
