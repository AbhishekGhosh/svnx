#import "MyWorkingCopy.h"
#import "MyWorkingCopyController.h"
#import "MySVN.h"
#import "Tasks.h"

@class MySvn;
@class SvnFileStatusToColourTransformer;
@class SvnFilePathTransformer;

enum {
	SVNXCallbackSvnStatus,
	SVNXCallbackSvnUpdate,
	SVNXCallbackSvnInfo,
	SVNXCallbackGeneric,
	SVNXCallbackFileMerge
};


//----------------------------------------------------------------------------------------

static BOOL
useOldParsingMethod ()
{
	return [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: @"useOldParsingMethod"] boolValue];
}


//----------------------------------------------------------------------------------------
#pragma mark -
//----------------------------------------------------------------------------------------

@implementation MyWorkingCopy


//----------------------------------------------------------------------------------------

- (void) svnError: (NSDictionary*) taskObj
{
	NSString* errMsg = [taskObj valueForKey: @"stderr"];
	if ([errMsg length] > 0)
		[controller svnError: errMsg];
}


//----------------------------------------------------------------------------------------

- (void) svnRefresh
{
//	NSLog(@"svnRefresh - isVisible=%d", [[controller window] isVisible]);
	[controller fetchSvnInfo];		
	[controller fetchSvnStatus];		
}


//----------------------------------------------------------------------------------------
#pragma mark -
//----------------------------------------------------------------------------------------

+ (void) presetDocumentName: name
{
	[MyWorkingCopyController presetDocumentName: name];
}


//----------------------------------------------------------------------------------------

