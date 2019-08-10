// Copyright 2015-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

import CatalogByConvention
import Nimbus

class NodeViewTableViewDemoCell: UITableViewCell {
}

class NodeViewTableViewPrimaryDemoCell: UITableViewCell {
}

class MDCNodeListViewController: CBCNodeListViewController {
  var componentDescription = ""

  deinit {
    NotificationCenter.default.removeObserver(self,
                                              name: AppTheme.didChangeGlobalThemeNotificationName,
                                              object: nil)
  }

  override init(node: CBCNode) {
    super.init(node: node)

    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .never
    }

    let examples = node.children.filter { $0.isExample() }

    // Make sure that primary demo appears first
    let primaryDemos = examples.filter { $0.isPrimaryDemo() }
    let nonPrimaryDemos = examples.filter { !$0.isPrimaryDemo() }

    let children = primaryDemos + nonPrimaryDemos

    componentDescription = children.first?.exampleDescription() ?? ""
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.tableView.backgroundColor = AppTheme.containerScheme.colorScheme.backgroundColor
  }
}

private func themeExample(vc: UIViewController) {
  let colorSel = NSSelectorFromString("setColorScheme:");
  if vc.responds(to: colorSel) {
    vc.perform(colorSel, with: AppTheme.containerScheme.colorScheme)
  }
  let typoSel = NSSelectorFromString("setTypographyScheme:");
  if vc.responds(to: typoSel) {
    vc.perform(typoSel, with: AppTheme.containerScheme.typographyScheme)
  }
  let containerSel = NSSelectorFromString("setContainerScheme:")
  if vc.responds(to: containerSel) {
    vc.perform(containerSel, with: AppTheme.containerScheme)
  }
}
