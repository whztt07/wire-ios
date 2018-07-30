//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation
import WireDataModel
import WireShareEngine
import Intents

/**
 * The object that handles responding to intents.
 */

public class IntentsManager {

    /// Creates a new intents manager.
    public init() {}

    deinit {
        StorageStack.reset()
    }

    // MARK: - Starting the flow

    /**
     * Returns the appropriate handler object for the specified intent.
     *
     * The intent must be of a known type. If the type is unknown, the app will crash.
     */

    public func requestHandler(for intent: INIntent) -> Any {
        let sharingSession = createSharingSession()

        if intent is INSendMessageIntent {
            return SendMessageIntentHandler(sharingSession: sharingSession)
        }

        fatalError("The intents manager does not support \(NSStringFromClass(type(of: intent))).")
    }

    // MARK: - Session

    /// Creates the sharing session to use for sending information.
    private func createSharingSession() -> SharingSession? {
        guard let applicationGroupIdentifier = applicationGroupIdentifier,
            let hostBundleIdentifier = hostBundleIdentifier,
            let account = self.currentAccount
            else { return nil }

        return try? SharingSession(
            applicationGroupIdentifier: applicationGroupIdentifier,
            accountIdentifier: account.userIdentifier,
            hostBundleIdentifier: hostBundleIdentifier
        )
    }

    private var accountManager: AccountManager? {
        guard let applicationGroupIdentifier = applicationGroupIdentifier else { return nil }
        let sharedContainerURL = FileManager.sharedContainerDirectory(for: applicationGroupIdentifier)
        return AccountManager(sharedDirectory: sharedContainerURL)
    }

    private var currentAccount: Account? {
        return accountManager?.selectedAccount
    }

    private var applicationGroupIdentifier: String? {
        return Bundle.main.infoDictionary?["ApplicationGroupIdentifier"] as? String
    }

    private var hostBundleIdentifier: String? {
        return Bundle.main.infoDictionary?["HostBundleIdentifier"] as? String
    }

}
