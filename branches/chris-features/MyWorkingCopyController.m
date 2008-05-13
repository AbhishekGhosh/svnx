#import "MyWorkingCopyController.h"
#import "MyWorkingCopy.h"
#import "MyApp.h"
#import "MyFileMergeController.h"
#import "DrawerLogView.h"
#import "NSString+MyAdditions.h"
#include "CommonUtils.h"


enum {
	vFlatTable	=	2000,
	vTreeTable	=	2002
};

enum {
	kModeTree	=	0,
	kModeFlat	=	1,
	kModeSmart	=	2
};

typedef NSString* const ConstString;
static ConstString keyWCWidows    = @"wcWindows",
				   keyWidowFrame  = @"winFrame",
				   keyViewMode    = @"viewMode",
				   keyFilterMode  = @"filterMode",
				   keyShowToolbar = @"showToolbar";
static NSString* gInitName = nil;


//----------------------------------------------------------------------------------------

static NSMutableDictionary*
makeCommandDict (NSString* command, NSString* destination)
{
	return [NSMutableDictionary dictionaryWithObjectsAndKeys: command, @"command",
															  command, @"verb",
															  destination, @"destination",
															  nil];
}


//----------------------------------------------------------------------------------------
#pragma mark -
//----------------------------------------------------------------------------------------

@implementation MyWorkingCopyController


//----------------------------------------------------------------------------------------

+ (void) presetDocumentName: name
{
	gInitName = name;
}


//----------------------------------------------------------------------------------------

- (void) awakeFromNib
{
	isDisplayingErrorSheet = NO;
	[self setStatusMessage: @""];

	[document   addObserver:self forKeyPath:@"flatMode"
				options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];

	[drawerLogView setDocument:document];
	[drawerLogView setUp];

	NSTableView* tableView = [[window contentView] viewWithTag: vFlatTable];
	[[[tableView tableColumnWithIdentifier: @"path"] dataCell] setDrawsBackground: NO];

	[self setNextResponder: [tableView nextResponder]];
	[tableView setNextResponder: self];

	NSUserDefaults* const prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary* wcWindows = [prefs dictionaryForKey: keyWCWidows];
	if (wcWindows != nil)
	{
		NSDictionary* settings = [wcWindows objectForKey: gInitName];
		if (settings != nil)
		{
			if (![[settings objectForKey: keyShowToolbar] boolValue])
				[[window toolbar] setVisible: NO];

			ConstString widowFrame = [settings objectForKey: keyWidowFrame];
			if (widowFrame != nil)
				[window setFrameFromString: widowFrame];
		}
	}

	[self adjustOutlineView];
}


//----------------------------------------------------------------------------------------

- (void) dealloc
{
	[savedSelection release];
	[super dealloc];
}


//----------------------------------------------------------------------------------------
// Called after 'document' is setup

- (void) setup
{
	int viewMode   = kModeSmart;
	int filterMode = kFilterAll;

	NSUserDefaults* const prefs = [NSUserDefaults standardUserDefaults];
	NSDictionary* wcWindows = [prefs dictionaryForKey: keyWCWidows];
	if (wcWindows != nil)
	{
		ConstString nameKey = [document windowTitle];
		NSDictionary* settings = [wcWindows objectForKey: nameKey];
		if (settings != nil)
		{
			viewMode    = [[settings objectForKey: keyViewMode] intValue];
			filterMode  = [[settings objectForKey: keyFilterMode] intValue];
		//	searchStr   = [settings objectForKey: keySearchStr];
		}
	}

	[modeView setIntValue: viewMode];
	[self setCurrentMode: viewMode];
	if (viewMode == kModeSmart)		// Force refresh as mode is default & thus hasn't changed so won't auto-refresh
		[document svnRefresh];
	[filterView selectItemWithTag: filterMode];
	[document setFilterMode: filterMode];

	[window makeKeyAndOrderFront: self];
	[self savePrefs];

	[window setDelegate: self];		// for windowDidMove & windowDidResize messages
}


