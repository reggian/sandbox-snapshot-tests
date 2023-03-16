//
// Copyright © 2023 reggian
//

import XCTest
@testable import Snap

final class SnapshotTests: XCTestCase {
  func test_safeAreaInsets_withSingleLineTitle() {
    let child = ChildViewController(title: "Single Line Title")
    let sut = ContainerViewController(childController: child)
    
    assert(snapshot: sut.snapshot(for: .iPhoneSE3()), named: "safe_area_insets_singleline--iPSE3")
  }
  
  func test_safeAreaInsets_withMultiLineTitle() {
    let child = ChildViewController(title: "Multi Line\nTitle")
    let sut = ContainerViewController(childController: child)
    
    assert(snapshot: sut.snapshot(for: .iPhoneSE3()), named: "safe_area_insets_multiline--iPSE3")
  }
}

// MARK: - Helpers
private final class ChildViewController: UIViewController {
  convenience init(title: String) {
    self.init()
    self.title = title
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .red
    let safeAreaInsetsView = UIView()
    safeAreaInsetsView.backgroundColor = .blue
    safeAreaInsetsView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(safeAreaInsetsView)
    NSLayoutConstraint.activate([
      safeAreaInsetsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      safeAreaInsetsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      safeAreaInsetsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      safeAreaInsetsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
  }
}
