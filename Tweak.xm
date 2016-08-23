#import <CoreGraphics/CoreGraphics.h>

#import "include.h"
#import "minimalhud/MHDPreferences.h"

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (float)volume;
@end

@interface SBHUDView : UIView
- (id)_blockColorForValue:(float)arg1;
@end

@interface SBHUDController : NSObject

@property(retain, nonatomic) UIView *hudContentView;
@property(retain, nonatomic) SBHUDView *hudView;
- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2;
- (void)presentHUDView:(id)arg1;
- (void)reorientHUDIfNeeded:(BOOL)arg1;
- (void)_recenterHUDView;
- (void)placeHUDView:(SBHUDView *)view atPoint:(CGPoint *)point andVertical:(BOOL)vertical;

// New methods
- (BOOL)isVertical;
- (BOOL)isVerticalForCurrentOrientation;
- (NSArray *)locationConversionArray;
- (void)configureView:(SBHUDView *)view;
- (void)placeHUDViewAtXPercent:(CGFloat)xPercent yPercent:(CGFloat)yPercent;
- (void)placeHUDViewAtPoint:(CGPoint)point;

@end

@interface NSUserDefaults (MinimalHUD)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

#define PADDING -2.

static NSString *notificationString = @"com.runnersaw.hud-preferencesChanged";
static MHDPreferences *preferences = nil;

%hook SBHUDController

%new
- (BOOL)isVertical
{
	BOOL isCustomVertical = (preferences.locationMode == MHDLocationModeCustom && preferences.locationOrientationVertical);
	BOOL isPresetVertical = (preferences.locationMode == MHDLocationModePreset && 
		(preferences.locationPreset == MHDLocationPresetRight || preferences.locationPreset == MHDLocationPresetLeft));
	return (isCustomVertical || isPresetVertical);
}

%new
- (BOOL)isVerticalForCurrentOrientation
{
	if (preferences.locationIgnoresRotation)
	{
		return [self isVertical];
	}

	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	switch (orientation)
	{
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown: 
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
			return [self isVertical];
		case UIDeviceOrientationLandscapeLeft:
		case UIDeviceOrientationLandscapeRight:
			return ![self isVertical];
	}

	// Shut up, compiler
	return [self isVertical];
}

/// Returns an array of 4 NSNumber *cgFloats where finalX = arr[0]*x0 + arr[1]*y0, finalY = arr[2]*x0 + arr[3]*y0
%new
- (NSArray *)locationConversionArray
{
	if (preferences.locationIgnoresRotation)
	{
		NSLog(@"ignores rotation");
		return @[ @1, @0, @0, @1 ];
	}

	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	switch (orientation)
	{
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown: 
		case UIDeviceOrientationPortrait:
		NSLog(@"portrait");
			return @[ @1, @0, @0, @1 ];
		case UIDeviceOrientationPortraitUpsideDown:
		NSLog(@"upsidedown");
			return @[ @-1, @0, @0, @-1 ];
		case UIDeviceOrientationLandscapeLeft:
		NSLog(@"left");
			return @[ @0, @-1, @1, @0 ];
		case UIDeviceOrientationLandscapeRight:
		NSLog(@"right");
			return @[ @0, @1, @-1, @0 ];
	}

	// Shut up, compiler
	return @[ @1, @0, @0, @1 ];
}

%new
- (void)configureView:(SBHUDView *)view
{
	UIView *backdropView = MSHookIvar<UIView *>(view, "_backdropView");
	backdropView.hidden = YES;

	if (preferences.locationIgnoresRotation)
	{
		if ([self isVertical])
		{
			double rads = 3 * M_PI / 2;
			view.transform = CGAffineTransformMakeRotation(rads);
		}
		return;
	}
	
	UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
	switch (orientation)
	{
		case UIDeviceOrientationUnknown:
		case UIDeviceOrientationFaceUp:
		case UIDeviceOrientationFaceDown: 
		case UIDeviceOrientationPortrait:
		case UIDeviceOrientationPortraitUpsideDown:
			if ([self isVertical])
			{
				double rads = 3 * M_PI / 2;
				view.transform = CGAffineTransformMakeRotation(rads);
			}
			return;
		case UIDeviceOrientationLandscapeLeft:
			if (![self isVertical])
			{
				double rads = M_PI / 2;
				view.transform = CGAffineTransformMakeRotation(rads);
			}
			return;
		case UIDeviceOrientationLandscapeRight:
			if ([self isVertical])
			{
				double rads = M_PI;
				view.transform = CGAffineTransformMakeRotation(rads);
			}
			else
			{
				double rads = 3 * M_PI / 2;
				view.transform = CGAffineTransformMakeRotation(rads);
			}
			return;
	}
}

- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2
{
	if (preferences.enabled)
	{
		[self configureView:arg1];
	}
	%orig;
}

- (void)presentHUDView:(id)arg1 {
	if (preferences.enabled)
	{
		[self configureView:arg1];
	}
	%orig;
}

- (void)reorientHUDIfNeeded:(BOOL)arg1 {
	if (!preferences.enabled)
	{
		%orig;
	}
}

