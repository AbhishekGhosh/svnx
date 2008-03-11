//
//  SvnListParser.h
//  svnX
//
//  Created by Dominique PERETTI on 05/01/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SvnListParser : NSObject
{
	NSMutableArray *listArray;
	NSMutableDictionary *tmpDict;
	NSMutableDictionary *tmpDict2;
	NSMutableString *tmpString;
}

-(NSArray *)parseXmlString:(NSString *)string;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
		namespaceURI:(NSString *)namespaceURI
		qualifiedName:(NSString *)qualifiedName
		attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
		namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;

- (NSMutableArray *)listArray;
- (void)setListArray:(NSMutableArray *)aListArray;
- (NSMutableDictionary *)tmpDict;
- (void)setTmpDict:(NSMutableDictionary *)atmpDict;
- (NSMutableDictionary *)tmpDict2;
- (void)setTmpDict2:(NSMutableDictionary *)aTmpDict2;
- (NSMutableString *)tmpString;
- (void)setTmpString:(NSMutableString *)aTmpString;

- (NSMutableArray*) pathsArray;	// subclass to implement

@end
