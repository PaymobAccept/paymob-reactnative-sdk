import PaymobSDK
import UIKit
import React

let paymob = PaymobSDK()

@objc(PaymobReactnative)
class PaymobReactnative: RCTEventEmitter, PaymobSDKDelegate {

    // MARK: - Properties
    private var appIcon: UIImage? = nil
    private var appName: String? = nil
    private var buttonBackgroundColor: UIColor? = nil
    private var buttonTextColor: UIColor? = nil
    private var saveCardDefault: Bool? = nil
    private var showSaveCard: Bool? = nil
    private var showConfirmationPage: Bool? = nil
    private var showTransactionResult: Bool? = nil
    private var isKeyboardHandlingEnabled: Bool? = nil

    // MARK: - React Native Module
    override static func moduleName() -> String {
        return "PaymobReactnative"
    }

    override func supportedEvents() -> [String]! {
        return ["onTransactionStatus"]
    }

    // MARK: - Public Methods
    @objc
    func setAppIcon(_ base64Image: String) {
      if let imageData = Data(base64Encoded: base64Image),
         let image = UIImage(data: imageData) {
          appIcon = image
      }
    }

    @objc
    func setAppName(_ name: String) {
        appName = name
    }

    @objc
    func setButtonBackgroundColor(_ color: UIColor) {
    buttonBackgroundColor =  color
    }

    @objc
    func setButtonTextColor(_ color: UIColor) {
         buttonTextColor = color
    }

    @objc
    func setSaveCardDefault(_ isChecked: Bool) {
        saveCardDefault = isChecked
    }

    @objc
    func setShowSaveCard(_ isVisible: Bool) {
        showSaveCard = isVisible
    }

    @objc
    func setShowConfirmationPage(_ isVisible: Bool) {
      showConfirmationPage = isVisible
    }

    @objc
    func setShowTransactionResult(_ isVisible: Bool) {
      showTransactionResult = isVisible
    }

    @objc
    func setKeyboardHandlingEnabled(_ isEnabled: Bool) {
      isKeyboardHandlingEnabled = isEnabled
    }

    @objc
    func presentPayVC(_ clientSecret: String, publicKey: String) {
        paymob.delegate = self

        // Get the current view controller on the main thread
        DispatchQueue.main.async {
            let currentVC = self.topMostController()
            do {
                self.setupPaymobCustomization()
                try paymob.presentPayVC(VC: currentVC!, PublicKey: publicKey, ClientSecret: clientSecret)
            } catch let error {
                print("Error presenting PayVC: \(error.localizedDescription)")
                return
            }
        }
    }

  // MARK: - Transaction Status Handling
 public func transactionRejected(message: String) {
      // Handle transaction rejection
      print("Transaction Rejected")
      let params: [String: Any] = ["status": "Fail"]
      emitEvent(eventName: "onTransactionStatus", params: params)
  }

 public func transactionAccepted(transactionDetails: [String: Any]) {
      // Handle transaction acceptance
      print("Transaction Accepted")
      var params: [String: Any] = ["status": "Success", "details": transactionDetails]
      emitEvent(eventName: "onTransactionStatus", params: params)
  }

 public func transactionPending() {
      // Handle transaction pending status
      print("Transaction Pending")
      let params: [String: Any] = ["status": "Pending"]
      emitEvent(eventName: "onTransactionStatus", params: params)
  }

    // MARK: - Private Methods
    private func setupPaymobCustomization() {
        if let appIcon = self.appIcon {
            paymob.paymobSDKCustomization.appIcon = appIcon
        }

        if let appName = self.appName {
            paymob.paymobSDKCustomization.appName = appName
        }

        if let buttonBackgroundColor = self.buttonBackgroundColor {
            paymob.paymobSDKCustomization.buttonBackgroundColor = buttonBackgroundColor
        }

        if let buttonTextColor = self.buttonTextColor {
            paymob.paymobSDKCustomization.buttonTextColor = buttonTextColor
        }

        if let showSaveCard = self.showSaveCard {
            paymob.paymobSDKCustomization.showSaveCard = showSaveCard
        }

        if let saveCardDefault = self.saveCardDefault {
            paymob.paymobSDKCustomization.saveCardDefault = saveCardDefault
        }

      if let showConfirmationPage = self.showConfirmationPage {
        paymob.paymobSDKCustomization.showConfirmationPage = showConfirmationPage
      }

        if let showTransactionResult = self.showTransactionResult {
            paymob.paymobSDKCustomization.showTransactionResult = showTransactionResult
        }

        if let isKeyboardHandlingEnabled = self.isKeyboardHandlingEnabled {
            paymob.paymobSDKCustomization.isKeyboardHandlingEnabled = isKeyboardHandlingEnabled
        }

    }

    private func emitEvent(eventName: String, params: [String: Any]) {
        sendEvent(withName: eventName, body: params)
    }

    // MARK: - Helper Methods
   private func topMostController() -> UIViewController? {
        // Check for available windows in the connected scenes
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Get the key window from the window scene
            let rootViewController = windowScene.windows.filter { $0.isKeyWindow }.first?.rootViewController

            // Traverse the view controller hierarchy to find the top view controller
            return findTopViewController(for: rootViewController)
        }
        return nil
    }

    private func findTopViewController(for vc: UIViewController?) -> UIViewController? {
        if let nav = vc as? UINavigationController {
            return findTopViewController(for: nav.visibleViewController)
        }
        if let tab = vc as? UITabBarController {
            if let selected = tab.selectedViewController {
                return findTopViewController(for: selected)
            }
        }
        if let presented = vc?.presentedViewController {
            return findTopViewController(for: presented)
        }
        return vc
    }

}
