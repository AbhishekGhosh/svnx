#import "MyApp.h"
#import "GetEthernetAddrSample.h"
#import "RepositoriesController.h"


static void
AddTransform (Class itsClass, NSString* itsName)
{
	[NSValueTransformer setValueTransformer: [[[itsClass alloc] init] autorelease] forName: itsName];
}


//----------------------------------------------------------------------------------------

@implementation MyApp

@class SvnFileStatusToColourTransformer, SvnDateTransformer, ArrayCountTransformer, SvnFilePathTransformer,
	   FilePathCleanUpTransformer, FilePathWorkingCopy, TrimNewLinesTransformer, TaskStatusToColorTransformer;

+ (MyApp *)myApp
{
    static id controller = nil;
    
    if (!controller) {
        controller = [NSApp delegate];
    }

    return controller;
}


+ (void)initialize
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSData *svnFileStatusModifiedColor = [NSArchiver archivedDataWithRootObject:[NSColor blackColor]];
	NSData *svnFileStatusNewColor = [NSArchiver archivedDataWithRootObject:[NSColor blueColor]];
	NSData *svnFileStatusMissingColor = [NSArchiver archivedDataWithRootObject:[NSColor redColor]];

	[dictionary setObject:svnFileStatusModifiedColor forKey:@"svnFileStatusModifiedColor"];
	[dictionary setObject:svnFileStatusNewColor forKey:@"svnFileStatusNewColor"];
	[dictionary setObject:svnFileStatusMissingColor forKey:@"svnFileStatusMissingColor"];
	
	[dictionary setObject:@"/usr/local/bin" forKey:@"svnBinariesFolder"];
	[dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"cacheSvnQueries"];
	[dictionary setObject:[NSNumber numberWithInt:0] forKey:@"defaultDiffApplication"];
	[dictionary setObject:@"%m/%d/%y %H:%M:%S" forKey:@"dateformat"];

	[dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"addWorkingCopyOnCheckout"];
	[dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"useOldParsingMethod"];

	[dictionary setObject: (id) kCFBooleanTrue forKey: @"abbrevWCFilePaths"];

	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:dictionary];

	// Transformers
	AddTransform([SvnFileStatusToColourTransformer class], @"SvnFileStatusToColourTransformer");	// used by MyWorkingCopy
	AddTransform([SvnDateTransformer class], @"SvnDateTransformer");								// used by MySvnLogView
	AddTransform([ArrayCountTransformer class], @"ArrayCountTransformer");							// used by MySvnLogView
	AddTransform([FilePathCleanUpTransformer class], @"FilePathCleanUpTransformer");				// used by FavoriteWorkingCopies
	AddTransform([FilePathWorkingCopy class], @"FilePathWorkingCopy");								// used by FavoriteWorkingCopies
	AddTransform([SvnFilePathTransformer class], @"lastPathComponent");								// used by SingleFileInspector
	AddTransform([TrimNewLinesTransformer class], @"TrimNewLines");									// used by MySvnLogView and MySvnLogView2 (to filter author name)
	AddTransform([TaskStatusToColorTransformer class], @"TaskStatusToColor");						// used by Activity Window in svnX.nib
}


- (bool)checkSVNExistence:(bool)warn
{
	NSString *svnPath = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"svnBinariesFolder"];
	NSFileManager* fm = [NSFileManager defaultManager];
	NSString* svnFilePath = [svnPath stringByAppendingPathComponent:@"svn"];
	bool exists = [fm fileExistsAtPath:svnFilePath];

	if (!exists && warn)
	{
		NSAlert *alert = [NSAlert alertWithMessageText:@"Error: Unable to locate svn binary."
										 defaultButton:@"Open Preferences"
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:@"Make sure the svn binary is present at path:\n%C%@%C.\n\n"
														"Is a Subversion client installed?"
														" If so, make sure the path is correctly set in the preferences.",
														0x201C, svnPath, 0x201D];
		
		[alert setAlertStyle:NSCriticalAlertStyle];
		[alert runModal];							 
		[preferencesWindow makeKeyAndOrderFront:self];
	}
	return exists;
}


- (void) initUI: (NSNotification*) note
{
	[repositoriesController showWindow];
	[favoriteWorkingCopies showWindow];
}


- (void)awakeFromNib
{
	[self checkSVNExistence:true];

	// Show the Repositories & Working Copies windows after ALL awakeFromNib calls
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(initUI:) name: @"initUI" object: self];
	[[NSNotificationQueue defaultQueue] enqueueNotification: [NSNotification notificationWithName: @"initUI" object: self]
										postingStyle:        NSPostWhenIdle]; 
}


- (IBAction)test:(id)sender
{
//	[self fileHistoryOpenSheetForItem:@"/Users/dom/Sites/alahup/flash/_classes/com/lachoseinteractive/SmartEdit/Inspector_text.as"];
}

- (void)fileHistoryOpenSheetForItem:(NSString *)path  // Compare a single file in a svnX window. Invoked from Applescript.
{	
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[favoriteWorkingCopies fileHistoryOpenSheetForItem:path];
}


- (IBAction)openPreferences:(id)sender
{
	[preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)closePreferences:(id)sender
{
    [preferencesWindow close];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender 
{
	return NO;
}

- (void)openRepository:(NSURL *)url user:(NSString *)user pass:(NSString *)pass
{
	[repositoriesController openRepositoryBrowser:[url absoluteString] title:[url absoluteString] user:user pass:pass];
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Tasks management

-(void)newTaskWithDictionary:(NSMutableDictionary *)taskObj
// called from MySvn class
{
	[tasksManager newTaskWithDictionary:taskObj];
}


//----------------------------------------------------------------------------------------
#pragma mark -
#pragma mark Sparkle Plus delegate methods

- (NSMutableArray *)updaterCustomizeProfileInfo:(NSMutableArray *)profileInfo
{
	NSString *MACAddress = [self getMACAddress];
	NSArray *profileDictKeys = [NSArray arrayWithObjects:@"key", @"visibleKey", @"value", @"visibleValue", nil];

	[profileInfo addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"MACAddr",@"MAC Address", MACAddress, MACAddress, nil] forKeys:profileDictKeys]];

	//NSLog(@"%@", profileInfo);
	
	return profileInfo;
}

- (NSString *)getMACAddress
{	
	EnetData data[10];
	UInt32 entryCount = 10;
	MACAddress mac;

	int err = GetEthernetAddressInfo((EnetData*)&data, &entryCount);

	if ( err == noErr )
	{
		NSValue *value = [NSValue valueWithBytes:&data[0].macAddress objCType:@encode(MACAddress)];
		[value getValue:&mac];
		NSMutableString *s = [NSMutableString string];
		int i;
		
		for ( i=0; i<kIOEthernetAddressSize; i++ )
		{
			[s appendFormat:@"%02X", mac[i]];
		
			if(i < kIOEthernetAddressSize-1) [s appendString:@":"];
		}
		
		return s;
	}
	
	return @"";
}

@end

