/* MySvnRepositoryBrowserView */

#import <Cocoa/Cocoa.h>
#import "MySvnView.h"

@interface MySvnRepositoryBrowserView : MySvnView
{
	IBOutlet NSBrowser *browser;
	IBOutlet NSTextField *revisionTextField;
	IBOutlet NSMenu *browserContextMenu;
		
	BOOL showRoot;
	BOOL disallowLeaves;
	NSString *browserPath;
}

- (void)unload;

- (void) onDoubleClick: (id) sender;
- (void) fetchSvn;
- (void) fetchSvnListForUrl: (NSString*) theURL
		 column:             (int)       column
		 matrix:             (NSMatrix*) matrix;
- (void) displayResultArray: (NSArray*)  resultArray
		 column:             (int)       column
		 matrix:             (NSMatrix*) matrix;

- (NSMutableArray*) selectedItems;
- (void) setAllowsEmptySelection: (BOOL) flag;
- (void) setAllowsMultipleSelection: (BOOL) flag;
- (void) reset;

- (BOOL)showRoot;
- (void)setShowRoot:(BOOL)flag;
- (BOOL)disallowLeaves;
- (void)setDisallowLeaves:(BOOL)flag;
- (NSString *)browserPath;
- (void)setBrowserPath:(NSString *)aBrowserPath;
- (NSString *)getCachePathForUrl:(NSURL *)theURL;

@end
