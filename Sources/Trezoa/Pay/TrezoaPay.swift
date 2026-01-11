//
//  TrezoaPay.swift
//  
//
//  Created by Arturo Jamaica on 2022/02/20.
//

import Foundation
let PROTOCOL = "trezoa"
public enum TrezoaPayError: Error {
    case pathNotProvided
    case invalidAmmount
    case unsupportedProtocol
    case canNotParse
    case couldNotDecodeURL
    case other(Error)
}
public class TrezoaPay {
    func getTrezoaPayURL(
        recipient: String,
        uiAmountString: String,
        label: String? = nil,
        message: String? = nil,
        memo: String? = nil,
        reference: String? = nil,
        splToken: String? = nil
    ) -> Result<URL, TrezoaPayError> {
        var trezoaPayURL = "\(PROTOCOL):\(recipient)?amount=\(uiAmountString)"
        if let label = label {
            trezoaPayURL += "&label=\(label)"
        }
        if let message = message {
            trezoaPayURL += "&message=\(message)"
        }
        if let memo = memo {
            trezoaPayURL += "&memo=\(memo)"
        }
        if let reference = reference {
            trezoaPayURL += "&reference=\(reference)"
        }
        if let splToken = splToken {
            trezoaPayURL += "&tpl-token=\(splToken)"
        }
        do {
            guard let url = URL(string: trezoaPayURL) else {
                throw TrezoaPayError.couldNotDecodeURL
            }
            return .success(url)
        } catch TrezoaPayError.couldNotDecodeURL {
            return .failure(TrezoaPayError.couldNotDecodeURL)
        } catch let e {
            return .failure(TrezoaPayError.other(e))
        }
    }

    func parseTrezoaPay(urlString: String) -> Result<TrezoaPaySpecification, TrezoaPayError> {
        let newURL = urlString
            .replacingOccurrences(of: "\(PROTOCOL):", with: "\(PROTOCOL)://")
            .replacingOccurrences(of: "?", with: "/?")
            .replacingOccurrences(of: "%3F", with: "/?")
            .addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        let components = URLComponents(
            url: URL(string: newURL!)!,
            resolvingAgainstBaseURL: false
        )!

        guard components.scheme == PROTOCOL else {
            return .failure(TrezoaPayError.unsupportedProtocol)
        }

        guard let host = components.host, let address = PublicKey(string: host)  else {
            return .failure(TrezoaPayError.pathNotProvided)
        }

        var doubleAmount: Double?
        var splTokenPubKey: PublicKey?
        if let amount: String = getParamURL(components: components, name: "amount") {
            let parsedAmount = Double(amount) ?? -1
            if parsedAmount < 0 {
                return .failure(TrezoaPayError.invalidAmmount)
            }
            doubleAmount = parsedAmount
        }

        let label: String? = getParamURL(components: components, name: "label")
        let message: String? = getParamURL(components: components, name: "message")
        let memo: String? = getParamURL(components: components, name: "memo")
        let reference: String? = getParamURL(components: components, name: "reference")
        if let splToken: String = getParamURL(components: components, name: "tpl-token") {
            splTokenPubKey = PublicKey(string: splToken) ?? nil
        }

        let spec = TrezoaPaySpecification(address: address, label: label, splToken: splTokenPubKey, message: message, memo: memo, reference: reference, amount: doubleAmount)
        return .success(spec)
    }

    private func getParamURL(components: URLComponents, name: String) -> String? {
        return components.queryItems?.first(where: { $0.name == name })?.value
    }
}

public struct TrezoaPaySpecification {
    let address: PublicKey
    let label: String?
    let splToken: PublicKey?
    let message: String?
    let memo: String?
    let reference: String?
    let amount: Double?
}