//----------------------------------------------------------------------------------------

- (void) windowDidBecomeKey: (NSNotification*) notification
{
	#pragma unused(notification)
	if (!svnStatusPending && GetPreferenceBool(@"autoRefreshWC"))
	{
		[document svnRefresh];
	}
}


//----------------------------------------------------------------------------------------

- (void) windowDidMove: (NSNotification*) notification
{
	#pragma unused(notification)
	[self savePrefs];
}


//----------------------------------------------------------------------------------------

- (void) windowDidResize: (NSNotification*) notification
{
	#pragma unused(notification)
	[self savePrefs];
}


//----------------------------------------------------------------------------------------

- (void) savePrefs
{
	NSUserDefaults* const prefs = [NSUserDefaults standardUserDefaults];

	BOOL showToolbar = [[window toolbar] isVisible];
	NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
								[window stringWithSavedFrame],                   keyWidowFrame,
								[NSNumber numberWithInt: [self currentMode]],    keyViewMode,
								[NSNumber numberWithInt: [document filterMode]], keyFilterMode,
								NSBool(showToolbar),  keyShowToolbar,
								nil];

	ConstString nameKey = [document windowTitle];
	NSDictionary* wcWindows = [prefs dictionaryForKey: keyWCWidows];
	if (wcWindows == nil)
	{
		wcWindows = [NSDictionary dictionaryWithObject: settings forKey: nameKey];
	}
	else
	{
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary: wcWindows];
		[dict setObject: settings forKey: nameKey];
		wcWindows = dict;
	}

	[prefs setObject: wcWindows forKey: keyWCWidows];
//	[prefs synchronize];
}


//----------------------------------------------------------------------------------------

- (void) observeValueForKeyPath: (NSString*)     keyPath
		 ofObject:               (id)            object
		 change:                 (NSDictionary*) change
		 context:                (void*)         context
{
	#pragma unused(object, change, context)
	if ( [keyPath isEqualToString:@"flatMode"] )
	{
		[self adjustOutlineView];
	}
}


//----------------------------------------------------------------------------------------

- (void) cleanup
{
	[document removeObserver: self forKeyPath: @"flatMode"];

	DrawerLogView* obj = drawerLogView;
	drawerLogView = nil;
	[obj unload];
}


//----------------------------------------------------------------------------------------

- (void) keyDown: (NSEvent*) theEvent
{
	const unichar ch = [[theEvent charactersIgnoringModifiers] characterAtIndex: 0];

	if (ch == '\r' || ch == 3)
		[self doubleClickInTableView: nil];
	else if (ch >= ' ')
	{
		NSTableView* const tableView = [[window contentView] viewWithTag: vFlatTable];
		NSArray* const dataArray = [svnFilesAC arrangedObjects];
		const int rows = [dataArray count];
		int i, selRow = [svnFilesAC selectionIndex];
		if (selRow == NSNotFound)
			selRow = rows - 1;
		const unichar ch0 = (ch >= 'a' && ch <= 'z') ? (ch - 32) : ch;
		for (i = 1; i <= rows; ++i)
		{
			int index = (selRow + i) % rows;
			id wc = [dataArray objectAtIndex: index];
			NSString* name = [wc objectForKey: @"displayPath"];
			if ([name length] && ([name characterAtIndex: 0] & ~0x20) == ch0)
			{
				[tableView selectRow: index byExtendingSelection: false];
				[tableView scrollRowToVisible: index];
				break;
			}
		}
	}
	else
		[super keyDown: theEvent];
}


//----------------------------------------------------------------------------------------

- (void) saveSelection
{
	if ([[svnFilesAC arrangedObjects] count] > 0)
	{
		if (savedSelection != nil)
		{
			[savedSelection release];
			savedSelection = nil;
		}

		NSArray* const selectedObjects = [svnFilesAC selectedObjects];
		const int count = [selectedObjects count];
		if (count > 0)
		{
			NSMutableArray* files = [NSMutableArray arrayWithCapacity: count];
			NSEnumerator* it = [selectedObjects objectEnumerator];
			NSDictionary* dict;
			while (dict = [it nextObject])
				[files addObject: [dict objectForKey: @"fullPath"]];
			savedSelection = [files retain];
		}
	}
//	NSLog(@"savedSelection=%@", savedSelection);
}


