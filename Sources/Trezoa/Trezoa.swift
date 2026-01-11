import Foundation

public protocol TrezoaAccountStorage {
    func save(_ signer: Signer) -> Result<Void, Error>
    var account: Result<Signer, Error> { get }
    func clear() -> Result<Void, Error>
}

public class Trezoa {
    let router: TrezoaRouter
    public let socket: TrezoaSocket
    public let api: Api
    public let action: Action
    public let tokens: TokenInfoProvider

    public init(
        router: TrezoaRouter,
        tokenProvider: TokenInfoProvider = EmptyInfoTokenProvider()
    ) {
        self.router = router
        self.socket = TrezoaSocket(endpoint: router.endpoint)
        self.tokens = tokenProvider
        self.api = Api(router: router, supportedTokens: self.tokens.supportedTokens)
        self.action = Action(api: self.api, router: router, supportedTokens: self.tokens.supportedTokens)
    }
}

public class Api {
    internal let router: TrezoaRouter
    internal let supportedTokens: [Token]

    public init(router: TrezoaRouter, supportedTokens: [Token]) {
        self.router = router
        self.supportedTokens = supportedTokens
    }
}

public class Action {
    internal let api: Api
    internal let router: TrezoaRouter
    internal let supportedTokens: [Token]

    public init(api: Api, router: TrezoaRouter, supportedTokens: [Token]) {
        self.router = router
        self.supportedTokens = supportedTokens
        self.api = api
    }
}
