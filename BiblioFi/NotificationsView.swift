import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct NotificationsView: View {
    @State private var notifications = [Notification]()
    
    var body: some View {
        VStack {
            Text("Notifications")
                .font(.largeTitle)
                .padding(.top, 40)
                .padding(.leading, 20)
            
            List(notifications) { notification in
                VStack(alignment: .leading) {
                    Text(notification.title)
                        .font(.headline)
                    Text(notification.message)
                        .font(.subheadline)
                    Text("\(notification.timestamp.dateValue(), formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            }
            .listStyle(PlainListStyle())
            .onAppear(perform: fetchNotifications)
        }
        .background(Color(hex: "F7EEEB"))
    }
    
    func fetchNotifications() {
        let db = Firestore.firestore()
        db.collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                } else {
                    self.notifications = querySnapshot?.documents.compactMap { document -> Notification? in
                        try? document.data(as: Notification.self)
                    } ?? []
                }
            }
    }
    
    func markAsRead(notification: Notification) {
        let db = Firestore.firestore()
        if let notificationId = notification.id {
            db.collection("notifications").document(notificationId).updateData(["status": "read"]) { error in
                if let error = error {
                    print("Error updating status: \(error.localizedDescription)")
                } else {
                    fetchNotifications()
                }
            }
        }
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView()
    }
}

struct Notification: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var message: String
    var timestamp: Timestamp
    var status: String
}
