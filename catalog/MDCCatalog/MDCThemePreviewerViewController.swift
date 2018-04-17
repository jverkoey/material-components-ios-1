/*
 Copyright 2018-present the Material Components for iOS authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import MaterialComponents.MaterialPalettes
import MaterialComponents.MaterialThemes
import UIKit

let colorScheme = MDCSemanticColorScheme()

class MDCThemePreviewerViewController: UIViewController {

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var colorSchemeDidChangeApplicators: [() -> Void] = [
  ]

  private let componentsScrollView = UIScrollView()
  private let schemeSymbolsView = UITableView(frame: .zero, style: .grouped)
  fileprivate let schemeSymbolEditorView = UIView()
  override func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DidChangeColor"), object: nil, queue: nil) { notification in
      self.colorSchemeDidChangeApplicators.forEach { $0() }
    }

    view.backgroundColor = .white

    let (componentFrame, schemeFrame) = view.bounds.divided(atDistance: view.bounds.midY, from: .minYEdge)

    componentsScrollView.frame = componentFrame
    componentsScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin]
    view.addSubview(componentsScrollView)

    var contentSize = CGSize.zero
    let expandContentSize = { (view: UIView) in
      contentSize = CGSize(width: max(contentSize.width, view.frame.maxX),
                           height: max(contentSize.height, view.frame.maxY))
    }

    colorSchemeDidChangeApplicators.append {
      self.view.backgroundColor = colorScheme.backgroundColor
    }

    let activityIndicator = MDCActivityIndicator()
    activityIndicator.sizeToFit()
    activityIndicator.startAnimating()
    activityIndicator.frame = CGRect(origin: .init(x: 16, y: 16), size: activityIndicator.bounds.size)
    componentsScrollView.addSubview(activityIndicator)
    expandContentSize(activityIndicator)
    colorSchemeDidChangeApplicators.append {
      MDCActivityIndicatorColorThemer.applySemanticColorScheme(colorScheme, to: activityIndicator)
    }

    let flatButton = MDCFlatButton()
    flatButton.setTitle("Flat button", for: .normal)
    flatButton.sizeToFit()
    flatButton.frame = CGRect(origin: .init(x: contentSize.width + 16, y: 16), size: flatButton.frame.size)
    componentsScrollView.addSubview(flatButton)
    expandContentSize(flatButton)
    colorSchemeDidChangeApplicators.append {
      MDCButtonColorThemer.applySemanticColorScheme(colorScheme, to: flatButton)
    }

    let floatingButton = MDCFloatingButton()
    floatingButton.setTitle("+", for: .normal)
    floatingButton.frame = CGRect(origin: .init(x: contentSize.width + 16, y: 16),
                                  size: floatingButton.sizeThatFits(CGSize(width: view.bounds.width, height: view.bounds.height)))
    componentsScrollView.addSubview(floatingButton)
    expandContentSize(floatingButton)
    colorSchemeDidChangeApplicators.append {
      MDCButtonColorThemer.applySemanticColorScheme(colorScheme, to: floatingButton)
    }

    let raisedButton = MDCRaisedButton()
    raisedButton.setTitle("Raised button", for: .normal)
    raisedButton.frame = CGRect(origin: .init(x: contentSize.width + 16, y: 16),
                                  size: raisedButton.sizeThatFits(CGSize(width: view.bounds.width, height: view.bounds.height)))
    componentsScrollView.addSubview(raisedButton)
    expandContentSize(raisedButton)
    colorSchemeDidChangeApplicators.append {
      MDCButtonColorThemer.applySemanticColorScheme(colorScheme, to: raisedButton)
    }

    let card = MDCCard()
    card.frame = CGRect(origin: .init(x: contentSize.width + 16, y: 16),
                        size: .init(width: 200, height: 200))
    componentsScrollView.addSubview(card)
    expandContentSize(card)
    colorSchemeDidChangeApplicators.append {
      MDCCardsColorThemer.applySemanticColorScheme(colorScheme, to: card)
    }

    let navigationBar = MDCNavigationBar()
    navigationBar.title = "Navigation Bar"
    let backImage = MDCIcons.imageFor_ic_arrow_back()!.withRenderingMode(.alwaysTemplate)
    navigationBar.leadingBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: nil, action: nil)
    navigationBar.trailingBarButtonItem = UIBarButtonItem(title: "T",
                                                       style: .plain,
                                                       target: nil,
                                                       action: nil)
    navigationBar.sizeToFit()
    navigationBar.frame = CGRect(origin: .init(x: 16, y: contentSize.height + 16),
                        size: .init(width: 320, height: navigationBar.bounds.height))
    componentsScrollView.addSubview(navigationBar)
    expandContentSize(navigationBar)
    colorSchemeDidChangeApplicators.append {
      MDCNavigationBarColorThemer.applySemanticColorScheme(colorScheme, to: navigationBar)
    }

    componentsScrollView.contentSize = contentSize

    let (symbolsFrame, editorFrame) = schemeFrame.divided(atDistance: schemeFrame.midX, from: .minXEdge)
    schemeSymbolsView.frame = symbolsFrame
    schemeSymbolsView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleRightMargin]
    schemeSymbolsView.dataSource = self
    schemeSymbolsView.delegate = self
    schemeSymbolsView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    view.addSubview(schemeSymbolsView)

    schemeSymbolEditorView.frame = editorFrame
    schemeSymbolEditorView.backgroundColor = .gray
    schemeSymbolEditorView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleLeftMargin]
    view.addSubview(schemeSymbolEditorView)
    
    self.colorSchemeDidChangeApplicators.forEach { $0() }
  }
}

private protocol SymbolEditor {
  var title: String { get }
  func createEditorView(frame: CGRect) -> UIView
}

private struct ColorSchemeEditor: SymbolEditor {
  let title: String
  let initialValue: () -> UIColor
  let didChange: (UIColor) -> Void

  class ColorPickerView: UIView {
    let redSlider = UISlider()
    let greenSlider = UISlider()
    let blueSlider = UISlider()
    let alphaSlider = UISlider()
    let didChange: (UIColor) -> Void
    var color: UIColor
    init(frame: CGRect, color: UIColor, didChange: @escaping (UIColor) -> Void) {
      self.color = color
      self.didChange = didChange

      super.init(frame: frame)

      let (topHalf, bottomHalf) = frame.divided(atDistance: frame.height / 2, from: .minYEdge)
      let (redFrame, greenFrame) = topHalf.divided(atDistance: topHalf.midY, from: .minYEdge)
      let (blueFrame, alphaFrame) = bottomHalf.divided(atDistance: topHalf.midY, from: .minYEdge)

      redSlider.frame = redFrame
      greenSlider.frame = greenFrame
      blueSlider.frame = blueFrame
      alphaSlider.frame = alphaFrame

      var red : CGFloat = 0
      var green : CGFloat = 0
      var blue : CGFloat = 0
      var alpha: CGFloat = 0
      if color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
        redSlider.value = Float(red)
        blueSlider.value = Float(blue)
        greenSlider.value = Float(green)
        alphaSlider.value = Float(alpha)
      }

      [redSlider, greenSlider, blueSlider, alphaSlider].forEach {
        $0.addTarget(self, action: #selector(ColorPickerView.sliderDidChange(_:)), for: .valueChanged)
        addSubview($0)
      }
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func sliderDidChange(_ sender: UISlider) {
      var red : CGFloat = 0
      var green : CGFloat = 0
      var blue : CGFloat = 0
      var alpha: CGFloat = 0
      guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        return
      }

      switch sender {
      case redSlider:
        red = CGFloat(sender.value)
      case blueSlider:
        blue = CGFloat(sender.value)
      case greenSlider:
        green = CGFloat(sender.value)
      case alphaSlider:
        alpha = CGFloat(sender.value)
      default:
        break
      }

      color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
      didChange(color)
    }
  }

  func createEditorView(frame: CGRect) -> UIView {
    return ColorPickerView(frame: frame, color: initialValue(), didChange: didChange)
  }
}

private let cellReuseIdentifier = "cell"
let symbolsModel = [
  [
    "Color Scheme",
    ColorSchemeEditor(title: "Primary", initialValue: { colorScheme.primaryColor }, didChange: {
      colorScheme.primaryColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "Primary variant", initialValue: { colorScheme.primaryColorVariant }, didChange: {
      colorScheme.primaryColorVariant = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "Secondary", initialValue: { colorScheme.secondaryColor }, didChange: {
      colorScheme.secondaryColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "Surface", initialValue: { colorScheme.surfaceColor }, didChange: {
      colorScheme.surfaceColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "Background", initialValue: { colorScheme.backgroundColor }, didChange: {
      colorScheme.backgroundColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "On primary", initialValue: { colorScheme.onPrimaryColor }, didChange: {
      colorScheme.onPrimaryColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "On secondary", initialValue: { colorScheme.onSecondaryColor }, didChange: {
      colorScheme.onSecondaryColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "On surface", initialValue: { colorScheme.onSurfaceColor }, didChange: {
      colorScheme.onSurfaceColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    }),
    ColorSchemeEditor(title: "On background", initialValue: { colorScheme.onBackgroundColor }, didChange: {
      colorScheme.onBackgroundColor = $0
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidChangeColor"), object: nil)
    })
  ],
  [
    "Typography Scheme"
  ]
]
extension MDCThemePreviewerViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return symbolsModel.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return symbolsModel[section].count - 1
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return (symbolsModel[section][0] as! String)
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    cell.accessoryType = .disclosureIndicator
    cell.textLabel?.text = (symbolsModel[indexPath.section][indexPath.row + 1] as! SymbolEditor).title
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    schemeSymbolEditorView.subviews.forEach { $0.removeFromSuperview() }

    let editor = (symbolsModel[indexPath.section][indexPath.row + 1] as! SymbolEditor)
    let editorView = editor.createEditorView(frame: schemeSymbolEditorView.bounds)
    editorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    schemeSymbolEditorView.addSubview(editorView)
  }
}

// MARK: Catalog by convention
extension MDCThemePreviewerViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["Themes", "Preview themes"]
  }

  class func catalogIsDebug() -> Bool {
    return true
  }

  class func catalogIsPrimaryDemo() -> Bool {
    return false
  }

  @objc class func catalogIsPresentable() -> Bool {
    return true
  }
}

