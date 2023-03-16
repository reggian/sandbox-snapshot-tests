//
// Copyright © 2023 reggian
//

import UIKit

final class ContainerViewController: UIViewController {
  private let childController: UIViewController
  
  init(childController: UIViewController) {
    self.childController = childController
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { return nil }
  
  private lazy var titleLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup(view: view, with: childController)
    setup(view: view)
    updateTitle()
  }
}

// MARK: - Private
private extension ContainerViewController {
  var titleMargins: (top: CGFloat, bottom: CGFloat) { (16, 16) }
  
  func setup(view: UIView, with childController: UIViewController) {
    addChild(childController)
    childController.view.frame = view.bounds
    view.addSubview(childController.view)
    childController.didMove(toParent: self)
  }
  
  func setup(view: UIView) {
    view.addSubview(titleLabel)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: titleMargins.top),
      titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor),
      titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    ])
    
    titleLabel.numberOfLines = 0
    titleLabel.textAlignment = .center
  }
  
  func updateTitle() {
    titleLabel.text = childController.title
    view.layoutIfNeeded()
    childController.additionalSafeAreaInsets.top = titleMargins.top + titleLabel.bounds.height + titleMargins.bottom
  }
}
