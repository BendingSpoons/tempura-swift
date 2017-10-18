//
//  ApplyStyleSpec.swift
//  TempuraTests
//
//  Created by Mauro Bolis on 18/10/2017.
//

@testable import Tempura
import Katana
import Quick
import Nimble

class ApplyStyleSpec: QuickSpec {
  override func spec() {
    describe("ApplyStyle") {
      it("applies the style") {
        
        let view = UIView()
        
        let closure = { (v: UIView) -> Void in
          v.backgroundColor = .red
        }
        
        Tempura.applyStyle(closure, to: view)
        
        expect(view.backgroundColor) == UIColor.red
      }
    }
  }
}
