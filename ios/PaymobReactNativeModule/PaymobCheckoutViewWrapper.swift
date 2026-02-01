import Foundation
import UIKit
import React
import PaymobSDK

@objc(PaymobCheckoutViewWrapper)
@objcMembers
public class PaymobCheckoutViewWrapper: UIView, PaymobSDKDelegate {

  // MARK: - React Native Props
  @objc var onSuccess: RCTDirectEventBlock?
  @objc var onFailure: RCTDirectEventBlock?
  @objc var onPending: RCTDirectEventBlock?
  // MARK: - Manager Reference
  weak var viewManager: PaymobCheckoutViewManager?
  // MARK: - UI Components
  private let checkoutView = PaymobCheckoutView()
  // MARK: - Height Management State
  private var lastSentHeight: CGFloat = 0
  // MARK: - Continuous Height Monitoring
  private var lastReportedBoundsHeight: CGFloat = 0
  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    setupCheckoutView()
    setupDelegate()
    bindHeightChanges()
  }

  // MARK: - Setup Methods
  private func setupDelegate() {
    checkoutView.delegate = self
  }

  private func setupCheckoutView() {
    checkoutView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(checkoutView)

    NSLayoutConstraint.activate([
      checkoutView.topAnchor.constraint(equalTo: topAnchor),
      checkoutView.leadingAnchor.constraint(equalTo: leadingAnchor),
      checkoutView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    
    layer.shouldRasterize = false
    checkoutView.layer.shouldRasterize = false
  }
  
  private func bindHeightChanges() {
    checkoutView.onHeightChanged = { [weak self] height in
      guard let self,
            height > 0,
            abs(height - self.lastSentHeight) >= 1 else { return }

      self.lastSentHeight = height

      DispatchQueue.main.async {
        self.viewManager?.updateHeight(
          height,
          forTag: self.reactTag!
        )
      }
    }
  }

  // MARK: - UIView Overrides
  public override func layoutSubviews() {
    super.layoutSubviews()

    let h = checkoutView.bounds.height
    guard h > 0 else { return }

    if abs(h - lastReportedBoundsHeight) >= 2,
       abs(h - lastSentHeight) >= 2 {

      lastReportedBoundsHeight = h
      lastSentHeight = h

      DispatchQueue.main.async {
        self.viewManager?.updateHeight(
          h,
          forTag: self.reactTag!
        )
      }
    }
  }


  // MARK: - Configuration Methods
  
  func configure(_ config: NSDictionary) {
    let uiCustomization = config["uiCustomization"] as? String
    let showAddNewCard = config["showAddNewCard"] as? Bool ?? true
    let showSaveCard = config["showSaveCard"] as? Bool ?? true
    let saveCardByDefault = config["saveCardByDefault"] as? Bool ?? false
    let payFromOutside = config["payFromOutside"] as? Bool ?? false

    checkoutView.configure(
      uiCustomization: uiCustomization,
      showAddNewCard: showAddNewCard,
      payFromOutside: payFromOutside,
      showSaveCard: showSaveCard,
      saveCardDefault: saveCardByDefault
    )
  }

  func setPaymentKeys(_ keys: NSDictionary) {
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
  
  // MARK: - Cleanup
  deinit {
    checkoutView.delegate = nil
  }
}
