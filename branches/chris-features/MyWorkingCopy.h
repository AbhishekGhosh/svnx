#import <Cocoa/Cocoa.h>

enum {
	kFilterAll		=	0,
	kFilterModified	=	1,
	kFilterNew		=	2,
	kFilterMissing	=	3,
	kFilterConflict	=	4,
	kFilterChanged	=	5
};

@class MyWorkingCopyController, MySvnFilesArrayController;

/*" Model of the working copy browser "*/
@interface MyWorkingCopy : NSDocument
{
	NSString *user;
	NSString *pass;

	NSString *workingCopyPath;
	NSString *revision;
	NSURL	 *repositoryUrl;

	NSString *windowTitle;

	NSString *outlineSelectedPath; // the currently selected path in the left outline view

	IBOutlet MyWorkingCopyController*	controller;
	IBOutlet MySvnFilesArrayController*	svnFilesAC;	
	
    NSArray*		svnFiles;
	NSDictionary*	svnDirectories;

	BOOL			flatMode, smartMode;
	BOOL			showUpdates; // svn status -u
	int				filterMode;
	NSString*		statusInfo;

	NSMutableDictionary *displayedTaskObj;
}


+ (void) presetDocumentName: name;
- (void) setup: (NSString*) title
		 user:  (NSString*) username
		 pass:  (NSString*) password
		 path:  (NSString*) fullPath;
- (void) svnRefresh;

- (void) fetchSvnInfo;
- (void) svnUpdate;
- (void) fileMergeItems: (NSArray*) items;
- (void) fetchSvnStatus: (BOOL) showUpdates;
- (void) fetchSvnInfoReceiveDataFinished: (NSString*) result;
- (void) computesVerboseResultArray: (NSString*) svnStatusText;

- (void) svnCommand: (NSString*)     command
		 options:    (NSArray*)      options
		 info:       (NSDictionary*) info;

- (NSInvocation*) svnOptionsInvocation;
- (void) setDisplayedTaskObj: (NSMutableDictionary*) aDisplayedTaskObj;
- (NSInvocation*) makeCallbackInvocation: (SEL) selector;
- (NSInvocation*) makeCallbackInvocationOfKind: (int) callbackKind;

- (NSString*) workingCopyPath;
- (void) setWorkingCopyPath: (NSString*) str;
- (NSString*) user;
- (void) setUser: (NSString*) aUser;
- (NSString*) pass;
- (void) setPass: (NSString*) aPass;
- (NSString*) revision;
- (void) setRevision: (NSString*) aRevision;

- (NSArray*) svnFiles;
- (void) setSvnFiles: (NSArray*) aSvnFiles;

- (NSDictionary*) svnDirectories;
- (void) setSvnDirectories: (NSDictionary*) aSvnDirectories;

- (NSString*) windowTitle;
- (void) setWindowTitle: (NSString*) aWindowTitle;

- (BOOL) flatMode;
- (void) setFlatMode: (BOOL) flag;
- (BOOL) smartMode;
- (void) setSmartMode: (BOOL) flag;
- (int)  filterMode;
- (void) setFilterMode: (int) aFilterMode;

- (id) controller;
- (NSURL*) repositoryUrl;
- (void) setRepositoryUrl: (NSURL*) aRepositoryUrl;

- (NSString*) outlineSelectedPath;
- (void) setOutlineSelectedPath: (NSString*) anOutlineSelectedPath;

- (NSString*) statusInfo;
- (void) setStatusInfo: (NSString*) aStatusInfo;


@end
