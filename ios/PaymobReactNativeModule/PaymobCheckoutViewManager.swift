import Foundation
import React
import PaymobSDK // Assuming the framework is named PaymobSDK

@objc(PaymobCheckoutViewManager)
class PaymobCheckoutViewManager: RCTViewManager {

  override func view() -> UIView! {
    return PaymobCheckoutViewWrapper()
  }

  override static func requiresMainQueueSetup() -> Bool {
    return true
  }

  @objc func configure(_ node: NSNumber, config: NSDictionary) {
    DispatchQueue.main.async {
      guard let wrapper = self.bridge.uiManager.view(forReactTag: node) as? PaymobCheckoutViewWrapper else { return }
      wrapper.configure(config)
    }
  }

  @objc func setPaymentKeys(_ node: NSNumber, keys: NSDictionary) {
    DispatchQueue.main.async {
      guard let wrapper = self.bridge.uiManager.view(forReactTag: node) as? PaymobCheckoutViewWrapper else { return }
      wrapper.setPaymentKeys(keys)
    }
  }
}
