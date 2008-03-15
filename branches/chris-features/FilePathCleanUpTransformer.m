#import "FilePathCleanUpTransformer.h"


@implementation FilePathCleanUpTransformer


+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)aString
{
	return [aString stringByStandardizingPath];
}

- (id)reverseTransformedValue:(id)aString
{
	return [aString stringByStandardizingPath];
}


@end


//----------------------------------------------------------------------------------------

@implementation FilePathAbbreviatedTransformer


+ (Class) transformedValueClass
{
    return [NSString class];
}

+ (BOOL) allowsReverseTransformation
{
    return NO;
}

- (id) transformedValue: (id) aString
{
	return [aString stringByAbbreviatingWithTildeInPath];
}


@end


//----------------------------------------------------------------------------------------

@implementation FilePathWorkingCopy


- (id) init
{
	self = [super init];
	if (self)
	{
		fTransform = [[[[NSUserDefaultsController sharedUserDefaultsController] values]
								valueForKey: @"abbrevWCFilePaths"] boolValue];
	}

    return self;
}

- (id) transformedValue: (id) aString
{
	return fTransform ? [aString stringByAbbreviatingWithTildeInPath] : aString;
}


@end

