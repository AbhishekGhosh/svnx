//
//  NSString+MyAdditions.h
//  svnX
//
//  Created by Dominique PERETTI on Sun Jul 18 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* UTF8 (const char* aUTF8String);


// NSString Additions
@interface NSString (MyAdditions)

+ (NSString*) stringByAddingPercentEscape: (NSString*) url;

- (NSString*) stringByDeletingLastComponent;
- (NSString*) escapeURL;
- (NSString*) trimSlashes;
- (NSString*) normalizeEOLs;

@end


// NSTextView Additions
@interface  NSTextView (MyAdditions)

- (void) appendString: (NSString*) string
		 isErrorStyle: (BOOL)      isErrorStyle;

@end

