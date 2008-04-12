//
// MySvnRepositoryBrowserView.m
//

#import "MySvnRepositoryBrowserView.h"
#import "MyApp.h"
#import "MySvn.h"
#import "MyRepository.h"
#import "SvnListParser.h"
#import "SvnLogReport.h"
#import "NSString+MyAdditions.h"
#include "CommonUtils.h"

#ifndef Assert
#define	Assert(expr)	/*(expr)*/
#endif


@class IconCache;

enum { kMiniIconSize = 13 };


static NSFont* gFont;
static IconCache* gIconCache;


//----------------------------------------------------------------------------------------

static NSImage*
makeMiniIcon (NSImage* image)
{
	Assert(image != nil);

	static const NSRect dstRect = { 0, 0, kMiniIconSize, kMiniIconSize };
	NSRect srcRect;
	srcRect.origin.x =
	srcRect.origin.y = 0;
	srcRect.size = [image size];

	NSImage* icon = [[NSImage alloc] initWithSize: dstRect.size];
	[icon lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation: NSImageInterpolationHigh];
	[image drawInRect: dstRect fromRect: srcRect operation: NSCompositeCopy fraction: 1];
	[icon unlockFocus];

	return icon;
}


//----------------------------------------------------------------------------------------
#pragma mark	-

@interface IconCache : NSObject
{
	NSWorkspace*			fWorkspace;
	NSMutableDictionary*	fDict;
	NSImage*				fDirIcon;
	NSImage*				fRootIcon;
}

- (NSImage*) iconForFileType: (NSString*) fileType;
- (NSImage*) dirIcon;
- (NSImage*) rootIcon;

@end	// IconCache


//----------------------------------------------------------------------------------------
#pragma mark	-

@implementation IconCache

- (id) init
{
	extern NSImage* GenericFolderImage ();

	self = [super init];
	if (self != nil)
	{
		fWorkspace = [NSWorkspace sharedWorkspace];
		fDict      = [[NSMutableDictionary alloc] init];
		fDirIcon   = makeMiniIcon(GenericFolderImage());
		fRootIcon  = makeMiniIcon([NSImage imageNamed: @"Repository"]);
	}

	return self;
}


//----------------------------------------------------------------------------------------

- (void) dealloc
{
	gIconCache = nil;
	[fDict release];
	[fDirIcon release];
	[fRootIcon release];

	[super dealloc];
}


//----------------------------------------------------------------------------------------

- (NSImage*) iconForFileType: (NSString*) fileType
{
	NSImage* icon = [fDict objectForKey: fileType];
	if (icon == nil)
	{
		NSImage* const image = [fWorkspace iconForFileType: fileType];
		if (image != nil)
		{
			icon = makeMiniIcon(image);
			[fDict setObject: icon forKey: fileType];
		}
	}

	return icon;
}


//----------------------------------------------------------------------------------------

- (NSImage*) dirIcon
{
	return fDirIcon;
}


//----------------------------------------------------------------------------------------

- (NSImage*) rootIcon
{
	return fRootIcon;
}

@end	// IconCache



//----------------------------------------------------------------------------------------
#pragma mark	-
//----------------------------------------------------------------------------------------

@implementation MySvnRepositoryBrowserView

- (id)initWithFrame:(NSRect)frameRect
{
	if (gFont == nil)
		gFont = [[NSFont fontWithName: @"Lucida Grande" size: 10] retain];

	if (gIconCache == nil)
		gIconCache = [[IconCache alloc] init];
	else
		[gIconCache retain];

	if ((self = [super initWithFrame:frameRect]) != nil)
	{
		if ([NSBundle loadNibNamed:@"MySvnRepositoryBrowserView" owner:self])
		{
		  [_view setFrame:[self bounds]];
		  [self addSubview:_view];
		}
	}

	return self;
}

- (void)dealloc
{
//	NSLog(@"dealloc repository browser view");
	[self setBrowserPath: nil];
	[gIconCache release];

	[super dealloc];
}

- (void)unload
{
	// the nib is responsible for releasing its top-level objects
//	[_view release];	// this is done by super

	// these objects are bound to the file owner and retain it
	// we need to unbind them 
	[revisionTextField unbind:@"value"];
	[super unload];
}


//----------------------------------------------------------------------------------------

- (void) onDoubleClick: (id) sender
{
	if (!disallowLeaves)
	{
		const BOOL optionPressed = ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) != 0;
		NSArray* items = [self selectedItems];
		if (items != nil && [items count] > 0)
		{
			NSDictionary* dict = [items objectAtIndex: 0];
			NSURL* furl = [dict objectForKey: @"url"];

			SvnLogReport* logReport = [SvnLogReport alloc];
			[logReport initWithURL: [furl absoluteString] revision: [self revision]];
			if ([NSBundle loadNibNamed: @"BrowseLog" owner: logReport])
			{
				[logReport begin: self verbose: !optionPressed];
			}
		}
	}
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	public methods

