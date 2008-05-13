//
// SvnLogReport.m
//

#include "SvnLogReport.h"
#include "CommonUtils.h"
#include "MySvn.h"
#include "NSString+MyAdditions.h"
#include "Tasks.h"
#include <WebKit/WebKit.h>
#include <unistd.h>


//----------------------------------------------------------------------------------------

@interface SvnLogToolbar : NSObject
{
	IBOutlet SvnLogReport*	fReport;

@private
	NSMutableDictionary*	fItems;
}

- (void) dealloc;
- (void) awakeFromNib;
- (NSToolbarItem*) toolbar: (NSToolbar*)toolbar
				   itemForItemIdentifier: (NSString*) itemIdentifier
				   willBeInsertedIntoToolbar: (BOOL) flag;
- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar;
- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar;
- (void) toolbarWillAddItem: (NSNotification*) notification;
- (NSToolbarItem*) createItem: (NSString*) itsID
				   label: (NSString*) itsLabel
				   help: (NSString*) itsHelp;

@end


//----------------------------------------------------------------------------------------
#pragma mark	-

@implementation SvnLogToolbar


- (void) dealloc
{
    [fItems release];

    [super dealloc];
}


//----------------------------------------------------------------------------------------

- (void) awakeFromNib
{
	fItems = [[NSMutableDictionary alloc] init];

	[self createItem: @"textSmaller" label: @"Smaller" help: @"Decrease font size."];
	[self createItem: @"textBigger"  label: @"Bigger"  help: @"Increase font size."];

	NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier: @"SvnLogToolbar"];
    [toolbar setDelegate: self];
    [toolbar setAllowsUserCustomization: YES];
    [toolbar setAutosavesConfiguration: YES];
    [toolbar setDisplayMode: NSToolbarDisplayModeDefault];
	[toolbar setSizeMode: NSToolbarSizeModeDefault];
    [[fReport window] setToolbar: toolbar];
    [toolbar release];
}


//----------------------------------------------------------------------------------------

- (NSToolbarItem*) toolbar: (NSToolbar*) toolbar
				   itemForItemIdentifier: (NSString*) itemIdentifier
				   willBeInsertedIntoToolbar: (BOOL) flag
{
    return [fItems objectForKey: itemIdentifier];
}


//----------------------------------------------------------------------------------------

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
					NSToolbarSeparatorItemIdentifier,
					NSToolbarSpaceItemIdentifier,
					NSToolbarFlexibleSpaceItemIdentifier,
					NSToolbarPrintItemIdentifier,
					@"textSmaller",
					@"textBigger",
					nil];
}


//----------------------------------------------------------------------------------------

- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
					@"textSmaller",
					@"textBigger",
					NSToolbarFlexibleSpaceItemIdentifier,
					NSToolbarPrintItemIdentifier,
					nil];
}


//----------------------------------------------------------------------------------------

- (void) toolbarWillAddItem: (NSNotification*) notification
{
	NSToolbarItem* item = [[notification userInfo] objectForKey: @"item"];
	if ([[item itemIdentifier] isEqual: NSToolbarPrintItemIdentifier])
		[item setTarget: fReport];
}


//----------------------------------------------------------------------------------------

- (NSToolbarItem*) createItem: (NSString*) itsID
				   label: (NSString*) itsLabel
				   help: (NSString*) itsHelp
{
	NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier: itsID];
	[item setPaletteLabel: itsLabel];
	[item setLabel: itsLabel];
	if (itsHelp)
		[item setToolTip: itsHelp];
	[item setTarget: fReport];
	[item setAction: NSSelectorFromString([itsID stringByAppendingString: @":"])];
	[item setImage: [NSImage imageNamed: itsID]];
	[fItems setObject: item forKey: itsID];
	[item release];
	return item;
}


//----------------------------------------------------------------------------------------

@end	// SvnLogToolbar


//========================================================================================
#pragma mark	-
//========================================================================================

@implementation SvnLogReport

- (void) taskCompleted: (Task*) task object: (id) object
{
	#pragma unused(task)
	if (![fWindow isVisible])
		return;

	if (object != nil)	// svn task
	{
	//	NSString* const tmpHtmlPath = [object objectForKey: @"html"];
	//	NSArray* const arguments = [object objectForKey: @"arguments"];

		Task* task = [[Task alloc] initWithDelegate: self object: nil];
	//	[task launch: @"/usr/bin/xsltproc" arguments: arguments stdOutput: tmpHtmlPath];
		[task launch:    @"/usr/bin/xsltproc"
			  arguments: [object objectForKey: @"arguments"]
			  stdOutput: [object objectForKey: @"html"]];
	}
	else				// xsltproc task
	{
		[[fLogView mainFrame] reload];
	//	[fBusyIndicator stopAnimation: self];
	//	[fBusyIndicator setHidden: YES];
	}
}


