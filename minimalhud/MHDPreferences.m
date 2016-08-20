#import "MHDPreferences.h"

@interface MHDPreferences ()

@property (nonatomic, readwrite) BOOL enabled;
@property (nonatomic, readwrite) MHDColorMode colorMode;
@property (nonatomic, readwrite) MHDColorTheme colorTheme;
@property (nonatomic, strong) UIColor *startingColor;
@property (nonatomic, strong) UIColor *endingColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, readwrite) MHDLocationMode locationMode;
@property (nonatomic, readwrite) MHDLocationPreset locationPreset;
@property (nonatomic, readwrite) MHDLocationOrientation locationOrientation;
@property (nonatomic, readwrite) CGFloat locationX;
@property (nonatomic, readwrite) CGFloat locationY;

@end

@implementation MHDPreferences

- (instancetype)initWithSettings:(NSDictionary *)settings
{
	self = [super init];
	if (self)
	{
		NSNumber *e = settings[@"enabled"];
		self.enabled = e ? e.boolValue : NO;

		NSNumber *cM = settings[@"colorMode"];
		self.colorMode = cM ? cM.unsignedIntegerValue : MHDColorModeTheme;

		if (self.colorMode == MHDColorModeTheme)
		{
			NSNumber *cT = settings[@"colorTheme"];
			self.colorTheme = cT ? cT.unsignedIntegerValue : MHDColorThemeWarm;
		}
		else if (self.colorMode == MHDColorModeCustom)
		{
			NSString *sC = settings[@"startingColor"];
			self.startingColor = sC ? [self.class colorFromString:sC] : [UIColor whiteColor];

			NSString *eC = settings[@"endingColor"];
			self.endingColor = eC ? [self.class colorFromString:eC] : [UIColor whiteColor];

			NSString *bC = settings[@"backgroundColor"];
			self.backgroundColor = bC ? [self.class colorFromString:bC] : [UIColor blackColor];
		}

		NSNumber *lM = settings[@"locationMode"];
		self.locationMode = lM.unsignedIntegerValue;

		if (self.locationMode == MHDLocationModePreset)
		{
			NSNumber *lP = settings[@"locationPreset"];
			self.locationPreset = lP ? lP.unsignedIntegerValue : MHDLocationPresetTop;
		}
		else if (self.locationMode == MHDLocationModeCustom)
		{
			NSNumber *lO = settings[@"locationOrientation"];
			self.locationOrientation = lO ? lO.unsignedIntegerValue : MHDLocationOrientationHorizontal;

			NSString *lX = settings[@"locationX"];
			self.locationX = lX ? [self.class cgFloatFromString:lX] : 0.0;

			NSString *lY = settings[@"locationY"];
			self.locationY = lY ? [self.class cgFloatFromString:lY] : 0.0;
		}
	}
	return self;
}

+ (UIColor *)colorFromString:(NSString *)string
{
	return [UIColor redColor];
}

+ (CGFloat)cgFloatFromString:(NSString *)string
{
	return 0;
}

@end