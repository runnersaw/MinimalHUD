#import <Preferences/Preferences.h>

@interface MinimalHUDListController: PSListController
@end

@implementation MinimalHUDListController

- (id)specifiers {
	if(_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray alloc] init];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain]];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"color_mode" target:self] retain]];

		_specifiers = specs;
	}

	return _specifiers;
}

@end

