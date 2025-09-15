import Foundation
import SwiftUI

enum CoordinatorView: Equatable {
    case onboarding
    case mainView
}

final class Coordinator: ObservableObject {
    @Published var path: [CoordinatorView] = []
    
    func resolve(pathItem: CoordinatorView) -> AnyView {
        var view = AnyView(OnboardingView())
        switch pathItem {
        case .onboarding:
            view = AnyView(OnboardingView())
        case .mainView:
            view = AnyView(MainView())
        }
        return view
    }
    
    func navigate(to pathItem: CoordinatorView) {
        path.append(pathItem)
    }
    
    func navigateBack() {
        _ = path.popLast()
    }
}

struct ContentView: View {
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        ZStack {
            coordinator.resolve(pathItem: coordinator.path.last ?? .onboarding)
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    ContentView()
}
