//
//  FeedlyOrganiseParsedItemsByFeedOperationTests.swift
//  AccountTests
//
//  Created by Kiel Gillard on 24/10/19.
//  Copyright © 2019 Ranchero Software, LLC. All rights reserved.
//

import XCTest
@testable import Account
import RSParser
import RSCore

class FeedlyOrganiseParsedItemsByFeedOperationTests: XCTestCase {
	
	private var account: Account!
	private let support = FeedlyTestSupport()
	
	override func setUp() {
		super.setUp()
		account = support.makeTestAccount()
	}
	
	override func tearDown() {
		if let account = account {
			support.destroy(account)
		}
		super.tearDown()
	}
	
	struct TestParsedItemsProvider: FeedlyParsedItemProviding {
		let parsedItemProviderName = "TestParsedItemsProvider"
		var resource: FeedlyResourceID
		var parsedEntries: Set<ParsedItem>
	}
	
	func testNoEntries() {
		let entries = support.makeParsedItemTestDataFor(numberOfFeeds: 0, numberOfItemsInFeeds: 0)
		let resource = FeedlyCategoryResourceID(id: "user/12345/category/6789")
		let parsedEntries = Set(entries.values.flatMap { $0 })
		let provider = TestParsedItemsProvider(resource: resource, parsedEntries: parsedEntries)
		
		let organise = FeedlyOrganiseParsedItemsByFeedOperation(account: account, parsedItemProvider: provider, log: support.log)
		
		let completionExpectation = expectation(description: "Did Finish")
		organise.completionBlock = { _ in
			completionExpectation.fulfill()
		}
		
		MainThreadOperationQueue.shared.add(organise)
		
		waitForExpectations(timeout: 2)
		
		let itemsAndFeedIDs = organise.parsedItemsKeyedByFeedID
		XCTAssertEqual(itemsAndFeedIDs, entries)
	}
	
	func testGroupsOneEntryByFeedID() {
		let entries = support.makeParsedItemTestDataFor(numberOfFeeds: 1, numberOfItemsInFeeds: 1)
		let resource = FeedlyCategoryResourceID(id: "user/12345/category/6789")
		let parsedEntries = Set(entries.values.flatMap { $0 })
		let provider = TestParsedItemsProvider(resource: resource, parsedEntries: parsedEntries)
		
		let organise = FeedlyOrganiseParsedItemsByFeedOperation(account: account, parsedItemProvider: provider, log: support.log)
		
		let completionExpectation = expectation(description: "Did Finish")
		organise.completionBlock = { _ in
			completionExpectation.fulfill()
		}
		
		MainThreadOperationQueue.shared.add(organise)
		
		waitForExpectations(timeout: 2)
		
		let itemsAndFeedIDs = organise.parsedItemsKeyedByFeedID
		XCTAssertEqual(itemsAndFeedIDs, entries)
	}
	
	func testGroupsManyEntriesByFeedID() {
		let entries = support.makeParsedItemTestDataFor(numberOfFeeds: 100, numberOfItemsInFeeds: 100)
		let resource = FeedlyCategoryResourceID(id: "user/12345/category/6789")
		let parsedEntries = Set(entries.values.flatMap { $0 })
		let provider = TestParsedItemsProvider(resource: resource, parsedEntries: parsedEntries)
		
		let organise = FeedlyOrganiseParsedItemsByFeedOperation(account: account, parsedItemProvider: provider, log: support.log)
		
		let completionExpectation = expectation(description: "Did Finish")
		organise.completionBlock = { _ in
			completionExpectation.fulfill()
		}
		
		MainThreadOperationQueue.shared.add(organise)
		
		waitForExpectations(timeout: 2)
		
		let itemsAndFeedIDs = organise.parsedItemsKeyedByFeedID
		XCTAssertEqual(itemsAndFeedIDs, entries)
	}
}
