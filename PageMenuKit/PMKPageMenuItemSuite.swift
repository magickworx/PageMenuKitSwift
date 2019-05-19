/*****************************************************************************
 *
 * FILE:	PMKPageMenuItemSuite.swift
 * DESCRIPTION:	PageMenuKit: PageMenuItem Class like "ニュース（News Suite）"
 * DATE:	Wed, Jun  7 2017
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
 *****************************************************************************/

import UIKit
import QuartzCore

public class PMKPageMenuItemSuite: PMKPageMenuItem {
  public required init(coder  aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public required init(frame: CGRect, title: String, design: PMKPageMenuItemDesign) {
    super.init(frame: frame, title: title, design: design)

    self.style = .suite

    self.gradientBackground(of: self)
  }

  override func render(active: Bool) {
    self.label.textColor = {
      if active {
        return self.design.titleColor
      }
      else if self.design.inactive.isEnabled {
        return self.design.inactive.titleColor
      }
      else {
        return .lightGray
      }
    }()
  }

  func gradientBackground(of view: UIView) {
    let gradientColors: [CGColor] = {
      if self.design.gradientColors.count > 0 {
        return self.design.gradientColors
      }
      let    topColor: UIColor = UIColor.hexColor(0x445a66)
      let bottomColor: UIColor = UIColor.hexColor(0x677983)
      return [ topColor.cgColor, bottomColor.cgColor ]
    }()
    let gradientLayer: CAGradientLayer = CAGradientLayer()
    gradientLayer.colors = gradientColors
    gradientLayer.frame = view.bounds
    view.layer.insertSublayer(gradientLayer, at: 0)
  }
}
