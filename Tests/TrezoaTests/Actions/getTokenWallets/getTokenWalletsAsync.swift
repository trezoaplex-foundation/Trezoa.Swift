import XCTest
import Trezoa

@available(iOS 13.0, *)
@available(macOS 10.15, *)
class getTokenWalletsAsync: XCTestCase {
    var endpoint = RPCEndpoint.devnetTrezoa
    var trezoa: Trezoa!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        trezoa = Trezoa(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testsGetTokenWallets() async throws {
        let wallets = try await trezoa.action.getTokenWallets(account: signer.publicKey.base58EncodedString)
        XCTAssertFalse(wallets.isEmpty)
    }
}
