//
//  String+Random.swift
//  Tempura
//
//  Copyright © 2021 Bending Spoons.
//  Distributed under the MIT License.
//  See the LICENSE file for more information.

import Foundation

extension String {
  static func random(
    length: Int,
    allowedChars: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  ) -> String {
    let allowedCharsCount = UInt32(allowedChars.count)
    var randomString = ""

    for _ in 0 ..< length {
      let randomNum = Int(arc4random_uniform(allowedCharsCount))
      let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
      let newCharacter = allowedChars[randomIndex]
      randomString += String(newCharacter)
    }

    return randomString
  }
}
