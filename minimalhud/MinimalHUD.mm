#import <Preferences/Preferences.h>

@interface MinimalHUDListController: PSListController
@end

@implementation MinimalHUDListController

- (PSSpecifier *)modeSpecifier
{
	PSSpecifier* modeSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Mode"
                                                        target:self
                                                           set:@selector(setMode:forSpecifier:)
                                                           get:@selector(mode)
                                                        detail:NSClassFromString(@"PSListItemsController")
                                                          cell:PSLinkListCell
                                                          edit:Nil];

	[modeSpecifier setProperty:@YES forKey:@"enabled"];
	[modeSpecifier setProperty:@"0" forKey:@"default"];		
	modeSpecifier.values = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
	modeSpecifier.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Title 1",@"Title 2",@"Title 3",nil] forKeys:specifier2.values];
	modeSpecifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"T1",@"T@",@"T3",nil] forKeys:specifier2.values];
	[modeSpecifier setProperty:@"kListValue" forKey:@"key"];

	return modeSpecifier
}	

- (id)specifiers {
	if(_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray alloc] init];
		[specs addObjectsFromArray: [[self loadSpecifiersFromPlistName:@"MinimalHUD" target:self] retain]];
		
		PSSpecifier* specifier1 = [PSSpecifier preferenceSpecifierNamed:@"title1"
	                                                        target:self
	                                                           set:@selector(setTitle1:forSpecifier:)
								   get:@selector(getTitle1)
	                                                        detail:NULL
	                                                          cell:PSLinkListCell
	                                                          edit:NULL];

		[specifier1 setProperty:@[ @"HI", @"Hello" ] forKey:@"validValues"];
		[specifier1 setProperty:@[ @"HI", @"Hello" ] forKey:@"validTitles"];
		[specifier1 setProperty:@[ @"HI", @"Hello" ] forKey:@"shortTitles"];

		PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:@"title"
	                                                        target:self
	                                                           set:@selector(setTitle:forSpecifier:)
								   get:@selector(getTitle)
	                                                        detail:NULL
	                                                          cell:PSSwitchCell
	                                                          edit:NULL];
	 
		[specifier setProperty:@YES forKey:@"enabled"];

		PSSpecifier* specifier2 = [PSSpecifier preferenceSpecifierNamed:@"Mode"
                                                        target:self
                                                           set:@selector(setMode:forSpecifier:)
                                                           get:@selector(mode)
                                                        detail:NSClassFromString(@"PSListItemsController")
                                                          cell:PSLinkListCell
                                                          edit:Nil];

		[specifier2 setProperty:@YES forKey:@"enabled"];
		[specifier2 setProperty:@"0" forKey:@"default"];		
		specifier2.values = [NSArray arrayWithObjects:@"0",@"1",@"2",nil];
		specifier2.titleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Title 1",@"Title 2",@"Title 3",nil] forKeys:specifier2.values];
		specifier2.shortTitleDictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"T1",@"T@",@"T3",nil] forKeys:specifier2.values];
		[specifier2 setProperty:@"kListValue" forKey:@"key"];

		// Now add the specifier to your controller.
		[specs addObject: specifier];
		[specs addObject: specifier1];
		[specs addObject: specifier2];

		_specifiers = specs;
	}

	return _specifiers;
}
- (void)setTitle1:(id)title forSpecifier:(id)specifier
{
	NSLog(@"title 1 %@", title);
}

- (id)getTitle1
{
	return @"";
}

- (void)setTitle:(id)title forSpecifier:(id)specifier
{
	NSLog(@"title %@", title);
}

- (id)getTitle
{
	return @"";
}
@end

