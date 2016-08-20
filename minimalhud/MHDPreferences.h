#import <Foundation/Foundation.h>

#import "../include.h"

@interface MHDPreferences : NSObject

@property (nonatomic, readonly) BOOL enabled;
@property (nonatomic, readonly) MHDColorMode colorMode;
@property (nonatomic, readonly) MHDColorTheme colorTheme;
@property (nonatomic, readonly) UIColor *startingColor;
@property (nonatomic, readonly) UIColor *endingColor;
@property (nonatomic, readonly) UIColor *backgroundColor;
@property (nonatomic, readonly) MHDLocationMode locationMode;
@property (nonatomic, readonly) MHDLocationPreset locationPreset;
@property (nonatomic, readonly) BOOL locationOrientationVertical;
@property (nonatomic, readonly) CGFloat locationX;
@property (nonatomic, readonly) CGFloat locationY;

- (instancetype)initWithSettings:(NSDictionary *)settings;

@end