import UIKit
import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?
    private var downloadTask: URLSessionDataTask?
    private let deliveryLock = NSLock()

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler

        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
            contentHandler(request.content)
            return
        }

        bestAttemptContent = content

        guard let imageURL = imageURL(from: request.content.userInfo) else {
            deliver(content)
            return
        }

        downloadTask = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, _ in
            guard let self = self else { return }

            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode),
                let data = data,
                data.count <= 10_000_000,
                let image = UIImage(data: data),
                let jpegData = image.jpegData(compressionQuality: 0.92)
            else {
                self.deliver(content)
                return
            }

            let attachmentURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")

            do {
                try jpegData.write(to: attachmentURL, options: .atomic)
                let attachment = try UNNotificationAttachment(
                    identifier: "notification-image",
                    url: attachmentURL,
                    options: nil
                )
                content.attachments = [attachment]
            } catch {
                // Deliver the notification without an image if the attachment cannot be created.
            }

            self.deliver(content)
        }

        downloadTask?.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        downloadTask?.cancel()

        if let bestAttemptContent = bestAttemptContent {
            deliver(bestAttemptContent)
        }
    }

    private func imageURL(from userInfo: [AnyHashable: Any]) -> URL? {
        var candidates: [Any?] = []

        if let fcmOptions = userInfo["fcm_options"] as? [String: Any] {
            candidates.append(fcmOptions["image"])
        }

        candidates.append(userInfo["gcm.notification.image"])
        candidates.append(userInfo["image"])
        candidates.append(userInfo["image_url"])
        candidates.append(userInfo["imageUrl"])

        for candidate in candidates {
            guard
                let value = candidate as? String,
                let url = URL(string: value),
                let scheme = url.scheme?.lowercased(),
                scheme == "https" || scheme == "http"
            else {
                continue
            }

            return url
        }

        return nil
    }

    private func deliver(_ content: UNNotificationContent) {
        deliveryLock.lock()
        let handler = contentHandler
        contentHandler = nil
        deliveryLock.unlock()

        handler?(content)
    }
}
