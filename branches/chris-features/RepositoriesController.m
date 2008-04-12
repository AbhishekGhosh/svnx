#import "RepositoriesController.h"
#import "MyDragSupportArrayController.h"
#import "MyRepository.h"
#import "NSString+MyAdditions.h"
#include "CommonUtils.h"


#define preferences [NSUserDefaults standardUserDefaults]


//----------------------------------------------------------------------------------------

static NSURL*
StringToURL (NSString* urlString)
{
	if ([urlString characterAtIndex: [urlString length] - 1] != '/')
		urlString = [urlString stringByAppendingString: @"/"];

	return [NSURL URLWithString: [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
}


//----------------------------------------------------------------------------------------

@implementation RepositoriesController

- (id)init
{
    self = [super init: @"rep"];
    if (self)
	{
		NSData *dataPrefs = [preferences objectForKey:@"repositories"];
		
		if ( dataPrefs != nil )
		{
			id repositoriesFromPrefs = [NSUnarchiver unarchiveObjectWithData:dataPrefs];
			
			if ( repositoriesFromPrefs != nil )
			{
				[self setRepositories:[NSMutableArray arrayWithArray:repositoriesFromPrefs]];
			
			} else
			{
				[self setRepositories:[NSMutableArray array]];
			}
		
		} else
		{
			[self setRepositories:[NSMutableArray array]];
		}
    }
    return self;
}

- (void)dealloc
{
//	[self removeObserver:self forKeyPath:@"repositories"];
    [self setRepositories: nil];

    [super dealloc];
}


- (void) savePreferences
{
	[self saveRepositoriesPrefs];
}


- (NSArray*) dataArray
{
	return repositories;
}


- (void)awakeFromNib
{
    [repositoriesAC bind:@"contentArray" toObject:self  withKeyPath:@"repositories" options:nil];

    [tableView registerForDraggedTypes:	[NSArray arrayWithObjects:@"COPIED_ROWS_TYPE", @"MOVED_ROWS_TYPE", NSURLPboardType, nil]];

//	[self addObserver:self forKeyPath:@"repositories" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];

	[super awakeFromNib];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//	[self saveRepositoriesPrefs];
//}
//

- (IBAction)newRepositoryItem:(id)sender
{
	[repositoriesAC addObject:
		[NSMutableDictionary dictionaryWithObjectsAndKeys: @"My Repository", @"name",
														   @"svn://", @"url",
														   @"", @"user",
														   @"", @"pass",
														   nil]];
	[repositoriesAC setSelectionIndex:([[repositoriesAC arrangedObjects] count]-1)];
	
	[window makeFirstResponder:nameTextField];	
}


- (BOOL) showExtantWindow: (NSString*) name
		 url:              (NSString*) urlString
{
	NSURL* url = StringToURL(urlString);

	NSEnumerator* enumerator = [[[NSDocumentController sharedDocumentController] documents] objectEnumerator];
	id obj;
	while (obj = [enumerator nextObject])
	{
		if ([[obj fileType] isEqualToString: @"repository"] &&
			[[obj windowTitle] isEqualToString: name] &&
			[[obj url] isEqual: url])
		{
			[[[[obj windowControllers] objectAtIndex: 0] window] makeKeyAndOrderFront: self];
			return TRUE;
		}
	}

	return FALSE;
}


- (void)onDoubleClick:(id)sender
{
	if ( [[repositoriesAC selectedObjects] count] != 0 )
	{
		NSString* const name = [repositoriesAC valueForKeyPath: @"selection.name"];
		NSString* const url  = [repositoriesAC valueForKeyPath: @"selection.url"];

		// If no option-key then look for & try to activate extant Repository window.
		if (([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) ||
			![self showExtantWindow: name url: url])
		{
			[self openRepositoryBrowser: url title: name
					user: [repositoriesAC valueForKeyPath: @"selection.user"]
					pass: [repositoriesAC valueForKeyPath: @"selection.pass"]];
		}
	}
}

-(void)openRepositoryBrowser:(NSString *)url title:(NSString *)title user:(NSString *)user pass:(NSString *)pass
{
	MyRepository *newDoc = [[NSDocumentController sharedDocumentController] makeUntitledDocumentOfType:@"repository"];	

	[newDoc setWindowTitle:title];
	[newDoc setUser:user];
	[newDoc setPass:pass];

	[newDoc setUrl: StringToURL(url)];
	[newDoc makeWindowControllers];

	[[NSDocumentController sharedDocumentController] addDocument:newDoc];

	[newDoc showWindows];
}

- (IBAction)openPath:(id)sender
{
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	NSString *selectionPath = nil;
	
	if (selectionPath == nil )
	{
		selectionPath = NSHomeDirectory();
	}
	
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];
	
	[oPanel beginSheetForDirectory:selectionPath file:nil types:nil modalForWindow:window
				modalDelegate: self
				didEndSelector:@selector(openPathDidEnd:returnCode:contextInfo:)
				contextInfo:nil
		];
}

- (void)openPathDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
 {
    NSString *pathToFile = nil;

    if (returnCode == NSOKButton) {

        pathToFile = [[[sheet filenames] objectAtIndex:0] copy];
		[repositoriesAC setValue:[NSString stringWithFormat:@"file://%@", pathToFile] forKeyPath:@"selection.url"];
		[self saveRepositoriesPrefs];

    }
}

#pragma mark -
#pragma mark Drag & drop


- (BOOL)tableView:(NSTableView *)tv
		writeRows:(NSArray*)rows
	 toPasteboard:(NSPasteboard*)pboard
{
	// declare our own pasteboard types
    NSArray *typesArray = [NSArray arrayWithObjects:@"COPIED_ROWS_TYPE", @"MOVED_ROWS_TYPE", nil];


	/*
	 If the number of rows is not 1, then we only support our own types.
	 If there is just one row, then try to create an NSURL from the url
	 value in that row.  If that's possible, add NSURLPboardType to the
	 list of supported types, and add the NSURL to the pasteboard.
	 */
	if ([rows count] != 1)
	{
		[pboard declareTypes:typesArray owner:self];
	}
	else
	{
		// Try to create an URL
		// If we can, add NSURLPboardType to the declared types and write
		//the URL to the pasteboard; otherwise declare existing types
		int row = [[rows objectAtIndex:0] intValue];
		NSString *urlString = [[[repositoriesAC arrangedObjects] objectAtIndex:row] valueForKey:@"url"];
		NSURL *url;
		if (urlString && (url = [NSURL URLWithString:urlString]))
		{
			typesArray = [typesArray arrayByAddingObject:NSURLPboardType];	
			[pboard declareTypes:typesArray owner:self];
			[url writeToPasteboard:pboard];	
		}
		else
		{
			[pboard declareTypes:typesArray owner:self];
		}
	}
	
    // add rows array for local move
    [pboard setPropertyList:rows forType:@"MOVED_ROWS_TYPE"];
	
	// create new array of selected rows for remote drop
    // could do deferred provision, but keep it direct for clarity
	NSMutableArray *rowCopies = [NSMutableArray arrayWithCapacity:[rows count]];    
	NSEnumerator *rowEnumerator = [rows objectEnumerator];
	NSNumber *idx;
	while (idx = [rowEnumerator nextObject])
	{
		[rowCopies addObject:[[repositoriesAC arrangedObjects] objectAtIndex:[idx intValue]]];
	}
	// setPropertyList works here because we're using dictionaries, strings,
	// and dates; otherwise, archive collection to NSData...
	[pboard setPropertyList:rowCopies forType:@"COPIED_ROWS_TYPE"];
	
    return YES;
}


- (NSDragOperation)tableView:(NSTableView*)tv
				validateDrop:(id <NSDraggingInfo>)info
				 proposedRow:(int)row
	   proposedDropOperation:(NSTableViewDropOperation)op
{
    
    NSDragOperation dragOp = NSDragOperationCopy;
	NSPasteboard *pboard = pboard;
    NSDragOperation sourceMask = [info draggingSourceOperationMask];

    // we want to put the object at, not over,
    // the current row (contrast NSTableViewDropOn) 
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];

	if ( sourceMask & NSDragOperationMove ) return NSDragOperationMove;
	if ( sourceMask & NSDragOperationCopy ) return NSDragOperationCopy;
    
    // default
    return NSDragOperationNone;
}



- (BOOL)tableView:(NSTableView*)tv
	   acceptDrop:(id <NSDraggingInfo>)info
			  row:(int)row
	dropOperation:(NSTableViewDropOperation)op
{
    NSPasteboard *pboard = [info draggingPasteboard];
    NSDragOperation sourceMask = [info draggingSourceOperationMask];

    if (row < 0)
	{
		row = 0;
	}
    
    // if drag source is self, it's a move
	if ( sourceMask & NSDragOperationMove )
	{
//    if ([info draggingSource] == tableView)
//    {

		NSArray *rows = [pboard propertyListForType:@"MOVED_ROWS_TYPE"];
		NSIndexSet  *indexSet = [repositoriesAC indexSetFromRows:rows];
		
		[repositoriesAC moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
		
		// set selected rows to those that were just moved
		// Need to work out what moved where to determine proper selection...
		int rowsAbove = [repositoriesAC rowsAboveRow:row inIndexSet:indexSet];
		
		NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
		indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
		[repositoriesAC setSelectionIndexes:indexSet];

		[self saveRepositoriesPrefs];

		return YES;
    }
	else if ( sourceMask & NSDragOperationCopy )
	{
		// Can we get rows from another document?  If so, add them, then return.
		NSArray *newRows = [pboard propertyListForType:@"COPIED_ROWS_TYPE"];
		if (newRows)
		{
			NSRange range = NSMakeRange(row, [newRows count]);
			NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
			
			[repositoriesAC insertObjects:newRows atArrangedObjectIndexes:indexSet];
			// set selected rows to those that were just copied
			[repositoriesAC setSelectionIndexes:indexSet];

			[self saveRepositoriesPrefs];
			
			return YES;
		}
	} 
	
		// Can we get an URL?  If so, add a new row, configure it, then return.
		NSURL *url = [NSURL URLFromPasteboard:pboard];
		if (url)
		{
			id newObject = [repositoriesAC newObject];	
			[repositoriesAC insertObject:newObject atArrangedObjectIndex:row];
			// "new" -- returned with retain count of 1
			[newObject release];
			[newObject takeValue:[url absoluteString] forKey:@"url"];
			[newObject takeValue:[NSCalendarDate date] forKey:@"date"];
			// set selected rows to those that were just copied
			[repositoriesAC setSelectionIndex:row];

			[self saveRepositoriesPrefs];
			
			return YES;		
		}

    return NO;
}



#pragma mark -
#pragma mark Prefs saving

- (IBAction)onValidate:(id)sender
/*" see Interface builder's text fields "*/
{
	[self saveRepositoriesPrefs];
}

- (void)saveRepositoriesPrefs
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:[NSArchiver archivedDataWithRootObject:[self repositories]] forKey:@"repositories"];
	[prefs setObject: NSBool([[self disclosureView] state]) forKey: @"repEditShown"];
	[prefs synchronize];
}

#pragma mark -
#pragma mark Accessors

- (void) insertObject:(id)anObject inRepositoriesAtIndex: (unsigned int)index {

    [repositories insertObject: anObject atIndex: index];
	[self saveRepositoriesPrefs];
}

- (void) removeObjectFromRepositoriesAtIndex: (unsigned int)index {
    [repositories removeObjectAtIndex: index];
	[self saveRepositoriesPrefs];
}

- (void) replaceObjectInRepositoriesAtIndex: (unsigned int)index withObject: (id)anObject {
    [repositories replaceObjectAtIndex: index withObject: anObject];
	[self saveRepositoriesPrefs];	
}

// - repositories:
- (NSMutableArray *)repositories {
    return repositories; 
}

// - setRepositories:
- (void)setRepositories:(NSMutableArray *)aRepositories {
    id old = [self repositories];
    repositories = [aRepositories retain];
    [old release];
}

@end
