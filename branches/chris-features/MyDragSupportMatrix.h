/* MyDragSupportMatrix */

#import <Cocoa/Cocoa.h>

@interface MyDragSupportMatrix : NSMatrix
{
    NSRect oldDrawRect, newDrawRect;
    BOOL shouldDraw;

	NSCell *destinationCell;
}


- (BOOL) isCellSelected: (NSCell*) cell;
- (NSCell*) destinationCell;
- (void) setDestinationCell: (NSCell*) aDestinationCell;

@end
