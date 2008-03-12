#import "MyWorkingCopyController.h"
#import "MyWorkingCopy.h"
#import "MyApp.h"
#import "MyFileMergeController.h"
#import "DrawerLogView.h"

typedef float GCoord;

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

@implementation MyWorkingCopyController


//----------------------------------------------------------------------------------------

+ (void) presetDocumentName: name
{
	gInitName = name;
}


//----------------------------------------------------------------------------------------

- (void)awakeFromNib
{
	isDisplayingErrorSheet = NO;

	[document   addObserver:self forKeyPath:@"flatMode"
				options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];

	[drawerLogView setDocument:document];
	[drawerLogView setUp];

	NSTableView* tableView = [[window contentView] viewWithTag: vFlatTable];
	[[[tableView tableColumnWithIdentifier: @"path"] dataCell] setDrawsBackground: false];

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
				[[window toolbar] setVisible: false];

			ConstString widowFrame = [settings objectForKey: keyWidowFrame];
			if (widowFrame != nil)
				[window setFrameFromString: widowFrame];
		}
	}

	[self adjustOutlineView];
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
	if (viewMode != kModeTree)
		[document svnRefresh];		
	[filterView selectItemWithTag: filterMode];
	[document setFilterMode: filterMode];

	[window makeKeyAndOrderFront: self];
	[self savePrefs];

	[window setDelegate: self];		// for windowDidMove & windowDidResize messages
}


//----------------------------------------------------------------------------------------

- (void) windowDidMove: (NSNotification*) notification
{
	[self savePrefs];
}


//----------------------------------------------------------------------------------------

- (void) windowDidResize: (NSNotification*) notification
{
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
								showToolbar ? kCFBooleanTrue : kCFBooleanFalse,  keyShowToolbar,
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
#pragma mark -
#pragma mark IBActions
//----------------------------------------------------------------------------------------

- (IBAction)openAWorkingCopy:(id)sender;
{
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

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString* pathToFile = [[[sheet filenames] objectAtIndex:0] copy];

		[document setWorkingCopyPath: pathToFile];
		[document svnRefresh];
	}
}

- (IBAction) refresh:(id)sender;
{	
	[self fetchSvnInfo];
	[self fetchSvnStatus];
}

- (IBAction) toggleView:(id)sender;
{		
	//[[self document] setFlatMode:!([[self document] flatMode])];

//	[self adjustOutlineView];
}

- (IBAction)performAction:(id)sender;
{
	NSDictionary *command;

	switch ( [[sender selectedCell] tag] )
	{
		case 0:			// Add Selected
			
			command = [NSDictionary dictionaryWithObjectsAndKeys:@"add", @"command",  
																@"add", @"verb", nil]; 
		break;

		case 1:		// Delete Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"remove", @"command",
																@"remove", @"verb", nil]; 

		break;

		case 2:		// Update Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"update", @"command",
																@"update", @"verb", nil]; 

		break;

		case 3:		// Revert Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"revert", @"command",
																@"revert", @"verb", nil]; 

		break;

		case 4:		// Resolved Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"resolved", @"command",
																	@"resolve", @"verb", nil]; 

		break;

		case 5:		// Commit Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"commit", @"command",
																	@"commit", @"verb",nil]; 

		break;

		case 6:		// Lock Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"lock", @"command",
																	@"lock", @"verb",nil]; 

		break;

		case 7:		// Unlock Selected

			command = [NSDictionary dictionaryWithObjectsAndKeys:@"unlock", @"command",
																	@"unlock", @"verb",nil]; 

		break;
	}

	[self runAlertBeforePerformingAction:command];
}

