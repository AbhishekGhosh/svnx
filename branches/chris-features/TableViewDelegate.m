#import "TableViewDelegate.h"
#import "MyWorkingCopy.h"
#import "MyWorkingCopyController.h"


enum { kFirstColumn = 1, kNumColumns = 8 };
static NSDictionary*   helpTags[kNumColumns + 1] = { nil };
static NSString* const colKeys[kNumColumns + 1]  = { nil, @"col1", @"col2", @"col3", @"col4", @"col5", @"col6", @"col7", @"col8" };


@implementation TableViewDelegate

- init
{
	if (helpTags[1] == NULL)
	{
	//	NSLog(@"TableViewDelegate -init");
		// Item changes
		helpTags[1] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"No modifications.", @" ", 
			@"Item is scheduled for Addition.", @"A", 
			@"Item is scheduled for Deletion.", @"D", 
			@"Item has been modified.", @"M", 
			@"Item has been replaced in your working copy. This means the file was scheduled for deletion,"
			 " and then a new file with the same name was scheduled for addition in its place.", @"R", 
			@"The contents (as opposed to the properties) of the item conflict with updates received from the repository.", @"C", 
			@"Item is related to an externals definition.", @"X", 
			@"Item is being ignored (e.g. with the svn:ignore property).", @"I", 
			@"Item is not under version control.", @"?", 
			@"Item is missing (e.g. you moved or deleted it without using svn)."
			 " This also indicates that a directory is incomplete (a checkout or update was interrupted).", @"!", 
			@"Item is versioned as one kind of object (file, directory, link), but has been replaced by different kind of object.", @"~", 
			nil];

		// Properties
		helpTags[2] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"No property modifications.", @" ", 
			@"Properties for this item have been modified.", @"M",
			@"Properties for this item are in conflict with property updates received from the repository.", @"C",
			nil];

		// Working copy directory is locked
		helpTags[3] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Item is not locked.", @" ", 
			@"Item is locked. (You may want to run svn clean up!)", @"L",
			nil];

		// Scheduled for addition-with-history
		helpTags[4] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"No history scheduled with commit.", @" ", 
			@"History scheduled with commit.", @"+",
			nil];

		// Switched
		helpTags[5] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Item is a child of its parent directory.", @" ", 
			@"Item is switched.", @"S",
			nil];

		// Lock
		helpTags[6] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"File is not locked in this working copy.", @" ", 
			@"File is locked in this working copy.", @"K",
			@"File is locked either by another user or in another working copy.", @"O",
			@"File was locked in this working copy, but the lock has been “stolen” and is invalid."
			 " The file is currently locked in the repository.", @"T",
			@"File was locked in this working copy, but the lock has been “broken” and is invalid."
			 " The file is no longer locked.", @"B",
			nil];

		// Out-of-date information
		helpTags[7] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Item is up-to-date.", @" ",
			@"A newer revision of the item exists on the server.", @"*",
			nil];

		helpTags[8] = [NSDictionary dictionaryWithObjectsAndKeys:
			@"File has properties", @"P",
			@"File doesn't have any properties.", @" ",
			nil];

		int i;
		for (i = kFirstColumn; i <= kNumColumns; ++i)
			[helpTags[i] retain];
	}

	return [super init];
}

- (BOOL)tableView:(NSTableView *)tableView writeRows:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard 
{
	NSArray *selectedObjects = [svnFilesAC selectedObjects];
	NSMutableArray *filePaths = [NSMutableArray arrayWithCapacity:[selectedObjects count]];
	NSEnumerator *en = [rows objectEnumerator];
	NSEnumerator *pathsEnumerator = [selectedObjects objectEnumerator];
	id object;

	while ( object = [pathsEnumerator nextObject] )
	{
		[filePaths addObject:[object objectForKey:@"fullPath"]];
	}
	
	// Dragging only works in non flatMode :
	
	if ([document flatMode] == true )
	{
		[pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
	
	} else
	{
		[pboard declareTypes:[NSArray arrayWithObjects:@"svnX", NSFilenamesPboardType, nil] owner:nil];

		// Let's prevent the user from dragging non selected items
		//
		while ( object = [en nextObject] )
		{
			if ( ![tableView isRowSelected:[object intValue]] ) return FALSE;
		}
	}

    [pboard setPropertyList:filePaths forType:NSFilenamesPboardType];
	
	return YES;

}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	[[document controller] requestSvnRenameSelectedItemTo:[ [[document workingCopyPath] stringByAppendingPathComponent:[document outlineSelectedPath]]
								stringByAppendingPathComponent:[fieldEditor string]]];
	return FALSE;
}

- (NSString*) tableView:      (NSTableView*)   aTableView
			  toolTipForCell: (NSCell*)        aCell
			  rect:           (NSRectPointer)  rect
			  tableColumn:    (NSTableColumn*) aTableColumn
			  row:            (int)            row
			  mouseLocation:  (NSPoint)        mouseLocation
{
	const int colID = [[aTableColumn identifier] intValue];

	if (colID >= kFirstColumn && colID <= kNumColumns)
	{
	//	NSLog(@"tableView %d: helpTags=%@ colKeys=%@", colID, helpTags[colID], colKeys[colID]);
		NSDictionary* rowDict = [[svnFilesAC arrangedObjects] objectAtIndex: row];
		return [helpTags[colID] objectForKey: [rowDict objectForKey: colKeys[colID]]];
	}
	else if ([[aTableColumn identifier] isEqual: @"path"])
	{
		NSMutableString* help = [NSMutableString stringWithCapacity: 0];
		NSDictionary* rowDict = [[svnFilesAC arrangedObjects] objectAtIndex: row];
		int i;
		for (i = kFirstColumn; i <= kNumColumns; ++i)
		{
			NSString* str = [helpTags[i] objectForKey: [rowDict objectForKey: colKeys[i]]];
			if (str)
			{
				if ([help length])
					[help appendFormat: @"\n%@", str];
				else
					[help appendString: str];
			}
		}
		return help;
	}

	return @"";
}

-(id)document
{
	return document;
}


@end
