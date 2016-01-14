#import <CoreGraphics/CoreGraphics.h>

@interface VolumeControl : NSObject

+ (id)sharedVolumeControl;
- (float)getMediaVolume;
- (float)volume;

@end

@interface SBHUDView : UIView

@property(retain, nonatomic) NSString *title;
- (id)_blockColorForValue:(float)arg1;
- (void)_updateBlockView:(UIView *)arg1 value:(float)arg2 blockSize:(struct CGSize)arg3 point:(struct CGPoint)arg4;
@end

@interface SBHUDController : NSObject

@property(retain, nonatomic) UIView *hudContentView;
@property(retain, nonatomic) SBHUDView *hudView;

- (SBHUDView *)createView:(SBHUDView *)view;

- (void)_createUI;

- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2;
- (void)presentHUDView:(id)arg1;

- (void)reorientHUDIfNeeded:(_Bool)arg1;
- (void)_recenterHUDView;

- (void)placeHUDView:(SBHUDView *)view atPoint:(CGPoint *)point andVertical:(_Bool)vertical;

@end

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static _Bool enabled = YES;
static NSString *theme = @"warm";
static NSString *location = @"right";

%hook SBHUDController

%new
- (SBHUDView *)createView:(SBHUDView *)view {

if ([location isEqualToString:@"right"] || [location isEqualToString:@"left"] || [location isEqualToString:@"volume"]) {
	double rads = 3 * M_PI / 2;
	view.transform = CGAffineTransformMakeRotation(rads);
}

UIView *backdropView = MSHookIvar<UIView *>(view, "_backdropView");
[backdropView setHidden:YES];

return view;

}

- (void)presentHUDView:(id)arg1 autoDismissWithDelay:(double)arg2 {

if (enabled) {
	SBHUDView *v = [self createView:arg1];
    %orig(v, arg2);
} else {
	%orig;
}

}

- (void)presentHUDView:(id)arg1 {

if (enabled) {
	SBHUDView *v = [self createView:arg1];
    %orig(v);
} else {
	%orig;
}

}

- (void)reorientHUDIfNeeded:(_Bool)arg1 {

if (!enabled) {
	%orig;
}

}

- (void)_recenterHUDView {
%orig;

if (enabled) {
	SBHUDView *view = MSHookIvar<SBHUDView *>(self, "_hudView");
	CGFloat w = [UIScreen mainScreen].bounds.size.width;
	CGFloat h = [UIScreen mainScreen].bounds.size.height;

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
}

}

- (void)placeHUDView:(SBHUDView *)view atPoint:(CGPoint *)point andVertical:(_Bool)vertical {
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

if (enabled) {
	VolumeControl *vc = [%c(VolumeControl) sharedVolumeControl];
	float v = [vc volume];

	if ([theme isEqualToString:@"stock"]) {
		return %orig;
	} else if ([theme isEqualToString:@"rainbow"]) {
		if (arg1 > v) {
			return [UIColor blackColor];
		}

		CGFloat red = (CGFloat)sinf(arg1*M_PI - M_PI/6); 
		CGFloat green = (CGFloat)sinf(arg1*M_PI + M_PI/6);
		CGFloat blue = (CGFloat)sinf(arg1*M_PI + M_PI/2);

		return [%c(UIColor) colorWithRed:red green:green blue:blue alpha:1.0];
	} else if ([theme isEqualToString:@"warm"]) {
		if (arg1 > v) {
			return [UIColor blackColor];
		}

		CGFloat red = (CGFloat)sinf(arg1*M_PI/2 + M_PI/6); // pi/6 to pi/2
		CGFloat green = (CGFloat)sinf(arg1*M_PI/2 + M_PI/2); // pi/2 to 5pi/6
		CGFloat blue = (CGFloat)sinf(arg1*M_PI/2 + 5*M_PI/6); // 5pi/6 to pi/6

		return [%c(UIColor) colorWithRed:red green:green blue:blue alpha:1.0];
	} else if ([theme isEqualToString:@"translucent"]) {
		if (arg1 > v) {
			return [%c(UIColor) colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
		}

		return [%c(UIColor) colorWithRed:0.75 green:0.75 blue:0.75 alpha:0.5];
	} else {
		return %orig;
	}
} else {
	return %orig;
}

}

%end

static NSString *bundleId = @"com.runnersaw.hud";
static NSString *notificationString = @"com.runnersaw.hud-preferencesChanged";

static void loadPrefs() {
	NSNumber *e = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:bundleId];
	enabled = (e)? [e boolValue]:YES;

	NSString *t = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"theme" inDomain:bundleId];
	theme = (t)? t:@"stock";

	NSString *l = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"location" inDomain:bundleId];
	location = (l)? l:@"right";
	
}
 
%ctor {
    loadPrefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, (CFStringRef)notificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
 
}