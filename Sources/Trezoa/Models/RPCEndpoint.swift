import Foundation

public struct RPCEndpoint: Hashable, Codable {
    public let url: URL
    public let urlWebSocket: URL
    public let network: Network
    public init(url: URL, urlWebSocket: URL, network: Network) {
        self.url = url
        self.urlWebSocket = urlWebSocket
        self.network = network
    }

    public static let mainnetBetaTrezoa = RPCEndpoint(url: URL(string: "https://api.mainnet-beta.trezoa.com")!, urlWebSocket: URL(string: "wss://api.mainnet-beta.trezoa.com")!, network: .mainnetBeta)
    public static let devnetTrezoa = RPCEndpoint(url: URL(string: "https://api.devnet.trezoa.com")!, urlWebSocket: URL(string: "wss://api.devnet.trezoa.com")!, network: .devnet)
    public static let testnetTrezoa = RPCEndpoint(url: URL(string: "https://api.testnet.trezoa.com")!, urlWebSocket: URL(string: "wss://api.testnet.trezoa.com")!, network: .testnet)
}
