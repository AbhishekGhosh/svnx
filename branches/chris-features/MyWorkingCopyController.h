#import <Cocoa/Cocoa.h>

@class MyWorkingCopy;
@class MySvnFilesArrayController, DrawerLogView;
@class MyFileMergeController;

/*" Controller of the working copy browser "*/
@interface MyWorkingCopyController : NSResponder
{
    IBOutlet MyWorkingCopy *document;
	
	IBOutlet id window;
	IBOutlet id splitView;
	IBOutlet id workingCopyPath;
	IBOutlet id progressIndicator;
	IBOutlet id textResult;
	IBOutlet id tableResult;
    IBOutlet id outliner;

	IBOutlet NSControl*		modeView;
	IBOutlet NSPopUpButton*	filterView;

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

	BOOL svnStatusPending;
	BOOL svnActionPending;
	
	BOOL isDisplayingErrorSheet;

	NSArray*	savedSelection;		// used by save/restoreSelection
}

+ (void) presetDocumentName: name;

- (IBAction) openAWorkingCopy: (id) sender;
- (IBAction) changeFilter:     (id) sender;
- (IBAction) performAction:    (id) sender;

- (IBAction) revealInFinder: (id) sender;
- (IBAction) refresh:        (id) sender;
- (IBAction) svnUpdate:      (id) sender;
- (IBAction) svnFileMerge:   (id) sender;
- (IBAction) openRepository: (id) sender;
- (IBAction) toggleSidebar:  (id) sender;
- (IBAction) changeMode:     (id) sender;
- (int)      currentMode;
- (void)     setCurrentMode: (int) mode;

- (IBAction) commitPanelValidate: (id) sender;
- (IBAction) commitPanelCancel:   (id) sender;
- (IBAction) renamePanelValidate: (id) sender;
- (IBAction) switchPanelValidate: (id) sender;

- (void) setup;
- (void) savePrefs;
- (void) cleanup;
- (void) keyDown: (NSEvent*) theEvent;
- (void) saveSelection;
- (void) restoreSelection;

- (void) doubleClickInTableView: (id) sender;
- (void) adjustOutlineView;
- (void) openOutlineView;
- (void) closeOutlineView;
- (void) fetchSvnStatus;
- (void) fetchSvnInfo;
- (void) fetchSvnStatusVerboseReceiveDataFinished;

- (void) runAlertBeforePerformingAction: (NSDictionary*) command;
- (void) startCommitMessage: (NSString*) selectedOrAll;
- (void) svnError: (NSString*) errorString;
- (void) startProgressIndicator;
- (void) stopProgressIndicator;

- (MyWorkingCopy*) document;
- (NSWindow*) window;
- (void) requestSwitchToRepositoryPath: (NSDictionary*) repositoryPathObj;
- (void) requestSvnRenameSelectedItemTo:           (NSString*) destination;
- (void) requestSvnMoveSelectedItemsToDestination: (NSString*) destination;
- (void) requestSvnCopySelectedItemsToDestination: (NSString*) destination;

@end
