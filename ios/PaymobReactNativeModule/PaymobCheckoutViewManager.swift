import Foundation
import React
import PaymobSDK

@objc(PaymobCheckoutViewManager)
class PaymobCheckoutViewManager: RCTViewManager {
  
  private var wrapperReferences: NSMapTable<NSNumber, PaymobCheckoutViewWrapper> = NSMapTable.strongToWeakObjects()
  
  override func view() -> UIView! {
    let wrapper = PaymobCheckoutViewWrapper()
    wrapper.viewManager = self
    return wrapper
  }
  
  override func shadowView() -> RCTShadowView! {
    return PaymobCheckoutShadowView()
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return true
  }
  
  @objc func configure(_ node: NSNumber, config: NSDictionary) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard let wrapper = self.bridge.uiManager.view(forReactTag: node) as? PaymobCheckoutViewWrapper else {
        return
      }
      
      self.wrapperReferences.setObject(wrapper, forKey: node)
      wrapper.configure(config)
    }
  }
  
  @objc func setPaymentKeys(_ node: NSNumber, keys: NSDictionary) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      guard let wrapper = self.bridge.uiManager.view(forReactTag: node) as? PaymobCheckoutViewWrapper else {
        return
      }
      wrapper.setPaymentKeys(keys)
    }
  }
  
  func updateHeight(_ height: CGFloat, forTag reactTag: NSNumber) {
    guard let bridge = self.bridge else { return }

    RCTExecuteOnUIManagerQueue {
      guard let shadowView =
        bridge.uiManager.shadowView(forReactTag: reactTag)
          as? PaymobCheckoutShadowView else { return }

      shadowView.cachedHeight = max(height, 1)

      let nextVersion = (shadowView.layoutVersion?.intValue ?? 0) + 1
      shadowView.layoutVersion = NSNumber(value: nextVersion)

      bridge.uiManager.setNeedsLayout()
    }
  }
}
