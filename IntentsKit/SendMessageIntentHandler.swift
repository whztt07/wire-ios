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
import Intents
import WireShareEngine

public class SendMessageIntentHandler: NSObject, INSendMessageIntentHandling {

    let sharingSession: SharingSession?

    init(sharingSession: SharingSession?) {
        self.sharingSession = sharingSession
    }

    // Implement resolution methods to provide additional information about your intent (optional).
    public func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void) {
        guard let recipients = intent.recipients, !recipients.isEmpty else {
            completion([INPersonResolutionResult.needsValue()])
            return
        }

        guard let sharingSession = self.sharingSession else {
            let response = recipients.map(INPersonResolutionResult.success)
            completion(response)
            return
        }

        if let recipients = intent.recipients {

            // If no recipients were provided we'll need to prompt for a value.
            if recipients.count == 0 {

                return
            }

            let contacts: [INPerson] = sharingSession.writeableNonArchivedConversations.map {

                if #available(iOS 10.2, *) {
                    let handle = INPersonHandle(value: $0.name, type: INPersonHandleType.unknown, label: INPersonHandleLabel.work)
                    return INPerson(personHandle: handle, nameComponents: nil, displayName: $0.name, image: nil, contactIdentifier: nil, customIdentifier: nil)
                } else {
                    return INPerson(handle: $0.name, nameComponents: nil, displayName: $0.name, image: nil, contactIdentifier: nil)
                }

            }

            var resolutionResults = [INPersonResolutionResult.disambiguation(with: contacts)]

            /*for recipient in recipients {
                let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
                switch matchingContacts.count {
                case 2  ... Int.max:
                    // We need Siri's help to ask user to pick one from the matches.
                    resolutionResults += [INPersonResolutionResult.disambiguation(with: matchingContacts)]

                case 1:
                    // We have exactly one matching contact
                    resolutionResults += [INPersonResolutionResult.success(with: recipient)]

                case 0:
                    // We have no contacts matching the description provided
                    resolutionResults += [INPersonResolutionResult.unsupported()]

                default:
                    break

                }
            }*/
            completion(resolutionResults)
        }
    }


    /**
     * Verifies that the message contains text.
     */

    public func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let text = intent.content, !text.isEmpty {
            completion(INStringResolutionResult.success(with: text))
        } else {
            completion(INStringResolutionResult.needsValue())
        }
    }

    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).

    public func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        guard let session = self.sharingSession, session.canShare else {
            let response = INSendMessageIntentResponse(code: .failureRequiringAppLaunch, userActivity: nil)
            completion(response)
            return
        }

        let response = INSendMessageIntentResponse(code: .ready, userActivity: nil)
        completion(response)
    }

    // Handle the completed intent (required).

    public func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
        // Implement your application logic to send a message here.

        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
        completion(response)
    }

}
