#import <Preferences/Preferences.h>

@interface MinimalHUDListController: PSListController {
}
@end

@implementation MinimalHUDListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
