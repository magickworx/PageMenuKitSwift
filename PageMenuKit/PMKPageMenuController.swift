/*****************************************************************************
 *
 * FILE:	PMKPageMenuController.swift
 * DESCRIPTION:	PageMenuKit: Paging Menu View Controller
 * DATE:	Fri, Jun  2 2017
 * UPDATED:	Sat, Jun 10 2017
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

import Foundation
import UIKit

// http://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string
public extension UIColor {
  class func hexColor(_ hex: UInt32) -> UIColor {
    let r = CGFloat((hex & 0xff0000) >> 16) / 255.0
    let g = CGFloat((hex &   0xff00) >>  8) / 255.0
    let b = CGFloat((hex &     0xff)) / 255.0
    return UIColor(red:r, green:g, blue: b, alpha:1.0)
  }
}

let   kMenuItemWidth: CGFloat = 90.0
let  kMenuItemHeight: CGFloat = 40.0
let  kMenuItemMargin: CGFloat = 10.0
let  kSmartTabMargin: CGFloat =  8.0
let kSeparatorHeight: CGFloat =  2.0
let kIndicatorHeight: CGFloat =  kSeparatorHeight

let kMenuItemBaseTag: Int = 170602

let   kHackaHexColor: UInt32 = 0x66cdaa
let  kJCNewsHexColor: UInt32 = 0x3fa9f5
let  kNetLabHexColor: UInt32 = 0x8e0c4e
let kNHKNewsHexColor: UInt32 = 0x0387d2

public class PMKPageMenuController: UIViewController, UIScrollViewDelegate
{
  public weak var delegate: PMKPageMenuControllerDelegate? = nil
  public internal(set) var menuStyle: PMKPageMenuControllerStyle = .Plain
  public internal(set) var titles: [String] = []
  public internal(set) var childControllers: [UIViewController] = []
  public internal(set) var menuColors: [UIColor] = []

  var topBarHeight: CGFloat = 40.0
  var scrollView: UIScrollView? = nil
  var itemMargin: CGFloat = 0.0
  var separatorHeight: CGFloat = kSeparatorHeight
  var indicatorHeight: CGFloat = kIndicatorHeight
  var menuSeparator: CALayer? = nil
  var menuIndicator: UIView? = nil
  var menuItems: [PMKPageMenuItem] = []
  var pageViewController: UIPageViewController? = nil

  static let standardColors: [UIColor] = [
	UIColor.hexColor(0xff7f7f),
	UIColor.hexColor(0xbf7fff),
	UIColor.hexColor(0x7f7fff),
	UIColor.hexColor(0x7fbfff),
	UIColor.hexColor(0x7fff7f),
	UIColor.hexColor(0xffbf7f)
  ]

  // Designated Initializer
  public required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  public init(controllers: [UIViewController],
                menuStyle: PMKPageMenuControllerStyle,
               menuColors: [UIColor] = PMKPageMenuController.standardColors,
             topBarHeight: CGFloat) {
    super.init(nibName: nil, bundle: nil)

       self.menuStyle = menuStyle
      self.menuColors = menuColors
    self.topBarHeight = topBarHeight
    self.currentIndex = 0

    self.childControllers = controllers

    var titles: [String] = []
    for (index, viewController) in controllers.enumerated() {
      if let title = viewController.value(forKey: "title") as? String,
         title.characters.count > 0 {
        titles.append(title)
      }
      else {
        titles.append(String(format: "Title%zd", index + 1))
      }
    }
    self.titles = titles

    self.prepareForMenuStyle(menuStyle)
  }

  public override func loadView() {
    super.loadView()

    let width: CGFloat = self.view.bounds.size.width

    let x: CGFloat = 0.0
    let y: CGFloat = topBarHeight
    let w: CGFloat = width
    let h: CGFloat = kMenuItemHeight + self.separatorHeight

    scrollView = UIScrollView(frame: CGRect(x: x, y: y, width: w, height: h))
    scrollView?.backgroundColor = .clear
    scrollView?.delegate = self
    scrollView?.bounces = false
    scrollView?.scrollsToTop = false
    scrollView?.isPagingEnabled = false
    scrollView?.showsHorizontalScrollIndicator = false
    self.view.addSubview(scrollView!)

    self.prepareForMenuItems()
    self.prepareForMenuSeparator()
    self.prepareForMenuIndicator()
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    let style: UIPageViewControllerTransitionStyle = .scroll
    let pageViewController: UIPageViewController = UIPageViewController(transitionStyle: style, navigationOrientation: .horizontal, options: nil)
    pageViewController.delegate = self

    if let startingViewController: UIViewController = self.childControllers.first {
      let viewControllers: [UIViewController] = [startingViewController]
      pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
    }

    pageViewController.dataSource = self

    self.addChildViewController(pageViewController)
    self.view.addSubview(pageViewController.view)

    let  width: CGFloat = self.view.bounds.size.width
    let height: CGFloat = self.view.bounds.size.height

    let x: CGFloat = 0.0
    let y: CGFloat = topBarHeight + self.scrollView!.frame.size.height
    let w: CGFloat = width
    let h: CGFloat = height - y
    pageViewController.view.frame = CGRect(x: x, y: y, width: w, height: h)

    pageViewController.didMove(toParentViewController: self)
    self.pageViewController = pageViewController

    delegate?.pageMenuController(self, didPrepare: menuItems)
  }


  // MARK: convenient method
  func menuColor(at index: Int) -> UIColor {
    let numberOfColors: Int = self.menuColors.count
    guard numberOfColors > 0 else {
      return PMKPageMenuController.standardColors[index % PMKPageMenuController.standardColors.count]
    }
    return self.menuColors[index % numberOfColors]
  }

  // MARK: - Properties
  var currentIndex: Int = 0 {
    willSet {
      let index = currentIndex
      let viewController: UIViewController = self.childControllers[index]
      delegate?.pageMenuController(self, didMoveTo: viewController, at: index)

      // タブの形状を復元
      let item: PMKPageMenuItem = self.menuItems[index]
      item.isSelected = false
    }
    didSet {
      self.moveIndicator(at: currentIndex)
    }
  }

  // MARK: - Private Methods for Indicator
  func moveIndicator(at index: Int) {
    // まずはタブを移動させる
    self.willMoveIndicator(at: index)
  
    // そのあとタブの装飾をする
    let w: CGFloat = kMenuItemWidth + itemMargin
    let x: CGFloat = w * CGFloat(index)

    let item: PMKPageMenuItem = self.menuItems[index]
    switch (menuStyle) {
      case .Plain, .Suite:
        if var frame: CGRect = self.menuIndicator?.frame {
          frame.origin.x = x
          self.menuIndicator?.frame = frame
        }
      case .Tab:
        self.menuSeparator?.backgroundColor = item.color.cgColor
        self.menuIndicator?.backgroundColor = .clear
      case .Smart:
        self.menuIndicator?.backgroundColor = item.color
      case .Hacka:
        self.menuIndicator?.backgroundColor = .clear
      default:
        break
    }
    item.isSelected = true

    delegate?.pageMenuController(self, didSelect: item, at: index)
  }

  func willMoveIndicator(at index: Int) {
    let w: CGFloat = kMenuItemWidth + itemMargin
    var x: CGFloat = w * CGFloat(index)
    let y: CGFloat = 0.0

    let  width: CGFloat = self.scrollView!.frame.size.width
    // 選択したタブを中央寄せにする計算
    let   size:  CGSize = self.scrollView!.contentSize
    let  leftX: CGFloat = (width - w) * 0.5 // 画面幅の半分からタブ幅の半分を引く
    let   tabN: CGFloat = ceil(width / w) // 画面内に見えるタブの数
    let rightX: CGFloat = size.width - floor((tabN * 0.5 + 0.5) * w)
         if (x <  leftX) { x  = 0.0 }
    else if (x > rightX) { x  = size.width - width }
    else		 { x -= leftX }
    self.scrollView?.setContentOffset(CGPoint(x: x, y: y), animated: true)
  }

}

// MARK: - Prepartions
extension PMKPageMenuController
{
  // CUSTOM: Add the settings for your custom menu style here.
  func prepareForMenuStyle(_ menuStyle: PMKPageMenuControllerStyle) {
    switch (menuStyle) {
      case .Plain:
        self.itemMargin = kMenuItemMargin
        self.separatorHeight = 1.0
        self.indicatorHeight = 3.0
        break
      case .Tab:
        self.itemMargin = 0.0
        self.separatorHeight = 4.0
        self.indicatorHeight = 4.0
        break
      case .Smart:
        self.itemMargin = 0.0
        self.separatorHeight = 0.0
        break
      case .Hacka:
        self.itemMargin = kMenuItemMargin * 0.4
        break
      case .Web:
        self.itemMargin = 0.0
        self.separatorHeight = 4.0
        self.indicatorHeight = 0.0
        break
      case .Ellipse, .NetLab:
        self.itemMargin = 0.0
        self.separatorHeight = 0.0
        self.indicatorHeight = 0.0
        break
      case .Suite:
        self.itemMargin = 0.0
        self.separatorHeight = 0.0
        self.indicatorHeight = 4.0
        break
      case .NHK:
        self.itemMargin = 0.0
        self.separatorHeight = 2.0
        self.indicatorHeight = 0.0
        break
    }
  }

  // CUSTOM: Add the separator color for your custom menu style if needed.
  func prepareForMenuSeparator() {
    var color: UIColor = .clear
    if let firstColor: UIColor = self.menuColors.first {
      color = firstColor
    }
    else {
      switch (menuStyle) {
        case .Plain, .Web:
          color = .orange
        case .Hacka:
          color = UIColor.hexColor(kHackaHexColor)
        case .NHK:
          color = UIColor.hexColor(kNHKNewsHexColor)
        default:
          color = PMKPageMenuController.standardColors.first!
      }
    }
    let  width: CGFloat = self.scrollView!.contentSize.width
    let height: CGFloat = self.scrollView!.frame.size.height

    let w: CGFloat = width
    let h: CGFloat = self.separatorHeight
    let x: CGFloat = 0.0
    let y: CGFloat = height - h

    let layer: CALayer = CALayer()
    layer.frame = CGRect(x: x, y: y, width: w, height: h)
    layer.actions = [ "backgroundColor" : NSNull() ]
    layer.backgroundColor = color.cgColor
    self.scrollView?.layer.addSublayer(layer)
    self.menuSeparator = layer
  }

  // CUSTOM: Add the indicator color for your custom menu style if needed.
  func prepareForMenuIndicator() {
    let x: CGFloat = 0.0
    let y: CGFloat = self.scrollView!.frame.size.height - self.indicatorHeight
    let w: CGFloat = menuStyle == .Tab || menuStyle == .Smart
                   ? self.scrollView!.contentSize.width
                   : kMenuItemWidth
    let h: CGFloat = self.indicatorHeight

    var color: UIColor = .clear
    if let firstColor: UIColor = self.menuColors.first {
      color = firstColor
    }
    else {
      switch (menuStyle) {
        case .Plain:
          color = .orange
        case .Hacka:
          color = UIColor.hexColor(kHackaHexColor)
        case .Suite:
          color = UIColor.hexColor(0x7ab7cc)
        default:
          color = PMKPageMenuController.standardColors.first!
      }
    }

    let menuIndicator: UIView
    menuIndicator = UIView(frame: CGRect(x: x, y: y, width: w, height: h))
    menuIndicator.backgroundColor = color
    self.scrollView?.addSubview(menuIndicator)
    self.menuIndicator = menuIndicator
  }

  func handleSingleTap(_ gesture: UITapGestureRecognizer) {
    if var index: Int = gesture.view?.tag {
      index -= kMenuItemBaseTag
      let  viewController: UIViewController = self.childControllers[index]
      let viewControllers: [UIViewController] = [viewController]
      let direction: UIPageViewControllerNavigationDirection = (index > currentIndex) ? .forward : .reverse
      self.currentIndex = index
      self.pageViewController?.setViewControllers(viewControllers, direction: direction, animated: true, completion: nil)
    }
  }

  /*
   * swift3 - how to create instance of a class from a string in swift 3
   * https://stackoverflow.com/questions/40373030/how-to-create-instance-of-a-class-from-a-string-in-swift-3
   */
  func stringClassFromString(_ className: String) -> AnyClass! {
    // get namespace
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    // XXX: 順に "namespace" を変更して探索を試みる
    if let cls: AnyClass = NSClassFromString("PageMenuKitSwift.\(className)") {
      return cls
    }
    if let cls: AnyClass = NSClassFromString("PageMenuKit.\(className)") {
      return cls
    }
    // get 'anyClass' with classname and namespace
    let cls: AnyClass = NSClassFromString("\(namespace).\(className)")!
    // return AnyClass
    return cls
  }

  // CUSTOM: Add the code to create instance of your custom menu style.
  func prepareForMenuItems() {
    self.menuItems = []

    var x: CGFloat = 0.0
    let y: CGFloat = menuStyle == .Smart || menuStyle == .Hacka
                   ? kSmartTabMargin
                   : 0.0
    let w: CGFloat = kMenuItemWidth
    let h: CGFloat = kMenuItemHeight - y

    let count: Int = self.titles.count
    for i in 0 ..< count {
      let frame: CGRect = CGRect(x: x, y: y, width: w, height: h)
      let title: String = self.titles[i]
      var color: UIColor = .clear
      if self.menuColors.count == 0 { // 色指定がない場合はデフォルト色を使用
        switch (menuStyle) {
          case .Plain:
            color = .orange
          case .Hacka:
            color = UIColor.hexColor(kHackaHexColor)
          case .Ellipse:
            color = UIColor.hexColor(kJCNewsHexColor)
          case .NetLab:
            color = UIColor.hexColor(kNetLabHexColor)
          case .NHK:
            color = UIColor.hexColor(kNHKNewsHexColor)
          default:
            color = self.menuColor(at: i)
        }
      }
      else {
        switch (menuStyle) {
          case .Plain, .Hacka, .Ellipse, .NetLab, .NHK:
            color = self.menuColor(at: 0)
          default:
            color = self.menuColor(at: i)
        }
      }

      let design = PMKPageMenuItemDesign(themeColor: color)
      switch (menuStyle) { // set default design
        case .Web:
          design.inactive.isEnabled = true
          design.inactive.backgroundColor = UIColor.hexColor(0x332f2e)
        case .Suite:
          design.titleColor = .white
          design.gradientColors = [
            UIColor.hexColor(0x445a66).cgColor,
            UIColor.hexColor(0x677983).cgColor
          ]
          design.inactive.isEnabled = true
          design.inactive.titleColor = .lightGray
        case .NetLab:
          design.backgroundColor = UIColor.hexColor(0xcb8fad)
        default:
          break
      }

      let className = menuStyle.className()
      let classType = stringClassFromString(className) as! PMKPageMenuItem.Type
      let item: PMKPageMenuItem = classType.init(frame: frame, title: title, design: design)
      item.tag = kMenuItemBaseTag + i
      self.scrollView?.addSubview(item)
      x += (w + itemMargin)

      item.isSelected = (i == 0)
      self.menuItems.append(item)

      let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
      item.addGestureRecognizer(tapGesture)
    }

    let  width: CGFloat = self.scrollView!.bounds.size.width
    let height: CGFloat = self.scrollView!.bounds.size.height
    self.scrollView?.contentSize = CGSize(width: x, height: height)

    var frame: CGRect = self.scrollView!.frame
    if (width > x) { // 項目が少ないのね
      frame.origin.x = floor((width - x) * 0.5)
      frame.size.width = x
    }
    else {
      frame.origin.x = 0.0
      frame.size.width = width
    }
    self.scrollView?.frame = frame
  }

}