- (id)init
{
    self = [super init];
    if (self)
	{
		filterMode = kFilterAll;

		// initialize svnFiles :
		// svnFilesAC is bound in Interface Builder to this variable.
		[self setSvnFiles:[NSMutableArray array]];

		[self setSvnDirectories:[NSMutableDictionary dictionary]];

		[self setFlatMode:TRUE];
		[self setSmartMode:TRUE];
		
		[self setOutlineSelectedPath:@""];
		[self setStatusInfo:@""];

		// register self as an observer for bound variables
		[self   addObserver:self forKeyPath:@"smartMode"
				options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
		[self   addObserver:self forKeyPath:@"outlineSelectedPath"
				options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
		[self   addObserver:self forKeyPath:@"flatMode"
				options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
		[self   addObserver:self forKeyPath:@"filterMode"
				options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
	}
    
	return self;
}


//----------------------------------------------------------------------------------------

- (void) setup: (NSString*) title
		 user:  (NSString*) username
		 pass:  (NSString*) password
		 path:  (NSString*) fullPath
{
	[self setWindowTitle:     title];
	[self setUser:            username];
	[self setPass:            password];
	[self setWorkingCopyPath: fullPath];
	[controller setup];
}


//----------------------------------------------------------------------------------------

- (void)dealloc
{
	[self setUser: nil];
	[self setPass: nil];
	[self setRevision:nil];
	[self setWorkingCopyPath: nil];
	[self setWindowTitle: nil];
	[self setOutlineSelectedPath: nil];
	[self setResultString: nil];
	[self setSvnFiles: nil];
	[self setSvnDirectories: nil];
	[self setRepositoryUrl: nil];
	[self setStatusInfo: nil];
	[self setDisplayedTaskObj: nil];

	[super dealloc];
}

- (NSString *)windowNibName
{
    return @"MyWorkingCopy";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	[aController setShouldCascadeWindows: NO];

	// set table view's default sorting to status type column
	
	[svnFilesAC setSortDescriptors:[NSArray arrayWithObjects: [[[NSSortDescriptor alloc] 
                                                 initWithKey:@"col1" ascending:NO] autorelease],
												 [[[NSSortDescriptor alloc] 
                                                 initWithKey:@"path" ascending:YES] autorelease], nil]];

    [super windowControllerDidLoadNib:aController];
}


- (void) close
{
	// tell the task center to cancel pending callbacks to prevent crash
	[[Tasks sharedInstance] cancelCallbacksOnTarget:self];

	[self removeObserver:self forKeyPath:@"smartMode"];
	[self removeObserver:self forKeyPath:@"outlineSelectedPath"];
	[self removeObserver:self forKeyPath:@"flatMode"];
	[self removeObserver:self forKeyPath:@"filterMode"];

	[controller cleanup];

	[super close];
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark svn status

- (void)fetchSvnStatusVerbose
{	
	NSMutableArray *options = [NSMutableArray array];

	if ( ![self smartMode] )
	{
		[options addObject:@"-v"];
	}

	if ( [self showUpdates] )
	{
		[options addObject:@"-u"];
	}

	if (!useOldParsingMethod())
	{
		[options addObject:@"--xml"];
	}
	
	[MySvn    statusAtWorkingCopyPath: [self workingCopyPath]
					   generalOptions: [self svnOptionsInvocation]
							  options: options
							 callback: [self makeCallbackInvocationOfKind:SVNXCallbackSvnStatus]
						 callbackInfo: nil
							 taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];
}

-(void)svnStatusCompletedCallback:(NSMutableDictionary *)taskObj
{
	if ( [[taskObj valueForKey:@"status"] isEqualToString:@"completed"] )
	{
		[self fetchSvnStatusVerboseReceiveDataFinished:[taskObj valueForKey:@"stdout"]];
	}

	[self svnError: taskObj];
}


- (void)fetchSvnStatusVerboseReceiveDataFinished:(NSString*)result
{
	[self setResultString:result]; // this will feed the log file

	[self computesVerboseResultArray];

	[controller fetchSvnStatusVerboseReceiveDataFinished];
}


//----------------------------------------------------------------------------------------

- (void)computesNewVerboseResultArray
{
    NSError* err = nil;
	NSXMLDocument* xmlDoc = [[NSXMLDocument alloc] initWithXMLString:
								[self resultString] options: NSXMLDocumentTidyXML error: &err];

	if (err)
		NSLog(@"Error parsing xml %@", err);

	if (xmlDoc == nil)
        return;

	NSMutableArray *newSvnFiles = [NSMutableArray arrayWithCapacity: 100];
	NSMutableArray* const rootChildren = [NSMutableArray array];
	NSMutableDictionary* outlineDirs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											rootChildren, @"children",
											[workingCopyPath lastPathComponent], @"name",
											@"", @"path", nil];

	// <target> node
	NSXMLElement *targetElement = [[[xmlDoc rootElement] elementsForName:@"target"] objectAtIndex:0];

	NSString* statusMsg = @"";
	// <against revision=""> node
	NSArray *againstElements = [targetElement elementsForName:@"against"];
	if ( [againstElements count] > 0 )
	{
		NSXMLElement *against = [againstElements objectAtIndex:0];
		statusMsg = [NSString stringWithFormat: @"Status against revision: %@",
												[[against attributeForName: @"revision"] stringValue]];
	}
	[self setStatusInfo: statusMsg];

	NSString* const targetPath = [[targetElement attributeForName: @"path"] stringValue];
	const int targetPathLength = [targetPath length];
	const id kTrue  = (id) kCFBooleanTrue,
			 kFalse = (id) kCFBooleanFalse;
	NSWorkspace* const workspace = [NSWorkspace sharedWorkspace];
	NSFileManager* const fileManager = [NSFileManager defaultManager];
	const BOOL kFlatMode    = [self flatMode],
			   kShowUpdates = [self showUpdates];
	const NSSize kIconSize = { 16, 16 };

	NSXMLElement *entry;
	NSEnumerator *e = [[targetElement elementsForName:@"entry"] objectEnumerator];

	// <entry> nodes
	while ( entry = [e nextObject] )
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSString *revisionCurrent = @"";
		NSString *revisionLastChanged = @"";
		NSString *theUser = @"" ;

		NSXMLElement *wc_status = nil;
		NSString *itemStatus = @"";
		NSString *propStatus = nil; 
		NSString *copiedStatus;
		NSString *switchedStatus;
		
		// wcLockedStatus has nothing to do with lockInWc
		// <http://svnbook.red-bean.com/nightly/en/svn.advanced.locking.html#svn.advanced.locking.meanings>
		NSString *wcLockedStatus;
		NSString* wc_lock = nil;
		
		// <wc-status> node
		NSArray *wc_status_elements = [entry elementsForName:@"wc-status"];
		if ( [wc_status_elements count] > 0 )
		{
			wc_status = [wc_status_elements objectAtIndex:0];
		
			itemStatus = [[wc_status attributeForName:@"item"] stringValue];
			propStatus = [[wc_status attributeForName:@"props"] stringValue];		
			copiedStatus = [[wc_status attributeForName:@"copied"] stringValue];
			switchedStatus = [[wc_status attributeForName:@"switched"] stringValue];
			wcLockedStatus = [[wc_status attributeForName:@"wc-locked"] stringValue];

			if ( [wc_status attributeForName:@"revision"] != nil )
			revisionCurrent = [[wc_status attributeForName:@"revision"] stringValue];

			// working copy lock? (when --show-update is NOT used)
			NSArray *lockInWCElements = [wc_status elementsForName:@"lock"];
			if ( [lockInWCElements count] > 0 )
			{
				NSXMLElement *lockInWC = [lockInWCElements objectAtIndex:0];
				wc_lock = [[[lockInWC elementsForName: @"token"] objectAtIndex: 0] stringValue];
			}
			
			NSArray *commitElements = [wc_status elementsForName:@"commit"];
			if ( [commitElements count] > 0 )
			{
				NSXMLElement *commit = [commitElements objectAtIndex:0];
				NSArray *commitElements = [commit elementsForName:@"author"];
				if ( [commitElements count] > 0 )
				{
					theUser = [[commitElements objectAtIndex:0] stringValue];
				}
				revisionLastChanged = [[commit attributeForName:@"revision"] stringValue];
			}
		}
		
		// <repos-status> node  (when running --show-update)
		NSXMLElement *repos_status = nil;
		NSArray *repos_status_elements = [entry elementsForName:@"repos-status"];
		
		NSString *reposItemStatus;
		NSString *reposPropStatus;
		NSString* repos_lock = nil;
		
		if ( [repos_status_elements count] > 0 )
		{
			repos_status = [repos_status_elements objectAtIndex:0];

			if (kShowUpdates)
			{
				// repository lock?
				NSArray *lockInReposElements = [repos_status elementsForName:@"lock"];
				if ( [lockInReposElements count] > 0 )
				{
					NSXMLElement *lockInRepos = [lockInReposElements objectAtIndex:0];
					repos_lock = [[[lockInRepos elementsForName: @"token"] objectAtIndex: 0] stringValue];
				}
			}

			reposItemStatus = [[repos_status attributeForName:@"item"] stringValue];
			reposPropStatus = [[repos_status attributeForName:@"props"] stringValue];		
			
		}

	#if 0
		// local lock?
		NSXMLElement *lockInWc;

		if ( wc_status != nil )
		{		
			NSArray *lockInWcElements = [wc_status elementsForName:@"lock"];

			if ( [lockInWcElements count] > 0 )
			{
				lockInWc = [lockInWcElements objectAtIndex:0];
			}
		}
	#endif

		NSString* const itemFullPath = [[entry attributeForName: @"path"] stringValue];
		NSString* const itemPath = (targetPathLength < [itemFullPath length])
									? [itemFullPath substringFromIndex: targetPathLength + 1] : @".";

		int col1 = ' ',  col2 = ' ';
		NSString *column1 = @" ";
		NSString *column2 = @" ";
		NSString *column3 = @" ";
		NSString *column4 = @" ";
		NSString *column5 = @" ";
		NSString *column6 = @" ";
		NSString *column7 = @" ";
		NSString *column8 = @" ";

		// see all meanings at http://svnbook.red-bean.com/nightly/en/svn.ref.svn.c.status.html
		// COLUMN 1
		const unichar ch0 = [itemStatus length] ? [itemStatus characterAtIndex: 0] : 0;
		if (ch0 == 0)
			;
		else if (ch0 == 'u' && [itemStatus isEqualToString: @"unversioned"])
		{
			col1 = '?';		column1 = @"?";
		}
		else if (ch0 == 'm' && [itemStatus isEqualToString: @"modified"])
		{
			col1 = 'M';		column1 = @"M";
		}
		else if (ch0 == 'a' && [itemStatus isEqualToString: @"added"])
		{
			col1 = 'A';		column1 = @"A";
		}
		else if (ch0 == 'd' && [itemStatus isEqualToString: @"deleted"])
		{
			col1 = 'D';		column1 = @"D";
		}
		else if (ch0 == 'r' && [itemStatus isEqualToString: @"replaced"])
		{
			col1 = 'R';		column1 = @"R";
		}
		else if (ch0 == 'c' && [itemStatus isEqualToString: @"conflicted"])
		{
			col1 = 'C';		column1 = @"C";
		}
		else if (ch0 == 'i' && [itemStatus isEqualToString: @"ignored"])
		{
			col1 = 'I';		column1 = @"I";
		}
		else if (ch0 == 'e' && [itemStatus isEqualToString: @"external"])
		{
			col1 = 'X';		column1 = @"X";
		}
		else if ((ch0 == 'i' && [itemStatus isEqualToString: @"incomplete"]) ||
				 (ch0 == 'm' && [itemStatus isEqualToString: @"missing"]))
		{
			col1 = '!';		column1 = @"!";
		}
		else if (ch0 == 'o' && [itemStatus isEqualToString: @"obstructed"])
		{
			col1 = '~';		column1 = @"~";
		}
		
		// COLUMN 2
		const unichar propStatusCh0 = (propStatus && [propStatus length]) ? [propStatus characterAtIndex: 0] : 0;
		if (propStatusCh0 == 'm' && [propStatus isEqualToString: @"modified"])
		{
			col2 = 'M';		column2 = @"M";
		}
		else if (propStatusCh0 == 'c' && [propStatus isEqualToString: @"conflicted"])
		{
			col2 = 'C';		column2 = @"C";
		}
		
		// COLUMN 3
		if ( [wcLockedStatus isEqualToString:@"true"] )
		{
			column3 = @"L";
		}
		
		// COLUMN 4
		if ( [copiedStatus isEqualToString:@"true"] )
		{
			column4 = @"+";
		}

		// COLUMN 5
		if ( [switchedStatus isEqualToString:@"true"] )
		{
			column5 = @"S";
		}
		
		// COLUMN 6
		// see <http://svn.collab.net/repos/svn/trunk/subversion/svn/status.c>, ~ line 112 for explanation
		if (kShowUpdates)
		{
			if ( repos_lock != nil )
			{
				if ( wc_lock != nil )
				{
				//	column6 = [[wc_lock objectForKey: @"token"] isEqualToString: repos_lock]
					column6 = [wc_lock isEqualToString: repos_lock]
								? @"K"	// File is locked in this working copy
								: @"T";	// File was locked in this working copy, but the lock has been 'stolen'
										// and is invalid. The file is currently locked in the repository
				}
				else
					column6 = @"O";		// File is locked either by another user or in another working copy
			}
			else if ( wc_lock )			// File was locked in this working copy, but the lock has
				 column6 = @"B";		// been 'broken' and is invalid. The file is no longer locked
		}
		else if ( wc_lock )
			column6 = @"K";				// File is locked in this working copy
		
		// COLUMN 7
		if ( repos_status != nil )
		{
			if ( [reposItemStatus isEqualToString:@"none"] == NO || [reposPropStatus isEqualToString:@"none"] == NO )
				column7 = @"*";
		}
		
		// COLUMN 8
		if (!(propStatusCh0 == 0 || (propStatusCh0 == 'n' &&
									 ([propStatus isEqualToString: @"none"] || [propStatus isEqualToString: @"normal"]))))
		{
			column8 = @"P";
		}
		
		BOOL renamable=NO, addable=NO, removable=NO, updatable=NO, revertable=NO, committable=NO,
			 copiable=NO, movable=NO, resolvable=NO, lockable=YES, unlockable=NO;

		if (col1 == 'M' || col2 == 'M')
		{
			removable = YES;
			updatable = YES;
			revertable = YES;
			committable = YES;
		}
		if (col1 == ' ')
		{
			removable = YES;
			renamable = YES;
			updatable = YES;
			copiable = YES;
			movable = YES;
		}		
		else if (col1 == '?')
		{
			addable = YES;
		//	removable = YES;
			lockable = NO;
		}
		else if (col1 == '!')
		{
			revertable = YES;
			updatable = YES;
			removable = YES;
			lockable = NO;			
		}
		else if (col1 == 'A' || col1 == 'R')
		{
			revertable = YES;
			committable = YES;
			lockable = NO;
			updatable = YES;
		}
		else if (col1 == 'D')
		{
			if ([fileManager fileExistsAtPath: itemFullPath])
				addable = YES;
			revertable = YES;
			committable = YES;
			updatable = YES;
		}
		if (col1 == 'C'|| col2 == 'C')
		{
			revertable = YES;
			resolvable = YES;
		}
		if ( [column6 isEqualToString:@"K"])
		{
			lockable = NO;
			unlockable = YES;
		}

		NSString* const dirPath = [itemPath stringByDeletingLastPathComponent];
		BOOL isDir;

		if (!kFlatMode && [itemPath length] &&
			[fileManager fileExistsAtPath: itemFullPath isDirectory: &isDir] && isDir)
		{
			NSArray* const pathArr = [itemPath componentsSeparatedByString: @"/"];
			const unsigned int wcPathLength = [workingCopyPath length] + 1;

			NSString* filePath = workingCopyPath;
			id tmp = rootChildren;		// let's start at root
			int j, count = [pathArr count];

			for (j = 0; j < count; ++j)
			{
				NSString* const dirName = [pathArr objectAtIndex: j];
				NSEnumerator *enumerator = [tmp objectEnumerator];
				id obj, child = nil;

				filePath = [filePath stringByAppendingPathComponent: dirName];

				while ( obj = [enumerator nextObject] )
				{
					if ([[obj objectForKey: @"name"] isEqualToString: dirName])
					{
						child = obj;
						break;
					}
				}

				if ( child == nil )
				{						
					NSImage* dirIcon = [workspace iconForFile: filePath];
					[dirIcon setSize: kIconSize];
					[tmp addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
												[NSMutableArray array], @"children",
												dirName, @"name",
												[filePath substringFromIndex: wcPathLength], @"path",
												dirIcon, @"icon",
												nil]];
					child = [tmp lastObject];
				}

				tmp = [child objectForKey: @"children"];
			}
		}

		NSImage* icon = [workspace iconForFile: itemFullPath];
		[icon setSize: kIconSize];
		[newSvnFiles addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
									column1, @"col1",
									column2, @"col2",
									column3, @"col3",
									column4, @"col4",
									column5, @"col5",
									column6, @"col6",
									column7, @"col7",
									column8, @"col8",
									revisionCurrent, @"revisionCurrent",
									revisionLastChanged, @"revisionLastChanged",
									theUser, @"user",
									icon, @"icon",
									(kFlatMode ? itemPath : [itemPath lastPathComponent]), @"displayPath",
									itemPath, @"path",
									itemFullPath, @"fullPath",
									dirPath, @"dirPath",

									(col1 == 'M' ? kTrue : kFalse), @"modified",
									(col1 == '?' ? kTrue : kFalse), @"new",
									(col1 == '!' ? kTrue : kFalse), @"missing",
									(col1 == 'A' ? kTrue : kFalse), @"added",
									(col1 == 'D' ? kTrue : kFalse), @"deleted",

									(renamable   ? kTrue : kFalse), @"renamable",
									(addable     ? kTrue : kFalse), @"addable",
									(removable   ? kTrue : kFalse), @"removable",
									(updatable   ? kTrue : kFalse), @"updatable",
									(revertable  ? kTrue : kFalse), @"revertable",
									(committable ? kTrue : kFalse), @"committable",
									(resolvable  ? kTrue : kFalse), @"resolvable",
									(lockable    ? kTrue : kFalse), @"lockable",
									(unlockable  ? kTrue : kFalse), @"unlockable",

									nil]];
		[pool release];
	
	}

	[self setSvnDirectories:outlineDirs];
	[self setSvnFiles:newSvnFiles];
}

- (void)computesOldVerboseResultArray
{
	NSArray *arr = [[self resultString] componentsSeparatedByString:@"\n"];
	NSMutableArray *newSvnFiles = [NSMutableArray arrayWithCapacity: 100];

	NSMutableDictionary* outlineDirs = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											[NSMutableArray array], @"children",
											[workingCopyPath lastPathComponent], @"name",
											@"", @"path", nil];
	
	int i, j;

//	[self setStatusInfo:@""];

	for (i = 0; i < [arr count] - 1; ++i) // last line is a blank line !
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		NSString *itemString = [arr objectAtIndex:i];
		NSString *itemFullPath = [NSString string];
		NSString *itemPath;

		NSString *revisionCurrent;
		NSString *revisionLastChanged;
		NSString *theUser;

		NSString *column1;
		NSString *column2;
		NSString *column3;
		NSString *column4;
		NSString *column5;
		NSString *column6;

		BOOL renamable=NO, addable=NO, removable=NO, updatable=NO, revertable=NO, committable=NO,
			 copiable=NO, movable=NO, resolvable=NO, lockable=YES, unlockable=NO;

		const int itemStringLength = [itemString length];
		if (itemStringLength == 0) continue;
		if (itemStringLength >= 38)
		{
			if ( [[itemString substringToIndex:38] isEqualToString:@"Performing status on external item at "] )
			{
				//[self setStatusInfo:itemString];
				continue;
			}
		}
		
		if (itemStringLength >= 24)
		{
			if ( [[itemString substringToIndex:24] isEqualToString:@"Status against revision:"] )
			{
				[self setStatusInfo:itemString];
				continue;
			}
		}
		
		if ( [self smartMode] )
		{
			if ( [self showUpdates] )
			{
				itemFullPath = [itemString substringFromIndex:20];
				int wcPathLength = [workingCopyPath length];
				if ([itemFullPath length] > wcPathLength)
					++wcPathLength;
				itemPath = [itemFullPath substringFromIndex: wcPathLength];
				revisionCurrent = [itemString substringWithRange:NSMakeRange(9, 8)];
				
				column5 = [itemString substringWithRange:NSMakeRange(7, 1)];
				
			} else
			{
				itemFullPath = [itemString substringFromIndex:7];
				
				if ( [itemFullPath length] > [workingCopyPath length] )
				{
					itemPath = [itemFullPath substringFromIndex:([workingCopyPath length]+1)];
				
				} else
				{
					itemPath = [NSString stringWithString:@""];
				}
				column5 = [itemString substringWithRange:NSMakeRange(4, 1)];

				revisionCurrent = @"";
			}

			revisionLastChanged = @"";
			theUser = @"";
		}
		else
		{
			itemFullPath = [itemString substringFromIndex:40];
			int wcPathLength = [workingCopyPath length];
			if ([itemFullPath length] > wcPathLength)
				++wcPathLength;
			itemPath = [itemFullPath substringFromIndex: wcPathLength];
			NSCharacterSet* ws = [NSCharacterSet whitespaceCharacterSet];
			revisionCurrent = [[itemString substringWithRange:NSMakeRange(9, 8)] stringByTrimmingCharactersInSet:ws];
			revisionLastChanged = [[itemString substringWithRange:NSMakeRange(18, 8)] stringByTrimmingCharactersInSet:ws];
			theUser = [[itemString substringWithRange:NSMakeRange(27, 12)] stringByTrimmingCharactersInSet:ws];
			
			if ( [self showUpdates] )
			{
				column5 = [itemString substringWithRange:NSMakeRange(7, 1)];
			
			} else
			{
				column5 = [itemString substringWithRange:NSMakeRange(4, 1)];
			}
		}
		
		column1 = [itemString substringWithRange:NSMakeRange(0, 1)];
		column2 = [itemString substringWithRange:NSMakeRange(1, 1)];
		column3 = [itemString substringWithRange:NSMakeRange(2, 1)];
		column4 = [itemString substringWithRange:NSMakeRange(3, 1)];

		column6 = [itemString substringWithRange:NSMakeRange(5, 1)]; 
		
		NSArray* pathArr = [itemPath componentsSeparatedByString:@"/"];
	//	NSMutableString* dirPath = [NSMutableString stringWithString:@"/"];

		if ( [column1 isEqualToString:@" "] )
		{
			removable = YES;
			renamable = YES;
			updatable = YES;
			copiable = YES;
			movable = YES;
		}		
		if ( [column1 isEqualToString:@"M"] || [column2 isEqualToString:@"M"] )
		{
			removable = YES;
			updatable = YES;
			revertable = YES;
			committable = YES;
		}
		if ( [column1 isEqualToString:@"?"] )
		{
			addable = YES;
			removable = YES;
			lockable = NO;
		}
		if ( [column1 isEqualToString:@"!"] )
		{
			revertable = YES;
			updatable = YES;
			removable = YES;
			lockable = NO;			
		}
		if ( [column1 isEqualToString:@"A"] )
		{
			revertable = YES;
			committable = YES;
		}
		if ( [column1 isEqualToString:@"D"] )
		{
			revertable = YES;
			committable = YES;
		}
		if ( [column1 isEqualToString:@"C"] )
		{
			revertable = YES;
			resolvable = YES;
		}
		if ( [column6 isEqualToString:@"K"] )
		{
			lockable = NO;
			unlockable = YES;
		}

		NSString* dirPath = [itemPath stringByDeletingLastPathComponent];
		BOOL isDir;
		
		if ( [[NSFileManager defaultManager] fileExistsAtPath:itemFullPath isDirectory:&isDir] && isDir )
		if ( ![itemPath isEqualToString:@""] )
		{
			id tmp = [outlineDirs objectForKey:@"children"]; // let's start at root
			
			for ( j=0; j<[pathArr count]; j++)
			{
				NSString *dirName = [pathArr objectAtIndex:j];
				NSEnumerator *enumerator = [tmp objectEnumerator];
				id obj;
				id child = nil;
				
				while ( obj = [enumerator nextObject] )
				{
					if ( [[obj objectForKey:@"name"] isEqualToString:dirName] )
					{
						child = obj;
						break;
					}
				}
				

				if ( child == nil )
				{						
					NSString *filePath = [[workingCopyPath stringByAppendingPathComponent:dirPath]
												stringByAppendingPathComponent:dirName];
					NSImage *dirIcon = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
					[dirIcon setSize:NSMakeSize(16,16)];
					[tmp addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSMutableArray array], @"children",
																					 dirName, @"name",
																					 itemPath, @"path",
																					 dirIcon, @"icon",
																					   nil]];
					tmp = [[tmp lastObject] objectForKey:@"children"];
					
//					[dirPath appendString:dirName];
//					[dirPath appendString:@"/"];

				} else
				{
					tmp = [child objectForKey:@"children"];
				}

			}
		}
		
		[newSvnFiles addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
									column1, @"col1",
									column2, @"col2",
									column3, @"col3",
									column4, @"col4",
									column5, @"col5",
									column6, @"col6",
									revisionCurrent, @"revisionCurrent",
									revisionLastChanged, @"revisionLastChanged",
									theUser, @"user",
									[[NSWorkspace sharedWorkspace] iconForFile:itemFullPath], @"icon",
									(([self flatMode])?(itemPath):([itemPath lastPathComponent])), @"displayPath",
									itemPath, @"path",
									itemFullPath, @"fullPath",
									dirPath, @"dirPath",
									[NSNumber numberWithBool:([column1 isEqualToString:@"M"] ? YES : FALSE)], @"modified",
									[NSNumber numberWithBool:([column1 isEqualToString:@"?"] ? YES : FALSE)], @"new",
									[NSNumber numberWithBool:([column1 isEqualToString:@"!"] ? YES : FALSE)], @"missing",
									[NSNumber numberWithBool:([column1 isEqualToString:@"A"] ? YES : FALSE)], @"added",
									[NSNumber numberWithBool:([column1 isEqualToString:@"D"] ? YES : FALSE)], @"deleted",

									[NSNumber numberWithBool:renamable], @"renamable",
									[NSNumber numberWithBool:addable], @"addable",
									[NSNumber numberWithBool:removable], @"removable",
									[NSNumber numberWithBool:updatable], @"updatable",
									[NSNumber numberWithBool:revertable], @"revertable",
									[NSNumber numberWithBool:committable], @"committable",
									[NSNumber numberWithBool:resolvable], @"resolvable",
									[NSNumber numberWithBool:lockable], @"lockable",
									[NSNumber numberWithBool:unlockable], @"unlockable",

									nil]];
		[pool release];
	}

	[self setSvnDirectories:outlineDirs];
	[self setSvnFiles:newSvnFiles];
}


