#import "PaymobCheckoutShadowView.h"
#import <UIKit/UIKit.h>

static YGSize RCTMeasurePaymobCheckoutView(YGNodeConstRef node,
                                           float width,
                                           YGMeasureMode widthMode,
                                           float height,
                                           YGMeasureMode heightMode) {
  PaymobCheckoutShadowView *shadowView =
      (__bridge PaymobCheckoutShadowView *)YGNodeGetContext(node);
  
  if (!shadowView) {
    return (YGSize){.width = 0, .height = 0};
  }

  CGFloat targetWidth = 0;
  if (widthMode == YGMeasureModeUndefined || width <= 0) {
    targetWidth = UIScreen.mainScreen.bounds.size.width;
  } else {
    targetWidth = (CGFloat)width;
  }

  CGFloat measuredHeight = shadowView.cachedHeight;
  if (measuredHeight <= 0) {
    measuredHeight = 1;
  }

  return (YGSize){
    .width = (float)targetWidth,
    .height = (float)measuredHeight
  };
}

@implementation PaymobCheckoutShadowView

- (instancetype)init {
  if (self = [super init]) {
    _cachedHeight = 1;
    YGNodeSetContext(self.yogaNode, (__bridge void *)self);
    YGNodeSetMeasureFunc(self.yogaNode, RCTMeasurePaymobCheckoutView);
  }
  return self;
}


#pragma mark - Props

- (void)setLayoutVersion:(NSNumber *)layoutVersion {
  if ([_layoutVersion isEqualToNumber:layoutVersion]) {
    return;
  }
  
  _layoutVersion = layoutVersion;
}

- (void)setCachedHeight:(CGFloat)cachedHeight {
  CGFloat h = cachedHeight > 0 ? cachedHeight : 1;
  if (fabs(_cachedHeight - h) < 1) return;

  _cachedHeight = h;
  YGNodeMarkDirty(self.yogaNode);
}

#pragma mark - Layout Override (CRITICAL FIX)


- (void)dealloc {
  if (self.yogaNode) {
    YGNodeSetContext(self.yogaNode, NULL);
    YGNodeSetMeasureFunc(self.yogaNode, NULL);
  }
}

@end