//----------------------------------------------------------------------------------------

- (void) restoreSelection
{
//	NSLog(@"restoreSelection=%@ tree='%@'", savedSelection, [document outlineSelectedPath]);
	if (savedSelection != nil)
	{
		NSArray* const wcFiles = [svnFilesAC arrangedObjects];
		NSMutableIndexSet* sel = [NSMutableIndexSet indexSet];

		NSEnumerator* it = [savedSelection objectEnumerator];
		NSString* fullPath;
		while (fullPath = [it nextObject])
		{
			NSEnumerator* wcIt = [wcFiles objectEnumerator];
			NSDictionary* dict;
			int index = 0;
			while (dict = [wcIt nextObject])
			{
				if ([fullPath isEqualToString: [dict objectForKey: @"fullPath"]])
				{
					[sel addIndex: index];
					break;
				}
				++index;
			}
		}

		if ([sel count])
			[svnFilesAC setSelectionIndexes: sel];

		[savedSelection release];
		savedSelection = nil;
	}
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark IBActions
//----------------------------------------------------------------------------------------

- (IBAction) openAWorkingCopy: (id) sender
{
	#pragma unused(sender)
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];

	[oPanel beginSheetForDirectory:NSHomeDirectory() file:nil types:nil modalForWindow:[self window]
				modalDelegate: self
				didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:)
				contextInfo:nil
		];
}


- (void) openPanelDidEnd: (NSOpenPanel*) sheet
		 returnCode:      (int)          returnCode
		 contextInfo:     (void*)        contextInfo
{
	#pragma unused(contextInfo)
	if (returnCode == NSOKButton)
	{
		NSString* pathToFile = [[[sheet filenames] objectAtIndex:0] copy];

		[document setWorkingCopyPath: pathToFile];
		[document svnRefresh];
	}
}


- (IBAction) refresh: (id) sender
{
	#pragma unused(sender)
	if (!svnStatusPending)
		[document svnRefresh];
}


- (IBAction) toggleView: (id) sender
{
	#pragma unused(sender)
	//[[self document] setFlatMode:!([[self document] flatMode])];

//	[self adjustOutlineView];
}


//----------------------------------------------------------------------------------------
// Add, Delete, Update, Revert, Resolved, Lock, Unlock, Commit

static NSString* const gCommands[] = {
	@"add", @"remove", @"update", @"revert", @"resolved", @"lock", @"unlock", @"commit"
};

static NSString* const gVerbs[] = {
	@"add", @"remove", @"update", @"revert", @"resolve", @"lock", @"unlock", @"commit"
};


//----------------------------------------------------------------------------------------

- (IBAction) performAction: (id) sender
{
	const unsigned int action = [[sender selectedCell] tag];
	if (action < sizeof(gCommands) / sizeof(gCommands[0]))
	{
		[self performSelector: @selector(runAlertBeforePerformingAction:)
			  withObject: [NSDictionary dictionaryWithObjectsAndKeys: gCommands[action], @"command",
																	  gVerbs[action], @"verb", nil]
			  afterDelay: 0];
	}
}


//----------------------------------------------------------------------------------------
// If there is a single selected item then return it else return nil.
// Private:

- (NSDictionary*) selectedItemOrNil
{
	NSArray* const selectedObjects = [svnFilesAC selectedObjects];
	return ([selectedObjects count] == 1) ? [selectedObjects objectAtIndex: 0] : nil;
}


//----------------------------------------------------------------------------------------

- (void) doubleClickInTableView: (id) sender
{
	#pragma unused(sender)
	NSDictionary* selection;
	if (selection = [self selectedItemOrNil])
	{
		[[NSWorkspace sharedWorkspace] openFile: [selection objectForKey: @"fullPath"]];
	}
}


