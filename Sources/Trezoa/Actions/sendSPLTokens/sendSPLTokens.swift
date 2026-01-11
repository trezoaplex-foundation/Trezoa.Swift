import Foundation

extension Action {
    public func sendTPLTokens(
        mintAddress: String,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        allowUnfundedRecipient: Bool = false,
        payer: Signer,
        onComplete: @escaping (Result<TransactionID, Error>) -> Void
    ) {

        ContResult.init { cb in
            self.findTPLTokenDestinationAddress(
                mintAddress: mintAddress,
                destinationAddress: destinationAddress,
                allowUnfundedRecipient: allowUnfundedRecipient
            ) { cb($0) }
        }.flatMap { (destination, isUnregisteredAsocciatedToken) in

            let toPublicKey = destination

            // catch error
            guard fromPublicKey != toPublicKey.base58EncodedString else {
                return .failure(TrezoaError.invalidPublicKey)
            }

            guard let fromPublicKey = PublicKey(string: fromPublicKey) else {
                return .failure( TrezoaError.invalidPublicKey)
            }
            var instructions = [TransactionInstruction]()

            // create associated token address
            if isUnregisteredAsocciatedToken {
                guard let mint = PublicKey(string: mintAddress) else {
                    return .failure(TrezoaError.invalidPublicKey)
                }
                guard let owner = PublicKey(string: destinationAddress) else {
                    return .failure(TrezoaError.invalidPublicKey)
                }

                let createATokenInstruction = AssociatedTokenProgram.createAssociatedTokenAccountInstruction(
                    mint: mint,
                    associatedAccount: toPublicKey,
                    owner: owner,
                    payer: payer.publicKey
                )
                instructions.append(createATokenInstruction)
            }

            // send instruction
            let sendInstruction = TokenProgram.transferInstruction(
                tokenProgramId: .tokenProgramId,
                source: fromPublicKey,
                destination: toPublicKey,
                owner: payer.publicKey,
                amount: amount
            )

            instructions.append(sendInstruction)
            return .success((instructions: instructions, account: payer))

        }.flatMap { (instructions, account) in
            ContResult.init { cb in
                self.serializeAndSendWithFee(instructions: instructions, signers: [account]) {
                    cb($0)
                }
            }
        }.run(onComplete)
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
    func sendTPLTokens(
        mintAddress: String,
        decimals: Decimals,
        from fromPublicKey: String,
        to destinationAddress: String,
        amount: UInt64,
        allowUnfundedRecipient: Bool = false,
        payer: Signer
    ) async throws -> TransactionID {
        try await withCheckedThrowingContinuation { c in
            self.sendTPLTokens(
                mintAddress: mintAddress,
                from: fromPublicKey,
                to: destinationAddress,
                amount: amount,
                allowUnfundedRecipient: allowUnfundedRecipient,
                payer: payer,
                onComplete: c.resume(with:)
            )
        }
    }
}

extension ActionTemplates {
    public struct SendTPLTokens: ActionTemplate {
        public let mintAddress: String
        public let fromPublicKey: String
        public let destinationAddress: String
        public let amount: UInt64
        public let payer: Signer
        public let allowUnfundedRecipient: Bool

        public typealias Success = TransactionID

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
            actionClass.sendTPLTokens(mintAddress: mintAddress, from: fromPublicKey, to: destinationAddress, amount: amount, allowUnfundedRecipient: allowUnfundedRecipient, payer: payer, onComplete: completion)
        }
    }
}