- (void)computesVerboseResultArray
{
//	NSLog(@"computesVerboseResultArray '%@' flat=%d smart=%d", windowTitle, flatMode, smartMode);
	if (useOldParsingMethod())
	{
		[self computesOldVerboseResultArray];
	}
	else
	{
		[self computesNewVerboseResultArray];
	}
}


//----------------------------------------------------------------------------------------
#pragma mark svn info

- (void)fetchSvnInfo
{
	[MySvn    genericCommand: @"info"
				   arguments: [NSArray arrayWithObject:[self workingCopyPath]]
              generalOptions: [self svnOptionsInvocation]
					 options: nil
					callback: [self makeCallbackInvocationOfKind:SVNXCallbackSvnInfo]
				callbackInfo: nil
					taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];
}

- (void)svnInfoCompletedCallback:(id)taskObj
{
	if ( [[taskObj valueForKey:@"status"] isEqualToString:@"completed"] )
	{
		[self fetchSvnInfoReceiveDataFinished:[taskObj valueForKey:@"stdout"]];
		
	}

	[self svnError: taskObj];
}

- (void)fetchSvnInfoReceiveDataFinished:(NSString*)result
{
	NSArray *lines = [result componentsSeparatedByString:@"\n"];

	if ( [lines count] < 5 )
	{
		[controller svnError:result];
	
	} else
	{
		int i;

		for ( i=0; i<[lines count]; i++)
		{
			NSString *line = [lines objectAtIndex:i];
			
			if ( [line length] > 9 && [[line substringWithRange:NSMakeRange(0, 10)] isEqual:@"Revision: "] )
			{
				[self setRevision:[line substringFromIndex:10]];			
				//[self setStatusInfo:line];
			}
			else
			if ( [line length] > 4 && [[line substringWithRange:NSMakeRange(0, 5)] isEqual:@"URL: "] )
			{
				NSString *urlString = [line substringFromIndex:5];
				NSString *repositoryUrlString;
				
				if ( ![[urlString substringFromIndex:([urlString length]-1)] isEqualToString:@"/"] )
				{
					repositoryUrlString = [urlString stringByAppendingString:@"/"];

				} else repositoryUrlString = urlString;
				
				[self setRepositoryUrl:[NSURL URLWithString:repositoryUrlString]];
			}
//			else
//			if ( [line length] > 16 && [[line substringWithRange:NSMakeRange(0, 17)] isEqual:@"Repository Root: "] )
//			{
//				NSString *repositoryUrlString = [line substringFromIndex:17];
//				
//				[self setRepositoryUrl:[NSURL URLWithString:repositoryUrlString]];
//			}
					
		
		}
	}
}