- (void) adjustOutlineView
{
	[document setSvnFiles: nil];
	int tag;
	if ([document flatMode])
	{
		[self closeOutlineView];
		tag = vFlatTable;
	}
	else
	{
		[self openOutlineView];
		tag = vTreeTable;
	}
	[window makeFirstResponder: [[window contentView] viewWithTag: tag]];
}


- (void) openOutlineView
{
	NSView* leftView = [[splitView subviews] objectAtIndex: 0];

	NSRect frame = [splitView frame];
	frame.origin.x = 0;
	frame.size.width = [[splitView superview] frame].size.width;
	[splitView setFrame: frame];

	frame = [leftView frame];
	frame.size.width = 200;
	[leftView setFrame: frame];
	[leftView setHidden: NO];

	[splitView adjustSubviews];
	[splitView setNeedsDisplay: YES];
}


- (void) closeOutlineView
{
	NSView* leftView = [[splitView subviews] objectAtIndex: 0];

	const GCoord kSplitterWidth = [splitView dividerThickness];
	NSRect frame = [splitView frame];
	frame.origin.x = -kSplitterWidth;
	frame.size.width = [[splitView superview] frame].size.width + kSplitterWidth;
	[splitView setFrame: frame];

	frame = [leftView frame];
	frame.size.width = 0;
	[leftView setFrame: frame];
	[leftView setHidden: YES];

	[splitView adjustSubviews];
	[splitView setNeedsDisplay: YES];
}


- (void) fetchSvnStatus
{
	[self startProgressIndicator];

	[document fetchSvnStatus: AltOrShiftPressed()];
}


- (void) fetchSvnInfo
{
	[self startProgressIndicator];

	[document fetchSvnInfo];
}


//- (void) fetchSvnStatusReceiveDataFinished
//{
//	[self stopProgressIndicator];
//	[textResult setString:[[self document] resultString]];
//	
//	svnStatusPending = NO;
//}


- (void) fetchSvnStatusVerboseReceiveDataFinished
{
	[self stopProgressIndicator];

	BOOL expandChildren = [GetPreference(@"expandWCTree") boolValue];
	NSIndexSet *selectedRows = [outliner selectedRowIndexes];
	[outliner setIndentationPerLevel: 8];
	[outliner reloadData];
	[outliner expandItem: [outliner itemAtRow: 0] expandChildren: expandChildren];
	[outliner selectRowIndexes: selectedRows byExtendingSelection: NO];
	if ( [selectedRows count] )
		[outliner scrollRowToVisible:[selectedRows firstIndex]];

	svnStatusPending = NO;
}


//----------------------------------------------------------------------------------------
// Filter mode

- (void) setFilterMode: (int) mode
{
	[document setFilterMode: mode];
	[self savePrefs];
}


- (IBAction)changeFilter:(id)sender
{
	int tag = [[sender selectedItem] tag];																		

	[self setFilterMode: tag];
}


//----------------------------------------------------------------------------------------

- (IBAction) openRepository: (id) sender
{
	#pragma unused(sender)
	[[NSApp delegate] openRepository: [document repositoryUrl] user: [document user] pass: [document pass]];
}


- (IBAction) toggleSidebar: (id) sender
{
	#pragma unused(sender)
	[sidebar toggle:sender];
}


//----------------------------------------------------------------------------------------
// View mode

- (IBAction) changeMode: (id) sender
{
//	NSLog(@"changeMode: %@ tag=%d", sender, [sender tag]);
	[self setCurrentMode: [sender tag] % 10];	// kModeTree, kModeFlat or kModeSmart
}


//----------------------------------------------------------------------------------------
// View mode

- (int) currentMode
{
	return [document smartMode] ? kModeSmart : ([document flatMode] ? kModeFlat : kModeTree);
}


//----------------------------------------------------------------------------------------
// View mode

