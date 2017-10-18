//
//  BonMotHelpers.swift
//  TempuraTests
//
//  Created by Mauro Bolis on 18/10/2017.
//

import Foundation
import BonMot

public extension StringStyle {
  
  /**
   Helper function to create an instance of `StringStyle` using the sketch values.
   The parameters should be copied as is from sketch
   
   - parameter family: the font family
   - parameter weight: the font weight
   - parameter size: the font size
   - parameter color: the text color
   - parameter alignment: the text alignment
   - parameter characterSpacing: the character spacing (also known as tracking)
   - parameter lineSpacing: the lineSpacing
   - parameter opacity: the text color opacity
  */
  static func fromSketchValues(
    family: FontFamily,
    weight: UIFont.Weight,
    size: CGFloat,
    color: UIColor,
    alignment: NSTextAlignment = .center,
    characterSpacing: CGFloat,
    lineSpacing: CGFloat,
    paragraphSpacing: CGFloat = 0,
    opacity: CGFloat = 1.0
  ) -> StringStyle {
    
    let font = { () -> UIFont in
      
      guard let f = family.font(with: size, weight: weight) else {
        print("Cannot find a font with name \(family), size: \(size), weight: \(weight). Fallback to system font")
        return UIFont.systemFont(ofSize: size, weight: weight)
      }
      
      return f
    }()
    
    let colorWithOpacity = color.withAlphaComponent(opacity)
    
    return StringStyle(
      .font(font),
      .color(colorWithOpacity),
      .alignment(alignment),
      .lineSpacing(lineSpacing / size),
      .tracking(.point(characterSpacing)),
      .paragraphSpacingAfter(paragraphSpacing)
    )
  }
}

/// Enum to dealing in a simpler way with fonts
public enum FontFamily {
  /// identifier for Copperplate
  case copperplate
  
  /// identifier for Heiti SC
  case heitiSC
  
  /// identifier for Apple SD Gothic Neo
  case appleSDGothicNeo
  
  /// identifier for Thonburi
  case thonburi
  
  /// identifier for Gill Sans
  case gillSans
  
  /// identifier for Marker Felt
  case markerFelt
  
  /// identifier for Hiragino Maru Gothic ProN
  case hiraginoMaruGothicProN
  
  /// identifier for Courier New
  case courierNew
  
  /// identifier for Kohinoor Telugu
  case kohinoorTelugu
  
  /// identifier for Heiti TC
  case heitiTC
  
  /// identifier for Avenir Next Condensed
  case avenirNextCondensed
  
  /// identifier for Tamil Sangam MN
  case tamilSangamMN
  
  /// identifier for Helvetica Neue
  case helveticaNeue
  
  /// identifier for Gurmukhi MN
  case gurmukhiMN
  
  /// identifier for Georgia
  case georgia
  
  /// identifier for Times New Roman
  case timesNewRoman
  
  /// identifier for Sinhala Sangam MN
  case sinhalaSangamMN
  
  /// identifier for Arial Rounded MT Bold
  case arialRoundedMTBold
  
  /// identifier for Kailasa
  case kailasa
  
  /// identifier for Kohinoor Devanagari
  case kohinoorDevanagari
  
  /// identifier for Kohinoor Bangla
  case kohinoorBangla
  
  /// identifier for Chalkboard SE
  case chalkboardSE
  
  /// identifier for Apple Color Emoji
  case appleColorEmoji
  
  /// identifier for PingFang TC
  case pingFangTC
  
  /// identifier for Gujarati Sangam MN
  case gujaratiSangamMN
  
  /// identifier for Geeza Pro
  case geezaPro
  
  /// identifier for Damascus
  case damascus
  
  /// identifier for Noteworthy
  case noteworthy
  
  /// identifier for Avenir
  case avenir
  
  /// identifier for Mishafi
  case mishafi
  
  /// identifier for Academy Engraved LET
  case academyEngravedLET
  
  /// identifier for Futura
  case futura
  
  /// identifier for Party LET
  case partyLET
  
  /// identifier for Kannada Sangam MN
  case kannadaSangamMN
  
  /// identifier for Arial Hebrew
  case arialHebrew
  
  /// identifier for Farah
  case farah
  
  /// identifier for Arial
  case arial
  
  /// identifier for Chalkduster
  case chalkduster
  
  /// identifier for Kefa
  case kefa
  