//----------------------------------------------------------------------------------------
#pragma mark svn generic command

- (void)svnCommand:(NSString *)command options:(NSArray *)options info:(NSDictionary *)info
{
	NSMutableArray *itemsPaths = [NSMutableArray arrayWithArray:[[svnFilesAC selectedObjects] mutableArrayValueForKey:@"fullPath"]];
	if ( options == nil ) options = [NSArray array];

	[controller startProgressIndicator];
	
	if ( [command isEqualToString:@"rename"] )
	{
		[itemsPaths addObject:[info objectForKey:@"destination"]];

		[MySvn   genericCommand: @"move"
					  arguments: itemsPaths
                 generalOptions: [self svnOptionsInvocation]
						options: options
					   callback: [self makeCallbackInvocationOfKind:SVNXCallbackGeneric]
				   callbackInfo: nil
					   taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];
		
	} else
	if ( [command isEqualToString:@"move"] )
	{
		[MySvn     moveMultiple: itemsPaths
					destination: [info objectForKey:@"destination"]
                 generalOptions: [self svnOptionsInvocation]
						options: options
					   callback: [self makeCallbackInvocationOfKind:SVNXCallbackGeneric]
				   callbackInfo: nil
					   taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];
	
	} else
	if ( [command isEqualToString:@"copy"] )
	{
		[MySvn     copyMultiple: itemsPaths
					destination: [info objectForKey:@"destination"]
                 generalOptions: [self svnOptionsInvocation]
						options: options
					   callback: [self makeCallbackInvocationOfKind:SVNXCallbackGeneric]
				   callbackInfo: nil
					   taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];
		
	} else
	if ( [command isEqualToString:@"switch"] )
	{
		// it would be much more clean to use a specific [MySvn switch:... command.
		[self setDisplayedTaskObj:
			[MySvn   genericCommand: command
						  arguments: [NSArray array]
					 generalOptions: [self svnOptionsInvocation]
							options: options
						   callback: [self makeCallbackInvocationOfKind:SVNXCallbackGeneric]
					   callbackInfo: nil
						   taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]]
		];
		
	} else
	{
		id taskObj =
		[MySvn   genericCommand: command
					  arguments: itemsPaths
                 generalOptions: [self svnOptionsInvocation]
						options: options
					   callback: [self makeCallbackInvocationOfKind:SVNXCallbackGeneric]
				   callbackInfo: nil
					   taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];

		if ( [command isEqualToString:@"commit"] ) [self setDisplayedTaskObj:taskObj];
					   
	}
}

