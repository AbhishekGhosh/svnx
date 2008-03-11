#import <Cocoa/Cocoa.h>
#import "NSString+MyAdditions.h"


@implementation NSTextView (MyAdditions)

- (void)appendString:(NSString *)string isErrorStyle:(BOOL)isErrorStyle
{
	NSFont *txtFont = [NSFont fontWithName:@"Courier" size:11];
	NSDictionary *txtDict;
	
	if ( isErrorStyle )
	{
		txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtFont, NSFontAttributeName, [NSColor redColor], NSForegroundColorAttributeName, nil];
	
	} else
	{
		txtDict = [NSDictionary dictionaryWithObjectsAndKeys:txtFont, NSFontAttributeName, [NSColor blackColor], NSForegroundColorAttributeName, nil];
	}
	
	NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:txtDict] ;
    [[self textStorage] appendAttributedString:attrStr];
    [attrStr release];
}

@end
