/*****************************************************************************
 *
 * FILE:	PMKPageMenuItem.swift
 * DESCRIPTION:	PageMenuKit: Base MenuItem Class for PageMenuController
 * DATE:	Fri, Jun  2 2017
 * UPDATED:	Mon, Nov 13 2017
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2017 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2017 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 *   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *   THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *   PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE
 *   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 *   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 *   INTERRUPTION)  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 *   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 *   THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $Id$
 *
 *****************************************************************************/

import UIKit
import QuartzCore

// CUSTOM: Add your custom menu style here.
public enum PMKPageMenuControllerStyle: Int {
  case Plain   = 1 // NewsPass  [https://itunes.apple.com/jp/app/id1106788059]
  case Tab     = 2 // Gunosy    [https://itunes.apple.com/jp/app/id590384791]
  case Smart   = 3 // SmartNews [https://itunes.apple.com/jp/app/id579581125]
  case Hacka   = 4 // Hackadoll [https://itunes.apple.com/jp/app/id888231424]
  case Web     = 5 // JCNews    [https://jcnews.tokyo/)
  case Ellipse = 6 // JCNews    [https://itunes.apple.com/jp/app/id1024341813]
  case Suite   = 7 // NewsSuite [https://itunes.apple.com/jp/app/id1176431318]
  case NetLab  = 8 // NLab      [https://itunes.apple.com/jp/app/id949325541]
  case NHK     = 9 // NHK NEWS  [https://itunes.apple.com/jp/app/id1121104608]

  /// メニュー画面のスタイル毎のクラス名を返す
  ///
  /// - Returns: クラス名
  func className() -> String {
    switch self {
      case .Plain:   return "PMKPageMenuItemPlain"
      case .Tab:     return "PMKPageMenuItemTab"
      case .Smart:   return "PMKPageMenuItemSmart"
      case .Hacka:   return "PMKPageMenuItemHacka"
      case .Web:     return "PMKPageMenuItemWeb"
      case .Ellipse: return "PMKPageMenuItemEllipse"
      case .Suite:   return "PMKPageMenuItemSuite"
      case .NetLab:  return "PMKPageMenuItemNetLab"
      case .NHK:     return "PMKPageMenuItemNHK"
    }
  }
}


protocol Design {
  var themeColor: UIColor { get set }
  var titleColor: UIColor { get set }
  var backgroundColor: UIColor { get set }
}

public class PMKPageMenuItemDesign: Design {
  var themeColor: UIColor = .clear // 通常は titleColor と同じはず
  var titleColor: UIColor = .black
  var backgroundColor: UIColor = .clear
  var gradientColors: [CGColor] = []

  struct inactiveStruct { // inactive を有効にする場合は isEnabled = true にする
    var isEnabled: Bool = false
    var titleColor: UIColor = .lightGray
    var backgroundColor: UIColor = .clear
  }
  var inactive = PMKPageMenuItemDesign.inactiveStruct()

  public init(themeColor: UIColor) {
    self.themeColor = themeColor
    self.titleColor = themeColor
  }
}


protocol Item {
  var title: String { get set }
  var isEnabled: Bool { get set }
}

protocol MenuItem: Item {
  var color: UIColor { get set } // メニューの基本色
  var titleColor: UIColor { get set }
  var borderColor: UIColor { get set } // メニュー枠の色
  var isSelected: Bool { get set }

  /// メニュー画面を装飾
  ///
  /// - Rarameters:
  ///   - active: メニュー選択時 = true, 非選択時 = false
  /// - Returns: なし
  func render(active: Bool)
}

public class PMKPageMenuItem: UIView, MenuItem {
  let kBorderLayerKey: String = "kBorderLayerKey"

  public internal(set) var color: UIColor = .clear
  public internal(set) var design: PMKPageMenuItemDesign? = nil
  public internal(set) var style: PMKPageMenuControllerStyle = .Plain

  var label: UILabel? = nil

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  public required init(frame: CGRect, title: String, design: PMKPageMenuItemDesign) {
    super.init(frame: frame)

    self.backgroundColor = .clear
    self.isUserInteractionEnabled = true
    self.autoresizesSubviews = true

    let label: UILabel = UILabel(frame: self.bounds)
    label.text = title
    label.textAlignment = .center
    label.backgroundColor = .clear
    label.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
    self.addSubview(label)
    self.label = label

    self.title = title
    self.color = design.themeColor
    self.design = design
  }


  /*
   * Properties
   */
  public var title: String = "" {
    willSet {
      if title != newValue {
        self.label?.text = newValue
      }
    }
  }

  public var isEnabled: Bool = true {
    willSet {
      self.label?.isUserInteractionEnabled = newValue
      self.label?.alpha = newValue ? 1.0 : 0.5
    }
  }

  var titleColor: UIColor = .black {
    willSet {
      self.label?.textColor = newValue
    }
  }

  var borderColor: UIColor = .clear

  public var isSelected: Bool = false {
    willSet {
      self.render(active: newValue)
    }
  }

  public var badgeValue: String? = nil // XXX: Override Point

  // MARK: - Overriden Functions
  func render(active: Bool) {
  }

  // 左上と右上の角を丸める
  func roundingCorners(of label: UILabel) {
    autoreleasepool {
      let maskPath: UIBezierPath = UIBezierPath(roundedRect: label.bounds, byRoundingCorners: [ .topLeft, .topRight ], cornerRadii: CGSize(width: 5.0, height: 5.0))
      let maskLayer: CAShapeLayer = CAShapeLayer()
      maskLayer.frame  = label.bounds
      maskLayer.path   = maskPath.cgPath
      label.layer.mask = maskLayer
    }
  }
}

// MARK: - Private Methods
extension PMKPageMenuItem {
  public var borderLayer: CAShapeLayer? {
    get {
      return self.label?.layer.value(forKey: kBorderLayerKey) as? CAShapeLayer
    }
  }

  // 左端と上と右端のみ枠線を付ける
  func addBorders(of label: UILabel) {
    autoreleasepool {
      let w: CGFloat = label.frame.size.width
      let h: CGFloat = label.frame.size.height
      var x: CGFloat = 0.0
      var y: CGFloat = h
      let bezierPath: UIBezierPath = UIBezierPath()
      bezierPath.move(to: CGPoint(x: x, y: y));    y = 0.0
      bezierPath.addLine(to: CGPoint(x: x, y: y)); x = w
      bezierPath.addLine(to: CGPoint(x: x, y: y)); y = h
      bezierPath.addLine(to: CGPoint(x: x, y: y))
      let shapeLayer: CAShapeLayer = CAShapeLayer()
      shapeLayer.frame = label.bounds
      shapeLayer.path = bezierPath.cgPath
      shapeLayer.fillColor = UIColor.clear.cgColor
      shapeLayer.strokeColor = self.borderColor.cgColor
      shapeLayer.lineWidth = 1.0
      /*
       * XXX: Disable implicit animation for hidden of CAShapeLayer.
       * http://stackoverflow.com/questions/5833488/how-to-disable-calayer-implicit-animations
       */
      shapeLayer.actions = [ "hidden" : NSNull() ]
      label.layer.addSublayer(shapeLayer)
      label.layer.setValue(shapeLayer, forKey:kBorderLayerKey)
    }
  }
}
