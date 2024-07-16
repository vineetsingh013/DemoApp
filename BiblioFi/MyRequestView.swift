import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MyRequestView: View {
    @State private var requests = [Request]()
    @State private var selectedSegment = 0
    @State private var memberId: String = Auth.auth().currentUser?.uid ?? ""
    @State private var timer: Timer? = nil
    
    var body: some View {
        
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#ffffff"), Color(hex: "#f1d4cf")]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Picker("Requests", selection: $selectedSegment) {
                    Text("All Requests").tag(0)
                    Text("Approved Books").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                .foregroundColor(Color(hex: "9E6028"))
                
                if selectedSegment == 0 {
                    List(requests.filter { $0.typeOfRequest == .issue && ($0.state == 0 || $0.state == 4) }) { request in
                        VStack(alignment: .leading) {
                            Text("Book: \(request.bookName)")
                            Text("Issue Status: \(request.issueStatus.rawValue)")
                                .foregroundColor(statusColor(request.issueStatus))
                        }
                    }
                } else {
                    List(requests.filter { $0.state == 2 || $0.state == 3 || $0.state == 1 || $0.state == 4 || $0.state == 5 }) { request in
                        VStack(alignment: .leading) {
                            Text("Book ID: \(request.bookId)")
                            Text("Book Name: \(request.bookName)")
                            
                            if request.returnStatus != .pending {
                                Text("Return Status: \(request.returnStatus.rawValue)")
                                    .foregroundColor(statusColor(request.returnStatus))
                            }
                            
                            // Display the status text
                            Text(statusText(for: request))
                                .foregroundColor(.gray)
                                .padding(.bottom, 5)
                            
                            if let timestamp = request.timestamp {
                                if request.returnStatus == .pending {
                                    Text("Time Remaining: \(timeRemaining(from: timestamp))")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            HStack {
                                Button(action: {
                                    print("Return button pressed")
                                    sendReturnRequest(request: request)
                                }) {
                                    Text(buttonText(for: request))
                                        .padding()
                                        .background(buttonBackgroundColor(for: request))
                                        .foregroundColor(buttonTextColor(for: request))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(request.returnStatus == .approved)
                                
                                if request.returnStatus != .approved {
                                    if request.issueStatus != .rejected {
                                        Button(action: {
                                            print("Reissue button pressed")
                                            sendReissueRequest(request: request)
                                        }) {
                                            Text("Reissue Book")
                                                .padding()
                                                .background(Color(hex: "9E6028"))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        .disabled(request.issueStatus == .pending)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                }
            }
            .onAppear {
                fetchMyRequests()
                startTimer()
            }
            .onChange(of: requests) { _ in
                fetchMyRequests()
            }
        }
    }
    
    func fetchMyRequests() {
        let db = Firestore.firestore()
        db.collection("requests")
            .whereField("memberId", isEqualTo: memberId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                } else {
                    self.requests = querySnapshot?.documents.compactMap { document -> Request? in
                        try? document.data(as: Request.self)
                    } ?? []
                }
            }
    }
    
    func sendReturnRequest(request: Request) {
        let db = Firestore.firestore()
        if let documentId = request.id {
            db.collection("requests").document(documentId).updateData(["state": 2, "typeOfRequest": TypeOfRequest.return.rawValue, "returnStatus": ReturnStatus.pending.rawValue]) { error in
                if let error = error {
                    print("Error sending return request: \(error.localizedDescription)")
                } else {
                    print("Return request sent")
                    fetchMyRequests()
                }
            }
        } else {
            print("Request document ID is nil")
        }
    }
    
    func sendReissueRequest(request: Request) {
        let db = Firestore.firestore()
        if let documentId = request.id {
            db.collection("requests").document(documentId).updateData(["state": 4, "typeOfRequest": TypeOfRequest.issue.rawValue, "issueStatus": IssueStatus.pending.rawValue]) { error in
                if let error = error {
                    print("Error sending reissue request: \(error.localizedDescription)")
                } else {
                    print("Reissue request sent")
                    fetchMyRequests()
                }
            }
        } else {
            print("Request document ID is nil")
        }
    }
    
    func statusColor(_ status: IssueStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        }
    }
    
    func statusColor(_ status: ReturnStatus) -> Color {
        switch status {
        case .pending:
            return .blue
        case .approved:
            return .green // Adjust as needed
        }
    }
    
    func buttonText(for request: Request) -> String {
        switch request.returnStatus {
        case .pending:
            return "Return Book"
        case .approved:
            return "Return Approved"
        }
    }
    
    func buttonBackgroundColor(for request: Request) -> Color {
        switch request.returnStatus {
        case .pending:
            return Color(hex: "9E6028")
        case .approved:
            return Color.green
        }
    }
    
    func buttonTextColor(for request: Request) -> Color {
        return Color.white
    }
    
    func statusText(for request: Request) -> String {
        if request.typeOfRequest == .return {
            return "Return request status: \(request.returnStatus.rawValue)"
        } else if request.typeOfRequest == .issue && request.state == 4 {
            return "Reissue request status: \(request.issueStatus.rawValue)"
        } else {
            return "Request status: \(request.issueStatus.rawValue)"
        }
    }
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            checkDueDates()
        }
    }
    
    func checkDueDates() {
        let db = Firestore.firestore()
        let now = Timestamp(date: Date())
        for request in requests {
            if request.issueStatus == .approved, let timestamp = request.timestamp {
                let timeInterval = now.seconds - timestamp.seconds
                if timeInterval >= 7 * 24 * 60 * 60 {
                    if let documentId = request.id {
                        db.collection("requests").document(documentId).updateData(["state": 6, "issueStatus": IssueStatus.rejected.rawValue]) { error in
                            if let error = error {
                                print("Error updating due request: \(error.localizedDescription)")
                            } else {
                                print("Request marked as due")
                                fetchMyRequests()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func timeRemaining(from timestamp: Timestamp) -> String {
        let now = Date()
        let approvalDate = timestamp.dateValue()
        let calendar = Calendar.current
        
        if let dueDate = calendar.date(byAdding: .day, value: 7, to: approvalDate) {
            let components = calendar.dateComponents([.day, .hour, .minute], from: now, to: dueDate)
            if let days = components.day, let hours = components.hour, let minutes = components.minute {
                return "\(days)d \(hours)h \(minutes)m"
            }
            
        }
        return "Time Expired"
    }
    
}

struct MyRequestView_Previews: PreviewProvider {
    static var previews: some View {
        MyRequestView()
    }
}
