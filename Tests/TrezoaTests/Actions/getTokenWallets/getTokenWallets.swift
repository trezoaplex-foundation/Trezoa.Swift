import XCTest
import Trezoa

class getTokenWallets: XCTestCase {
    var endpoint = RPCEndpoint.devnetTrezoa
    var trezoa: Trezoa!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .getWallets
        trezoa = Trezoa(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testsGetTokenWallets() {
        let wallets = try? trezoa.action.getTokenWallets(account: signer.publicKey.base58EncodedString)?.get()
        XCTAssertNotNil(wallets)
        XCTAssertNotEqual(wallets!.count, 0)
    }
}
