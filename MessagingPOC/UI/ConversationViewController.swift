//
//  ConversationViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseFirestore

// MARK: - Message

private struct Message: Equatable {
    let id: String
    let text: String
    let isRead: Bool
    let sent: Date
    let from: String
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let text = data["text"] as? String,
            let isRead = data["is_read"] as? Bool,
            let timestamp = data["time"] as? Timestamp,
            let sender = data["sender"] as? [String: Any],
            let from = sender["id"] as? String
            else {
                return nil
        }
        
        self.id = snapshot.documentID
        self.text = text
        self.isRead = isRead
        self.sent = timestamp.dateValue()
        self.from = from
    }
}

// MARK: - ConversationViewController

final class ConversationViewController: UITableViewController {
    
    // TODO: user real id
    private let userId: String = "123"
    
    var conversationId: String?
    
    private var conversationSubscription: ListenerRegistration?
    
    private var messages: [Message] = [] {
        didSet {
            // TODO: support diffing / updating
            tableView.reloadData()
        }
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let conversationId = self.conversationId else {
            preconditionFailure("conversationId must be set before being presented")
        }
        
        conversationSubscription = Firestore.defaultStore
            .collection("/users/\(userId)/messages")
            .whereField("conversation_id", isEqualTo: conversationId)
            .whereField("is_blocked", isEqualTo: false)
            .whereField("is_deleted", isEqualTo: false)
            .order(by: "time", descending: true)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                
                if let error = error {
                    print(error)
                    // TODO: Handle error
                } else if let documentSnapshot = documentSnapshot{
                    
                    self?.messages = documentSnapshot.documents.compactMap {
                        Message(snapshot: $0)
                    }
                }
        }
    }
    
    deinit {
        conversationSubscription?.remove()
        conversationSubscription = nil
    }
    
    // MARK: - UITableViewControllerDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TODO: custom cell with config method
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        guard let message = messages[safe: indexPath.row] else { return cell }
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = "From: \(message.from)"
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let message = messages[safe: indexPath.row] else { return }
        
        Firestore.defaultStore.collection("users/\(userId)/messages").document(message.id).updateData(["is_read": true]) { error in
            if let error = error {
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
