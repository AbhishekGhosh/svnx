//
// SvnLogReport.m
//

#import "SvnLogReport.h"
#import "MySvn.h"
#import <WebKit/WebKit.h>
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

- (SvnLogReport*) initWithURL: (NSString*) fileURL revision: (NSString*) revision
{
	if ((self = [super init]) != nil)
	{
	//	NSLog(@"SvnLogReport r%@ '%@'", revision, fileURL);
		fFileURL  = fileURL;
		fRevision = revision;
	}

	return self;
}


//----------------------------------------------------------------------------------------

- (NSTask*) launchTask: (NSString*) taskLaunchPath
			 arguments: (NSArray*) arguments
			 stdOutput: (NSString*) stdOutput
{
	NSTask* task = [[NSTask alloc] init];
	NSMutableDictionary* environment = [[NSMutableDictionary alloc] initWithDictionary:
												[[NSProcessInfo processInfo] environment]];

	[environment setObject: @"YES"         forKey: @"NSUnbufferedIO"];
	[environment setObject: @"en_US.UTF-8" forKey: @"LC_ALL"];
//	[environment setObject: @"en_US.UTF-8" forKey: @"LC_CTYPE"];
//	[environment setObject: @"en_US.UTF-8" forKey: @"LANG"];
	[task setEnvironment: environment];

	[task setLaunchPath: taskLaunchPath];
	[task setArguments: arguments];

	if (stdOutput != nil)
	{
		[@"?" writeToFile: stdOutput atomically: false];
		NSFileHandle* file = [NSFileHandle fileHandleForWritingAtPath: stdOutput];
	//	NSLog(@"launchTask: %@", file);
		[task setStandardOutput: file];
	}

	[task launch];

//	NSLog(@"launchTask: %@", task);
	return task;
}


//----------------------------------------------------------------------------------------

- (void) begin: (MySvnView*) svnView verbose: (BOOL) verbose
{
	if (fWindow == NULL || fLogView == NULL)
	{
		NSLog(@"SvnLogReport.begin fWindow=%@ fLogView=%@", fWindow, fLogView);
		return;
	}

	if (fWindow)
	{
		[fWindow setTitle: [NSString stringWithFormat: @"%@ r%@", fFileURL, fRevision]];
		[fWindow makeKeyAndOrderFront: nil];
	}

//	NSLog(@"svn log --xml -v -r %@ '%@'", fRevision, fFileURL);
	const pid_t pid = getpid();
	static unsigned int uid = 0;
	++uid;
	NSString* const tmpXmlPath  = [NSString stringWithFormat: @"/tmp/svnX-%u-log-%u.xml", pid, uid];
	NSString* const tmpHtmlPath = [NSString stringWithFormat: @"/tmp/svnX-%u-log-%u.html", pid, uid];

	NSBundle* bundle = [NSBundle mainBundle];
	NSString* const srcXslPath = [bundle pathForResource: @"svnlog" ofType: @"xsl"];
//	NSString* const srcCssPath = [bundle pathForResource: @"svnlog" ofType: @"css"];

	NSString* svnCmd = [[MySvn svnPath] stringByAppendingPathComponent: @"svn"];
	NSString* svnRev = [NSString stringWithFormat: @"-r%@:1", fRevision];
	NSArray* arguments = [NSArray arrayWithObjects: @"log", @"--xml", svnRev, fFileURL,
													(verbose ? @"-v" : nil), nil];
	NSTask* task = [self launchTask: svnCmd arguments: arguments stdOutput: tmpXmlPath];
	if (task)
		[task waitUntilExit];

	if (task)
	{
		arguments = [NSArray arrayWithObjects: @"--stringparam", @"file", fFileURL,
											   @"--stringparam", @"revision", fRevision,
											   @"--stringparam", @"base", [bundle resourcePath],
											   srcXslPath, tmpXmlPath, nil];
		task = [self launchTask: @"/usr/bin/xsltproc" arguments: arguments stdOutput: tmpHtmlPath];
		if (task)
			[task waitUntilExit];
	}

	if (task)
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

@end	// SvnLogReport


//----------------------------------------------------------------------------------------
// End of SvnLogReport.m