-(NSMutableArray *)selectedItems
/* Returns a array of the selected represented objects */
{
	NSEnumerator *en = [[browser selectedCells] objectEnumerator];
	NSCell *cell;
	NSMutableArray *arr = [NSMutableArray array];
	
	while ( cell = [en nextObject] )
	{
		[arr addObject:[cell representedObject]];
	}
	
	return arr;
}

- (void)setAllowsEmptySelection:(BOOL)flag
{
	[browser setAllowsEmptySelection:flag];
}

- (void)setAllowsMultipleSelection:(BOOL)flag
{
	[browser setAllowsMultipleSelection:flag];
}

- (void)reset
{
	[self setBrowserPath:nil];
	[browser setPath:@"/"];
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Browser delegate methods

- (void) browser:             (NSBrowser*) sender
		 createRowsForColumn: (int)        column
		 inMatrix:            (NSMatrix*)  matrix
{
	if ( [self revision] == nil ) return; 

	if ( [matrix numberOfRows] != 0 )
	{
	}
	else if (column == 0 && [self showRoot])
	{
		NSBrowserCell *cell = [[NSBrowserCell alloc] initTextCell:@"root"];
		NSDictionary *txtDict = [NSDictionary dictionaryWithObjectsAndKeys:
										gFont, NSFontAttributeName,
										[NSNumber numberWithFloat:0.4], NSObliquenessAttributeName,
										nil];
		NSAttributedString *attrStr = [[[NSAttributedString alloc] initWithString:@"root" attributes:txtDict] autorelease];
		[cell setAttributedStringValue:attrStr];

		[self setIsFetching:NO];

		[cell setImage: [gIconCache rootIcon]];
		[cell setLeaf:NO];
		[cell setRepresentedObject:[NSDictionary dictionaryWithObjectsAndKeys:
															kNSTrue, @"isRoot",
															@"root", @"name",
															@"", @"path",
															[self url], @"url",
															[self revision], @"revision",
															NSFileTypeDirectory, @"fileType",
															kNSTrue, @"isDir",
															nil]];

		[matrix addRowWithCells:[NSArray arrayWithObject:cell]];
		[matrix putCell:cell atRow:0 column:0];
		[cell release];
		[matrix sizeToCells];
		[matrix display];
	}
	else
		[self fetchSvnListForUrl:[sender path] column:column matrix:matrix];
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	svn related methods


- (void)fetchSvn
/* Triggers the fetching */
{
	[self setBrowserPath:[browser path]];

	[super fetchSvn];
	
	if ( [self showRoot] )
	{
		[browser reloadColumn:0];
		[browser selectRow:0 inColumn:0];
		[browser setWidth:50 ofColumn:0];
		
	} else
	{
		[browser reloadColumn:0];
	}
}


- (void)fetchSvnListForUrl:(NSString *)theURL column:(int)column matrix:(NSMatrix *)matrix
{
	NSString* url2 = theURL;
	
	if ( [self showRoot] )
		url2 = [url2 substringFromIndex:5]; // get rid of "root" prefix

	NSURL *cleanUrl = [NSURL URLWithString:[[url2 trimSlashes] escapeURL] relativeToURL:[self url]];

	BOOL useCache = [GetPreference(@"cacheSvnQueries") boolValue];
	NSData* cachedXML;

	if (useCache && ![[self revision] isEqualToString:@"HEAD"] &&
		(cachedXML = [NSData dataWithContentsOfFile: [self getCachePathForUrl: cleanUrl]]))
	{
		NSArray* resultArray = [SvnListParser parseData: cachedXML];

		[self displayResultArray:resultArray column:column matrix:matrix];
	}
	else
	{
		[self setIsFetching:YES];

		[self setPendingTask:
			[MySvn	list: [NSString stringWithFormat:@"%@@%@", [cleanUrl absoluteString], [self revision]]
		  generalOptions: [self svnOptionsInvocation]
				 options: [NSArray arrayWithObjects:@"--xml", @"-r", [self revision], nil]
                callback: [self makeCallbackInvocationOfKind:10]
			callbackInfo: [NSDictionary dictionaryWithObjectsAndKeys:
								matrix, @"matrix", [NSNumber numberWithInt:column], @"column", cleanUrl, @"url", nil]
			    taskInfo: [self documentNameDict]]
		];
	}
}


- (NSString*) pathToColumn: (int) column
{
	NSString* result = [browser pathToColumn: column];
	if ([self showRoot])
	{
		result = [result substringFromIndex: 5];	// don't keep the "root" prefix
	}

	return result;
}


- (void)fetchSvnReceiveDataFinished:(id)taskObj
{
	[super fetchSvnReceiveDataFinished:taskObj];

	id info = [taskObj objectForKey:@"callbackInfo"];
	NSData* result = [taskObj objectForKey: @"stdoutData"];

	NSURL *fetchedUrl = [info objectForKey:@"url"];
	NSMatrix *matrix = [info objectForKey:@"matrix"];
	int column = [[info objectForKey:@"column"] intValue];
	NSArray* resultArray = [SvnListParser parseData: result];
	[self displayResultArray:resultArray column:column matrix:matrix];

	if ( ![[self revision] isEqualToString:@"HEAD"] )
	{
		if ( ![result writeToFile: [self getCachePathForUrl: fetchedUrl] atomically: YES] )
		{
			NSLog(@"Could not cache: %@", fetchedUrl);
		}
	}
}


- (void) displayResultArray: (NSArray*)  resultArray
		 column:             (int)       column
		 matrix:             (NSMatrix*) matrix
{
	//NSLog(@"matrix %@ %@ %d %@", browser, matrix, column, [self pathToColumn:column]);
	NSImage* const dirIcon = [gIconCache dirIcon];
	NSString* const pathToColumn = [self pathToColumn: column];

	int i, count = [resultArray count];
	for (i = 0; i < count; ++i)
	{
		NSMutableDictionary* row  = [resultArray objectAtIndex: i];
		NSString* const name      = [row objectForKey: @"name"];
		const BOOL isDir          = [[row objectForKey: @"isDir"] boolValue];
		NSBrowserCell* const cell = [[NSBrowserCell alloc] initTextCell: name];

		NSString* path = [[pathToColumn stringByAppendingPathComponent: name] trimSlashes];
		NSString* urlPath = [path escapeURL];
		if (isDir)
			urlPath = [urlPath stringByAppendingString: @"/"];
		NSURL* theURL = [NSURL URLWithString: urlPath relativeToURL: [self url]];

		NSString* fileType = isDir ? NSFileTypeDirectory : [name pathExtension];
		NSImage* icon = isDir ? dirIcon : [gIconCache iconForFileType: fileType];
		[row setObject: fileType forKey: @"fileType"];
		[row setObject: path     forKey: @"path"];
		[row setObject: theURL   forKey: @"url"];

		if (isDir)	// set the contextual menu on folders
		{
			NSMenu* m = [browserContextMenu copy];
			[[m itemAtIndex: 0] setRepresentedObject: row];
			[cell setMenu: m];
		}
		else if (disallowLeaves)	// !isDir
		{
			[cell setEnabled: NO];
		}

		[cell setFont: gFont];
		[cell setImage: icon];
		[cell setLeaf: !isDir];
		[cell setRepresentedObject: row];
	//	NSLog(@"row=%@", row);

		[matrix addRowWithCells: [NSArray arrayWithObject: cell]];

		NSString* const revisionStr = [row objectForKey: @"revision"];
		NSString* const authorStr   = [row objectForKey: @"author"];
		NSString* const dateStr     = [row objectForKey: @"date"];
		NSString* const timeStr     = [row objectForKey: @"time"];
		NSString* const helpStr = (isDir) ? [NSString stringWithFormat:
													@"Revision: %@\nAuthor: %@\nDate: %@\nTime: %@",
													revisionStr, authorStr, dateStr, timeStr]
										  : [NSString stringWithFormat:
													@"Revision: %@\nAuthor: %@\nSize: %@ bytes\nDate: %@\nTime: %@",
													revisionStr, authorStr, [row objectForKey: @"size"],
													dateStr, timeStr];
		[matrix setToolTip: helpStr forCell: cell];

		[matrix putCell: cell atRow: i column: 0];
		[cell release];
	}

	[matrix sizeToCells];
	[matrix display];
	
//	if ( [self browserPath] != nil ) 
//	{
//		[browser setPath:[self browserPath]]; // attempt to restore the previously displayed path
//		[self setBrowserPath:nil];
//	}
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Accessors

// - showRoot:
- (BOOL) showRoot { return showRoot; }

// - setShowRoot:
- (void) setShowRoot: (BOOL) flag
{
	showRoot = flag;
}


// - disallowLeaves:
- (BOOL) disallowLeaves { return disallowLeaves; }

// - setDisallowLeaves:
- (void) setDisallowLeaves: (BOOL) flag
{
	disallowLeaves = flag;
}


// - browserPath:
- (NSString*) browserPath { return browserPath; }

// - setBrowserPath:
- (void) setBrowserPath: (NSString*) aBrowserPath
{
	id old = browserPath;
	browserPath = [aBrowserPath retain];
	[old release];
}


- (NSString*) getCachePathForUrl: (NSURL*) theURL
{
	return [MySvn cachePathForKey: [NSString stringWithFormat: @"%@::%@ list",
															   [theURL absoluteString], [self revision]]];
}

@end

