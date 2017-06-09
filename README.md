# PageMenuKitSwift

[PageMenuController](https://github.com/magickworx/PageMenuController) の Swift 版。

日本のニュース系アプリで使われている横スクロールのメニュー画面とそのコンテンツを表示するユーザインタフェースのクラス。
Xcode のプロジェクト一式を登録してあるので、実行すればシミュレータ上で動作確認が可能。

Swift3 で実装し直す際に、汎用的で拡張しやすいようにクラスを再設計した。ページメニューの見た目だけが違うので、スタイルごとに PMKPageMenuItem のサブクラスを実装し、それを利用する仕組みにした。よって、簡単にカスタムメニューを追加できる。

## How to use PageMenuKit.framework

Xcode の Build Target に PageMenuKitFatBinary を指定して Build を実行すると、PageMenuKit.framework が作成される。これを自作アプリの Xcode の Project で設定する。

あとは、以下のようなコードを記述して利用する。

```Swift
class RootViewController: UIViewController
{
  var pageMenuController: PMKPageMenuController? = nil

  override func viewDidLoad() {
    super.viewDidLoad()

    var controllers: [UIViewController] = []
    let dateFormatter = DateFormatter()
    for month in dateFormatter.monthSymbols {
      let viewController: DataViewController = DataViewController()
      viewController.title = month
      controllers.append(viewController)
    }

    let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    /*
     * Available menu styles:
     * .Plain, .Tab, .Smart, .Hacka, .Ellipse, .Web, .Suite, .NetLab and .NHK
     * See PMKPageMenuItem.swift in PageMenuKit folder.
     */
    pageMenuController = PMKPageMenuController(controllers: controllers, menuStyle: .Smart, topBarHeight: statusBarHeight)
    self.addChildViewController(pageMenuController!)
    self.view.addSubview(pageMenuController!.view)
    pageMenuController?.didMove(toParentViewController: self)
  }
}
```

より詳細なコードは PageMenuKitDemo 内の RootViewController.swift を見てね。


## Available Menu Styles

### .Plain
[ニュースパス](https://itunes.apple.com/jp/app/id1106788059?mt=8)っぽいメニュー画面

![.Plain](screenshots/tab_Plain.png "ニュースパス")

### .Tab
[グノシー](https://itunes.apple.com/jp/app/id590384791?mt=8)っぽいメニュー画面

![.Tab](screenshots/tab_Tab.png "グノシー")

### .Smart
[SmartNews](https://itunes.apple.com/jp/app/id579581125?mt=8)っぽいメニュー画面

![.Smart](screenshots/tab_Smart.png "SmartNews")

### .Hacka
[ハッカドール](https://itunes.apple.com/jp/app/id888231424?mt=8)っぽいメニュー画面

![.Hacka](screenshots/tab_Hacka.png "ハッカドール")

### .Ellipse
[JCnews](https://itunes.apple.com/jp/app/id1024341813?mt=8)っぽいメニュー画面

![.Ellipse](screenshots/tab_Ellipse.png "JCnews iOS App")

### .Web
[JCnews のウェブサイト](https://jcnews.tokyo/)っぽいメニュー画面

![.Web](screenshots/tab_Web.png "JCnews ウェブサイト")

### .Suite
[NewsSuite](https://itunes.apple.com/jp/app/id1176431318?mt=8)っぽいメニュー画面

![.Suite](screenshots/tab_Suite.png "ニュース（NewsSuite）")

### .NetLab
[ねとらぼ](https://itunes.apple.com/jp/app/id949325541?mt=8)っぽいメニュー画面

![.NetLab](screenshots/tab_NetLab.png "ねとらぼ")

### .NHK
[NHK ニュース防災](https://itunes.apple.com/jp/app/id1121104608?mt=8)っぽいメニュー画面

![.NHK](screenshots/tab_NHK.png "NHK ニュース防災")



## Delegate Methods (optional)

ページの切り替え時に呼び出される Delegate を使うことも可能。

```swift
pageMenuController?.delegate = self
```

上記のような記述を追加して、必要に応じて以下のメソッドを実装してね。
現時点では、 **.Hacka** スタイルのバッジ表示の際に利用しているだけ。

```PMKPageMenuControllerDelegte.swift
public protocol PMKPageMenuControllerDelegate: class
{
  // ページ画面上でスワイプ操作による切り替えが行われる前に呼び出される
  func pageMenuController(_ pageMenuController: PMKPageMenuController, willMoveTo viewController: UIViewController, at menuIndex: Int)
  // ページの切り替えが完了した際に呼び出される
  func pageMenuController(_ pageMenuController: PMKPageMenuController, didMoveTo viewController: UIViewController, at menuIndex: Int)

  // メニュー項目の作成などが完了した際に呼び出される
  func pageMenuController(_ pageMenuController: PMKPageMenuController, didPrepare menuItems: [PMKPageMenuItem])
  // メニューがタップされた際に呼び出される
  func pageMenuController(_ pageMenuController: PMKPageMenuController, didSelect menuItem: PMKPageMenuItem, at menuIndex: Int)
}
```

## References

Qiita の[ニュース系アプリのユーザインタフェース PageMenuKit の実装](http://qiita.com/magickworx/items/5de63eb926a9447b2665) も見てね。カスタムメニューの実装方法についても書いてあるよ。

## Requirements

 - Swift3
 - iOS 10.3 or later
 - Xcode 8.3 or later

## License Agreement

Copyright (c) 2017, Kouichi ABE (WALL) All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 1. Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

