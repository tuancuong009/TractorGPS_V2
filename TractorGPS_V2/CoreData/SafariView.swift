import SwiftUI
import SafariServices

struct SafariURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        return SFSafariViewController(url: url, configuration: config)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) { }
}

final class SafariManager: ObservableObject {
    static let shared = SafariManager()
    
    @Published var safariURL: SafariURL? = nil
    
    private init() {}
    
    func open(_ urlString: String) {
        if let url = URL(string: urlString) {
            DispatchQueue.main.async {
                self.safariURL = SafariURL(url: url)
            }
        }
    }
}