  /// identifier for Hoefler Text
  case hoeflerText
  
  /// identifier for Optima
  case optima
  
  /// identifier for Palatino
  case palatino
  
  /// identifier for Malayalam Sangam MN
  case malayalamSangamMN
  
  /// identifier for Al Nile
  case alNile
  
  /// identifier for Lao Sangam MN
  case laoSangamMN
  
  /// identifier for Bradley Hand
  case bradleyHand
  
  /// identifier for Hiragino Mincho ProN
  case hiraginoMinchoProN
  
  /// identifier for PingFang HK
  case pingFangHK
  
  /// identifier for Helvetica
  case helvetica
  
  /// identifier for Courier
  case courier
  
  /// identifier for Cochin
  case cochin
  
  /// identifier for Trebuchet MS
  case trebuchetMS
  
  /// identifier for Devanagari Sangam MN
  case devanagariSangamMN
  
  /// identifier for Oriya Sangam MN
  case oriyaSangamMN
  
  /// identifier for Snell Roundhand
  case snellRoundhand
  
  /// identifier for Zapf Dingbats
  case zapfDingbats
  
  /// identifier for Bodoni 72
  case bodoni72
  
  /// identifier for Verdana
  case verdana
  
  /// identifier for American Typewriter
  case americanTypewriter
  
  /// identifier for Avenir Next
  case avenirNext
  
  /// identifier for Baskerville
  case baskerville
  
  /// identifier for Khmer Sangam MN
  case khmerSangamMN
  
  /// identifier for Didot
  case didot
  
  /// identifier for Savoye LET
  case savoyeLET
  
  /// identifier for Bodoni Ornaments
  case bodoniOrnaments
  
  /// identifier for Symbol
  case symbol
  
  /// identifier for Menlo
  case menlo
  
  /// identifier for Noto Nastaliq Urdu
  case notoNastaliqUrdu
  
  /// identifier for Bodoni 72 Smallcaps
  case bodoni72Smallcaps
  
  /// identifier for Papyrus
  case papyrus
  
  /// identifier for Hiragino Sans
  case hiraginoSans
  
  /// identifier for PingFang SC
  case pingFangSC
  
  /// identifier for Myanmar Sangam MN
  case myanmarSangamMN
  
  /// identifier for Zapfino
  case zapfino
  
  /// identifier for Telugu Sangam MN
  case teluguSangamMN
  
  /// identifier for Bodoni 72 Oldstyle
  case bodoni72Oldstyle
  
  /// identifier for Euphemia UCAS
  case euphemiaUCAS
  
  /// identifier for Bangla Sangam MN
  case banglaSangamMN
  
  /// identifier for San Francisco Font
  case systemFont
  
  /// identifier for custom font
  case customFont(familyName: String)
  
