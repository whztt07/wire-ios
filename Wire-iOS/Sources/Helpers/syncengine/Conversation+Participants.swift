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

extension ZMConversation {
    @objc(addParticipantsOrShowError:)
    func addOrShowError(participants: Set<ZMUser>) {
        self.addParticipants(participants,
                             userSession: ZMUserSession.shared()!) { result in
                                switch result {
                                case .success:
                                    Analytics.shared().tagAddParticipants(source:.conversationDetails, participants, allowGuests: self.allowGuests, in: self)
                                case .failure(let error):
                                    self.showAlertForAdding(for: error)
                                }
        }
    }
    
    @objc (removeParticipantOrShowError:)
    func removeOrShowError(participnant user: ZMUser) {
        self.removeParticipant(user,
                               userSession: ZMUserSession.shared()!) { result in
                                switch result {
                                case .success:
                                    if user.isServiceUser {
                                        Analytics.shared().tagDidRemoveService(user)
                                    }
                                    else if user.isSelfUser {
                                        Analytics.shared().tagEventObject(AnalyticsGroupConversationEvent(forLeave: .leave, participantCount: UInt(self.activeParticipants.count)))
                                    }
                                case .failure(let error):
                                    self.showAlertForRemoval(for: error)
                                }
        }
    }
    
    private func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "error.conversation.title".localized,
                                                message: message,
                                                cancelButtonTitle: "general.ok".localized)
        
        UIApplication.shared.wr_topmostController()?.present(alertController, animated: true)
    }
    
    private func showAlertForAdding(for error: Error) {
        switch error {
        case ConversationAddParticipantsError.tooManyMembers:
            showErrorAlert(message: "error.conversation.too_many_members".localized)
        default:
            showErrorAlert(message: "error.conversation.cannot_add".localized)
        }
    }
    
    private func showAlertForRemoval(for error: Error) {
        showErrorAlert(message: "error.conversation.cannot_remove".localized)
    }
}