#import <React/RCTViewManager.h>

@interface RCT_EXTERN_MODULE(PaymobCheckoutViewManager, RCTViewManager)

RCT_EXPORT_VIEW_PROPERTY(onSuccess, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onFailure, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPending, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(layoutVersion, NSNumber)

RCT_EXTERN_METHOD(configure:(nonnull NSNumber *)node
                  config:(NSDictionary *)config)

RCT_EXTERN_METHOD(setPaymentKeys:(nonnull NSNumber *)node
                  keys:(NSDictionary *)keys)

@end
