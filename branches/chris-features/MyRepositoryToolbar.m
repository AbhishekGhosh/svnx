
#import "MyRepositoryToolbar.h"


@implementation MyRepositoryToolbar

- (void) awakeFromNib
{
    items = [[NSMutableDictionary alloc] init];

	[self createItem: @"svnCopy" label: @"Copy" help: @"Copy selected item within the repository."];
	[self createItem: @"svnMove" label: @"Move" help: @"Move selected item within the repository."];
	[self createItem: @"svnMkdir" label: @"Make Dir" help: @"Create directories in the repository." image: @"mkdir"];
	[self createItem: @"svnDelete" label: @"Delete" help: @"Delete items in the repository." image: @"delete"];
	[self createItem: @"svnCheckout" label: @"Checkout" help: @"Checkout items from the repository." image: @"checkout2"];
	[self createItem: @"svnExport" label: @"Export" help: @"Export items from the repository." image: @"export"];
	[self createItem: @"svnFileMerge" label: @"Diff" help: @"Compare revisions of an item in the repository." image: @"FileMerge"];
	[self createItem: @"toggleSidebar" label: @"Output" help: @"Show/Hide output of main operations." image: @"sidebar"];

	NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier: @"RepositoryToolBar2"];
	[toolbar setDelegate: self];
	[toolbar setAllowsUserCustomization: YES];
	[toolbar setAutosavesConfiguration: YES];
	[toolbar setDisplayMode: NSToolbarDisplayModeDefault];
	[toolbar setSizeMode: NSToolbarSizeModeDefault];
	[window setToolbar: toolbar];
	[toolbar release];

	[window makeKeyAndOrderFront:nil];
}


//----------------------------------------------------------------------------------------

- (void) dealloc
{
    [items release];
	[super dealloc];
}


//----------------------------------------------------------------------------------------

- (NSToolbarItem*) createItem: (NSString*) itsID
				   label:      (NSString*) itsLabel
				   help:       (NSString*) itsHelp
				   image:      (NSString*) imageName
{
	NSToolbarItem* item = [[NSToolbarItem alloc] initWithItemIdentifier: itsID];
	[item setPaletteLabel: itsLabel];
	[item setLabel: itsLabel];
	if (itsHelp)
		[item setToolTip: itsHelp];
	[item setTarget: document];
	[item setAction: NSSelectorFromString([itsID stringByAppendingString: @":"])];
	[item setImage: [NSImage imageNamed: imageName]];
	[items setObject: item forKey: itsID];
	[item release];
	return item;
}


//----------------------------------------------------------------------------------------

- (NSToolbarItem*) createItem: (NSString*) itsID
				   label:      (NSString*) itsLabel
				   help:       (NSString*) itsHelp
{
	return [self createItem: itsID label: itsLabel help: itsHelp image: itsID];
}


//----------------------------------------------------------------------------------------

- (NSToolbarItem*) toolbar:                   (NSToolbar*) toolbar
				   itemForItemIdentifier:     (NSString*)  itemIdentifier
				   willBeInsertedIntoToolbar: (BOOL)       flag
{
    return [items objectForKey: itemIdentifier];
}


- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
					@"svnCopy",
					@"svnMove",
					@"svnMkdir",
					@"svnDelete",
					@"svnFileMerge",
					NSToolbarFlexibleSpaceItemIdentifier,
					@"svnCheckout",
					@"svnExport",
					NSToolbarSeparatorItemIdentifier,
					@"toggleSidebar",
					nil];
}

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) toolbar
{
    return [NSArray arrayWithObjects:
					NSToolbarSeparatorItemIdentifier,
					NSToolbarSpaceItemIdentifier,
					NSToolbarFlexibleSpaceItemIdentifier,
					@"svnCopy",
					@"svnMove",
					@"svnMkdir",
					@"svnDelete",
					@"svnCheckout",
					@"svnExport",					
					@"svnFileMerge",
					@"toggleSidebar",
					nil];
}


@end

