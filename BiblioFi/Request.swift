import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation

enum TypeOfRequest: String, Codable {
    case issue
    case `return`
}

enum IssueStatus: String, Codable {
    case pending
    case approved
    case rejected
}

enum ReturnStatus: String, Codable {
    case pending
    case approved
}

struct Request: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var memberId: String
    var memberEmail: String
    var memberName: String
    var bookId: String
    var bookName: String
    var issueStatus: IssueStatus
    var typeOfRequest: TypeOfRequest
    var returnStatus: ReturnStatus
    var state: Int
    var timestamp: Timestamp?
}


