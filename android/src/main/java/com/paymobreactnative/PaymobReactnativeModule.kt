package com.paymobreactnative

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.util.Base64
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.paymob.paymob_sdk.PaymobSdk
import com.paymob.paymob_sdk.domain.model.CreditCard
import com.paymob.paymob_sdk.domain.model.SavedCard
import com.paymob.paymob_sdk.ui.PaymobSdkListener


class PaymobReactnativeModule(reactContext: ReactApplicationContext) :
  EventEmitterModule(reactContext), PaymobSdkListener {

  private var appIcon: Bitmap? = null
  private var appName: String? = null
  private var buttonBackgroundColor: Int? = null
  private var buttonTextColor: Int? = null
  private var saveCardDefault: Boolean? = null
  private var showSaveCard: Boolean? = null
  private var showResultsPage: Boolean? = null
  private var showTransactionResult: Boolean? = null

  override fun getName(): String {
    return "PaymobReactnative"
  }

  /**
   * Sets the logo of the merchant to be displayed in the SDK.
   *
   * @param base64Image Base64 encoded image.
   */
  @ReactMethod
  fun setAppIcon(base64Image: String) {
    try {
      val decodedString: ByteArray = Base64.decode(base64Image, Base64.DEFAULT)
      appIcon = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  /**
   * Sets the name of the merchant to be displayed in the SDK.
   *
   * @param name Display name of the merchant.
   */
  @ReactMethod
  fun setAppName(name: String) {
    appName = name
  }

  /**
   * Sets the background color of SDK buttons.
   *
   * @param color The color represented as an integer.
   */
  @ReactMethod
  fun setButtonBackgroundColor(color: Int) {
    buttonBackgroundColor = color
  }

  /**
   * Sets the text color of SDK buttons.
   *
   * @param color The color represented as an integer.
   */
  @ReactMethod
  fun setButtonTextColor(color: Int) {
    buttonTextColor = color
  }

  /**
   * Sets whether the save card option is checked by default.
   *
   * @param isEnabled Boolean to enable/disable save card by default.
   */
  @ReactMethod
  fun setSaveCardDefault(isEnabled: Boolean) {
    saveCardDefault = isEnabled
  }

  /**
   * Sets whether the save card option is shown in the SDK.
   *
   * @param isVisible Boolean to show/hide the save card option.
   */
  @ReactMethod
  fun setShowSaveCard(isVisible: Boolean) {
    showSaveCard = isVisible
  }

  /**
   * Sets whether the confirmation page is shown in the SDK.
   *
   * @param isVisible Boolean to show/hide the confirmation page.
   */
  @ReactMethod
  fun setShowConfirmationPage(isVisible: Boolean) {
    showResultsPage = isVisible
  }

  /**
   * Sets whether the transaction result page is shown in the SDK.
   *
   * @param isVisible Boolean to show/hide the transaction result page.
   */
  @ReactMethod
  fun setShowTransactionResult(isVisible: Boolean) {
    showTransactionResult = isVisible
  }

  @ReactMethod
  fun setKeyboardHandlingEnabled(isEnabled: Boolean) {
  }

  /**
   * Presents the payment view controller with the specified parameters.
   *
   * @param clientSecret The client secret provided by Paymob.
   * @param publicKey The public key provided by Paymob.
   */
  @ReactMethod
  fun presentPayVC(clientSecret: String, publicKey: String) {
    val context: Context = currentActivity ?: reactApplicationContext

    PaymobSdk.Builder(
      context = context,
      paymobSdkListener = this,
      clientSecret = clientSecret,
      publicKey = publicKey,
    ).apply {
//      appIcon?.let { set(it) }
      appName?.let { setAppName(it) }
      buttonBackgroundColor?.let { setButtonBackgroundColor(it) }
      buttonTextColor?.let { setButtonTextColor(it) }
      saveCardDefault?.let { saveCardByDefault(it) }
      showSaveCard?.let { showSaveCard(it) }
      showResultsPage?.let { showResultPage(it) }
      showTransactionResult?.let { showTransactionResult(it) }
    }.build().start()
  }

  /**
   * Keep: Required for RN built-in Event Emitter Calls.
   */
  @ReactMethod
  override fun addListener(event: String?) {
    super.addListener(event!!)
  }

  /**
   * Keep: Required for RN built-in Event Emitter Calls.
   */
  @ReactMethod
  override fun removeListeners(count: Int?) {
    super.removeListeners(count!!)
  }

  /**
   * Called when the payment process fails.
   */
  override fun onFailure() {
    emitTransactionStatus("Fail")
  }

  /**
   * Called when the payment process is pending.
   */
  override fun onPending() {
    emitTransactionStatus("Pending")
  }

  /**
   * Called when the payment process is successful.
   *
   * @param payResponse A map containing the payment response data.
   */
  override fun onSuccess(payResponse: HashMap<String, String?>) {
    emitTransactionStatus("Success", payResponse)
  }

  /**
   * Emits the transaction status and details (if available) to the JavaScript side.
   *
   * @param status The status of the transaction.
   * @param payResponse A map containing the payment response data (optional).
   */
  private fun emitTransactionStatus(status: String, payResponse: HashMap<String, String?>? = null) {
    // Create a WritableMap to send to React Native
    val statusMap: WritableMap = Arguments.createMap()

    // Add status to the map
    statusMap.putString("status", status)

    // If payResponse is not null, add details
    if (payResponse != null) {
      val detailsMap: WritableMap = Arguments.createMap()
      for ((key, value) in payResponse) {
        detailsMap.putString(key, value)
      }
      statusMap.putMap("details", detailsMap)
    } else {
      // If no payResponse, we can still send a null or empty details map
      statusMap.putMap("details", Arguments.createMap())
    }

    // Send the event with both status and details
    sendEvent("onTransactionStatus", statusMap)
  }
}
