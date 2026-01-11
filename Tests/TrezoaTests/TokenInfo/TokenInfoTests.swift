import Foundation
import XCTest
@testable import Trezoa

class TokenInfoTests: XCTestCase {
    var endpoint = RPCEndpoint.mainnetBetaTrezoa
    var trezoaSDK: Trezoa!

    override func setUpWithError() throws {
        let tokenProvider = try! TokenListProvider(path: getFileFrom("TokenInfo/mainnet-beta.tokens"))
        trezoaSDK = Trezoa(router: NetworkingRouter(endpoint: endpoint), tokenProvider: tokenProvider)
    }
    
    func testCloseAccountInstruction() {
        XCTAssert(trezoaSDK.tokens.supportedTokens.count > 1000)
    }
}

func getFileFrom(_ filename: String) -> URL {
    @objc class TrezoaTests: NSObject { }
    let thisSourceFile = URL(fileURLWithPath: #file)
    let thisDirectory = thisSourceFile.deletingLastPathComponent()
    let resourceURL = thisDirectory.appendingPathComponent("../Resources/\(filename).json")
    return resourceURL
}

