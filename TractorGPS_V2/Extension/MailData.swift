//
//  MailData.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 19/9/25.
//


// ShareAndMail.swift
// Reusable helpers: MailView + ActivityView + example usage
// Requires: import MessageUI

import SwiftUI
import MessageUI
import UIKit

// MARK: - Mail model
struct MailData: Identifiable {
    let id = UUID()
    var to: [String] = []
    var subject: String = ""
    var body: String = ""
    var isHTML: Bool = false
    var attachments: [MailAttachment] = []
}

struct MailAttachment {
    let data: Data
    let mimeType: String
    let fileName: String
}

// MARK: - MailView: UIViewControllerRepresentable (MFMailComposeViewController)
struct MailView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation
    let mail: MailData
    let completion: (Result<MFMailComposeResult, Error>) -> Void

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer { parent.presentation.wrappedValue.dismiss() }

            if let err = error {
                parent.completion(.failure(err))
            } else {
                parent.completion(.success(result))
            }
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        if !mail.to.isEmpty { vc.setToRecipients(mail.to) }
        vc.setSubject(mail.subject)
        vc.setMessageBody(mail.body, isHTML: mail.isHTML)
        for attachment in mail.attachments {
            vc.addAttachmentData(attachment.data, mimeType: attachment.mimeType, fileName: attachment.fileName)
        }
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

// MARK: - ActivityView: UIViewControllerRepresentable (UIActivityViewController)
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let completion: ((UIActivity.ActivityType?, Bool, [Any]?, Error?) -> Void)?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        vc.excludedActivityTypes = excludedActivityTypes
        vc.completionWithItemsHandler = completion
        return vc
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Fallback helper: open mailto if MFMailCompose not available
enum MailError: LocalizedError {
    case cannotSendMail
    case cannotOpenMailApp

    var errorDescription: String? {
        switch self {
        case .cannotSendMail: return "This device is not configured to send mail."
        case .cannotOpenMailApp: return "Unable to open the Mail app."
        }
    }
}

@discardableResult
func openMailToFallback(_ mail: MailData) -> Bool {
    // Build mailto URL
    var components = URLComponents()
    components.scheme = "mailto"
    components.path = mail.to.joined(separator: ",")
    var queryItems = [URLQueryItem]()
    if !mail.subject.isEmpty {
        queryItems.append(URLQueryItem(name: "subject", value: mail.subject))
    }
    if !mail.body.isEmpty {
        queryItems.append(URLQueryItem(name: "body", value: mail.body))
    }
    components.queryItems = queryItems.isEmpty ? nil : queryItems

    guard let url = components.url else { return false }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
    return false
}

// MARK: - Optional manager (ObservableObject) that helps present sheets from SwiftUI view
final class ShareAndMailManager: ObservableObject {
    @Published var presentMailSheet: Bool = false
    @Published var presentShareSheet: Bool = false

    // Data
    @Published var mailData: MailData?
    @Published var shareItems: [Any] = []

    // Call to trigger mail sheet. If device cannot use MFMailCompose, you may call fallback
    func sendMail(_ mail: MailData, fallbackToMailApp: Bool = true) {
        if MFMailComposeViewController.canSendMail() {
            self.mailData = mail
            self.presentMailSheet = true
        } else if fallbackToMailApp {
            _ = openMailToFallback(mail)
        } else {
            // you can show an alert
            print("Mail not available")
        }
    }

    func share(_ items: [Any]) {
        shareItems = items
        presentShareSheet = true
    }
}


