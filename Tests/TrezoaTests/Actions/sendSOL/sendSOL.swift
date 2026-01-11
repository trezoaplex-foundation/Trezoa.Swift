import XCTest
import Trezoa

class sendTRZ: XCTestCase {
    var endpoint = RPCEndpoint.devnetTrezoa
    var trezoa: Trezoa!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        trezoa = Trezoa(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))! // 5Zzguz4NsSRFxGkHfM4FmsFpGZiCDtY72zH2jzMcqkJx
    }
    
    func testSendSOLFromBalance() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"

        let balance = try! trezoa.api.getBalance(account: signer.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(balance)

        let transactionId = try! trezoa.action.sendTRZ(
            to: toPublicKey,
            amount: balance!/10,
            from: signer
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOL() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        let transactionId = try! trezoa.action.sendTRZ(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9),
            from: signer
            ,allowUnfundedRecipient: true
        )?.get()
        XCTAssertNotNil(transactionId)
    }
    func testSendSOLIncorrectDestination() {
        let toPublicKey = "XX"
        XCTAssertThrowsError(try trezoa.action.sendTRZ(
            to: toPublicKey,
            amount: 0.001.toLamport(decimals: 9),
            from: signer
        )?.get())
    }
    func testSendSOLBigAmmount() {
        let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
        XCTAssertThrowsError(try trezoa.action.sendTRZ(
            to: toPublicKey,
            amount: 9223372036854775808,
            from: signer
        )?.get())
    }
}
