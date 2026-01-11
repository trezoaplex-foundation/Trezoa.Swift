import Foundation

extension Action {
    public typealias TPLTokenDestinationAddress = (destination: PublicKey, isUnregisteredAsocciatedToken: Bool)

    public func findTPLTokenDestinationAddress(
        mintAddress: String,
        destinationAddress: String,
        allowUnfundedRecipient: Bool = false,
        onComplete: @escaping (Result<TPLTokenDestinationAddress, Error>) -> Void
    ) {
        if allowUnfundedRecipient {
            checkTPLTokenAccountExistence(
                mintAddress: mintAddress,
                destinationAddress: destinationAddress,
                onComplete: onComplete
            )
        } else {
            findTPLTokenDestinationAddressOfExistingAccount(
                mintAddress: mintAddress,
                destinationAddress: destinationAddress,
                onComplete: onComplete
            )
        }
    }

    fileprivate func checkTPLTokenAccountExistence(
        mintAddress: String,
        destinationAddress: String,
        onComplete: @escaping (Result<TPLTokenDestinationAddress, Error>) -> Void
    ) {
        guard
            let owner = PublicKey(string: destinationAddress),
            let tokenMint = PublicKey(string: mintAddress),
            case let .success(associatedTokenAddress) = PublicKey.associatedTokenAddress(walletAddress: owner, tokenMintAddress: tokenMint)
        else {
            onComplete(.failure(TrezoaError.invalidPublicKey))
            return
        }

        self.api.getAccountInfo(account: associatedTokenAddress.base58EncodedString, decodedTo: AccountInfo.self) { result in
            let hasAssociatedTokenAccount: Bool

            switch result {
            case .failure(let error):
                guard let trezoaError = error as? TrezoaError,
                      case .nullValue = trezoaError
                else {
                    onComplete(.failure(error))
                    return
                }

                hasAssociatedTokenAccount = false
            case .success:
                hasAssociatedTokenAccount = true
            }

            onComplete(.success((associatedTokenAddress, !hasAssociatedTokenAccount)))
        }
    }

    fileprivate func findTPLTokenDestinationAddressOfExistingAccount(
        mintAddress: String,
        destinationAddress: String,
        onComplete: @escaping (Result<TPLTokenDestinationAddress, Error>) -> Void
    ) {
        ContResult<BufferInfo<AccountInfo>, Error>.init { cb in
            self.api.getAccountInfo(
                account: destinationAddress,
                decodedTo: AccountInfo.self
            ) { cb($0) }
        }.flatMap { info in
            let toTokenMint = info.data.value?.mint.base58EncodedString
            var toPublicKeyString: String = ""
            if mintAddress == toTokenMint {
                // detect if destination address is already a TPLToken address
                toPublicKeyString = destinationAddress
            } else if info.owner == PublicKey.systemProgramId.base58EncodedString {
                // detect if destination address is a TRZ address
                guard let owner = PublicKey(string: destinationAddress) else {
                    return .failure(TrezoaError.invalidPublicKey)
                }
                guard let tokenMint = PublicKey(string: mintAddress) else {
                    return .failure(TrezoaError.invalidPublicKey)
                }

                // create associated token address
                guard case let .success(address) = PublicKey.associatedTokenAddress(
                    walletAddress: owner,
                    tokenMintAddress: tokenMint
                ) else {
                    return .failure(TrezoaError.invalidPublicKey)
                }

                toPublicKeyString = address.base58EncodedString
            }

            guard let toPublicKey = PublicKey(string: toPublicKeyString) else {
                return .failure(TrezoaError.invalidPublicKey)
            }

            if destinationAddress != toPublicKey.base58EncodedString {
                // check if associated address is already registered
                return ContResult.init { cb in
                    self.api.getAccountInfo(
                        account: toPublicKey.base58EncodedString,
                        decodedTo: AccountInfo.self
                    ) { cb($0)}
                }.flatMap { info1 in
                    var isUnregisteredAsocciatedToken = true
                    // if associated token account has been registered
                    if info1.owner == PublicKey.tokenProgramId.base58EncodedString &&
                        info.data.value != nil {
                        isUnregisteredAsocciatedToken = false
                    }
                    return .success((destination: toPublicKey, isUnregisteredAsocciatedToken: isUnregisteredAsocciatedToken))
                }
            } else {
                return .success((destination: toPublicKey, isUnregisteredAsocciatedToken: false))
            }
        }.run(onComplete)
    }
}

extension ActionTemplates {
    public struct FindTPLTokenDestinationAddress: ActionTemplate {
        public init(mintAddress: String, destinationAddress: String, allowUnfundedRecipient: Bool) {
            self.mintAddress = mintAddress
            self.destinationAddress = destinationAddress
            self.allowUnfundedRecipient = allowUnfundedRecipient
        }

        public typealias Success = Action.TPLTokenDestinationAddress
        public let mintAddress: String
        public let destinationAddress: String
        public let allowUnfundedRecipient: Bool

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<Action.TPLTokenDestinationAddress, Error>) -> Void) {
            actionClass.findTPLTokenDestinationAddress(mintAddress: mintAddress, destinationAddress: destinationAddress, allowUnfundedRecipient: allowUnfundedRecipient, onComplete: completion)
        }
    }
}
