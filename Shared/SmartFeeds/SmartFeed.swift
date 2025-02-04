//
//  SmartFeed.swift
//  NetNewsWire
//
//  Created by Brent Simmons on 11/19/17.
//  Copyright © 2017 Ranchero Software. All rights reserved.
//

import Foundation
import RSCore
import Articles
import ArticlesDatabase
import Account

final class SmartFeed: PseudoFeed {

	var account: Account? = nil

	public var defaultReadFilterType: ReadFilterType {
		return .none
	}

	var itemID: ItemIdentifier? {
		delegate.itemID
	}

	var nameForDisplay: String {
		return delegate.nameForDisplay
	}

	var unreadCount = 0 {
		didSet {
			if unreadCount != oldValue {
				postUnreadCountDidChangeNotification()
			}
		}
	}

	var smallIcon: IconImage? {
		return delegate.smallIcon
	}
	
	#if os(macOS)
	var pasteboardWriter: NSPasteboardWriting {
		return SmartFeedPasteboardWriter(smartFeed: self)
	}
	#endif

	public let delegate: SmartFeedDelegate
	private var unreadCounts = [String: Int]()

	init(delegate: SmartFeedDelegate) {
		self.delegate = delegate
		NotificationCenter.default.addObserver(self, selector: #selector(unreadCountDidChange(_:)), name: .UnreadCountDidChange, object: nil)
		queueFetchUnreadCounts() // Fetch unread count at startup
	}

	@objc func unreadCountDidChange(_ note: Notification) {
		if note.object is AppDelegate {
			queueFetchUnreadCounts()
		}
	}

	@MainActor @objc func fetchUnreadCounts() {
		let activeAccounts = AccountManager.shared.activeAccounts
		
		// Remove any accounts that are no longer active or have been deleted
		let activeAccountIDs = activeAccounts.map { $0.accountID }
		for accountID in unreadCounts.keys {
			if !activeAccountIDs.contains(accountID) {
				unreadCounts.removeValue(forKey: accountID)
			}
		}
		
		if activeAccounts.isEmpty {
			updateUnreadCount()
		} else {
			for account in activeAccounts {
				fetchUnreadCount(for: account)
			}
		}
	}
	
}

extension SmartFeed: ArticleFetcher {

	func fetchArticles() throws -> Set<Article> {
		return try delegate.fetchArticles()
	}

	func fetchArticlesAsync(_ completion: @escaping ArticleSetResultBlock) {
		delegate.fetchArticlesAsync(completion)
	}

	func fetchUnreadArticles() throws -> Set<Article> {
		return try delegate.fetchUnreadArticles()
	}

	func fetchUnreadArticlesBetween(before: Date? = nil, after: Date? = nil) throws -> Set<Article> {
		return try delegate.fetchUnreadArticlesBetween(before: before, after: after)
	}

	func fetchUnreadArticlesAsync(_ completion: @escaping ArticleSetResultBlock) {
		delegate.fetchUnreadArticlesAsync(completion)
	}
}

private extension SmartFeed {

	func queueFetchUnreadCounts() {
		Task { @MainActor in
			CoalescingQueue.standard.add(self, #selector(fetchUnreadCounts))
		}
	}

	@MainActor func fetchUnreadCount(for account: Account) {
		delegate.fetchUnreadCount(for: account) { singleUnreadCountResult in
			guard let accountUnreadCount = try? singleUnreadCountResult.get() else {
				return
			}
			self.unreadCounts[account.accountID] = accountUnreadCount
			self.updateUnreadCount()
		}
	}

	@MainActor func updateUnreadCount() {
		unreadCount = AccountManager.shared.activeAccounts.reduce(0) { (result, account) -> Int in
			if let oneUnreadCount = unreadCounts[account.accountID] {
				return result + oneUnreadCount
			}
			return result
		}
	}
}
