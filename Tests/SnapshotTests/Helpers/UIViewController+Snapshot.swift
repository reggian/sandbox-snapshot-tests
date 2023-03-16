//
// Copyright © 2023 reggian
//

import UIKit

extension UIViewController {
  func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
    let window = SnapshotWindow(configuration: configuration)
    window.setupRoot(self)
    let snapshot = window.snapshot()
    window.teardownRoot()
    return snapshot
  }
}

struct SnapshotConfiguration {
  let size: CGSize
  let safeAreaInsets: UIEdgeInsets
  let directionalLayoutMargins: NSDirectionalEdgeInsets
  let traitCollection: UITraitCollection
  
  static func iPhone14(style: UIUserInterfaceStyle = .light) -> SnapshotConfiguration {
    return SnapshotConfiguration(
      size: .init(width: 390, height: 844),
      safeAreaInsets: .init(top: 47, left: 0, bottom: 34, right: 0),
      directionalLayoutMargins: .init(top: 47, leading: 16, bottom: 34, trailing: 16),
      traitCollection: .init(traitsFrom: [
        .init(forceTouchCapability: .unavailable),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .large),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(displayScale: 3),
        .init(accessibilityContrast: .normal),
        .init(displayGamut: .P3),
        .init(userInterfaceStyle: style)
      ])
    )
  }
  
  static func iPhone14Zoomed(style: UIUserInterfaceStyle = .light) -> SnapshotConfiguration {
    return SnapshotConfiguration(
      size: .init(width: 320, height: 693),
      safeAreaInsets: .init(top: 39, left: 0, bottom: 28, right: 0),
      directionalLayoutMargins: .init(top: 39, leading: 16, bottom: 28, trailing: 16),
      traitCollection: .init(traitsFrom: [
        .init(forceTouchCapability: .unavailable),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .large),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(displayScale: 3),
        .init(accessibilityContrast: .normal),
        .init(displayGamut: .P3),
        .init(userInterfaceStyle: style)
      ])
    )
  }
  
  static func iPhoneSE3(style: UIUserInterfaceStyle = .light) -> SnapshotConfiguration {
    return SnapshotConfiguration(
      size: .init(width: 375, height: 667),
      safeAreaInsets: .init(top: 20, left: 0, bottom: 0, right: 0),
      directionalLayoutMargins: .init(top: 20, leading: 16, bottom: 0, trailing: 16),
      traitCollection: .init(traitsFrom: [
        .init(forceTouchCapability: .unavailable),
        .init(layoutDirection: .leftToRight),
        .init(preferredContentSizeCategory: .large),
        .init(userInterfaceIdiom: .phone),
        .init(horizontalSizeClass: .compact),
        .init(verticalSizeClass: .regular),
        .init(displayScale: 2),
        .init(displayGamut: .P3),
        .init(userInterfaceStyle: style)
      ])
    )
  }
}

// MARK: - Private
private final class SnapshotWindow: UIWindow {
  private var configuration: SnapshotConfiguration = .iPhone14()
  
  convenience init(configuration: SnapshotConfiguration) {
    self.init(frame: CGRect(origin: .zero, size: configuration.size))
    self.configuration = configuration
    self.directionalLayoutMargins = configuration.directionalLayoutMargins
  }
  
  override var safeAreaInsets: UIEdgeInsets {
    return configuration.safeAreaInsets
  }
  
  override var traitCollection: UITraitCollection {
    return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
  }
  
  func setupRoot(_ root: UIViewController) {
    rootViewController = SnapshotContainerViewController(configuration: configuration, root: root)
    isHidden = false
  }
  
  func teardownRoot() {
    rootViewController = nil
  }
  
  func snapshot() -> UIImage {
    let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
    return renderer.image { action in
      layer.render(in: action.cgContext)
    }
  }
}

private final class SnapshotContainerViewController: UIViewController {
  private let configuration: SnapshotConfiguration
  private let root: UIViewController
  
  init(configuration: SnapshotConfiguration, root: UIViewController) {
    self.configuration = configuration
    self.root = root
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { return nil }
  
  override func loadView() {
    addChild(root)
    view = SnapshotView(configuration: configuration, root: root.view)
    root.didMove(toParent: self)
  }
}

private final class SnapshotView: UIView {
  private let configuration: SnapshotConfiguration
  
  init(configuration: SnapshotConfiguration, root: UIView) {
    self.configuration = configuration
    super.init(frame: CGRect(origin: .zero, size: configuration.size))
    root.frame = bounds
    addSubview(root)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { return nil }
  
  override var safeAreaInsets: UIEdgeInsets {
    configuration.safeAreaInsets
  }
}
