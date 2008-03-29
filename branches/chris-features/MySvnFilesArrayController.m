#import "MySvnFilesArrayController.h"
#import "MyWorkingCopy.h"

@implementation MySvnFilesArrayController

- (void)search:(id)sender
{
    [self setSearchString:[sender stringValue]];
    [self rearrangeObjects];    
}


- (NSArray*) arrangeObjects: (NSArray*) objects
{
    NSMutableArray* matchedObjects = [NSMutableArray arrayWithCapacity: [objects count]];

	const int filterMode = [document filterMode];
	const BOOL flatMode = [document flatMode];
	NSString* const	selectedPath = [document outlineSelectedPath];
    NSString* const lowerSearch = (searchString != nil && [searchString length] > 0) ? [searchString lowercaseString] : nil;

	NSEnumerator* oEnum;
	id item;
	for (oEnum = [objects objectEnumerator]; item = [oEnum nextObject]; )
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		BOOL test = TRUE;

		if (filterMode != kFilterAll)
		{
			const unichar ch = [[item objectForKey: @"col1"] characterAtIndex: 0];

			switch (filterMode)
			{
				case kFilterModified:
					test = (ch == 'M');
					break;

				case kFilterNew:
					test = (ch == '?');
					break;

				case kFilterMissing:
					test = (ch == '!');
					break;

				case kFilterConflict:
					test = (ch == 'C');
					break;

				case kFilterChanged:	// Modified, added, deleted, replaced, conflict, missing, wrong kind
					test = (ch == 'M' || ch == 'A' || ch == 'D' || ch == 'R' || ch == 'C' || ch == '!' || ch == '~');
					break;
			}
		}

		if (test && !flatMode)
		{
			test = [[item objectForKey: @"dirPath"] isEqualToString: selectedPath] &&
					![[item objectForKey: @"path"] isEqualToString: selectedPath];
		}

		if (test && lowerSearch)
		{
			test = ([[[item objectForKey: @"path"] lowercaseString] rangeOfString: lowerSearch].location != NSNotFound);
		}

		if (test)
			[matchedObjects addObject: item];

		[pool release];
	}

	return [super arrangeObjects: matchedObjects];
}


//  - dealloc:
- (void)dealloc
{
    [self setSearchString: nil];    
    [super dealloc];
}


// - searchString:
- (NSString *)searchString
{
	return searchString;
}
// - setSearchString:
- (void)setSearchString:(NSString *)newSearchString
{
    if (searchString != newSearchString)
	{
        [searchString autorelease];
        searchString = [newSearchString copy];
    }
}

@end
