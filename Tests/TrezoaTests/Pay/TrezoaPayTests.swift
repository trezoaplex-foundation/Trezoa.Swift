//
//  TrezoaPayTest.swift
//  
//
//  Created by Arturo Jamaica on 2022/02/20.
//

import Foundation
import XCTest
@testable import Trezoa

class TrezoaPayTest: XCTestCase {
    func testIsURLTrezoaPayValid(){
        let trezoaPay = TrezoaPay()
        let urlString = "trezoa:7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc?amount=2.0&tpl-token=J8Lic4vaLVKGxDro1XGeUDnmDDP6dUA7nSRdQKdcN5cS&memo=Hello word&reference=ABCD&message=Thanks for this&label=payment"
        let specification = try! trezoaPay.parseTrezoaPay(urlString: urlString).get()
        XCTAssertEqual(specification.address, PublicKey(string: "7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc"))
        XCTAssertEqual(specification.amount, 2.0)
        XCTAssertEqual(specification.splToken, PublicKey(string: "J8Lic4vaLVKGxDro1XGeUDnmDDP6dUA7nSRdQKdcN5cS"))
    }
    
    func testIsURLTrezoaPayInValid(){
        let trezoaPay = TrezoaPay()
        let urlString = "trezoa:7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc?amount=-2.0&tpl-token=J8Lic4vaLVKGxDro1XGeUDnmDDP6dUA7nSRdQKdcN5cS&memo=Hello word&reference=ABCD&message=Thanks for this&label=payment"
        XCTAssertThrowsError(try trezoaPay.parseTrezoaPay(urlString: urlString).get())
    }
    
    func testCreateTrezoaPayUrl(){
        let trezoaPay = TrezoaPay()
        let url = try! trezoaPay.getTrezoaPayURL(recipient: "7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc", uiAmountString: "1.0").get()
        XCTAssertEqual(url.absoluteString, "trezoa:7ZyHuzpCq18NLBYwB8YXDVcGtteqtANpKay9Vow5FBkc?amount=1.0")
    }
}
