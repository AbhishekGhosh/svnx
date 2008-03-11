#import <Cocoa/Cocoa.h>

@class MySvn;

@class MyWorkingCopy;
@class MySvnFilesArrayController, DrawerLogView;
@class MyFileMergeController;

/*" Controller of the working copy browser "*/
@interface MyWorkingCopyController : NSObject
{
    IBOutlet MyWorkingCopy *document;
	
    IBOutlet id window;
    IBOutlet id splitView;
    IBOutlet id workingCopyPath;
    IBOutlet id progressIndicator;
    IBOutlet id refreshButton;
    IBOutlet id textResult;
    IBOutlet id tableResult;

    IBOutlet id outliner;

    IBOutlet id performPopUp;
    IBOutlet id addMenu;
    IBOutlet id deleteMenu;
	
	IBOutlet id commitPanel;
	IBOutlet id commitPanelText;
	IBOutlet id toolbar;
	IBOutlet NSDrawer *sidebar;

	IBOutlet MySvnFilesArrayController *svnFilesAC;
	IBOutlet MyFileMergeController *fileMergeController;

	IBOutlet DrawerLogView *drawerLogView;

	IBOutlet NSPanel		*renamePanel;
	IBOutlet NSTextField	*renamePanelTextField;

	IBOutlet NSPanel		*switchPanel;
	IBOutlet NSTextField	*switchPanelSourceTextField;
	IBOutlet NSTextField	*switchPanelDestinationTextField;
	IBOutlet NSButton		*switchPanelRelocateButton;
	
	NSDictionary *performActionMenusDict;
    	
	BOOL svnStatusPending;
	BOOL svnActionPending;
	
	BOOL isDisplayingErrorSheet;
}

- (IBAction)openAWorkingCopy:(id)sender;
- (IBAction)refresh:(id)sender;

- (IBAction)changeFilter:(id)sender;

- (IBAction)performAction:(id)sender;

- (IBAction)openRepository:(id)sender;

- (IBAction)commitPanelValidate:(id)sender;
- (IBAction)commitPanelCancel:(id)sender;

- (IBAction)renamePanelValidate:(id)sender;
- (IBAction)switchPanelValidate:(id)sender;

- (void) cleanup;

- (void) doubleClickInTableView: (id) sender;
- (void) adjustOutlineView;
- (void) openOutlineView;
- (void) closeOutlineView;
- (void) fetchSvnStatus;
- (void) fetchSvnInfo;
- (void) fetchSvnStatusVerboseReceiveDataFinished;

- (void) svnUpdate: (id) sender;
- (void) svnFileMerge: (id) sender;

- (void) runAlertBeforePerformingAction: (NSDictionary*) command;
- (void) startCommitMessage: (NSString*) selectedOrAll;
- (void) svnError: (NSString*) errorString;
- (void) startProgressIndicator;
- (void) stopProgressIndicator;

- (MyWorkingCopy*) document;
- (NSWindow*) window;
- (void) revealInFinder: (id) sender;
- (void) requestSwitchToRepositoryPath: (NSDictionary*) repositoryPathObj;
- (void) requestSvnRenameSelectedItemTo:           (NSString*) destination;
- (void) requestSvnMoveSelectedItemsToDestination: (NSString*) destination;
- (void) requestSvnCopySelectedItemsToDestination: (NSString*) destination;

@end
