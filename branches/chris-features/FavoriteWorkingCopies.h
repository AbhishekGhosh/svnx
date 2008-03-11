/* WorkingCopies */

#import <Cocoa/Cocoa.h>

@class MyDragSupportArrayController;

/* "Implements BOTH the model and the controller of the favorite working copies panel. "*/
@interface FavoriteWorkingCopies : NSObject
{
	NSMutableArray *favoriteWorkingCopies;
	IBOutlet MyDragSupportArrayController *favoriteWorkingCopiesAC;

	IBOutlet id window;
	IBOutlet id nameTextField;
	IBOutlet id pathTextField;
	IBOutlet id workingCopiesTableView;

	IBOutlet id application;
}

- (IBAction)newWorkingCopyItem:(id)sender;

- (IBAction)openPath:(id)sender;
- (IBAction)onValidate:(id)sender;

- (NSArray*) dataArray;
- (void)saveFavoriteWorkingCopiesPrefs;

- (void)onDoubleClick:(id)sender;


///////  favoriteWorkingCopies  ///////

- (NSArray *) favoriteWorkingCopies;
- (void) setFavoriteWorkingCopies: (NSMutableArray *) aFavoriteWorkingCopies;

- (unsigned int) countOfFavoriteWorkingCopies;
- (id) objectInFavoriteWorkingCopiesAtIndex: (unsigned int)index;
- (void) insertObject: (id)anObject inFavoriteWorkingCopiesAtIndex: (unsigned int)index;
- (void) removeObjectFromFavoriteWorkingCopiesAtIndex: (unsigned int)index;
- (void) replaceObjectInFavoriteWorkingCopiesAtIndex: (unsigned int)index withObject: (id)anObject;

// Adds a new working copy with the given path.
- (void)newWorkingCopyItemWithPath:(NSString *)workingCopyPath;

@end
