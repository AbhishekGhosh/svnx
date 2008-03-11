/* RepositoriesController */

#import <Cocoa/Cocoa.h>

@class MyRepository, MyDragSupportArrayController;

@interface RepositoriesController : NSObject
{
	IBOutlet MyDragSupportArrayController *repositoriesAC;
    IBOutlet id nameTextField;
    IBOutlet id window;
    IBOutlet NSTableView* tableView;

	NSMutableArray *repositories;
}

- (IBAction)onValidate:(id)sender;
- (IBAction)newRepositoryItem:(id)sender;

- (NSMutableArray *)repositories;
- (void)setRepositories:(NSMutableArray *)aRepositories;
- (void)saveRepositoriesPrefs;
- (void)openRepositoryBrowser:(NSString *)url title:(NSString *)title
		user:(NSString *)user pass:(NSString *)pass;

@end
