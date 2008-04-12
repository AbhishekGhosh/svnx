#import "MySvnLogView.h"
#import "MySvnLogParser.h"
#import "MyRepository.h"
#import "MyApp.h"
#include "CommonUtils.h"


static NSString*
getRevisionAtIndex (NSArray* array, int index)
{
	return [[array objectAtIndex: index] objectForKey: @"revision"];
}


//----------------------------------------------------------------------------------------
#pragma mark -

@implementation MySvnLogView

- (id) initWithFrame: (NSRect) frameRect
{
	self = [super initWithFrame: frameRect];
	if (self != nil)
	{
		NSString* nibName = [self isVerbose] ? @"MySvnLogView2" : @"MySvnLogView";

		if ([NSBundle loadNibNamed:nibName owner:self])
		{
			[_view setFrame: [self bounds]];
			[self addSubview: _view];

		//  [self addObserver:self forKeyPath:@"currentRevision"
		//			options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:nil];
		}

		[self setMostRecentRevision:1];
	}

	return self;
}

- (void)dealloc
{
//	NSLog(@"dealloc logview");
	[self setPath: nil];

	[self setLogArray: nil];
	[self setCurrentRevision: nil];

	[super dealloc];
}

- (void)unload
{
	// the nib is responsible for releasing its top-level objects
//	[_view release];	// this is done by super
	[logsAC release];
	[logsACSelection release];

	// these objects are bound to the file owner and retain it
	// we need to unbind them 
	[logsAC unbind:@"contentArray"];	// -> self retainCount -1
	
	[super unload];
}

- (void)resetUrl:(NSURL *)anUrl
{
	[self setUrl:anUrl];
	[self setMostRecentRevision:0];
	[self setLogArray:nil];
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	svn related methods


- (void) doSvnLog: (NSString*) aPath
{
	NSMutableDictionary* taskInfo =
				[MySvn		log: aPath
				 generalOptions: [self svnOptionsInvocation]
						options: [NSArray arrayWithObjects: @"--xml", 
										[NSString stringWithFormat: @"-rHEAD:%d", [self mostRecentRevision]],
										[self isVerbose] ? @"-v" : nil,
										nil]
					   callback: [self makeCallbackInvocationOfKind: 0]
				   callbackInfo: nil
					   taskInfo: [self documentNameDict]];
	[self setPendingTask: taskInfo];
}


- (void)fetchSvnLog
{
	[self fetchSvn];
}


- (void)fetchSvn
/* Triggers the fetching */
{
	[super fetchSvn];

	if ( [self path] != nil )
	{
		[self fetchSvnLogForPath];  // when called from the working copy window, the fileMerge operation (svn diff)
	}								// takes a filesystem path, not an url+revision
	else
		[self fetchSvnLogForUrl];
}


- (void)fetchSvnLogForUrl
{
	NSDictionary* cacheDict = nil;
	BOOL useCache = [GetPreference(@"cacheSvnQueries") boolValue];

	NSData* cacheData;
	if (useCache && (cacheData = [NSData dataWithContentsOfFile: [self getCachePath]]))
	{
		NSString* errorString = nil;
		cacheDict = [NSPropertyListSerialization propertyListFromData: cacheData
												 mutabilityOption:     kCFPropertyListMutableContainers
												 format:               NULL
												 errorDescription:     &errorString];
		if (errorString)
			NSLog(@"fetchSvnLogForUrl: ERROR: %@", errorString);
		[errorString release];
	}
	if (cacheDict)
	{
		[self setMostRecentRevision:[[cacheDict objectForKey:@"revision"] intValue]];
		[self setLogArray:[cacheDict objectForKey:@"logArray"]];
	}

	[self doSvnLog: [[self url] absoluteString]];
}


- (void)fetchSvnLogForPath
{
	[self doSvnLog: [self path]];
}


- (void) fetchSvnReceiveDataFinished: (id) taskObj
{
	[super fetchSvnReceiveDataFinished:taskObj];

	NSData* data = [taskObj valueForKey: @"stdoutData"];
	if (data != nil && [data length] != 0)
	{
		NSMutableArray* parsedArray = [MySvnLogParser parseData: data];

		[self setMostRecentRevision: [parsedArray count] ? [getRevisionAtIndex(parsedArray, 0) intValue] : 0];

		NSMutableArray* array = [self logArray];
		const int count = [array count];
		if (count > 0)
		{
			[array removeObjectAtIndex: 0];

			if (count > 1)
				[parsedArray addObjectsFromArray: array];
		}

		[self setLogArray: parsedArray];
		array = parsedArray;

		if (currentRevision == nil)
		{
			[self setCurrentRevision: [array count] ? getRevisionAtIndex(array, 0) : @"0"];
		}

		if ([self url] != nil)	// Only cache logs for repository URLs not Working Copy paths
		{
			id dict = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSNumber numberWithInt: [self mostRecentRevision]], @"revision",
							array, @"logArray",
							nil];
			NSString* errorString = nil;
			id data = [NSPropertyListSerialization dataFromPropertyList: dict
												   format:               NSPropertyListBinaryFormat_v1_0
												   errorDescription:     &errorString];
			if (data)
			{
				[data writeToFile: [self getCachePath] atomically: YES];
			}
			else
			{
				NSLog(@"fetchSvnReceiveDataFinished: ERROR: %@", errorString);
				[errorString release];
			}
		}
	}
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Table View datasource