- (void) doubleClickInTableView:(id)sender
{
	if ([[svnFilesAC selectedObjects] count] == 1 )
	{
		[[NSWorkspace sharedWorkspace] openFile:[[[svnFilesAC selectedObjects] objectAtIndex:0] objectForKey:@"fullPath"]];
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

	[document setShowUpdates: ([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask) != 0];
	[document fetchSvnStatusVerbose];
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
//	[textResult setString:[[self document] resultString]];
//	[tableResult reloadData];

	[outliner setIndentationPerLevel:8];
	
	NSIndexSet *selectedRows = [outliner selectedRowIndexes];
	[outliner reloadData];
	[outliner expandItem:[outliner itemAtRow:0] expandChildren:YES];
	[outliner selectRowIndexes:selectedRows byExtendingSelection:NO];
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

- (IBAction)openRepository:(id)sender
{
	[[NSApp delegate] openRepository: [document repositoryUrl] user: [document user] pass: [document pass]];
}

- (IBAction)toggleSidebar:(id)sender
{
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
	//if ([self currentMode] != mode)
	{
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
#pragma mark -
#pragma mark Split View delegate
//----------------------------------------------------------------------------------------

- (BOOL)splitView:(NSSplitView *)sender canCollapseSubview:(NSView *)subview
{
	NSView *leftView = [[splitView subviews] objectAtIndex:0];
	
	if ( subview == leftView )
	{
		return NO; // I would like to return YES here, but can't find a way to uncollapse a view programmatically.
				   // Collasping a view is obviously not setting its width to 0 ONLY.
				   // If I allow user collapsing here, I won't be able to expand the left view with the "toggle button"
				   // (it will remain closed, in spite of a size.width > 0);
	
	} else
	{
		return NO;
	}
}

- (GCoord)splitView:(NSSplitView *)sender constrainMaxCoordinate:(GCoord)proposedMax ofSubviewAt:(int)offset
{	
	if ( offset == 0 )
	{
		if ( [document flatMode] ) return 0;
	}	
	return proposedMax;
}

- (GCoord)splitView:(NSSplitView *)sender constrainMinCoordinate:(GCoord)proposedMin ofSubviewAt:(int)offset
{
	//NSView *leftView = [[splitView subviews] objectAtIndex:0];
	if ( [document flatMode] ) return (GCoord)0;
	
	return (GCoord)140;
}

- (void)splitView:(NSSplitView *)sender resizeSubviewsWithOldSize:(NSSize)oldSize
{
    // how to resize a horizontal split view so that the left frame stays a constant size
    NSView *left = [[sender subviews] objectAtIndex:0];      // get the two sub views
    NSView *right = [[sender subviews] objectAtIndex:1];
    GCoord dividerThickness = [sender dividerThickness];		// and the divider thickness
    NSRect newFrame = [sender frame];                           // get the new size of the whole splitView
    NSRect leftFrame = [left frame];                            // current size of the left subview
    NSRect rightFrame = [right frame];                          // ...and the right
    leftFrame.size.height = newFrame.size.height;               // resize the height of the left
    leftFrame.origin = NSMakePoint(0,0);                        // don't think this is needed
    rightFrame.size.width = newFrame.size.width - leftFrame.size.width - dividerThickness;  // the rest of the width
    rightFrame.size.height = newFrame.size.height;              // the whole height
    rightFrame.origin.x = leftFrame.size.width + dividerThickness;  // 
    [left setFrame:leftFrame];
    [right setFrame:rightFrame];
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Svn Operation Requests
//----------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------
#pragma mark	svn update

- (void)svnUpdate:(id)sender
{
	[[NSAlert alertWithMessageText:[NSString stringWithFormat:@"Update this working copy to the latest revision?", @"update"]
					 defaultButton:@"OK"
				   alternateButton:@"Cancel"
					   otherButton:nil
		 informativeTextWithFormat:@""]
		
		beginSheetModalForWindow:[self window]
				   modalDelegate:self
				  didEndSelector:@selector(updateWorkingCopyPanelDidEnd:returnCode:contextInfo:)
					 contextInfo:nil];					 
}

- (void)updateWorkingCopyPanelDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{	
	if ( returnCode == 0 ) return;

	[document svnUpdate];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn merge

- (void)fileHistoryOpenSheetForItem:(id)item;
{
	// close the sheet if it is already open
	if ( [fileMergeController window] )
		[NSApp endSheet:[fileMergeController window]];
	
	if ( [NSBundle loadNibNamed:@"svnFileMerge" owner:fileMergeController] )
	{
		[fileMergeController setPath:[item objectForKey:@"fullPath"]];
		[fileMergeController setSvnOptionsInvocation:[[self document] svnOptionsInvocation]];
		[fileMergeController setSourceItem:item];
		[fileMergeController setup]; 

		[NSApp beginSheet:[fileMergeController window]
		   modalForWindow:[document windowForSheet]
			modalDelegate:self
		   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			  contextInfo:nil];
	}	

}

- (void)svnFileMerge:(id)sender
{
	if ( [[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask )
	{

		if ( [[svnFilesAC selectedObjects] count ] != 1 )
		{
			[self svnError:@"Please select exactly one item."];
			return;	
		} 

		[self fileHistoryOpenSheetForItem:[[svnFilesAC selectedObjects] objectAtIndex:0]];

	}
	else
	{
		[[self document] fileMergeItems:[[svnFilesAC selectedObjects] mutableArrayValueForKey:@"fullPath"]];
	}
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;
{
	[sheet orderOut:nil];
	
	if ( returnCode == 1 )
	{
	}
	
	[fileMergeController unload];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn rename

- (void) requestSvnRenameSelectedItemTo:(NSString *)destination
{
	[self runAlertBeforePerformingAction:[NSDictionary dictionaryWithObjectsAndKeys:	@"rename", @"command", 
																						@"rename", @"verb", 
																						destination, @"destination",
																						nil]];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn move

- (void)requestSvnMoveSelectedItemsToDestination:(NSString *)destination
{
	NSMutableDictionary *action = [NSMutableDictionary dictionaryWithObjectsAndKeys:	@"move", @"command", 
																						@"move", @"verb", 
																						destination, @"destination",
																						nil];
	if ( [[svnFilesAC selectedObjects] count] == 1 )
	{
		[renamePanel setTitle:@"Move and rename"];
		[renamePanelTextField setStringValue:[[[[svnFilesAC selectedObjects] objectAtIndex:0] valueForKey:@"path"] lastPathComponent]];
		[NSApp beginSheet:renamePanel modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(renamePanelDidEnd:returnCode:contextInfo:) contextInfo:[action retain]];
	
	} else [self runAlertBeforePerformingAction:action];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn copy

- (void) requestSvnCopySelectedItemsToDestination:(NSString *)destination
{
	NSMutableDictionary *action = [NSMutableDictionary dictionaryWithObjectsAndKeys:	@"copy", @"command", 
																						@"copy", @"verb", 
																						destination, @"destination",
																						nil];
	if ( [[svnFilesAC selectedObjects] count] == 1 )
	{
		[renamePanel setTitle:@"Copy and rename"];
		[renamePanelTextField setStringValue:[[[[svnFilesAC selectedObjects] objectAtIndex:0] valueForKey:@"path"] lastPathComponent]];
		[NSApp beginSheet:renamePanel modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(renamePanelDidEnd:returnCode:contextInfo:) contextInfo:[action retain]];
	
	} else
	[self runAlertBeforePerformingAction:action];
}


//----------------------------------------------------------------------------------------
#pragma mark	svn copy & svn move common 

- (void)renamePanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:nil];
	NSMutableDictionary *action = contextInfo;
	
	[action setObject:[[(id) contextInfo objectForKey:@"destination"] stringByAppendingPathComponent:[renamePanelTextField stringValue]] forKey:@"destination"];
	
	if ( returnCode == 1 )
	{
		[self runAlertBeforePerformingAction:action];
	}
	
	[action release];																					
}

- (IBAction)renamePanelValidate:(id)sender;
{
	[NSApp endSheet:renamePanel returnCode:[sender tag]];
}


//----------------------------------------------------------------------------------------
// called from MyDragSupportWindow
#pragma mark	svn switch

-(void)requestSwitchToRepositoryPath:(NSDictionary *)repositoryPathObj
{
//	NSLog(@"%@", repositoryPathObj);
	NSString *path = [repositoryPathObj valueForKeyPath:@"url.absoluteString"];
	NSString *revision = [repositoryPathObj valueForKey:@"revision"];

	NSMutableDictionary *action = [NSMutableDictionary dictionaryWithObjectsAndKeys:	@"switch", @"command", 
																						@"switch", @"verb", 
																						path, @"destination",
																						revision, @"revision",
																						nil];

	[switchPanel setTitle:@"Switch"];
	[switchPanelSourceTextField setStringValue:[NSString stringWithFormat:@"%@  (rev. %@)", [[self document] repositoryUrl], [[self document] revision]]];
	[switchPanelDestinationTextField setStringValue:[NSString stringWithFormat:@"%@  (rev. %@)", path, revision]];
	
	[NSApp beginSheet:switchPanel modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(switchPanelDidEnd:returnCode:contextInfo:) contextInfo:[action retain]];

}

- (IBAction)switchPanelValidate:(id)sender;
{
	[NSApp endSheet:switchPanel returnCode:[sender tag]];
}

- (void)switchPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:nil];
	NSMutableDictionary *action = contextInfo;
	
	if ( returnCode == 1 )
	{
		if ( [switchPanelRelocateButton intValue] == 1 )//  --relocate
		{
			[[self document] svnCommand:@"switch" options:[NSArray arrayWithObjects:@"-r",
															[action objectForKey:@"revision"],
															@"--relocate",
															[[[self document] repositoryUrl] absoluteString],
															[action objectForKey:@"destination"],
															[document workingCopyPath],
															nil] info:nil];
		}
		else
		{
			[[self document] svnCommand:@"switch" options:[NSArray arrayWithObjects:@"-r",
															[action objectForKey:@"revision"],
															[action objectForKey:@"destination"],
															[document workingCopyPath],
														//	[action objectForKey:@"source"],
															nil] info:nil];
		}
	}
	
	[action release];																					
}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Common Methods
//----------------------------------------------------------------------------------------

- (void)runAlertBeforePerformingAction:(NSDictionary *)command
{
	if ( [[command objectForKey:@"command"] isEqualToString:@"commit"] )
	{
		[self startCommitMessage:@"selected"];
	}
	else
	{
		[[NSAlert alertWithMessageText:[NSString stringWithFormat: @"Are you sure you want to %@ selected items?",
																   [command objectForKey:@"verb"]]
			defaultButton:@"Yes"
			alternateButton:@"No"
			otherButton:nil
			informativeTextWithFormat:@""]
			
			beginSheetModalForWindow:window
						modalDelegate:self
						didEndSelector:@selector(commandPanelDidEnd:returnCode:contextInfo:)
						contextInfo:[command retain]];
	}
	
	return;
}

- (void)commandPanelDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
	id action = contextInfo;
	NSString *command = [action objectForKey:@"command"];

	if ( returnCode == 0 )
	{
		[svnFilesAC discardEditing]; // cancel editing, useful to revert a row being renamed (see TableViewDelegate).
		[action release];
		return;
	}
	
	if ( [command isEqualToString:@"rename"] )
	{
		[[self document] svnCommand:@"rename" options:[action objectForKey:@"options"] info:contextInfo];
	}
	else if ( [command isEqualToString:@"move"] )
	{
		[[self document] svnCommand:@"move" options:[action objectForKey:@"options"] info:contextInfo];
	}
	else if ( [command isEqualToString:@"copy"] )
	{
		[[self document] svnCommand:@"copy" options:[action objectForKey:@"options"] info:contextInfo];
	}
	else if ( [command isEqualToString:@"remove"] )
	{
		[[self document] svnCommand:@"remove" options:[NSArray arrayWithObject:@"--force"] info:nil];
	}
	else if ( [command isEqualToString:@"commit"] )
	{
		[self startCommitMessage:@"selected"];
	}
	else
	{
		[[self document] svnCommand:command options:nil info:nil];
	}

	[action release];
}

- (void)startCommitMessage:(NSString *)selectedOrAll
{
	[NSApp beginSheet:commitPanel   modalForWindow:[self window]
									modalDelegate:self
									didEndSelector:@selector(commitPanelDidEnd:returnCode:contextInfo:)
									contextInfo:[selectedOrAll retain]];
}

- (void)commitPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;
{
	if ( returnCode == 1 )
	{
		[[self document] svnCommand:@"commit" options:[NSArray arrayWithObjects:@"-m", [commitPanelText string], nil] info:nil];
	}
	[(id) contextInfo release];	
	[sheet close];
}


//----------------------------------------------------------------------------------------
// Error Sheet

- (void)svnError:(NSString*)errorString
{
	// close any existing sheet that is not an svnError sheet (workaround a "double sheet" effect that can occur because svn info and svn status are launched simultaneously)
	if ( !isDisplayingErrorSheet && [window attachedSheet] != nil ) [NSApp endSheet:[window attachedSheet]];
	
 	[self stopProgressIndicator];
	
	if ( !isDisplayingErrorSheet )
	{
		isDisplayingErrorSheet = YES;

		NSAlert *alert = [NSAlert alertWithMessageText:@"Error"
				defaultButton:@"OK"
				alternateButton:nil
				otherButton:nil
				informativeTextWithFormat:errorString];

		[alert setAlertStyle:NSCriticalAlertStyle];

		[alert	beginSheetModalForWindow:window
						   modalDelegate:self
						  didEndSelector:@selector(svnErrorSheetEnded:returnCode:contextInfo:)
						     contextInfo:nil];
	}
}

- (void)svnErrorSheetEnded:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	isDisplayingErrorSheet = NO;
}


//----------------------------------------------------------------------------------------

- (IBAction)commitPanelValidate:(id)sender
{
	[NSApp endSheet:commitPanel returnCode:1];
}

- (IBAction)commitPanelCancel:(id)sender
{
	[NSApp endSheet:commitPanel returnCode:0];
}

- (void)startProgressIndicator
{
	[progressIndicator startAnimation:self];
}
- (void)stopProgressIndicator
{
	[progressIndicator stopAnimation:self];
}

//- (NSDictionary *)performActionMenusDict
//{
//	if ( performActionMenusDict == nil )
//	{
//		performActionMenusDict = [[NSDictionary dictionaryWithContentsOfFile:[[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"/Contents/Resources/" ]
//								stringByAppendingPathComponent:@"performMenus.plist"]] retain];
//	}
//	
//	return performActionMenusDict;
//}


//----------------------------------------------------------------------------------------
#pragma mark	-
#pragma mark	Convenience Accessors
//----------------------------------------------------------------------------------------

-(MyWorkingCopy*)document
{
	return document;
}
-(NSWindow*)window
{
	return window;
}

// Have the Finder show the parent folder for the selected files.
///if no row in the list is selected then 
///open the root directory of the project
- (void)revealInFinder:(id)sender
{
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	
	if([[svnFilesAC selectedObjects] count] <= 0) {
		NSURL *fileURL = [NSURL fileURLWithPath:[document workingCopyPath]];
		[ws selectFile:[fileURL path] inFileViewerRootedAtPath:nil];		
	} else {
		NSEnumerator *enumerator = [[svnFilesAC selectedObjects] objectEnumerator];
		id file;
		
		while(file = [enumerator nextObject]) 
		{
			NSURL *fileURL = [NSURL fileURLWithPath:[file valueForKey:@"fullPath"]];
			[ws selectFile:[fileURL path] inFileViewerRootedAtPath:nil];
		}
	}
}

@end
