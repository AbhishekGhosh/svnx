//
//  NSString+MyAdditions.m
//  svnX
//
//  Created by Dominique PERETTI on Sun Jul 18 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "NSString+MyAdditions.h"


//----------------------------------------------------------------------------------------

NSString*
UTF8 (const char* aUTF8String)
{
	return aUTF8String ? [NSString stringWithUTF8String: aUTF8String] : @"";
}


//----------------------------------------------------------------------------------------

BOOL
ToUTF8 (NSString* string, char* buf, unsigned int bufSize)
{
	return string &&
		   [string getCString: buf maxLength: bufSize encoding: NSUTF8StringEncoding];
}


//----------------------------------------------------------------------------------------

@implementation NSString (MyAdditions)

+ (NSString *)stringByAddingPercentEscape:(NSString *)url
{
	return [(id) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) url, NULL, NULL,
														 kCFStringEncodingUTF8) autorelease];
}


//----------------------------------------------------------------------------------------
// used in MyRepository.m as a workaround to a problem in standard
// [NSString stringByDeletingLastPathComponent] which turns "svn://blah" to "svn:/blah"

- (NSString*) stringByDeletingLastComponent
{
	NSRange r = [[self trimSlashes] rangeOfString: @"/" options: NSBackwardsSearch];

	if ( r.length > 0 )
		return [self substringToIndex: r.location];

	return self;
}


//----------------------------------------------------------------------------------------

- (NSString*) escapeURL
{
	return [(id) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) self, NULL, NULL,
														 kCFStringEncodingUTF8) autorelease];
}


//----------------------------------------------------------------------------------------

- (NSString*) trimSlashes
{
	static NSCharacterSet* chSet = nil;
	if (chSet == nil)
		[chSet = [NSCharacterSet characterSetWithCharactersInString: @"/"] retain];

	return [self stringByTrimmingCharactersInSet: chSet];
}


//----------------------------------------------------------------------------------------
// Normalize end-of-line characters

- (NSString*) normalizeEOLs
{
	NSMutableString* str = [NSMutableString stringWithCapacity: 0];
	[str setString: self];
	[str replaceOccurrencesOfString: @"\r\n" withString: @"\n"
		 options: NSLiteralSearch range: NSMakeRange(0, [str length])];
	[str replaceOccurrencesOfString: @"\r" withString: @"\n"
		 options: NSLiteralSearch range: NSMakeRange(0, [str length])];

	return str;
}


@end