//----------------------------------------------------------------------------------------

- (void) createReport: (NSString*) fileURL
		 revision:     (NSString*) revision
		 verbose:      (BOOL)      verbose
{
	Assert(fWindow != nil);
	Assert(fLogView != nil);

	[fWindow setTitle: PathWithRevision(fileURL, revision)];
	[fWindow makeKeyAndOrderFront: nil];

//	[fBusyIndicator setHidden: NO];
//	[fBusyIndicator startAnimation: self];
//	NSLog(@"svn log --xml -v -r %@ '%@'", revision, fileURL);
	const pid_t pid = getpid();
	static unsigned int uid = 0;
	++uid;
	NSString* const tmpXmlPath  = [NSString stringWithFormat: @"/tmp/svnX-%u-log-%u.xml", pid, uid];
	NSString* const tmpHtmlPath = [NSString stringWithFormat: @"/tmp/svnX-%u-log-%u.html", pid, uid];

	NSBundle* bundle = [NSBundle mainBundle];
	NSString* const srcXslPath = [bundle pathForResource: @"svnlog" ofType: @"xsl"];
//	NSString* const srcCssPath = [bundle pathForResource: @"svnlog" ofType: @"css"];

	NSString* svnRev = [NSString stringWithFormat: @"-r%@:1", revision];
	NSArray* arguments = [NSArray arrayWithObjects: @"log", @"--xml", svnRev,
													PathPegRevision(fileURL, revision),
													(verbose ? @"-v" : nil), nil];

	NSArray* args2 = [NSArray arrayWithObjects: @"--stringparam", @"file", fileURL,
												@"--stringparam", @"revision", revision,
												@"--stringparam", @"base", [bundle resourcePath],
												srcXslPath, tmpXmlPath, nil];
	// TO_DO: store task & kill it if window closes before completion
	Task* task = [[Task alloc] initWithDelegate: self
							   object: [NSDictionary dictionaryWithObjectsAndKeys:
															tmpHtmlPath, @"html",
															args2, @"arguments", nil]];
	[@"?" writeToFile: tmpXmlPath atomically: false];
	[task launch: SvnCmdPath() arguments: arguments stdOutput: tmpXmlPath];

	[@"Working..." writeToFile: tmpHtmlPath atomically: false];
	[[fLogView mainFrame] loadRequest: [NSURLRequest requestWithURL:
											[NSURL fileURLWithPath: tmpHtmlPath]]];
}


//----------------------------------------------------------------------------------------

- (void) textSmaller: (id) sender
{
	if ([fLogView canMakeTextSmaller])
		[fLogView makeTextSmaller: sender];
}


//----------------------------------------------------------------------------------------

- (void) textBigger: (id) sender
{
	if ([fLogView canMakeTextLarger])
		[fLogView makeTextLarger: sender];
}


//----------------------------------------------------------------------------------------

- (void) printDocument: (id) sender
{
//	NSView* view = fLogView;
	NSView* view = [[[fLogView mainFrame] frameView] documentView];
	NSPrintOperation* printOperation = [NSPrintOperation printOperationWithView: view];
	[printOperation runOperationModalForWindow: fWindow delegate: nil
					didRunSelector: NULL contextInfo: NULL];
}


//----------------------------------------------------------------------------------------
// Optional method:  This message is sent to us since we are the target of some toolbar item actions 
// (for example:  of the save items action) 

NSString* const SaveDocToolbarItemIdentifier = @"svnX.save";
NSString* const SearchDocToolbarItemIdentifier = @"svnX.search";

- (BOOL) validateToolbarItem: (NSToolbarItem*) toolbarItem
{
	bool enable = !false;
	NSString* itemID = [toolbarItem itemIdentifier];
	if ([itemID isEqual: SaveDocToolbarItemIdentifier])
		enable = true;	//[self isDocumentEdited];
	else if ([itemID isEqual: NSToolbarPrintItemIdentifier])
		enable = true;
	else if ([itemID isEqual: SearchDocToolbarItemIdentifier])
		enable = true;	//[[[documentTextView textStorage] string] length] > 0;

	return enable;
}


//----------------------------------------------------------------------------------------

- (NSWindow*) window
{
	return fWindow;
}


//----------------------------------------------------------------------------------------

+ (void) svnLogReport: (NSString*) fileURL
		 revision:     (NSString*) revision
		 verbose:      (BOOL)      verbose
{
	SvnLogReport* report = [[SvnLogReport alloc] init];
	if ([NSBundle loadNibNamed: @"BrowseLog" owner: report])
		[report createReport: fileURL revision: revision verbose: verbose];
	else
		[report release];
}


//----------------------------------------------------------------------------------------

@end	// SvnLogReport


//----------------------------------------------------------------------------------------
// End of SvnLogReport.m
