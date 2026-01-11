import XCTest
@testable import Trezoa

class getMintData: XCTestCase {
    var endpoint = RPCEndpoint.devnetTrezoa
    var trezoa: Trezoa!
    var signer: Signer!

    override func setUpWithError() throws {
        let wallet: TestsWallet = .devnet
        trezoa = Trezoa(router: NetworkingRouter(endpoint: endpoint))
        signer = HotAccount(phrase: wallet.testAccount.components(separatedBy: " "))!
    }
    
    func testGetMintData() {
        let data: Mint? = try! trezoa.action.getMintData(mintAddress: PublicKey(string: "8wzZaGf89zqx7PRBoxk9T6QyWWQbhwhdU555ZxRnceG3")!)?.get()
        XCTAssertNotNil(data)
    }
    
    func testGetMultipleMintDatas() {
        let datas: [PublicKey: Mint]? = try! trezoa.action.getMultipleMintDatas(mintAddresses: [PublicKey(string: "8wzZaGf89zqx7PRBoxk9T6QyWWQbhwhdU555ZxRnceG3")!])?.get()
        XCTAssertNotNil(datas)
    }
    
    func testGetPools() {
        let pools: [Pool]? = try! trezoa.action.getSwapPools()?.get()
        XCTAssertNotNil(pools)
        XCTAssertNotEqual(pools!.count, 0)
    }

    func testMintToInstruction() {
        let publicKey = PublicKey(string: "11111111111111111111111111111111")!
        let instruction = TokenProgram.mintToInstruction(tokenProgramId: publicKey, mint: publicKey, destination: publicKey, authority: publicKey, amount: 1000000000)
        XCTAssertEqual("6AsKhot84V8s", Base58.encode(instruction.data))
    }
}
