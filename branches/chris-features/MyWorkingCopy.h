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
	
	NSString *resultString;

	IBOutlet MyWorkingCopyController *controller;
	IBOutlet MySvnFilesArrayController *svnFilesAC;	
	
    NSMutableArray *svnFiles;
	NSMutableDictionary *svnDirectories;

	BOOL flatMode, smartMode;
	BOOL showUpdates; // svn status -u
	int filterMode;
	NSString *statusInfo;
	
	NSMutableDictionary *displayedTaskObj;
}


+ (void) presetDocumentName: name;
- (void) setup: (NSString*) title
		 user:  (NSString*) username
		 pass:  (NSString*) password
		 path:  (NSString*) fullPath;
- (void) svnRefresh;

//- (void)fetchSvnStatus;
//- (void)fetchSvnStatusReceiveData:(NSArray*)shellOutput;
//- (void)fetchSvnStatusReceiveDataFinished: (NSString *)result;

- (void) fetchSvnInfo;
- (void) svnUpdate;
- (void) fileMergeItems: (NSArray*) items;
- (void) fetchSvnStatusVerbose;
- (void) fetchSvnStatusVerboseReceiveDataFinished: (NSString*) result;
- (void) fetchSvnInfoReceiveDataFinished: (NSString*) result;
- (void) computesVerboseResultArray;

//- (void)svnCommand:(NSString *)command options:(NSDictionary *)options;
- (void) svnCommand: (NSString*)     command
		 options:    (NSArray*)      options
		 info:       (NSDictionary*) info;

- (NSInvocation*) svnOptionsInvocation;
- (void) setDisplayedTaskObj: (NSMutableDictionary*) aDisplayedTaskObj;
- (NSInvocation*) makeCallbackInvocationOfKind: (int) callbackKind;


//- (void)computesResultArray;

- (int) filterMode;
- (void) setFilterMode: (int) aFilterMode;

- (void)setResultString: (NSString *)str;
- (NSString *)resultString;

- (void)setWorkingCopyPath: (NSString *)str;
- (NSString *)workingCopyPath;


- (NSString *) user;
- (void) setUser: (NSString *) aUser;
- (NSString *) pass;
- (void) setPass: (NSString *) aPass;
- (NSString*) revision;
- (void) setRevision: (NSString*) aRevision;

- (NSArray *)svnFiles;
- (void)setSvnFiles:(NSMutableArray *)aSvnFiles;

- (NSMutableDictionary *) svnDirectories;
- (void) setSvnDirectories: (NSMutableDictionary *) aSvnDirectories;

- (NSString *) windowTitle;
- (void) setWindowTitle: (NSString *) aWindowTitle;

- (BOOL) flatMode;
- (void) setFlatMode: (BOOL) flag;
- (BOOL) smartMode;
- (void) setSmartMode: (BOOL) flag;
- (BOOL)showUpdates;
- (void)setShowUpdates:(BOOL)flag;

- (id) controller;
- (NSURL*) repositoryUrl;
- (void) setRepositoryUrl: (NSURL*) aRepositoryUrl;

- (NSString *) outlineSelectedPath;
- (void) setOutlineSelectedPath: (NSString *) anOutlineSelectedPath;

- (NSString *)statusInfo;
- (void)setStatusInfo:(NSString *)aStatusInfo;


@end
