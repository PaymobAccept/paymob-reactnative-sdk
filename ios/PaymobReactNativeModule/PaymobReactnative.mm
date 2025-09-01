#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(PaymobReactnative, RCTEventEmitter)

// Expose your methods here
RCT_EXTERN_METHOD(setAppIcon:(NSString *)base64Image)
RCT_EXTERN_METHOD(setAppName:(NSString *)name)
RCT_EXTERN_METHOD(setButtonBackgroundColor:(UIColor *)color)
RCT_EXTERN_METHOD(setButtonTextColor:(UIColor *)color)
RCT_EXTERN_METHOD(setSaveCardDefault:(BOOL)isChecked)
RCT_EXTERN_METHOD(setShowSaveCard:(BOOL)isVisible)
RCT_EXTERN_METHOD(setShowConfirmationPage:(BOOL)isVisible)
RCT_EXTERN_METHOD(setShowTransactionResult:(BOOL)isVisible)
RCT_EXTERN_METHOD(setKeyboardHandlingEnabled:(BOOL)isEnabled)
RCT_EXTERN_METHOD(presentPayVC:(NSString *)clientSecret
                  publicKey:(NSString *)publicKey)

+ (BOOL)requiresMainQueueSetup
{
  return NO;
}

@end
