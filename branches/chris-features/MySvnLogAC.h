/* MySvnLogAC */

#import <Cocoa/Cocoa.h>

@interface MySvnLogAC : NSArrayController
{
	NSString *searchString;
}


- (void) setSearchString: (NSString*) newSearchString;

@end
