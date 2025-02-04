//
//  FeedlyOrganiseParsedItemsByFeedOperation.swift
//  Account
//
//  Created by Kiel Gillard on 20/9/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import Foundation
import RSParser
import RSCore

protocol FeedlyParsedItemsByFeedProviding {
	var parsedItemsByFeedProviderName: String { get }
	var parsedItemsKeyedByFeedID: [String: Set<ParsedItem>] { get }
}

/// Group articles by their feeds.
final class FeedlyOrganiseParsedItemsByFeedOperation: FeedlyOperation, FeedlyParsedItemsByFeedProviding, Logging {

	private let account: Account
	private let parsedItemProvider: FeedlyParsedItemProviding
	
	var parsedItemsByFeedProviderName: String {
		return name ?? String(describing: Self.self)
	}
	
	var parsedItemsKeyedByFeedID: [String : Set<ParsedItem>] {
		precondition(Thread.isMainThread) // Needs to be on main thread because Feed is a main-thread-only model type.
		return itemsKeyedByFeedID
	}
	
	private var itemsKeyedByFeedID = [String: Set<ParsedItem>]()
	
	init(account: Account, parsedItemProvider: FeedlyParsedItemProviding) {
		self.account = account
		self.parsedItemProvider = parsedItemProvider
	}
	
	override func run() {
		defer {
			didFinish()
		}

		let items = parsedItemProvider.parsedEntries
		var dict = [String: Set<ParsedItem>](minimumCapacity: items.count)
		
		for item in items {
			let key = item.feedURL
			let value: Set<ParsedItem> = {
				if var items = dict[key] {
					items.insert(item)
					return items
				} else {
					return [item]
				}
			}()
			dict[key] = value
		}
		
        self.logger.debug("Grouped \(items.count, privacy: .public) items by \(dict.count, privacy: .public) feeds for \(self.parsedItemProvider.parsedItemProviderName, privacy: .public).")
		
		itemsKeyedByFeedID = dict
	}
}
