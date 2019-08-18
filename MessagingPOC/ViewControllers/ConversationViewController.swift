//
//  ConversationViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseFirestore
import os.log
import Crashlytics

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

final class ConversationViewController: UITableViewController, CoordinatorController {
    
    // MARK: - CoordinatorController
    
    weak var coordinatorActionHandler: ActionHandler<MessagingApplicationFlow, ConversationAction>?
    
    // MARK: - Dependencies
    
    var firestore: Firestore!
    
    private let log = OSLog(subsystem: "com.messaging", category: "conversation")
    
    // MARK: - State
    
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
        
        tableView.tableFooterView = UIView()
        
        guard let conversationId = self.conversationId else { preconditionFailure("conversationId must be set before being presented") }
        
        conversationSubscription = firestore
            .collection("/users/\(userId)/messages")
            .whereField("conversation_id", isEqualTo: conversationId)
            .whereField("is_blocked", isEqualTo: false)
            .whereField("is_deleted", isEqualTo: false)
            .order(by: "time", descending: true)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                
                guard let self = self else { return }
                
                if let error = error {
                    os_log("error fetching conversation messages", log: self.log, type: .error)
                    Crashlytics.sharedInstance().recordError(error)
                    //TODO: Handle error
                } else if let documentSnapshot = documentSnapshot{
                    self.messages = documentSnapshot.documents.compactMap { Message(snapshot: $0) }
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
        
        firestore.collection("users/\(userId)/messages").document(message.id).updateData(["is_read": true]) { [weak self] error in
            
            guard let self = self else { return }
            
            if let error = error {
                os_log("error marking message as read", log: self.log, type: .error)
                Crashlytics.sharedInstance().recordError(error)
            } else {
                os_log("message marked as read", log: self.log, type: .info)
            }
        }
    }
}
