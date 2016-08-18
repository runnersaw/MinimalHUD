#import <CoreGraphics/CoreGraphics.h>

#import "include.h"

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (float)volume;
@end

@interface SBHUDView : UIView
- (id)_blockColorForValue:(float)arg1;
- (void)_updateBlockView:(UIView *)arg1 value:(float)arg2 blockSize:(struct CGSize)arg3 point:(struct CGPoint)arg4;
@end

@interface SBHUDController : NSObject

@property(retain, nonatomic) UIView *hudContentView;
@property(retain, nonatomic) SBHUDView *hudView;

- (void)_createUI;

- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2;
- (void)presentHUDView:(id)arg1;

- (void)reorientHUDIfNeeded:(BOOL)arg1;
- (void)_recenterHUDView;

- (void)placeHUDView:(SBHUDView *)view atPoint:(CGPoint *)point andVertical:(BOOL)vertical;

// New methods
- (BOOL)isVertical;
- (SBHUDView *)createView:(SBHUDView *)view;

@end

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static BOOL enabled = YES;
static NSUInteger colorMode = MHDColorModeTheme;
static NSUInteger colorTheme = MHDColorThemeWarm;
static UIColor *startingColor = nil;
static UIColor *endingColor = nil;
static UIColor *backgroundColor = nil;
static NSUInteger locationMode = MHDLocationModePreset;
static NSUInteger locationPreset = MHDLocationPresetRight;
static NSUInteger locationOrientation = nil;
static CGFloat locationX = 0;
static CGFloat locationY = 0;

%hook SBHUDController

%new
- (BOOL)isVertical
{
	BOOL isCustomVertical = (locationMode == MHDLocationModeCustom && locationOrientation == MHDLocationOrientationVertical);
	BOOL isPresetVertical = (locationMode == MHDLocationModePreset && 
		(locationPreset == MHDLocationPresetRight || locationPreset == MHDLocationPresetLeft || locationPreset == MHDLocationPresetVolume));
	return (isCustomVertical || isPresetVertical);
}

%new
- (SBHUDView *)createView:(SBHUDView *)view
{
	if ([self isVertical])
	{
		double rads = 3 * M_PI / 2;
		view.transform = CGAffineTransformMakeRotation(rads);
	}

	UIView *backdropView = MSHookIvar<UIView *>(view, "_backdropView");
	[backdropView setHidden:YES];

	return view;
}

- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2
{
	if (enabled)
	{
		SBHUDView *v = [self createView:arg1];
	    %orig(v, arg2);
	}
	else
	{
		%orig;
	}
}

- (void)presentHUDView:(id)arg1 {
	if (enabled)
	{
		SBHUDView *v = [self createView:arg1];
	    %orig(v);
	}
	else
	{
		%orig;
	}
}

- (void)reorientHUDIfNeeded:(BOOL)arg1 {
	if (!enabled)
	{
		%orig;
	}
}

