//
//  Models.swift
//  KatanaExperiment
//
//  Created by Andrea De Angelis on 10/07/2017.
//

import Foundation
import UIKit

extension Story {
  enum Genre: String {
    case horror = "Horror"
    case romance = "Romance"
    case comedy = "Comedy"
  }
}

struct Story {
  typealias Sender = String
  typealias Message = String
  typealias ID = String

  let id: ID
  let title: String
  let genre: Genre
  let author: String
  let cover: UIImage
  let description: String
  let chat: [Sender: Message]
}