- (void)svnGenericCompletedCallback:(id)taskObj
{
	[controller stopProgressIndicator];

	if ( [[taskObj valueForKey:@"status"] isEqualToString:@"completed"] )
	{
		[self svnRefresh];		
	}

	[self svnError: taskObj];
}


//----------------------------------------------------------------------------------------
#pragma mark svn update

-(void) svnUpdate
{	
	[controller startProgressIndicator];
	
	[self setDisplayedTaskObj:[MySvn    updateAtWorkingCopyPath: [self workingCopyPath]
					   generalOptions: [self svnOptionsInvocation]
							  options: nil
							 callback: [self makeCallbackInvocationOfKind:SVNXCallbackSvnUpdate]
						 callbackInfo: nil
							 taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]]];
}

-(void)svnUpdateCompletedCallback:(id)taskObj
{
	[controller stopProgressIndicator];

	if ( [[taskObj valueForKey:@"status"] isEqualToString:@"completed"] )
	{
		[self svnRefresh];		
	}

	[self svnError: taskObj];
}


//----------------------------------------------------------------------------------------
#pragma mark FileMerge

-(void) fileMergeItems:(NSArray *)items
{	
	[MySvn	   fileMergeItems: items
			   generalOptions: [self svnOptionsInvocation]
					  options: nil
					 callback: [self makeCallbackInvocationOfKind:SVNXCallbackFileMerge]
				 callbackInfo: nil
					 taskInfo: [NSDictionary dictionaryWithObjectsAndKeys:[self windowTitle], @"documentName", nil]];
}

