import Foundation
import UIKit
import React
import PaymobSDK

@objc(PaymobCheckoutViewWrapper)
public class PaymobCheckoutViewWrapper: UIView, PaymobSDKDelegate {

  @objc var onSuccess: RCTDirectEventBlock?
  @objc var onFailure: RCTDirectEventBlock?
  @objc var onPending: RCTDirectEventBlock?

  private var checkoutView: PaymobCheckoutView?

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupCheckoutView()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupCheckoutView()
  }

  private func setupCheckoutView() {
    // Initialize PaymobCheckoutView
    // Note: The provided source code suggests it loads from Nib in commonInit.
    // We initiate it here. Frame will be updated by layoutSubviews.
    let view = PaymobCheckoutView()
    view.frame = self.bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.delegate = self
    self.addSubview(view)
    self.checkoutView = view
  }

  func configure(_ config: NSDictionary) {
    guard let checkoutView = checkoutView else { return }

    let uiCustomization = config["uiCustomization"] as? String
    let showAddNewCard = config["showAddNewCard"] as? Bool ?? true
    let showSaveCard = config["showSaveCard"] as? Bool ?? true
    let saveCardByDefault = config["saveCardByDefault"] as? Bool ?? false // Default false per code provided
    let payFromOutside = config["payFromOutside"] as? Bool ?? false

    // 1. Configure UI & Settings
    // Note: 'activity' param in Android is replaced by context/view hierarchy in iOS usually.
    // The iOS 'configure' method signature:
    // configure(uiCustomization: String?, showAddNewCard: Bool, payFromOutside: Bool, showSaveCard: Bool, saveCardDefault: Bool)
    
    checkoutView.configure(
      uiCustomization: uiCustomization,
      showAddNewCard: showAddNewCard,
      payFromOutside: payFromOutside,
      showSaveCard: showSaveCard,
      saveCardDefault: saveCardByDefault
    )

    // 2. Set Payment Keys - REMOVED from configure
    // checkoutView.setPaymentKeys(publicKey: publicKey, clientSecret: clientSecret)
  }

  func setPaymentKeys(_ keys: NSDictionary) {
      guard let checkoutView = checkoutView else { return }
      let publicKey = keys["publicKey"] as? String ?? ""
      let clientSecret = keys["clientSecret"] as? String ?? ""
      checkoutView.setPaymentKeys(publicKey: publicKey, clientSecret: clientSecret)
  }
  
  // MARK: - PaymobSDKDelegate

public func transactionAccepted(transactionDetails: [String : Any]) {
      onSuccess?(transactionDetails)
  }
 
  public func transactionRejected(message: String) {
      onFailure?(["error": message])
  }
 
  public func transactionPending() {
      onPending?([:])
  }
 
}
