//
//  BonMotHelpers.swift
//  TempuraTests
//
//  Created by Mauro Bolis on 18/10/2017.
//

@testable import Tempura
import Katana
import Quick
import Nimble
import BonMot
import TempuraHelpers

class BonMotHlpersSpec: QuickSpec {
  override func spec() {
    describe("BonMot StringStyle") {
      it("is correctly created from sketch values") {
        let style = StringStyle.fromSketchValues(
          family: .avenir,
          weight: .medium,
          size: 10,
          color: .white,
          alignment: .left,
          characterSpacing: 1.89,
          lineSpacing: 19,
          paragraphSpacing: 10,
          opacity: 0.5
        )

        expect(style.font?.fontName) == "Avenir-Medium"
        expect(style.font?.pointSize) == 10
        
        expect(style.color) == UIColor(white: 1.0, alpha: 0.5)
        expect(style.alignment) == .left
        expect(style.tracking) == Tracking.point(1.89)
        expect(style.lineSpacing) == 19.0 / 10.0
        expect(style.paragraphSpacingAfter) == 10
      }
      
      it("uses proper sketch default values") {
        let style = StringStyle.fromSketchValues(
          family: .avenir,
          weight: .medium,
          size: 10,
          color: .white,
          characterSpacing: 1.89,
          lineSpacing: 19
        )
        
        expect(style.font?.fontName) == "Avenir-Medium"
        expect(style.font?.pointSize) == 10
        
        expect(style.color) == UIColor(white: 1.0, alpha: 1.0)
        expect(style.alignment) == .center
        expect(style.tracking) == Tracking.point(1.89)
        expect(style.lineSpacing) == 19.0 / 10.0
        expect(style.paragraphSpacingAfter) == 0
      }
    }
  }
}


extension Tracking: Equatable {
  public static func == (l: Tracking, r: Tracking) -> Bool {
    switch (l, r) {
    case let (.point(v1), .point(v2)): return v1 == v2
    case let (.adobe(v1), .adobe(v2)): return v1 == v2
    default: return false
    }
  }
}
