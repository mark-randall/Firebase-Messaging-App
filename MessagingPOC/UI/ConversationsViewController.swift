//
//  ViewController.swift
//  MessagingPOC
//
//  Created by Mark Randall on 8/8/19.
//  Copyright © 2019 Mark Randall. All rights reserved.
//

import UIKit
import FirebaseFirestore

// MARK: - Conversation

private struct Conversation: Equatable {
    let id: String
    let text: String
    let hasUnreadMessages: Bool
    let lastMessageSend: Date
    
    init?(snapshot: DocumentSnapshot) {
        
        guard
            let data = snapshot.data(),
            let text = data["last_message_text"] as? String,
            let hasUnreadMessages = data["has_unread_messages"] as? Bool,
            let timestamp = data["time"] as? Timestamp
            else {
            return nil
        }
        
        self.id = snapshot.documentID
        self.text = text
        self.hasUnreadMessages = hasUnreadMessages
        self.lastMessageSend = timestamp.dateValue()
    }
}

// MARK: - ConversationsViewController

final class ConversationsViewController: UITableViewController {

    // TODO: user real id
    private let userId: String = "123"
    
    private var conversationsSubscription: ListenerRegistration?
    
    private var conversations: [Conversation] = [] {
        didSet {
            // TODO: support diffing / updating
            tableView.reloadData()
        }
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        conversationsSubscription = Firestore.defaultStore
            .collection("/users/\(userId)/conversations")
            .whereField("is_blocked", isEqualTo: false)
            .whereField("is_deleted", isEqualTo: false)
            .order(by: "time", descending: true)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                
                if let error = error {
                    print(error)
                    // TODO: Handle error
                } else if let documentSnapshot = documentSnapshot{
                    
                    self?.conversations = documentSnapshot.documents.compactMap {
                        Conversation(snapshot: $0)
                    }
                }
            }
    }
    
    deinit {
        conversationsSubscription?.remove()
        conversationsSubscription = nil
    }
    
    // MARK: - UITableViewControllerDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // TODO: custom cell with config method
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        guard let conversation = conversations[safe: indexPath.row] else { return cell }
        cell.textLabel?.text = conversation.text
        cell.detailTextLabel?.text = "@: \(conversation.lastMessageSend)"
        
        if conversation.hasUnreadMessages {
            cell.backgroundColor = .yellow
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard
            let conversation = conversations[safe: indexPath.row],
            let vc: ConversationViewController = try? UIViewController.create(storyboard: "Main", identifier: "ConversationViewController")
            else { return }
        
        vc.conversationId = conversation.id
        show(vc, sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if
            editingStyle == .delete,
            let conversation = conversations[safe: indexPath.row]
        {
            Firestore.defaultStore.collection("users/\(userId)/conversations").document(conversation.id).updateData(["is_deleted": true]) { error in
                
                if let error = error {
                    print(error)
                }
            }
        }
    }
}