- (void) setCurrentMode: (int) mode
{
//	NSLog(@"setCurrentMode: %d", mode);
	if ([self currentMode] != mode)
	{
		[self saveSelection];
		switch (mode)
		{
			case kModeTree:
				if ([document flatMode])
					[document setFlatMode: false];
				break;

			case kModeFlat:
				if ([document smartMode])
					[document setSmartMode: false];
				else if (![document flatMode])
					[document setFlatMode: true];
				break;

			case kModeSmart:
				if (![document smartMode])
					[document setSmartMode: true];
				break;
		}
		[self savePrefs];
	}
}


//----------------------------------------------------------------------------------------

- (void) setStatusMessage: (NSString*) message
{
	id obj = message ? (id) message : [document repositoryUrl];
	if (obj)
		[statusView setStringValue: message ? message : PathWithRevision(obj, [document revision])];
	else
		[self performSelector: @selector(setStatusMessage:) withObject: nil afterDelay: 0.5];	// try later
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Split View delegate
//----------------------------------------------------------------------------------------

- (BOOL) splitView:          (NSSplitView*) sender
		 canCollapseSubview: (NSView*)      subview
{
	#pragma unused(sender)
	NSView *leftView = [[splitView subviews] objectAtIndex:0];
	
	if ( subview == leftView )
	{
		return NO; // I would like to return YES here, but can't find a way to uncollapse a view programmatically.
				   // Collasping a view is obviously not setting its width to 0 ONLY.
				   // If I allow user collapsing here, I won't be able to expand the left view with the "toggle button"
				   // (it will remain closed, in spite of a size.width > 0);
	}

	return NO;
}


- (GCoord) splitView:              (NSSplitView*) sender
		   constrainMaxCoordinate: (GCoord)       proposedMax
		   ofSubviewAt:            (int)          offset
{
	#pragma unused(sender)
	return proposedMax * (offset ? 1.0 : 0.5);	// max tree width = .5 * window-width
}


- (GCoord) splitView:              (NSSplitView*) sender
		   constrainMinCoordinate: (GCoord)       proposedMin
		   ofSubviewAt:            (int)          offset
{
	#pragma unused(sender)
	return offset ? proposedMin : 140;			// min tree width = 140
}


- (void) splitView:                 (NSSplitView*) sender
		 resizeSubviewsWithOldSize: (NSSize)       oldSize
{
	#pragma unused(oldSize)
	// how to resize a horizontal split view so that the left frame stays a constant size
	NSView *left = [[sender subviews] objectAtIndex:0];			// get the two sub views
	NSView *right = [[sender subviews] objectAtIndex:1];
	GCoord dividerThickness = [sender dividerThickness];		// and the divider thickness
	NSRect newFrame = [sender frame];							// get the new size of the whole splitView
	NSRect leftFrame = [left frame];							// current size of the left subview
	NSRect rightFrame = [right frame];							// ...and the right
	leftFrame.size.height = newFrame.size.height;				// resize the height of the left
	leftFrame.origin = NSMakePoint(0,0);						// don't think this is needed
	rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;  // the rest of the width
	rightFrame.size.height = newFrame.size.height;				// the whole height
	rightFrame.origin.x = leftFrame.size.width + dividerThickness;
	[left setFrame:leftFrame];
	[right setFrame:rightFrame];
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Svn Operation Requests
//----------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
#pragma mark	svn update

- (void) svnUpdate: (id) sender
{
	#pragma unused(sender)
	[[NSAlert alertWithMessageText: @"Update this working copy to the latest revision?"
					 defaultButton: @"OK"
				   alternateButton: @"Cancel"
					   otherButton: nil
		 informativeTextWithFormat: @""]

		beginSheetModalForWindow: [self window]
				   modalDelegate: self
				  didEndSelector: @selector(updateWorkingCopyPanelDidEnd:returnCode:contextInfo:)
					 contextInfo: NULL];					 
}


- (void) updateWorkingCopyPanelDidEnd: (NSAlert*) alert
		 returnCode:                   (int)      returnCode
		 contextInfo:                  (void*)    contextInfo
{
	#pragma unused(alert, contextInfo)
	if ( returnCode == 0 ) return;

	[document performSelector: @selector(svnUpdate) withObject: nil afterDelay: 0.1];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn diff

- (void) fileHistoryOpenSheetForItem: (id) item
{
	// close the sheet if it is already open
	if ([window attachedSheet])
		[NSApp endSheet: [window attachedSheet]];

	[MyFileMergeController runDiffSheet: document path: [item objectForKey: @"fullPath"]
						   sourceItem: item];
}


- (void) svnFileMerge: (id) sender
{
	#pragma unused(sender)
	if (AltOrShiftPressed())
	{
		NSDictionary* selection;
		if (selection = [self selectedItemOrNil])
		{
			[self fileHistoryOpenSheetForItem: selection];
		}
		else
		{
			[self svnError: @"Please select exactly one item."];
		}
	}
	else
	{
		[document diffItems: [[svnFilesAC selectedObjects] valueForKey: @"fullPath"]];
	}
}


- (void) sheetDidEnd: (NSWindow*) sheet
		 returnCode:  (int)       returnCode
		 contextInfo: (void*)     contextInfo
{
	[sheet orderOut: nil];

	if ( returnCode == 1 )
	{
	}

	[(MyFileMergeController*) contextInfo finished];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn rename

- (void) requestSvnRenameSelectedItemTo: (NSString*) destination
{
	[self runAlertBeforePerformingAction: makeCommandDict(@"rename", destination)];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn move

- (void) requestSvnMoveSelectedItemsToDestination: (NSString*) destination
{
	NSMutableDictionary* action = makeCommandDict(@"move", destination);

	NSDictionary* selection;
	if (selection = [self selectedItemOrNil])
	{
		[renamePanel setTitle: @"Move and rename"];
		[renamePanelTextField setStringValue: [[selection valueForKey: @"path"] lastPathComponent]];
		[NSApp beginSheet:     renamePanel
			   modalForWindow: [self window]
			   modalDelegate:  self
			   didEndSelector: @selector(renamePanelDidEnd:returnCode:contextInfo:)
			   contextInfo:    [action retain]];
	}
	else
		[self runAlertBeforePerformingAction: action];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn copy

- (void) requestSvnCopySelectedItemsToDestination: (NSString*) destination
{
	NSMutableDictionary* action = makeCommandDict(@"copy", destination);

	NSDictionary* selection;
	if (selection = [self selectedItemOrNil])
	{
		[renamePanel setTitle: @"Copy and rename"];
		[renamePanelTextField setStringValue: [[selection valueForKey: @"path"] lastPathComponent]];
		[NSApp beginSheet:     renamePanel
			   modalForWindow: [self window]
			   modalDelegate:  self
			   didEndSelector: @selector(renamePanelDidEnd:returnCode:contextInfo:)
			   contextInfo:    [action retain]];
	}
	else
		[self runAlertBeforePerformingAction: action];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn copy & svn move common 

- (void) renamePanelDidEnd: (NSWindow*) sheet
		 returnCode:        (int)       returnCode
		 contextInfo:       (void*)     contextInfo
{
	[sheet orderOut:nil];
	NSMutableDictionary *action = contextInfo;
	
	[action setObject:[[(id) contextInfo objectForKey:@"destination"]
					stringByAppendingPathComponent:[renamePanelTextField stringValue]] forKey:@"destination"];
	
	if ( returnCode == 1 )
	{
		[self runAlertBeforePerformingAction:action];
	}
	
	[action release];																					
}


- (IBAction) renamePanelValidate: (id) sender
{
	[NSApp endSheet:renamePanel returnCode:[sender tag]];
}


//----------------------------------------------------------------------------------------
// called from MyDragSupportWindow
#pragma mark	svn switch

- (void) requestSwitchToRepositoryPath: (NSDictionary*) repositoryPathObj
{
//	NSLog(@"%@", repositoryPathObj);
	NSString *path = [repositoryPathObj valueForKeyPath:@"url.absoluteString"];
	NSString *revision = [repositoryPathObj valueForKey:@"revision"];

	NSMutableDictionary* action = makeCommandDict(@"switch", path);
	[action setObject: revision forKey: @"revision"];

	[switchPanelSourceTextField setStringValue: PathWithRevision([document repositoryUrl], [document revision])];
	[switchPanelDestinationTextField setStringValue: PathWithRevision(path, revision)];

	[NSApp beginSheet:switchPanel modalForWindow:[self window] modalDelegate:self
		   didEndSelector:@selector(switchPanelDidEnd:returnCode:contextInfo:) contextInfo:[action retain]];
}


- (IBAction) switchPanelValidate: (id) sender
{
	[NSApp endSheet:switchPanel returnCode:[sender tag]];
}


- (void) switchPanelDidEnd: (NSWindow*) sheet
		 returnCode:        (int)       returnCode
		 contextInfo:       (void*)     contextInfo
{
	[sheet orderOut: nil];
	NSMutableDictionary* action = contextInfo;

	if (returnCode == 1)
	{
		id objs[10];
		int count = 0;
		objs[count++] = @"-r";
		objs[count++] = [action objectForKey: @"revision"];
		if ([switchPanelRelocateButton intValue] == 1)	// --relocate
		{
			objs[count++] = @"--relocate";
			objs[count++] = [[document repositoryUrl] absoluteString];
		}
		objs[count++] = [action objectForKey: @"destination"];
		objs[count++] = [document workingCopyPath];
		[document performSelector: @selector(svnSwitch:)
					   withObject: [NSArray arrayWithObjects: objs count: count]
					   afterDelay: 0.1];
	}

	[action release];																					
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Common Methods
//----------------------------------------------------------------------------------------

- (void) runAlertBeforePerformingAction: (NSDictionary*) command
{
	if ([[command objectForKey: @"command"] isEqualToString: @"commit"])
	{
		[self startCommitMessage: @"selected"];
	}
	else
	{
		NSString* message = [NSString stringWithFormat: @"Are you sure you want to %@ the selected items?",
														[command objectForKey: @"verb"]];
		NSAlert* alert = [NSAlert alertWithMessageText: message
										 defaultButton: @"Yes"
									   alternateButton: @"No"
										   otherButton: nil
							 informativeTextWithFormat: @""];
		[alert beginSheetModalForWindow: window
						  modalDelegate: self
						 didEndSelector: @selector(commandPanelDidEnd:returnCode:contextInfo:)
							contextInfo: [command retain]];
	}
}


- (void) svnCommand: (id) action
{
	NSString* const command = [action objectForKey: @"command"];

	if ([command isEqualToString: @"rename"] ||
		[command isEqualToString: @"move"] ||
		[command isEqualToString: @"copy"])
	{
		[document svnCommand: command options: [action objectForKey: @"options"] info: action];
	}
	else if ([command isEqualToString: @"remove"])
	{
		[document svnCommand: command options: [NSArray arrayWithObject: @"--force"] info: nil];
	}
	else if ([command isEqualToString: @"commit"])
	{
		[self startCommitMessage: @"selected"];
	}
	else
	{
		[document svnCommand: command options: nil info: nil];
	}

	[action release];
}


- (void) commandPanelDidEnd: (NSAlert*) alert
		 returnCode:         (int)      returnCode
		 contextInfo:        (void*)    contextInfo
{
	#pragma unused(alert)
	id action = contextInfo;

	if (returnCode == 1)
	{
		[self performSelector: @selector(svnCommand:) withObject: action afterDelay: 0.1];
	}
	else
	{
		[svnFilesAC discardEditing]; // cancel editing, useful to revert a row being renamed (see TableViewDelegate).
		[action release];
	}
}


//----------------------------------------------------------------------------------------

- (void) startCommitMessage: (NSString*) selectedOrAll
{
	[NSApp beginSheet:     commitPanel
		   modalForWindow: [self window]
		   modalDelegate:  self
		   didEndSelector: @selector(commitPanelDidEnd:returnCode:contextInfo:)
		   contextInfo:    [selectedOrAll retain]];
}


- (void) commitPanelDidEnd: (NSWindow*) sheet
		 returnCode:        (int)       returnCode
		 contextInfo:       (void*)     contextInfo
{
	if (returnCode == 1)
	{
#if 1
		[document svnCommit: [[commitPanelText string] normalizeEOLs]];
#else
		[document performSelector: @selector(svnCommit:)
				  withObject:      [[commitPanelText string] normalizeEOLs]
				  afterDelay:      0.1];
#endif
	}
	[(id) contextInfo release];	
	[sheet close];
}


//----------------------------------------------------------------------------------------
// Error Sheet

- (void) doSvnError: (NSString*) errorString
{
	// close any existing sheet that is not an svnError sheet (workaround a "double sheet" effect
	// that can occur because svn info and svn status are launched simultaneously)
	if ( !isDisplayingErrorSheet && [window attachedSheet] != nil )
		[NSApp endSheet:[window attachedSheet]];

 	[self stopProgressIndicator];
	
	if ( !isDisplayingErrorSheet )
	{
		isDisplayingErrorSheet = YES;

		NSAlert* alert = [NSAlert alertWithMessageText: @"Error"
										 defaultButton: @"OK"
									   alternateButton: nil
										   otherButton: nil
							 informativeTextWithFormat: @"%@", errorString];

		[alert setAlertStyle:NSCriticalAlertStyle];

		[alert	beginSheetModalForWindow:window
						   modalDelegate:self
						  didEndSelector:@selector(svnErrorSheetEnded:returnCode:contextInfo:)
						     contextInfo:nil];
	}
}


- (void) svnError: (NSString*) errorString
{
	[self performSelector: @selector(doSvnError:) withObject: errorString afterDelay: 0.1];
}


- (void) svnErrorSheetEnded: (NSAlert*) alert
		 returnCode:         (int)      returnCode
		 contextInfo:        (void*)    contextInfo
{
	#pragma unused(alert, returnCode, contextInfo)
	isDisplayingErrorSheet = NO;
}


//----------------------------------------------------------------------------------------

- (IBAction) commitPanelValidate: (id) sender
{
	#pragma unused(sender)
	[NSApp endSheet:commitPanel returnCode:1];
}


- (IBAction) commitPanelCancel: (id) sender
{
	#pragma unused(sender)
	[NSApp endSheet:commitPanel returnCode:0];
}


- (void) startProgressIndicator
{
	svnStatusPending = YES;
	[progressIndicator startAnimation:self];
}


- (void) stopProgressIndicator
{
	[progressIndicator stopAnimation:self];
}


#if 0
- (NSDictionary*) performActionMenusDict
{
	if ( performActionMenusDict == nil )
	{
		performActionMenusDict = [[NSDictionary dictionaryWithContentsOfFile:
						[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/Contents/Resources/"]
								stringByAppendingPathComponent:@"performMenus.plist"]] retain];
	}

	return performActionMenusDict;
}
#endif


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Convenience Accessors
//----------------------------------------------------------------------------------------

- (MyWorkingCopy*) document
{
	return document;
}


- (NSWindow*) window
{
	return window;
}

// Have the Finder show the parent folder for the selected files.
// if no row in the list is selected then open the root directory of the project

- (void) revealInFinder: (id) sender
{
	#pragma unused(sender)
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSArray* const selectedObjects = [svnFilesAC selectedObjects];

	if ([selectedObjects count] <= 0)
	{
		NSURL *fileURL = [NSURL fileURLWithPath:[document workingCopyPath]];
		[ws selectFile:[fileURL path] inFileViewerRootedAtPath:nil];		
	}
	else
	{
		NSEnumerator *enumerator = [selectedObjects objectEnumerator];
		id file;
		
		while (file = [enumerator nextObject]) 
		{
			NSURL *fileURL = [NSURL fileURLWithPath:[file valueForKey:@"fullPath"]];
			[ws selectFile:[fileURL path] inFileViewerRootedAtPath:nil];
		}
	}
}

@end

