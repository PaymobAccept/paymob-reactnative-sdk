#import <React/RCTShadowView.h>
#import <yoga/Yoga.h>

@interface PaymobCheckoutShadowView : RCTShadowView

@property (atomic, assign) CGFloat cachedHeight;

- (void)invalidateLayout;
@property (nonatomic, strong) NSNumber *layoutVersion;


@end