- (void)_recenterHUDView {
	%orig;

	if (!preferences.enabled)
	{
		return;
	}

	if (preferences.locationMode == MHDLocationModePreset)
	{
		switch (preferences.locationPreset)
		{
			case MHDLocationPresetRight:
			{
				[self placeHUDViewAtXPercent:100 yPercent:50];
				break;
			}
			case MHDLocationPresetLeft:
			{
				[self placeHUDViewAtXPercent:0 yPercent:50];
				break;
			}
			case MHDLocationPresetTop:
			{
				[self placeHUDViewAtXPercent:50 yPercent:0];
				break;
			}
			case MHDLocationPresetBottom:
			{
				[self placeHUDViewAtXPercent:50 yPercent:100];
				break;
			}
		}
	}
	else if (preferences.locationMode == MHDLocationModeCustom)
	{
		[self placeHUDViewAtXPercent:preferences.locationX yPercent:preferences.locationY];
	}
}

%new
- (void)placeHUDViewAtXPercent:(CGFloat)xPercent yPercent:(CGFloat)yPercent
{
	SBHUDView *view = MSHookIvar<SBHUDView *>(self, "_hudView");
	UIView *blockView = MSHookIvar<UIView *>(view, "_blockView");

	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
	CGFloat blockWidth = blockView.frame.size.width;
	CGFloat blockHeight = blockView.frame.size.height;

	if ([self isVerticalForCurrentOrientation])
	{
		CGFloat tempWidth = blockHeight;
		blockHeight = blockWidth;
		blockWidth = tempWidth;
	}

	CGFloat initialXPercent = xPercent;
	if (initialXPercent < 0 || initialXPercent > 100)
	{
		initialXPercent = 0;
	}
	CGFloat initialYPercent = yPercent;
	if (initialYPercent < 0 || initialYPercent > 100)
	{
		initialYPercent = 0;
	}

	NSArray *conversionArray = [self locationConversionArray];
	CGFloat finalXPercent = ((NSNumber *)conversionArray[0]).doubleValue * initialXPercent + ((NSNumber *)conversionArray[1]).doubleValue * initialYPercent;
	CGFloat finalYPercent = ((NSNumber *)conversionArray[2]).doubleValue * initialXPercent + ((NSNumber *)conversionArray[3]).doubleValue * initialYPercent;
	finalXPercent = (finalXPercent + 100.) / 2.;
	finalYPercent = (finalYPercent + 100.) / 2.;
	NSLog(@"%@ %@ %@ %@ %@", @(initialXPercent), @(initialYPercent), conversionArray, @(finalXPercent), @(finalYPercent));

	CGFloat availableWidth = screenWidth - blockWidth + 2*PADDING;
	CGFloat originX = finalXPercent * availableWidth / 100. + PADDING;

	CGFloat availableHeight = screenHeight - blockHeight + 2*PADDING;
	CGFloat originY = finalYPercent * availableHeight / 100. + PADDING;

	[self placeHUDViewAtPoint:CGPointMake(originX, originY)];
}

%new
- (void)placeHUDViewAtPoint:(CGPoint)point
{
	SBHUDView *view = MSHookIvar<SBHUDView *>(self, "_hudView");
	UIView *blockView = MSHookIvar<UIView *>(view, "_blockView");

	CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
	CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

	CGFloat blockOffsetX = blockView.frame.origin.x;
	CGFloat blockOffsetY = blockView.frame.origin.y;
	CGFloat blockWidth = blockView.frame.size.width;
	CGFloat blockHeight = blockView.frame.size.height;

	if ([self isVerticalForCurrentOrientation])
	{
		CGFloat tempWidth = blockHeight;
		blockHeight = blockWidth;
		blockWidth = tempWidth;
	}

	CGFloat finalX = point.x - blockOffsetX;
	if (finalX > screenWidth || finalX < 0)
	{
		finalX = 0;
	}

	CGFloat finalY = point.y - blockOffsetY;
	if (finalY > screenHeight || finalY < 0)
	{
		finalY = 0;
	}

	CGRect frame = view.frame;
	frame.origin = CGPointMake(finalX, finalY);
	view.frame = frame;
}

%end

%hook SBHUDView

- (id)_blockColorForValue:(float)arg1
{
	if (!preferences.enabled)
	{
		return %orig;
	}

	VolumeControl *vc = [%c(VolumeControl) sharedVolumeControl];
	float v = [vc volume];

	if (preferences.colorMode == MHDColorModeTheme)
	{
		switch (preferences.colorTheme)
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
	else if (preferences.colorMode == MHDColorModeCustom)
	{
		if (arg1 > v) {
			return preferences.backgroundColor;
		}

		CGFloat startingRed; 
		CGFloat startingGreen;
		CGFloat startingBlue;
		CGFloat startingAlpha;
		BOOL success1 = [preferences.startingColor getRed:&startingRed green:&startingGreen blue:&startingBlue alpha:&startingAlpha];

		CGFloat endingRed; 
		CGFloat endingGreen;
		CGFloat endingBlue;
		CGFloat endingAlpha;
		BOOL success2 = [preferences.endingColor getRed:&endingRed green:&endingGreen blue:&endingBlue alpha:&endingAlpha];

		if (!success1 || !success2)
		{
			return %orig;
		}

		CGFloat red = (endingRed - startingRed) * arg1 + startingRed;
		CGFloat green = (endingGreen - startingGreen) * arg1 + startingGreen;
		CGFloat blue = (endingBlue - startingBlue) * arg1 + startingBlue;
		CGFloat alpha = (endingAlpha - startingAlpha) * arg1 + startingAlpha;

		return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
	}

	return %orig;
}

%end

static void loadPrefs()
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREFERENCES_PATH];
	NSLog(@"initting with settings %@", settings);
	preferences = [[MHDPreferences alloc] initWithSettings:settings];
}
 
%ctor
{
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
}