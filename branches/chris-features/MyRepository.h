/* Manages the repository inspector interface */

#import <Cocoa/Cocoa.h>
#import "MySVN.h";

@class MySvnLogView, MySvnLogView2, MySvnRepositoryBrowserView, DrawerLogView;
@class MySvnOperationController, MySvnMkdirController, MySvnMoveController,
	   MySvnCopyController, MySvnDeleteController, MyFileMergeController;

/* Manages the repository inspector. */
@interface MyRepository : NSDocument
{
	IBOutlet MySvnLogView *svnLogView1;
	IBOutlet MySvnLogView2 *svnLogView2;
	IBOutlet MySvnLogView *svnLogView;
	IBOutlet MySvnRepositoryBrowserView *svnBrowserView;

	IBOutlet MySvnOperationController *svnOperationController;
	IBOutlet MySvnMkdirController *svnMkdirController;
	IBOutlet MySvnMoveController *svnMoveController;
	IBOutlet MySvnCopyController *svnCopyController;
	IBOutlet MySvnDeleteController *svnDeleteController;
	IBOutlet MyFileMergeController *fileMergeController;
	
	IBOutlet NSDrawer *sidebar;
	IBOutlet DrawerLogView *drawerLogView;

    IBOutlet NSTextView *urlTextView;
    IBOutlet NSTextView *commitTextView;
    IBOutlet NSTextField *fileNameTextField;
    IBOutlet NSPanel *importCommitPanel;
	
	BOOL operationInProgress;
	
	NSURL *url;
	NSURL *rootUrl;
	NSString *revision;
	NSString *user;
	NSString *pass;
	NSString *windowTitle;
	
	NSString *logViewKind;
	NSMutableDictionary *displayedTaskObj;
}

- (NSURL *)url;
- (void)setUrl:(NSURL *)anUrl;
- (void) changeRepositoryUrl: (NSURL*) anUrl;

- (NSString *)revision;
- (void)setRevision:(NSString *)aRevision;

- (NSString *)user;
- (void) setUser: (NSString *) aUser;

- (NSString *)pass;
- (void) setPass: (NSString *) aPass;


- (NSString *)windowTitle;
- (void) setWindowTitle: (NSString *) aWindowTitle;

- (void) setDisplayedTaskObj: (NSMutableDictionary*) aDisplayedTaskObj;
- (void) exportFiles: (NSDictionary*) args;
- (void) extractFiles:     (NSArray*) validatedFiles
		 toDestinationURL: (NSURL*)   destinationURL
		 checkout:         (BOOL)     checkoutOrExport;

- (NSURL *)url;
- (void)setUrl:(NSURL *)anUrl;

- (NSURL *)rootUrl;
- (void)setRootUrl:(NSURL *)anUrl;

- (NSString *)logViewKind;
- (void)setLogViewKind:(NSString *)aLogViewKind;

- (void) fetchSvnInfo;
- (void) fetchSvnInfoReceiveDataFinished: (NSString*) result;

- (void) svnError: (NSString*) errorString;
- (NSArray*) userValidatedFiles: (NSArray*) files forDestination: (NSURL*) destinationURL;
- (void) dragOutFilesFromRepository: (NSArray*) filesDicts toURL: (NSURL*) destinationURL;
- (void) dragExternalFiles: (NSArray*) files ToRepositoryAt: (NSDictionary*) representedObject;

- (NSInvocation*) makeSvnOptionInvocation;
- (NSInvocation*) makeCallbackInvocationOfKind: (int) callbackKind;
- (NSInvocation*) svnOptionsInvocation;

@end