- (void)_recenterHUDView {
	%orig;

	if (!enabled)
	{
		return;
	}

	SBHUDView *view = MSHookIvar<SBHUDView *>(self, "_hudView");
	CGFloat w = [UIScreen mainScreen].bounds.size.width;
	CGFloat h = [UIScreen mainScreen].bounds.size.height;
	UIView *blockView = MSHookIvar<UIView *>(view, "_blockView");
	CGFloat blockWidth = blockView.frame.size.width;
	CGFloat blockHeight = blockView.frame.size.height;
	NSLog(@"blockView %@ %@", @(blockWidth), @(blockHeight));
	NSLog(@"blockView frame %@", NSStringFromCGRect(blockView.frame));

	if (locationMode == MHDLocationModePreset)
	{
		switch (locationPreset)
		{
			case MHDLocationPresetRight:
			{
				[view setFrame:CGRectMake(w - view.frame.size.width+16, (h-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height)];
				break;
			}
			case MHDLocationPresetLeft:
			{
				[view setFrame:CGRectMake(22 - view.frame.size.width, (h-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height)];
				break;
			}
			case MHDLocationPresetTop:
			{
				[view setFrame:CGRectMake((w-view.frame.size.width)/2, 22 - view.frame.size.height, view.frame.size.width, view.frame.size.height)];
				break;
			}
			case MHDLocationPresetBottom:
			{
				[view setFrame:CGRectMake((w-view.frame.size.width)/2, h-view.frame.size.height + 16, view.frame.size.width, view.frame.size.height)];
				break;
			}
			case MHDLocationPresetVolume:
			{
				[view setFrame:CGRectMake((w-view.frame.size.width)/2, h-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
				break;
			}
		}
	}
	else if (locationMode == MHDLocationModeCustom)
	{

	}
}

%new
- (void)placeHUDView:(SBHUDView *)view atPoint:(CGPoint *)point vertical:(BOOL)vertical {
	// UIView *blockView = MSHookIvar<UIView *>(view, "_blockView");
	/*CGFloat *volumeWidth = 16.0;
	CGFloat *volumeFromBottom = 22.0;
	CGFloat *volumeFromTop = view.frame.size.height - volumeFromBottom;
	if (vertical) {
		if ([location isEqualToString:@"right"]) {
			[view setFrame:CGRectMake(w - view.frame.size.width+16, (h-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height)];
		}
		if ([location isEqualToString:@"left"]) {
			[view setFrame:CGRectMake(22 - view.frame.size.width, (h-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height)];
		}
		if ([location isEqualToString:@"top"]) {
			[view setFrame:CGRectMake((w-view.frame.size.width)/2, 22 - view.frame.size.height, view.frame.size.width, view.frame.size.height)];
		}
		if ([location isEqualToString:@"bottom"]) {
			[view setFrame:CGRectMake((w-view.frame.size.width)/2, h-view.frame.size.height + 16, view.frame.size.width, view.frame.size.height)];
		}
		if ([location isEqualToString:@"volume"]) {
			[view setFrame:CGRectMake((w-view.frame.size.width)/2, h-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
		}
	}*/
}


%end

%hook SBHUDView

- (id)_blockColorForValue:(float)arg1
{
	if (!enabled)
	{
		return %orig;
	}

	VolumeControl *vc = [%c(VolumeControl) sharedVolumeControl];
	float v = [vc volume];

	if (colorMode == MHDColorModeTheme)
	{
		switch (colorTheme)
		{
			case MHDColorThemeWarm:
			{
				if (arg1 > v) {
					return [UIColor blackColor];
				}

				CGFloat red = (CGFloat)sinf(arg1*M_PI/2 + M_PI/6); // pi/6 to pi/2
				CGFloat green = (CGFloat)sinf(arg1*M_PI/2 + M_PI/2); // pi/2 to 5pi/6
				CGFloat blue = (CGFloat)sinf(arg1*M_PI/2 + 5*M_PI/6); // 5pi/6 to pi/6

				return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
			}
			case MHDColorThemeRainbow:
			{
				if (arg1 > v) {
					return [UIColor blackColor];
				}

				CGFloat red = (CGFloat)sinf(arg1*M_PI - M_PI/6); 
				CGFloat green = (CGFloat)sinf(arg1*M_PI + M_PI/6);
				CGFloat blue = (CGFloat)sinf(arg1*M_PI + M_PI/2);

				return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
			}
			case MHDColorThemeTranslucent:
			{
				if (arg1 > v) {
					return [%c(UIColor) colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
				}

				return [%c(UIColor) colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
			}
			case MHDColorThemeStock:
			{
				return %orig;
			}
		}
	}
	else if (colorMode == MHDColorModeCustom)
	{
		if (arg1 > v) {
			return backgroundColor;
		}

		CGFloat *startingRed = nil; 
		CGFloat *startingGreen = nil;
		CGFloat *startingBlue = nil;
		CGFloat *startingAlpha = nil;
		BOOL success1 = [startingColor getRed:startingRed green:startingGreen blue:startingBlue alpha:startingAlpha];

		CGFloat *endingRed = nil; 
		CGFloat *endingGreen = nil;
		CGFloat *endingBlue = nil;
		CGFloat *endingAlpha = nil;
		BOOL success2 = [endingColor getRed:endingRed green:endingGreen blue:endingBlue alpha:endingAlpha];

		if (!success1 || !success2)
		{
			return %orig;
		}

		CGFloat red = (*endingRed - *startingRed) * arg1 + *startingRed;
		CGFloat green = (*endingGreen - *startingGreen) * arg1 + *startingGreen;
		CGFloat blue = (*endingBlue - *startingBlue) * arg1 + *startingBlue;
		CGFloat alpha = (*endingAlpha - *startingAlpha) * arg1 + *startingAlpha;

		return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	}

	return %orig;
}

- (void)_updateBlockView:(UIView *)arg1 value:(float)arg2 blockSize:(struct CGSize)arg3 point:(struct CGPoint)arg4
{
	%log;
	%orig;
}

%end

static NSString *bundleId = @"com.runnersaw.hud";
static NSString *notificationString = @"com.runnersaw.hud-preferencesChanged";

static UIColor *colorFromString(NSString *string)
{
	return [UIColor redColor];
}

static CGFloat cgFloatFromString(NSString *string)
{
	return 0;
}

static void loadPrefs()
{
	NSString *path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleId];
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
	NSLog(@"loadPrefs %@", settings);

	NSNumber *e = settings[@"enabled"];
	enabled = e ? e.boolValue : NO;

	NSNumber *cM = settings[@"colorMode"];
	colorMode = cM ? cM.unsignedIntegerValue : MHDColorModeTheme;

	if (colorMode == MHDColorModeTheme)
	{
		NSNumber *cT = settings[@"colorTheme"];
		colorTheme = cT ? cT.unsignedIntegerValue : MHDColorThemeWarm;
	}
	else if (colorMode == MHDColorModeCustom)
	{
		NSString *sC = settings[@"startingColor"];
		startingColor = sC ? colorFromString(sC) : [UIColor whiteColor];

		NSString *eC = settings[@"endingColor"];
		endingColor = eC ? colorFromString(eC) : [UIColor whiteColor];

		NSString *bC = settings[@"backgroundColor"];
		backgroundColor = bC ? colorFromString(bC) : [UIColor blackColor];
	}

	NSNumber *lM = settings[@"locationMode"];
	locationMode = lM.unsignedIntegerValue;

	if (locationMode == MHDLocationModePreset)
	{
		NSNumber *lP = settings[@"locationPreset"];
		locationPreset = lP ? lP.unsignedIntegerValue : MHDLocationPresetTop;
	}
	else if (locationMode == MHDLocationModeCustom)
	{
		NSNumber *lO = settings[@"locationOrientation"];
		locationOrientation = lO ? lO.unsignedIntegerValue : MHDLocationOrientationHorizontal;

		NSString *lX = settings[@"locationX"];
		locationX = lX ? cgFloatFromString(lX) : 0.0;

		NSString *lY = settings[@"locationY"];
		locationX = lY ? cgFloatFromString(lY) : 0.0;
	}
}
 
%ctor
{
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
}