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
import MaterialCatalog
import Nimbus

import MaterialComponents.MaterialTypography

private let inset: CGFloat = 16
private let logoWidthHeight: CGFloat = 30
private let spacing: CGFloat = 1

class MDCCatalogComponentsController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

  private let node: CBCNode
  private let model: NICollectionViewModel?
  private let factory = NICollectionViewCellFactory()

  init(collectionViewLayout ignoredLayout: UICollectionViewLayout, node: CBCNode) {
    self.node = node
    self.model = NICollectionViewModel(listArray: node.children, delegate: factory)

    factory.mapObjectClass(CBCNode.self, toCellClass: MDCCatalogCollectionViewCell.self)

    let layout = UICollectionViewFlowLayout()
    let sectionInset: CGFloat = spacing
    layout.sectionInset = UIEdgeInsets(top: sectionInset,
                                       left: sectionInset,
                                       bottom: sectionInset,
                                       right: sectionInset)
    layout.minimumInteritemSpacing = spacing
    layout.minimumLineSpacing = spacing

    super.init(collectionViewLayout: layout)

    title = "Material Components for iOS"
    if #available(iOS 11.0, *) {
      navigationItem.largeTitleDisplayMode = .always
    }

    let logo = MDCDrawImage(CGRect(x:0, y:0, width: logoWidthHeight, height: logoWidthHeight), {
      MDCCatalogDrawMDCLogoLight($0, $1)
    }, AppTheme.containerScheme.colorScheme)
    let logoImageView = UIImageView(image: logo)
    let logoItem = UIBarButtonItem(customView: logoImageView)
    logoItem.isEnabled = false
    navigationItem.leftBarButtonItem = logoItem

    navigationItem.rightBarButtonItem =
      UIBarButtonItem(barButtonSystemItem: .action,
      target: self,
      action: #selector(presentMenu))
  }

  convenience init(node: CBCNode) {
    self.init(collectionViewLayout: UICollectionViewLayout(), node: node)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView?.backgroundColor = AppTheme.containerScheme.colorScheme.backgroundColor
    view.backgroundColor = AppTheme.containerScheme.colorScheme.backgroundColor

    collectionView?.accessibilityIdentifier = "collectionView"

    collectionView.dataSource = model
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    let dividerWidth: CGFloat = 1
    var safeInsets: CGFloat = 0
    if #available(iOS 11, *) {
      safeInsets = view.safeAreaInsets.left + view.safeAreaInsets.right
    }
    var cellWidthHeight: CGFloat

    // iPhones have 2 columns in portrait and 3 in landscape
    if UI_USER_INTERFACE_IDIOM() == .phone {
      cellWidthHeight = (view.frame.size.width - 3 * dividerWidth - safeInsets) / 2
      if view.frame.size.width > view.frame.size.height {
        cellWidthHeight = (view.frame.size.width - 4 * dividerWidth - safeInsets) / 3
      }
    } else {
      // iPads have 4 columns
      cellWidthHeight = (view.frame.size.width - 5 * dividerWidth - safeInsets) / 4
    }
    layout.itemSize = CGSize(width: cellWidthHeight, height: cellWidthHeight)
  }

  override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation,
                                    duration: TimeInterval) {
    collectionView?.collectionViewLayout.invalidateLayout()
  }

  override func collectionView(_ collectionView: UICollectionView,
                               didSelectItemAt indexPath: IndexPath) {
    let node = self.node.children[indexPath.row]
    var vc: UIViewController
    if node.isExample() {
      vc = node.createExampleViewController()
    } else {
      vc = MDCNodeListViewController(node: node)
    }

    vc.navigationItem.rightBarButtonItem =
      UIBarButtonItem(barButtonSystemItem: .action,
      target: vc,
      action: #selector(presentMenu))

    self.navigationController?.pushViewController(vc, animated: true)
  }
}
