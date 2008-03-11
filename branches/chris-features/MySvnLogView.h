/* MySvnLogView */

#import <Cocoa/Cocoa.h>
#import "MySvnView.h"

#import "MySvnLogParser.h"

@interface MySvnLogView : MySvnView
{
    IBOutlet id svnLog;
	IBOutlet NSArrayController *logsAC;
	IBOutlet NSArrayController *logsACSelection;

	NSString *currentRevision;

	NSString *path;
	NSMutableArray *logArray;
	int mostRecentRevision; // remembers most recent revision to avoid fetching from scratch
	BOOL isVerbose; // passes -v to svn log to retrieve the changed paths of each revision
}

- (void)unload;

- (void) resetUrl: (NSURL*) anUrl;
- (void)fetchSvnLog;
- (void)fetchSvn;
- (void)fetchSvnLogForUrl;
- (void)fetchSvnLogForPath;

- (NSString*) selectedRevision;
- (NSString *)currentRevision;
- (void)setCurrentRevision:(NSString *)aCurrentRevision;

- (NSString *)path; // Sets the path to get the log from. If set, url and revision won't be used.
- (void)setPath:(NSString *)aPath;

- (BOOL)isVerbose;
- (void)setIsVerbose:(BOOL)flag;

- (NSMutableArray *)logArray;
- (void)setLogArray:(NSMutableArray *)aLogArray;

- (int)mostRecentRevision;
- (void)setMostRecentRevision:(int)aMostRecentRevision;

- (NSString *)getCachePath;

@end
