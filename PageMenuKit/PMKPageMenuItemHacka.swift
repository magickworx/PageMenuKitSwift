/*****************************************************************************
 *
 * FILE:	PMKPageMenuItemHacka.swift
 * DESCRIPTION:	PageMenuKit: PageMenuItem Class like "ハッカドール" iOS App
 * DATE:	Fri, Jun  2 2017
 * UPDATED:	Thu, Nov 15 2018
 * AUTHOR:	Kouichi ABE (WALL) / 阿部康一
 * E-MAIL:	kouichi@MagickWorX.COM
 * URL:		http://www.MagickWorX.COM/
 * COPYRIGHT:	(c) 2017-2018 阿部康一／Kouichi ABE (WALL), All rights reserved.
 * LICENSE:
 *
 *  Copyright (c) 2017-2018 Kouichi ABE (WALL) <kouichi@MagickWorX.COM>,
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

public class PMKPageMenuItemHacka: PMKPageMenuItem {
  let  kBadgeLayerKey: String = "kBadgeLayerKey"

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public required init(frame: CGRect, title: String, design: PMKPageMenuItemDesign) {
    super.init(frame: frame, title: title, design: design)

    self.style = .hacka
    self.titleColor = design.themeColor
    self.borderColor = design.themeColor

    self.addBorders(to: self.label)
  }

  override func render(active: Bool) {
    var frame: CGRect = self.frame
    if active {
      self.label.textColor = .white
      self.label.backgroundColor = self.design.themeColor
      self.borderLayer?.isHidden = true
      frame.origin.y = 0.0
      frame.size.height = kMenuItemHeight
    }
    else {
      self.label.textColor = self.design.themeColor
      self.label.backgroundColor = .clear
      self.borderLayer?.isHidden = false
      frame.origin.y = kSmartTabMargin
      frame.size.height = kMenuItemHeight - kSmartTabMargin
    }
    self.frame = frame

    if let textLayer = self.label.layer.value(forKey: kBadgeLayerKey) as? CATextLayer {
      textLayer.isHidden = (self.badgeValue == nil || active)
    }
  }

  override var borderColor: UIColor {
    willSet {
      self.borderLayer?.strokeColor = newValue.cgColor
    }
  }

  override public var badgeValue: String? {
    willSet {
      let textLayer: CATextLayer = {
        if let textLayer = self.label.layer.value(forKey: kBadgeLayerKey) as? CATextLayer {
          return textLayer
        }
        let w: CGFloat = 16.0
        let h: CGFloat = w
        let x: CGFloat = self.label.frame.size.width - w - 4.0
        let y: CGFloat = -kSmartTabMargin
        let textLayer = CATextLayer()
        textLayer.frame = CGRect(x: x, y: y, width: w, height: h)
        textLayer.fontSize = 12.0
        textLayer.foregroundColor = UIColor.white.cgColor
        textLayer.backgroundColor = UIColor.red.cgColor
        textLayer.cornerRadius = w * 0.5
        textLayer.masksToBounds = true
        textLayer.alignmentMode = .center
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.actions = [ "hidden" : NSNull() ]
        self.label.layer.addSublayer(textLayer)
        self.label.layer.setValue(textLayer, forKey: kBadgeLayerKey)
        return textLayer
      }()
      textLayer.string = newValue
      textLayer.isHidden = (newValue == nil || isSelected)
    }
  }
}
