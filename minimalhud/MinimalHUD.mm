#import <Preferences/Preferences.h>

@interface MinimalHUDListController: PSListController {
}
@end

@implementation MinimalHUDListController
- (id)specifiers {
	if(_specifiers == nil) {
		NSMutableArray *specs = [NSMutableArray init];
		[specs addObjectsFromArray: [self loadSpecifiersFromPlistName:@"MinimalHUD" target:self]];
	
		PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:@"title"
	                                                        target:self
	                                                           set:NULL
	                                                           get:NULL
	                                                        detail:NSClassFromString(@"PSListItemsController")
	                                                          cell:PSLinkListCell
	                                                          edit:Nil];
	 
		[specifier setProperty:@YES forKey:@"enabled"];
		[specifier setProperty:@"0" forKey:@"default"];		
		specifier.values = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
		specifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Title 1",@"Title 2",@"Title 3",nil] forKeys:specifier.values];
		specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"T1",@"T@",@"T3",nil] forKeys:specifier.values];
		[specifier setProperty:@"kListValue" forKey:@"key"];
		 
		// Now add the specifier to your controller.
		[specs addObject:specifier];

		_specifiers = specs;
	}

	return _specifiers;
}
@end

// vim:ft=objc