// MARK: - Public Methods
extension PMKPageMenuController
{
  public func setMenuSeparatorColor(_ color: UIColor) {
    self.menuSeparator?.backgroundColor = color.cgColor
  }

  public func setMenuIndicatorColor(_ color: UIColor) {
    self.menuIndicator?.backgroundColor = color
  }

}

/*
 * MARK: - UIPageViewControllerDelegate
 */
extension PMKPageMenuController: UIPageViewControllerDelegate
{
  // MARK - UIPageViewControllerDelegate (optional)
  public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    if let viewController: UIViewController = pendingViewControllers.last {
      if let index = self.childControllers.index(of: viewController) {
        if index != currentIndex {
          self.willMoveIndicator(at: index)
        }
        delegate?.pageMenuController(self, willMoveTo: viewController, at: index)
      }
    }
  }

  // MARK - UIPageViewControllerDelegate (optional)
  public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if let viewController: UIViewController = pageViewController.viewControllers?.last {
      guard let index = self.childControllers.index(of: viewController) else {
        return
      }
      if (completed) {
        self.currentIndex = index
      }
      else {
        self.willMoveIndicator(at: index)
      }
    }
  }

  // MARK - UIPageViewControllerDelegate (optional)
  public func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
    if UIInterfaceOrientationIsPortrait(orientation) ||
       UIDevice.current.userInterfaceIdiom == .phone {
      if let currentViewController: UIViewController = pageViewController.viewControllers?.first {
        let viewControllers: [UIViewController] = [currentViewController]
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
      }
      pageViewController.isDoubleSided = false
      return .min
    }
    return .none
  }

}

/*
 * MARK: - UIPageViewControllerDataSource
 */
extension PMKPageMenuController: UIPageViewControllerDataSource
{
  // MARK - UIPageViewControllerDataSource (required)
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let index = self.childControllers.index(of: viewController) {
      if index != 0 && index != NSNotFound {
        return self.childControllers[index - 1]
      }
    }
    return nil
  }

  // MARK - UIPageViewControllerDataSource (required)
  public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let index = self.childControllers.index(of: viewController) {
      let count: Int = self.childControllers.count
      if index != NSNotFound && index + 1 < count {
        return self.childControllers[index + 1]
      }
    }
    return nil
  }

}
