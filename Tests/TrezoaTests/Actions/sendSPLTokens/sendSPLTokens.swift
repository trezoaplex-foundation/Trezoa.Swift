import XCTest
import Trezoa

class sendTPLTokens: XCTestCase {
    var endpoint = RPCEndpoint.devnetTrezoa
    var trezoa: Trezoa!
    var signer: Signer!
    
    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        trezoa = Trezoa(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
        _ = try trezoa.api.requestAirdrop(account: signer.publicKey.base58EncodedString, lamports: 100.toLamport(decimals: 9))?.get()
    }
    
    func testSendTPLTokenWithFee() {
        let mintAddress = "6AUM4fSvCAxCugrbJPFxTqYFp9r3axYx973yoSyzDYVH"
        let source = "8hoBQbSFKfDK3Mo7Wwc15Pp2bbkYuJE8TdQmnHNDjXoQ"
        let destination = "8Poh9xusEcKtmYZ9U4FSfjrrrQR155TLWGAsyFWjjKxB"
        
        let transactionId = try! trezoa.action.sendTPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: source,
            to: destination,
            amount: Double(0.001).toLamport(decimals: 5),
            payer: signer
        )?.get()
        XCTAssertNotNil(transactionId)
        
        let transactionIdB = try! trezoa.action.sendTPLTokens(
            mintAddress: mintAddress,
            decimals: 5,
            from: destination,
            to: source,
            amount: Double(0.001).toLamport(decimals: 5),
            payer: signer
        )?.get()
        XCTAssertNotNil(transactionIdB)
    }
}
