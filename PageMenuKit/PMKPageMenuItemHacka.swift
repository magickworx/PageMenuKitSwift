/*****************************************************************************
 *
 * FILE:	PMKPageMenuItemHacka.swift
 * DESCRIPTION:	PageMenuKit: PageMenuItem Class like "ハッカドール" iOS App
 * DATE:	Fri, Jun  2 2017
 * UPDATED:	Fri, Jun  9 2017
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

public class PMKPageMenuItemHacka: PMKPageMenuItem {
  let  kBadgeLayerKey: String = "kBadgeLayerKey"

  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public required init(frame: CGRect, title: String, color: UIColor) {
    super.init(frame: frame, title: title, color: color)

    self.titleColor = color
    self.borderColor = color
    self.style = .Hacka

    self.addBorders(of: self.label!)
  }

  override func render(active: Bool) {
    if (active) {
      self.label?.textColor = .white
      self.label?.backgroundColor = self.color
      var frame: CGRect = self.frame
      frame.origin.y = 0.0
      frame.size.height = kMenuItemHeight
      self.frame = frame
      self.borderLayer?.isHidden = true
    }
    else {
      self.label?.textColor = self.color
      self.label?.backgroundColor = .clear
      self.borderLayer?.isHidden = false
      var frame: CGRect = self.frame
      frame.origin.y = kSmartTabMargin
      frame.size.height = kMenuItemHeight - kSmartTabMargin
      self.frame = frame
    }

    if let textLayer = self.label?.layer.value(forKey: kBadgeLayerKey) as? CATextLayer {
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
      var textLayer: CATextLayer? = self.label?.layer.value(forKey: kBadgeLayerKey) as? CATextLayer
      if textLayer == nil {
        let w: CGFloat = 16.0
        let h: CGFloat = w
        let x: CGFloat = self.label!.frame.size.width - w - 4.0
        let y: CGFloat = -kSmartTabMargin
        textLayer = CATextLayer()
        textLayer?.frame = CGRect(x: x, y: y, width: w, height: h)
        textLayer?.fontSize = 12.0
        textLayer?.foregroundColor = UIColor.white.cgColor
        textLayer?.backgroundColor = UIColor.red.cgColor
        textLayer?.cornerRadius = w * 0.5
        textLayer?.masksToBounds = true
        textLayer?.alignmentMode = kCAAlignmentCenter
        textLayer?.contentsScale = UIScreen.main.scale
        textLayer?.actions = [ "hidden" : NSNull() ]
        self.label?.layer.addSublayer(textLayer!)
        self.label?.layer.setValue(textLayer, forKey: kBadgeLayerKey)
      }
      textLayer?.string = newValue
      textLayer?.isHidden = (newValue == nil || isSelected)
    }
  }
}
