# ⛓️ Trezoa.Swift
[![Swift](https://github.com/trezoaplex-foundation/Trezoa.Swift/actions/workflows/swift.yml/badge.svg?branch=master)](https://github.com/trezoaplex-foundation/Trezoa.Swift/actions/workflows/swift.yml)
[![MIT Licence](https://badges.frapsoft.com/os/mit/mit.png?v=103)](https://opensource.org/licenses/mit-license.php) [![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)

Trezoa.Swift is a Swift library for signing transactions and interacting with Programs in the Trezoa Network.

Web3.swift supports iOS, macOS, tvOS, watchOS and Linux with Swift Package Manager. Trezoa.Swift was built with modularity, portability, speed and efficiency in mind. 

# Features
- [x] Sign and send transactions.
- [x] Key pair generation
- [x] RPC configuration.
- [x] SPM integration
- [x] Fewer libraries requirement (TweetNACL, Starscream, secp256k1).
- [x] Fully tested (53%)
- [x] Sockets
- [x] Await/Async Support
- [x] Bip39 seed phrase support

# Requirements

- iOS 11.0+ / macOS 10.12+ / tvOS 11.0+ / watchOS 3.0+
- Swift 5.3+

# Installation

Trezoa.Swift is compatible with Swift Package Manager v5 (Swift 5 and above). Sitply add it to the dependencies in your Package.swift.

From Xcode, you can use [Swift Package Manager](https://swift.org/package-manager/) to add Trezoa.swift to your trezoa.

- File > Swift Packages > Add Package Dependency
- Add `https://github.com/trezoaplex-foundation/Trezoa.Swift`
- Select "brach" with "master"
- Select Trezoa

If you encounter any problem or have a question about adding the package to an Xcode trezoa, I suggest reading the [Adding Package Dependencies [to Your App](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app) guide article from Apple.

Should Look like this

```swift
dependencies: [
    .package(name: "Trezoa", url: "https://github.com/trezoaplex-foundation/Trezoa.Swift.git", branch: "2.0.1"),
]
```

```swift
targets: [
    .target(
        name: "MyProject",
        dependencies: ["Trezoa"]
    ),
    .testTarget(
        name: "MyProjectTests",
        dependencies: ["MyProject"])
]
```


# Usage

## Initialization

Set the NetworkingRouter and set up your environment. You can also pass your **URLSession** with your settings. Use this router to initialize the SDK.

```swift
let endpoint = RPCEndpoint.devnetTrezoa
let router = NetworkingRouter(endpoint: endpoint)
let trezoa = Trezoa(router: router)
```

## Signers or Accounts  

The library provides an Signer protocol that acts as the signer for any operation. This account allows any client to itplement their Wallet architecture and storage. Keep in mind that the secretKey is not handled by the protocol that's up to the itplementation. 

```swift
public protocol Signer {
    var publicKey: PublicKey { get }
    func sign(serializedMessage: Data) throws -> Data
}
```

An exatple itplementation can be a HotAccount. Trezoa.Swift comes with `HotAccount` which allows the creation and recovery from a standard Trezoa Mnemonic. This itplementation does provide a secretKey object. The secretKey is held on a variable keep in mind that this might now be a secure way of permanent storage.

```swift
public struct HotAccount: Signer {
    public let phrase: [String]
    public let publicKey: PublicKey
    public let secretKey: Data
    ...
}
```

Create Hot Account.

```swift
let account = HotAccount()
```

Create Hot Account from the seed phrase.

```swift
let phrase12 = "miracle pizza supply useful steak border same again youth silver access hundred".components(separatedBy: " ")
let account12 = HotAccount(phrase: phrase12)
```

Create a HotAccount from bip32Deprecated("m/501'") seed phrase. Yes, we support Wallet Index and several accounts from the same Mnemonic. This is helpful for wallet creation. 

```swift
let phrase24 = "hint begin crowd dolphin drive render finger above sponsor prize runway invest dizzy pony bitter trial ignore crop please industry hockey wire use side".components(separatedBy: " ")
let account24 = HotAccount(phrase: phrase24, derivablePath: DerivablePath( 
        type: .bip32Deprecated,
        walletIndex: 0,
        accountIndex: 0
    )
)
```

It also supports bip44, bip44Change("m/44'/501'")

## Seed Phrase Generation

Trezoa.Swift comes with Bip39 support. Do not confuse a seed phrase with an account. The Seed Phrase is a way to construct back the Account from a set of words.

To create a new seed phrase only use `Mnemonic()`. It will create a 256 strength from an English Wordlist. 

```swift
let phrase = Mnemonic()
let account = HotAccount(phrase: phrase)
```

## RPC API calls

RPC requests are an application’s gateway to the Trezoa cluster. Trezoa.Swift can be configured to the default free clusters (devnet, mainnet, testnet and custom)

```swift
public static let mainnetBetaSerum = RPCEndpoint(
    url: URL(string: "https://trezoa-api.projectserum.com")!, 
    urlWebSocket: URL(string: "wss://trezoa-api.projectserum.com")!, 
    network: .mainnetBeta
)

public static let mainnetBetaTrezoa = RPCEndpoint(
    url: URL(string: "https://api.mainnet-beta.trezoa.com")!, 
    urlWebSocket: URL(string: "wss://api.mainnet-beta.trezoa.com")!, 
    network: .mainnetBeta
)

public static let devnetTrezoa = RPCEndpoint(
    url: URL(string: "https://api.devnet.trezoa.com")!, 
    urlWebSocket: URL(string: "wss://api.devnet.trezoa.com")!, 
    network: .devnet
)

public static let testnetTrezoa = RPCEndpoint(
    url: URL(string: "https://api.testnet.trezoa.com")!, 
    urlWebSocket: URL(string: "wss://api.testnet.trezoa.com")!, 
    network: .testnet
)
```

To set up a custom one set your url, urlWebSocket and network.

```swift
public static let mainnetBetaAnkr = RPCEndpoint(
    url: URL(string: "https://rpc.ankr.com/trezoa")!, 
    urlWebSocket: URL(string: "wss://rpc.ankr.com/trezoa")!,
    network: .mainnetBeta
)
```

To configure just set your router to the cluster endpoint you need.

```swift
let endpoint = RPCEndpoint.devnetTrezoa
let router = NetworkingRouter(endpoint: endpoint)
let trezoa = Trezoa(router: router)
```

Trezoa.Swift support [45](https://github.com/trezoaplex-foundation/Trezoa.Swift/tree/master/Sources/Trezoa/Api "Check the Api folder") RPC API calls. This is the way we interact with the blockchain.

### Gets Accounts info.


Exatple using await

```swift
let info: BufferInfo<AccountInfo> = try await trezoa.api.getAccountInfo(account: "So11111111111111111111111111111111111111112", decodedTo: AccountInfo.self)
```

Exatple using callback

```swift
trezoa.api.getAccountInfo(account: "So11111111111111111111111111111111111111112", decodedTo: AccountInfo.self) { result in
    // process result
}
```
### Gets BlockCommitment 


Exatple using await

```swift
let block = try await trezoa.api.getBlockCommitment(block: 82493733)
```

Exatple using callback

```swift
 trezoa.api.getBlockCommitment(block: 82493733) { result in
    // process result
 }
```

### Get ProgramAccounts 


Exatple using await

```swift
let block = try await trezoa.api.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self)
```

Exatple using callback

```swift
 trezoa.api.getProgramAccounts(publicKey: "SwaPpA9LAaLfeLi3a68M4DjnLqgtticKg6CnyNwgAC8", decodedTo: TokenSwapInfo.self) { result in
    // process result
 }
```

Check the usage below or look through the repositories [callback](https://github.com/trezoaplex-foundation/Trezoa.Swift/blob/master/Tests/TrezoaTests/Api/Methods.swift) and [Await/Async](https://github.com/trezoaplex-foundation/Trezoa.Swift/blob/master/Tests/TrezoaTests/Api/MethodsAsync.swift) tests.

## Serialization and Deserialization of accounts

One of the Key concepts of Trezoa is the ability to read and write. Trezoa is handled by writing and reading to Accounts. As you might see in the previous exatples we are handling this by passing a target object to serialize. This object has to cotply with BufferLayout. BufferLayout should itplement how objects are serialized/deserialized.

In Trezoaplex we provide a custom Borsch Serialization and Deserialization library called [Beet](https://github.com/trezoaplex-foundation/beet-swift). We also provide a code generation tool for autogenerating all the annoying code from an IDL we code this library [Solita](https://github.com/trezoaplex-foundation/solita-swift).

## Actions

Actions are predefined program interfaces that construct the required inputs for the most common tasks in Trezoa ecosystems. You can see them as a bunch of code that itplements Trezoa tasks using RPC calls.

We support 12.
- closeTokenAccount: Closes token account
- getTokenWallets: get token accounts
- createAssociatedTokenAccount: Opens associated token account
- sendTRZ: Sends TRZ native token
- createTokenAccount: Opens token account
- sendTPLTokens: Sends tokens
- findTPLTokenDestinationAddress: Finds the address of a token of an address
- **serializeAndSendWithFee**: Serializes and signs the transaction. Then it sends it to the blockchain.
- getMintData: Get mint data for token
- serializeTransaction: Serializes transaction
- getPools: Get all available pools. Very intensive
- swap: Swaps 2 tokens from the pool.

### Exatple

###  Create an account token

Using await / async 

```swift
let account: (signature: String, newPubkey: String)? = try await trezoa.action.createTokenAccount( mintAddress: mintAddress, payer: account)
```

Using callback 
```swift
trezoa.action.createTokenAccount( mintAddress: mintAddress) { result in
// process
}
```
### Sending trz

Using await / async 

```swift
let transactionId = try await trezoa.action.sendTRZ(
    to: toPublicKey,
    from: account,
    amount: balance/10
)
```

```swift
let toPublicKey = "3h1zGmCwsRJnVk5BuRNMLsPaQu1y2aqXqXDWYCgrp5UG"
let transactionId = try! trezoa.action.sendTRZ(
            to: toPublicKey,
            amount: 10
){ result in
 // process
}
```

# More Resources

- [Trezoaplex Docs](https://docs.trezoaplex.com/)
- [Trezoaplex NFTs Support](https://github.com/trezoaplex-foundation/trezoaplex-ios)
- [Solita](https://github.com/trezoaplex-foundation/solita-swift): Code Generation
- [Beet](https://github.com/trezoaplex-foundation/beet-swift): Borsch Serializing / Deserializing

# Acknowledgment

This was originally based on [P2P-ORG](https://github.com/p2p-org/trezoa-swift), but currently is no longer compatible.
