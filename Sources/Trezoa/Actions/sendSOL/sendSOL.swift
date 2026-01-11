import Foundation

extension Action {
    public func sendTRZ(
        to destination: String,
        from: Signer,
        amount: UInt64,
        allowUnfundedRecipient: Bool = false,
        onComplete: @escaping ((Result<TransactionID, Error>) -> Void)
    ) {
        let account = from
        let fromPublicKey = account.publicKey
        if fromPublicKey.base58EncodedString == destination {
            onComplete(.failure(TrezoaError.other("You can not send tokens to yourself")))
            return
        }

        // check

        api.getAccountInfo(account: destination, decodedTo: EmptyInfo.self,
                                         allowUnfundedRecipient: allowUnfundedRecipient) { resultInfo in
            if case let Result.failure(error) = resultInfo {
                if let trezoaError = error as? TrezoaError,
                   case TrezoaError.couldNotRetriveAccountInfo = trezoaError {
                    // let request through
                } else {
                    onComplete(.failure(error))
                    return
                }
            }
            if allowUnfundedRecipient == false {
                guard case let Result.success(info) = resultInfo else {
                    onComplete(.failure(TrezoaError.couldNotRetriveAccountInfo))
                    return
                }

                guard info?.owner == PublicKey.systemProgramId.base58EncodedString else {
                    onComplete(.failure(TrezoaError.other("Invalid account info")))
                    return
                }
            }
            guard let to = PublicKey(string: destination) else {
                onComplete(.failure(TrezoaError.invalidPublicKey))
                return
            }

            let instruction = SystemProgram.transferInstruction(
                from: fromPublicKey,
                to: to,
                lamports: amount
            )
            self.serializeAndSendWithFee(
                instructions: [instruction],
                signers: [account]
            ) {
                switch $0 {
                case let .success(transaction):
                    onComplete(.success(transaction))
                case let .failure(error):
                    onComplete(.failure(error))
                }
            }
        }
    }
}

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public extension Action {
    func sendTRZ(
        to destination: String,
        from: Signer,
        amount: UInt64
    ) async throws -> TransactionID {
        try await withCheckedThrowingContinuation { c in
            self.sendTRZ(to: destination, from: from, amount: amount, onComplete: c.resume(with:))
        }
    }
}

extension ActionTemplates {
    public struct SendSOL: ActionTemplate {
        public init(amount: UInt64, destination: String, from: Signer) {
            self.amount = amount
            self.destination = destination
            self.from = from
        }

        public typealias Success = TransactionID
        public let amount: UInt64
        public let destination: String
        public let from: Signer

        public func perform(withConfigurationFrom actionClass: Action, completion: @escaping (Result<TransactionID, Error>) -> Void) {
            actionClass.sendTRZ(to: destination, from: from, amount: amount, onComplete: completion)
        }
    }
}
