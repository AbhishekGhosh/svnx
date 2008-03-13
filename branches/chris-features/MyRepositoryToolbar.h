
#import <Foundation/Foundation.h>

@class MyRepository;

@interface MyRepositoryToolbar : NSObject
{
	IBOutlet id				window;
	IBOutlet MyRepository*	document;

	NSMutableDictionary*	items; // all items that are allowed to be in the toolbar
}

// private:
- (NSToolbarItem*) createItem: (NSString*) itsID
				   label: (NSString*) itsLabel
				   help: (NSString*) itsHelp
				   image: (NSString*) imageName;
- (NSToolbarItem*) createItem: (NSString*) itsID
				   label: (NSString*) itsLabel
				   help: (NSString*) itsHelp;

@end
