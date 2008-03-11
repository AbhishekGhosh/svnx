//
//  MySvnLogParser.h
//  svnX
//
//  Created by Dominique PERETTI on Mon Jul 12 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MySvnLogParser : NSObject
{
	NSMutableArray *logArray;
	NSMutableDictionary *tmpDict;
	NSMutableDictionary *tmpDict2;
	NSMutableString *tmpString;
	NSMutableArray *pathsArray;
}

- (NSArray*) parseXmlString: (NSString*) string;

- (NSMutableArray*) logArray;
- (void) setLogArray: (NSMutableArray*) aLogArray;
- (NSMutableDictionary*) tmpDict;
- (void) setTmpDict: (NSMutableDictionary*) atmpDict;
- (NSMutableDictionary*) tmpDict2;
- (void) setTmpDict2: (NSMutableDictionary*) aTmpDict2;
- (NSMutableString*) tmpString;
- (void) setTmpString: (NSMutableString*) aTmpString;
- (NSMutableArray*) pathsArray;
- (void) setPathsArray: (NSMutableArray*) aPathsArray;

@end