// The tableview is driven by the bindings, except for the radio button column.

- (id) tableView:                 (NSTableView*)   aTableView
	   objectValueForTableColumn: (NSTableColumn*) aTableColumn
	   row:                       (int)            rowIndex
{
	if ( [[aTableColumn identifier] isEqualToString: @"currentRevision"] ) // should be always the case
	{
		if ( [getRevisionAtIndex([logsAC arrangedObjects], rowIndex) isEqualToString: currentRevision] )
			return @"1";
	}
	
	return nil;
}


- (void) tableView:      (NSTableView*)   aTableView
		 setObjectValue: (id)             anObject
		 forTableColumn: (NSTableColumn*) aTableColumn
		 row:            (int)            rowIndex
{
	// The tableview is driven by the bindings, except for the first column !
	if ( [[ aTableColumn identifier] isEqualToString:@"currentRevision"] ) // should be always the case
	{
		NSString* newRevision = getRevisionAtIndex([logsAC arrangedObjects], rowIndex);

		if (currentRevision == nil || ![currentRevision isEqualToString: newRevision])
		{
			[self setCurrentRevision:newRevision];
			[aTableView setNeedsDisplay:YES];
		}
	}
}


// Sometimes required by the compiler, sometimes not.

- (int) numberOfRowsInTableView: (NSTableView*) aTableView
{
	return [[logsAC arrangedObjects] count];
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Accessors


- (NSString*) selectedRevision	// This is different from the checked one
{
	return getRevisionAtIndex([logsAC selectedObjects], 0);
}


// - currentRevision:
- (NSString*) currentRevision { return currentRevision; }

// - setCurrentRevision:
- (void) setCurrentRevision: (NSString*) aCurrentRevision
{
	id old = currentRevision;
	currentRevision = [aCurrentRevision retain];
	[old release];
}


// - path:
- (NSString*) path { return path; }

// - setPath:
- (void) setPath: (NSString*) aPath
{
	id old = path;
	path = [aPath retain];
	[old release];
}


// - isVerbose:
- (BOOL) isVerbose { return isVerbose; }

// - setIsVerbose:
- (void) setIsVerbose: (BOOL) flag
{
	isVerbose = flag;
}


// - logArray:
- (NSMutableArray*) logArray { return logArray; }

// - setLogArray:
- (void) setLogArray: (NSMutableArray*) aLogArray
{
	id old = logArray;
	logArray = [aLogArray retain];
	[old release];
}


// - mostRecentRevision:
- (int) mostRecentRevision { return mostRecentRevision; }

// - setMostRecentRevision:
- (void) setMostRecentRevision: (int) aMostRecentRevision
{
	mostRecentRevision = aMostRecentRevision;
}


- (NSString*) getCachePath
{
	NSString* logName = [self isVerbose] ? @" log_verbose" : @" log";
	return [MySvn cachePathForKey: [[[self url] absoluteString] stringByAppendingString: logName]];
}

@end

