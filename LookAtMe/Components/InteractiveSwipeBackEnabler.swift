import SwiftUI
import UIKit

struct InteractiveSwipeBackEnabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller {
        Controller()
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.enableSwipeBackIfNeeded()
    }

    final class Controller: UIViewController {
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            enableSwipeBackIfNeeded()
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            enableSwipeBackIfNeeded()
        }

        func enableSwipeBackIfNeeded() {
            guard
                let navigationController = nearestNavigationController(),
                navigationController.viewControllers.count > 1,
                let gesture = navigationController.interactivePopGestureRecognizer
            else {
                return
            }

            gesture.isEnabled = true
            gesture.delegate = nil
        }

        private func nearestNavigationController() -> UINavigationController? {
            if let navigationController {
                return navigationController
            }

            var current = parent
            while let viewController = current {
                if let navigationController = viewController as? UINavigationController {
                    return navigationController
                }
                if let navigationController = viewController.navigationController {
                    return navigationController
                }
                current = viewController.parent
            }

            return nil
        }
    }
}
