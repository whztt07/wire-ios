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
import WireShareEngine

class ContactLookup {

    let sharingSession: SharingSession

    init(sharingSession: SharingSession) {
        self.sharingSession = sharingSession
    }

    func findContact(named spokenContactName: String) -> [Conversation] {
        var propsedMatches: [Conversation] = []

        for convesation in sharingSession.writeableNonArchivedConversations {
            print("\(convesation.name) <=> \(spokenContactName)")
            print(convesation.name.levenshtein(spokenContactName))
        }

        return propsedMatches
    }


}

private extension String {
    subscript(ix: Int) -> Character {
        let index = self.index(startIndex, offsetBy: ix)
        return self[index]
    }

    subscript(range: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start ..< end])
    }
}

extension String {

    private var normalizingForComparison: [UInt32] {
        let lowercased = self.lowercased()

        var allowedCharacters = CharacterSet()
        allowedCharacters.formUnion(.alphanumerics)
        allowedCharacters.formUnion(.whitespaces)

        return lowercased.unicodeScalars.compactMap {
            guard allowedCharacters.contains($0) else {
                return nil
            }

            return $0.value
        }
    }


    fileprivate func levenshtein(_ cmpString: String) -> Int {
        let base = self.normalizingForComparison
        let target = cmpString.normalizingForComparison

        let (length, cmpLength) = (base.count, target.count)

        guard cmpLength > 0 else {
            return base.count
        }

        var matrix = Array(repeating: Array(repeating: 0,
                                            count: length + 1),
                           count: cmpLength + 1)

        for m in 1 ..< cmpLength {
            matrix[m][0] = matrix[m - 1][0] + 1
        }

        for n in 1 ..< length {
            matrix[0][n] = matrix[0][n - 1] + 1
        }

        for m in 1 ..< (cmpLength + 1) {
            for n in 1 ..< (length + 1) {
                let penalty = base[n - 1] == target[m - 1] ? 0 : 1
                let (horizontal, vertical, diagonal) = (matrix[m - 1][n] + 1, matrix[m][n - 1] + 1, matrix[m - 1][n - 1])
                matrix[m][n] = Swift.min(horizontal, vertical, diagonal + penalty)
            }
        }

        return matrix[cmpLength][length]
    }
}

