// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import Shared
import WebKit
import Common
import Storage

enum ValidFieldType: String, CaseIterable {
    case ccNumber = "cc-number"
    case ccExpMonth = "cc-exp-month"
    case ccExpYear = "cc-exp-year"
    case ccName = "cc-name"
}

struct Payload: Codable {
    let id: Int
    let fieldTypes: [FieldType]
}

struct FieldType: Codable {
    let type: String
    let value: String
}

struct FillCreditCardForm: Codable {
    let payload: Payload
    let type: String
}


class CreditCardHelper: TabContentScript {
    private weak var tab: Tab?
    private var logger: Logger = DefaultLogger.shared

    class func name() -> String {
        return "CreditCardHelper"
    }

    required init(tab: Tab) {
        self.tab = tab
    }

    func scriptMessageHandlerName() -> String? {
        return "creditCardMessageHandler"
    }

    func userContentController(_ userContentController: WKUserContentController,
                               didReceiveScriptMessage message: WKScriptMessage) {
        guard let data = message.body as? [String: Any] else { return }
        guard let fieldTypes = parseFieldType(messageBody: data) else { return }
        let fieldTypeValues = getFieldTypeValues(fieldTypes: fieldTypes)
    }

    func parseFieldType(messageBody: [String: Any]) -> [FieldType]? {
        let decoder = JSONDecoder()

        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: messageBody, options: .prettyPrinted)
            let fillCreditCardForm = try decoder.decode(FillCreditCardForm.self,
                                                        from: jsonData)
            let fieldTypes = fillCreditCardForm.payload.fieldTypes
            return fieldTypes
        } catch {
            logger.log("Unable to parse field type for CC",
                       level: .warning,
                       category: .webview)
        }

        return nil
    }

    func getFieldTypeValues(fieldTypes: [FieldType]) -> UnencryptedCreditCardFields {
        var ccPlainText = UnencryptedCreditCardFields()
        fieldTypes.forEach { field in
            if let fieldType = ValidFieldType(rawValue: field.type) {
                switch fieldType {
                case .ccName:
                    ccPlainText.ccName = field.value
                case .ccExpMonth:
                    let val = field.value.filter { $0.isNumber }
                    ccPlainText.ccExpMonth = Int64(val) ?? 0
                case .ccExpYear:
                    let val = field.value.filter { $0.isNumber }
                    ccPlainText.ccExpYear = Int64(val) ?? 0
                case .ccNumber:
                    let val = field.value.filter { $0.isNumber }
                    ccPlainText.ccNumber = "\(val)"
                }
            }
        }
        return ccPlainText
    }
}