  fileprivate func font(with size: CGFloat, weight: UIFont.Weight) -> UIFont? {
    switch self {
    case .copperplate: return UIFont.fontWith(family: "Copperplate", weight: weight, size: size)
      
    case .heitiSC: return UIFont.fontWith(family: "Heiti SC", weight: weight, size: size)
      
    case .appleSDGothicNeo: return UIFont.fontWith(family: "Apple SD Gothic Neo", weight: weight, size: size)
      
    case .thonburi: return UIFont.fontWith(family: "Thonburi", weight: weight, size: size)
      
    case .gillSans: return UIFont.fontWith(family: "Gill Sans", weight: weight, size: size)
      
    case .markerFelt: return UIFont.fontWith(family: "Marker Felt", weight: weight, size: size)
      
    case .hiraginoMaruGothicProN: return UIFont.fontWith(family: "Hiragino Maru Gothic ProN", weight: weight, size: size)
      
    case .courierNew: return UIFont.fontWith(family: "Courier New", weight: weight, size: size)
      
    case .kohinoorTelugu: return UIFont.fontWith(family: "Kohinoor Telugu", weight: weight, size: size)
      
    case .heitiTC: return UIFont.fontWith(family: "Heiti TC", weight: weight, size: size)
      
    case .avenirNextCondensed: return UIFont.fontWith(family: "Avenir Next Condensed", weight: weight, size: size)
      
    case .tamilSangamMN: return UIFont.fontWith(family: "Tamil Sangam MN", weight: weight, size: size)
      
    case .helveticaNeue: return UIFont.fontWith(family: "Helvetica Neue", weight: weight, size: size)
      
    case .gurmukhiMN: return UIFont.fontWith(family: "Gurmukhi MN", weight: weight, size: size)
      
    case .georgia: return UIFont.fontWith(family: "Georgia", weight: weight, size: size)
      
    case .timesNewRoman: return UIFont.fontWith(family: "Times New Roman", weight: weight, size: size)
      
    case .sinhalaSangamMN: return UIFont.fontWith(family: "Sinhala Sangam MN", weight: weight, size: size)
      
    case .arialRoundedMTBold: return UIFont.fontWith(family: "Arial Rounded MT Bold", weight: weight, size: size)
      
    case .kailasa: return UIFont.fontWith(family: "Kailasa", weight: weight, size: size)
      
    case .kohinoorDevanagari: return UIFont.fontWith(family: "Kohinoor Devanagari", weight: weight, size: size)
      
    case .kohinoorBangla: return UIFont.fontWith(family: "Kohinoor Bangla", weight: weight, size: size)
      
    case .chalkboardSE: return UIFont.fontWith(family: "Chalkboard SE", weight: weight, size: size)
      
    case .appleColorEmoji: return UIFont.fontWith(family: "Apple Color Emoji", weight: weight, size: size)
      
    case .pingFangTC: return UIFont.fontWith(family: "PingFang TC", weight: weight, size: size)
      
    case .gujaratiSangamMN: return UIFont.fontWith(family: "Gujarati Sangam MN", weight: weight, size: size)
      
    case .geezaPro: return UIFont.fontWith(family: "Geeza Pro", weight: weight, size: size)
      
    case .damascus: return UIFont.fontWith(family: "Damascus", weight: weight, size: size)
      
    case .noteworthy: return UIFont.fontWith(family: "Noteworthy", weight: weight, size: size)
      
    case .avenir: return UIFont.fontWith(family: "Avenir", weight: weight, size: size)
      
    case .mishafi: return UIFont.fontWith(family: "Mishafi", weight: weight, size: size)
      
    case .academyEngravedLET: return UIFont.fontWith(family: "Academy Engraved LET", weight: weight, size: size)
      
    case .futura: return UIFont.fontWith(family: "Futura", weight: weight, size: size)
      
    case .partyLET: return UIFont.fontWith(family: "Party LET", weight: weight, size: size)
      
    case .kannadaSangamMN: return UIFont.fontWith(family: "Kannada Sangam MN", weight: weight, size: size)
      
    case .arialHebrew: return UIFont.fontWith(family: "Arial Hebrew", weight: weight, size: size)
      
    case .farah: return UIFont.fontWith(family: "Farah", weight: weight, size: size)
      
    case .arial: return UIFont.fontWith(family: "Arial", weight: weight, size: size)
      
    case .chalkduster: return UIFont.fontWith(family: "Chalkduster", weight: weight, size: size)
      
    case .kefa: return UIFont.fontWith(family: "Kefa", weight: weight, size: size)
      
    case .hoeflerText: return UIFont.fontWith(family: "Hoefler Text", weight: weight, size: size)
      
    case .optima: return UIFont.fontWith(family: "Optima", weight: weight, size: size)
      
    case .palatino: return UIFont.fontWith(family: "Palatino", weight: weight, size: size)
      
    case .malayalamSangamMN: return UIFont.fontWith(family: "Malayalam Sangam MN", weight: weight, size: size)
      
    case .alNile: return UIFont.fontWith(family: "Al Nile", weight: weight, size: size)
      
    case .laoSangamMN: return UIFont.fontWith(family: "Lao Sangam MN", weight: weight, size: size)
      
    case .bradleyHand: return UIFont.fontWith(family: "Bradley Hand", weight: weight, size: size)
      
    case .hiraginoMinchoProN: return UIFont.fontWith(family: "Hiragino Mincho ProN", weight: weight, size: size)
      
    case .pingFangHK: return UIFont.fontWith(family: "PingFang HK", weight: weight, size: size)
      
    case .helvetica: return UIFont.fontWith(family: "Helvetica", weight: weight, size: size)
      
    case .courier: return UIFont.fontWith(family: "Courier", weight: weight, size: size)
      
    case .cochin: return UIFont.fontWith(family: "Cochin", weight: weight, size: size)
      
    case .trebuchetMS: return UIFont.fontWith(family: "Trebuchet MS", weight: weight, size: size)
      
    case .devanagariSangamMN: return UIFont.fontWith(family: "Devanagari Sangam MN", weight: weight, size: size)
      
    case .oriyaSangamMN: return UIFont.fontWith(family: "Oriya Sangam MN", weight: weight, size: size)
      
    case .snellRoundhand: return UIFont.fontWith(family: "Snell Roundhand", weight: weight, size: size)
      
    case .zapfDingbats: return UIFont.fontWith(family: "Zapf Dingbats", weight: weight, size: size)
      
    case .bodoni72: return UIFont.fontWith(family: "Bodoni 72", weight: weight, size: size)
      
    case .verdana: return UIFont.fontWith(family: "Verdana", weight: weight, size: size)
      
    case .americanTypewriter: return UIFont.fontWith(family: "American Typewriter", weight: weight, size: size)
      
    case .avenirNext: return UIFont.fontWith(family: "Avenir Next", weight: weight, size: size)
      
    case .baskerville: return UIFont.fontWith(family: "Baskerville", weight: weight, size: size)
      
    case .khmerSangamMN: return UIFont.fontWith(family: "Khmer Sangam MN", weight: weight, size: size)
      
    case .didot: return UIFont.fontWith(family: "Didot", weight: weight, size: size)
      
    case .savoyeLET: return UIFont.fontWith(family: "Savoye LET", weight: weight, size: size)
      
    case .bodoniOrnaments: return UIFont.fontWith(family: "Bodoni Ornaments", weight: weight, size: size)
      
    case .symbol: return UIFont.fontWith(family: "Symbol", weight: weight, size: size)
      
    case .menlo: return UIFont.fontWith(family: "Menlo", weight: weight, size: size)
      
    case .notoNastaliqUrdu: return UIFont.fontWith(family: "Noto Nastaliq Urdu", weight: weight, size: size)
      
    case .bodoni72Smallcaps: return UIFont.fontWith(family: "Bodoni 72 Smallcaps", weight: weight, size: size)
      
    case .papyrus: return UIFont.fontWith(family: "Papyrus", weight: weight, size: size)
      
    case .hiraginoSans: return UIFont.fontWith(family: "Hiragino Sans", weight: weight, size: size)
      
    case .pingFangSC: return UIFont.fontWith(family: "PingFang SC", weight: weight, size: size)
      
    case .myanmarSangamMN: return UIFont.fontWith(family: "Myanmar Sangam MN", weight: weight, size: size)
      
    case .zapfino: return UIFont.fontWith(family: "Zapfino", weight: weight, size: size)
      
    case .teluguSangamMN: return UIFont.fontWith(family: "Telugu Sangam MN", weight: weight, size: size)
      
    case .bodoni72Oldstyle: return UIFont.fontWith(family: "Bodoni 72 Oldstyle", weight: weight, size: size)
      
    case .euphemiaUCAS: return UIFont.fontWith(family: "Euphemia UCAS", weight: weight, size: size)
      
    case .banglaSangamMN: return UIFont.fontWith(family: "Bangla Sangam MN", weight: weight, size: size)
      
    case .systemFont: return UIFont.systemFont(ofSize:size, weight: weight)
      
    case let .customFont(familyName): return UIFont.fontWith(family: familyName, weight: weight, size: size)
    }
  }
}

/// Private helpers for UIFont / BonMot
fileprivate extension UIFont {
  
  /**
   Returns the proper font given the faimily, the size and the weight.
   It can fail if the font is not found
   
   - parameter family: the family name
   - parameter weight: the weight of the font
   - parameter size: the size of the font
  */
  fileprivate static func fontWith(family: String, weight: UIFont.Weight, size: CGFloat) -> UIFont? {
    let familyFonts = UIFont.fontNames(forFamilyName: family)
    
    for item in familyFonts {
      guard let f = UIFont(name: item, size: size) else {
        continue
      }
      
      let traits = f.fontDescriptor.object(forKey: UIFontDescriptor.AttributeName.traits) as? [UIFontDescriptor.TraitKey: Any]
      let fontWeight = traits?[UIFontDescriptor.TraitKey.weight] as? UIFont.Weight ?? .regular
      
      if weight == fontWeight {
        return f
      }
    }
    
    return nil
  }
}