-(void)fileMergeCallback:(id)taskObj
{
	if ( [[taskObj valueForKey:@"status"] isEqualToString:@"completed"] )
		;

	[self svnError: taskObj];
}


//----------------------------------------------------------------------------------------
#pragma -
#pragma mark Helpers

- (NSMutableDictionary *)getSvnOptions
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys:[self user], @"user", [self pass], @"pass", nil ];
}

- (NSInvocation *) makeSvnOptionInvocation
{
	SEL getSvnOptions = @selector(getSvnOptions);
	
	NSInvocation *svnOptionsInvocation = [NSInvocation invocationWithMethodSignature:
												[MyWorkingCopy instanceMethodSignatureForSelector:getSvnOptions]];
	[svnOptionsInvocation setSelector:getSvnOptions];
	[svnOptionsInvocation setTarget:self];
	
	return svnOptionsInvocation;
}

- (NSInvocation *)makeCallbackInvocationOfKind:(int)callbackKind
{
	
	SEL callbackSelector;
	NSInvocation *callback;

	switch ( callbackKind )
	{
		case SVNXCallbackSvnUpdate:
		
			callbackSelector = @selector(svnUpdateCompletedCallback:);

		break;
		
		case SVNXCallbackSvnStatus:
		
			callbackSelector = @selector(svnStatusCompletedCallback:);

		break;
		
		case SVNXCallbackSvnInfo:
		
			callbackSelector = @selector(svnInfoCompletedCallback:);

		break;
		
		case SVNXCallbackGeneric:
		
			callbackSelector = @selector(svnGenericCompletedCallback:);
			
		break;
		
		case SVNXCallbackFileMerge:
			
			callbackSelector = @selector(fileMergeCallback:);
		
		break;
	}
	
	callback = [NSInvocation invocationWithMethodSignature:[MyWorkingCopy instanceMethodSignatureForSelector:callbackSelector]];
	[callback setSelector:callbackSelector];
	[callback setTarget:self];	

	return callback;
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Key-Value interface observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
//	NSLog(@"WC:observe: '%@'", keyPath);
	BOOL doRefresh = false,
		 doRearrange = false;

	if ( [keyPath isEqualToString:@"smartMode"] )
	{
		doRefresh = YES;
		if (smartMode)
			flatMode = YES;
		[controller adjustOutlineView];
	}
	else if ( [keyPath isEqualToString:@"flatMode"] )
	{
		doRefresh = YES;
		if (!flatMode)
			smartMode = NO;
	//	[controller adjustOutlineView];
	}
	else if ( [keyPath isEqualToString:@"outlineSelectedPath"] )
	{
		doRearrange = YES;
	}
	else if ( [keyPath isEqualToString:@"filterMode"] )
	{
		doRearrange = YES;
	}

	if (doRefresh)
		[self svnRefresh];
	else if (doRearrange)
		[svnFilesAC rearrangeObjects];
//	NSLog(@"WC:observe ---");
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Accessors

// ACCESSORS
//
- (NSInvocation *)svnOptionsInvocation
{
	return [self makeSvnOptionInvocation];
}

//  displayedTaskObj 
- (NSMutableDictionary *) displayedTaskObj {
    return displayedTaskObj; 
}
- (void) setDisplayedTaskObj: (NSMutableDictionary *) aDisplayedTaskObj {
    id old = [self displayedTaskObj];
    displayedTaskObj = [aDisplayedTaskObj retain];
    [old release];
}

// - user name:
- (NSString *) user { return user; }
- (void) setUser: (NSString *) aUser {
    id old = [self user];
    user = [aUser retain];
    [old release];
}

// - user password:
- (NSString *) pass { return pass; }
- (void) setPass: (NSString *) aPass {
    id old = [self pass];
    pass = [aPass retain];
    [old release];
}

- (NSArray *)svnFiles
{
	return svnFiles;
}
- (void)setSvnFiles:(NSMutableArray *)aSvnFiles
{
    if (svnFiles != aSvnFiles)
	{
        [svnFiles release];
        svnFiles = aSvnFiles ? [aSvnFiles mutableCopy] : nil;
    }
}

- (NSString *)resultString
{
	return resultString;
}
- (void)setResultString: (NSString *)str
{
	id old = resultString;
	resultString = [str retain];
	[old release];
}

- (NSString *)revision { return revision; }
- (void)setRevision:(NSString *)aRevision {
    id old = [self revision];
    revision = [aRevision retain];
    [old release];
}

- (NSString *)workingCopyPath
{
	return workingCopyPath;
}
- (void)setWorkingCopyPath: (NSString *)str
{
	id old = workingCopyPath;
	workingCopyPath = [str retain];
	[old release];
}

// - svnDirectories:
- (NSMutableDictionary *) svnDirectories { return svnDirectories; }

// - setSvnDirectories:
- (void) setSvnDirectories: (NSMutableDictionary *) aSvnDirectories {
    id old = [self svnDirectories];
    svnDirectories = [aSvnDirectories retain];
    [old release];
}



// filterMode : set by the toolbar dropdown menu
//
- (int) filterMode { return filterMode; }
- (void) setFilterMode: (int) aFilterMode
{
//	NSLog(@"setFilterMode: %d", aFilterMode);
    filterMode = aFilterMode;
}

// - windowTitle:
- (NSString *) windowTitle { return windowTitle; }

// - setWindowTitle:
- (void) setWindowTitle: (NSString *) aWindowTitle {
    id old = [self windowTitle];
    windowTitle = [aWindowTitle retain];
    [old release];
}

// - flatMode:
- (BOOL) flatMode { return flatMode; }
// - setFlatMode:
- (void) setFlatMode: (BOOL) flag {
    flatMode = flag;
}

// - smartMode:
- (BOOL) smartMode { return smartMode; }
// - setSmartMode:
- (void) setSmartMode: (BOOL) flag {
    smartMode = flag;
}

// - showUpdates:
- (BOOL)showUpdates { return showUpdates; }
// - setShowUpdates:
- (void)setShowUpdates:(BOOL)flag {
    showUpdates = flag;
}

// - outlineSelectedPath:
- (NSString *) outlineSelectedPath { return outlineSelectedPath; }

// - setOutlineSelectedPath:
- (void) setOutlineSelectedPath: (NSString *) anOutlineSelectedPath {
    id old = [self outlineSelectedPath];
    outlineSelectedPath = [anOutlineSelectedPath retain];
    [old release];
}

-(id)controller
{
	return controller;
}

// - repositoryUrl:
- (NSURL *)repositoryUrl { return repositoryUrl; }

	// - setRepositoryUrl:
- (void)setRepositoryUrl:(NSURL *)aRepositoryUrl {
    id old = [self repositoryUrl];
    repositoryUrl = [aRepositoryUrl retain];
    [old release];
}

// - statusInfo:
- (NSString *)statusInfo { return statusInfo; }

// - setStatusInfo:
- (void)setStatusInfo:(NSString *)aStatusInfo {
    id old = [self statusInfo];
    statusInfo = [aStatusInfo retain];
    [old release];
}

@end

