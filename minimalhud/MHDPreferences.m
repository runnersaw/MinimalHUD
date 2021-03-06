#import "MHDPreferences.h"

#define NOT_FOUND -1

@interface MHDPreferences ()

@property (nonatomic, readwrite) BOOL enabled;
@property (nonatomic, readwrite) MHDColorMode colorMode;
@property (nonatomic, readwrite) MHDColorTheme colorTheme;
@property (nonatomic, copy) NSString *startingColorString;
@property (nonatomic, copy) NSString *endingColorString;
@property (nonatomic, copy) NSString *backgroundColorString;
@property (nonatomic, strong) UIColor *startingColor;
@property (nonatomic, strong) UIColor *endingColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, readwrite) MHDLocationMode locationMode;
@property (nonatomic, readwrite) MHDLocationPreset locationPreset;
@property (nonatomic, readwrite) BOOL locationOrientationVertical;
@property (nonatomic, readwrite) CGFloat locationX;
@property (nonatomic, readwrite) CGFloat locationY;
@property (nonatomic, copy) NSString *locationXString;
@property (nonatomic, copy) NSString *locationYString;

@end

@implementation MHDPreferences

+ (UIColor *)colorFromString:(NSString *)string
{
	NSDictionary *colors = @{
		@"red" : [UIColor redColor],
		@"orange" : [UIColor orangeColor],
		@"yellow" : [UIColor yellowColor],
		@"green" : [UIColor greenColor],
		@"blue" : [UIColor blueColor],
		@"purple" : [UIColor purpleColor],
		@"black" : [UIColor blackColor],
		@"white" : [UIColor whiteColor]
	};

	NSString *finalStr = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	UIColor *color = colors[finalStr.lowercaseString];
	if (color)
	{
		return color;
	}

	return [self colorWithHexString:finalStr];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length])
    {
        case 3: // #RGB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:1];
            green = [self colorComponentFrom:colorString start:1 length:1];
            blue = [self colorComponentFrom:colorString start:2 length:1];
            break;
        case 4: // #ARGB
            alpha = [self colorComponentFrom:colorString start:0 length:1];
            red = [self colorComponentFrom:colorString start:1 length:1];
            green = [self colorComponentFrom:colorString start:2 length:1];
            blue = [self colorComponentFrom:colorString start:3 length:1];          
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red = [self colorComponentFrom:colorString start:0 length:2];
            green = [self colorComponentFrom:colorString start:2 length:2];
            blue = [self colorComponentFrom:colorString start:4 length:2];                      
            break;
        case 8: // #AARRGGBB
            alpha = [self colorComponentFrom:colorString start:0 length:2];
            red = [self colorComponentFrom:colorString start:2 length:2];
            green = [self colorComponentFrom:colorString start:4 length:2];
            blue = [self colorComponentFrom:colorString start:6 length:2];                      
            break;
        default:
        	return nil;
    }

    if (red == NOT_FOUND || green == NOT_FOUND || blue == NOT_FOUND || alpha == NOT_FOUND)
    {
    	return nil;
    }

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
    unsigned int hexComponent;
    BOOL success = [[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
    if (!success)
    {
    	return NOT_FOUND;
    }
    return hexComponent / 255.;
}

+ (CGFloat)cgFloatFromString:(NSString *)string
{
    double doubleValue;
    NSString *finalStr = [string stringByReplacingOccurrencesOfString:@"%" withString:@""];
    BOOL success = [[NSScanner scannerWithString:finalStr] scanDouble:&doubleValue];
    if (!success)
    {
    	return 0.;
    }
    return (CGFloat)doubleValue;
}

- (instancetype)initWithSettings:(NSDictionary *)settings
{
	self = [super init];
	if (self)
	{
		NSNumber *e = settings[@"enabled"];
		self.enabled = e ? e.boolValue : YES;

		NSNumber *cM = settings[@"colorMode"];
		self.colorMode = cM ? cM.unsignedIntegerValue : MHDColorModeTheme;

		NSNumber *cT = settings[@"colorTheme"];
		self.colorTheme = cT ? cT.unsignedIntegerValue : MHDColorThemeWarm;

		self.startingColorString = settings[@"startingColorString"] ?: @"";
		UIColor *sColor = [self.class colorFromString:self.startingColorString];
		self.startingColor = sColor ? : [UIColor whiteColor];

		self.endingColorString = settings[@"endingColorString"] ?: @"";
		UIColor *eColor = [self.class colorFromString:self.endingColorString];
		self.endingColor = eColor ? : [UIColor whiteColor];

		self.backgroundColorString = settings[@"backgroundColorString"] ?: @"";
		UIColor *bColor = [self.class colorFromString:self.backgroundColorString];
		self.backgroundColor = bColor ? : [UIColor blackColor];

		NSNumber *lM = settings[@"locationMode"];
		self.locationMode = lM ? lM.unsignedIntegerValue : MHDLocationModePreset;

		NSNumber *lP = settings[@"locationPreset"];
		self.locationPreset = lP ? lP.unsignedIntegerValue : MHDLocationPresetTop;

		NSNumber *lO = settings[@"locationOrientationVertical"];
		self.locationOrientationVertical = lO ? lO.boolValue : NO;

		self.locationXString = settings[@"locationXString"] ? : @"0";
		self.locationX = [self.class cgFloatFromString:self.locationXString];

		self.locationYString = settings[@"locationYString"] ? : @"0";
		self.locationY = [self.class cgFloatFromString:self.locationYString];
	}
	return self;
}

- (void)updateValue:(id)value forKey:(NSString *)key
{
	[self setValue:value forKey:key];
}

- (NSDictionary *)dictionaryRepresentation
{
	return @{
		@"enabled" : @(self.enabled),
		@"colorMode" : @(self.colorMode),
		@"colorTheme" : @(self.colorTheme),
		@"startingColorString" : self.startingColorString ? : @"",
		@"endingColorString" : self.endingColorString ? : @"",
		@"backgroundColorString" : self.backgroundColorString ? : @"",
		@"locationMode" : @(self.locationMode),
		@"locationPreset" : @(self.locationPreset),
		@"locationOrientationVertical" : @(self.locationOrientationVertical),
		@"locationXString" : self.locationXString,
		@"locationYString" : self.locationYString
	};
}

@end