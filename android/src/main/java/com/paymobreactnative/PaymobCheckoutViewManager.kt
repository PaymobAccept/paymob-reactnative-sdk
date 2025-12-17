package com.paymobreactnative

import android.content.Context
import androidx.activity.ComponentActivity
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.common.MapBuilder
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.events.RCTEventEmitter
import com.paymob.paymob_sdk.ui.PaymobSdkListener
import com.paymob.paymob_sdk.ui.embedded.PaymobCheckoutView
import java.util.HashMap

class PaymobCheckoutViewManager : SimpleViewManager<PaymobCheckoutView>() {

    override fun getName(): String {
        return "PaymobCheckoutView"
    }

    override fun createViewInstance(reactContext: ThemedReactContext): PaymobCheckoutView {
        return PaymobCheckoutView(reactContext)
    }

    override fun getExportedCustomDirectEventTypeConstants(): Map<String, Any>? {
        return MapBuilder.builder<String, Any>()
            .put("onSuccess", MapBuilder.of("registrationName", "onSuccess"))
            .put("onFailure", MapBuilder.of("registrationName", "onFailure"))
            .put("onPending", MapBuilder.of("registrationName", "onPending"))
            .build()
    }

    override fun receiveCommand(root: PaymobCheckoutView, commandId: String, args: ReadableArray?) {
        super.receiveCommand(root, commandId, args)
        if (commandId == "configure" && args != null) {
            val configMap = args.getMap(0) ?: return
            
            // Extract Configuration
            val publicKey = if (configMap.hasKey("publicKey")) configMap.getString("publicKey") else ""
            val clientSecret = if (configMap.hasKey("clientSecret")) configMap.getString("clientSecret") else ""
            val uiCustomization = if (configMap.hasKey("uiCustomization")) configMap.getString("uiCustomization") else null
            
            val showAddNewCard = if (configMap.hasKey("showAddNewCard")) configMap.getBoolean("showAddNewCard") else true
            val showSaveCard = if (configMap.hasKey("showSaveCard")) configMap.getBoolean("showSaveCard") else true // Assuming true as default fallback
            val saveCardByDefault = if (configMap.hasKey("saveCardByDefault")) configMap.getBoolean("saveCardByDefault") else true 
            val payFromOutside = if (configMap.hasKey("payFromOutside")) configMap.getBoolean("payFromOutside") else false

            // Get Activity
            val context = root.context as? ReactContext
            val activity = context?.currentActivity as? ComponentActivity

            if (activity != null && publicKey != null && clientSecret != null) {
                
                // Configure View
                root.configure(
                    activity = activity,
                    uiCustomization = uiCustomization,
                    showAddNewCard = showAddNewCard,
                    showSaveCard = showSaveCard,
                    saveCardByDefault = saveCardByDefault,
                    payFromOutside = payFromOutside,
                    paymobSdkListener = object : PaymobSdkListener {
                        override fun onSuccess(payResponse: HashMap<String, String?>) {
                            val eventArgs = Arguments.createMap()
                            for ((key, value) in payResponse) {
                                eventArgs.putString(key, value)
                            }
                            context.getJSModule(RCTEventEmitter::class.java)
                                .receiveEvent(root.id, "onSuccess", eventArgs)
                        }

                        override fun onFailure(msg: String?) {
                            val eventArgs = Arguments.createMap()
                            eventArgs.putString("error", msg)
                            context.getJSModule(RCTEventEmitter::class.java)
                                .receiveEvent(root.id, "onFailure", eventArgs)
                        }

                        override fun onPending() {
                            context.getJSModule(RCTEventEmitter::class.java)
                                .receiveEvent(root.id, "onPending", Arguments.createMap())
                        }
                    }
                )

                // Set Payment Keys - REMOVED from configure
                // root.setPaymentKeys(publicKey, clientSecret)
            }
        } else if (commandId == "setPaymentKeys" && args != null) {
             val configMap = args.getMap(0) ?: return
             val publicKey = if (configMap.hasKey("publicKey")) configMap.getString("publicKey") else ""
             val clientSecret = if (configMap.hasKey("clientSecret")) configMap.getString("clientSecret") else ""
             
             if (publicKey != null && clientSecret != null) {
                 root.setPaymentKeys(publicKey, clientSecret)
             }
        }
    }
}
