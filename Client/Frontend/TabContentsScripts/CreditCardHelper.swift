// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0

import Foundation
import Shared
import WebKit
import Common

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
        // TODO: FXIOS-6125 - Retrieve response value from user selected credit card
        guard (message.body as? [String: Any]) != nil else { return }
        guard message.body is [String: Any] else { return }
        // TODO: FXIOS-6125 - Check payload received from JS and parse it
        //
        // Example value: [
        //     "data": [
        //         "cc-name": "Jane Doe",
        //         "cc-number": "5555555555554444",
        //         "cc-exp-month": "05",
        //         "cc-exp-year": "2028",
        //       ],
        //     "id": request["id"]!,
        // ]
    }
}
