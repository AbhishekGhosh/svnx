#import "MySvnLogAC.h"
#import "MyApp.h"

@implementation MySvnLogAC

- (void)search:(id)sender
{
    [self setSearchString:[sender stringValue]];
    [self rearrangeObjects];    
}

- (void)rearrange:(id)sender
{
    [self rearrangeObjects];    
}

- (NSArray*) arrangeObjects: (NSArray*) objects
{
	if (searchString != nil && [searchString length] != 0)
	{
		const BOOL searchInPaths = [GetPreference(@"shouldSearchPathsOrMessages") boolValue];
		NSString* const lowerSearch = [searchString lowercaseString];
		NSMutableArray* const matchedObjects = [NSMutableArray arrayWithCapacity: [objects count]];

		NSEnumerator* oEnum = [objects objectEnumerator];
		id item;
		while (item = [oEnum nextObject])
		{
			NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
			BOOL test = FALSE;

			if (searchInPaths)
			{
				NSArray* paths = [item objectForKey: @"paths"];
				if (paths != nil)
				{
					id pathDict;
					NSEnumerator* pEnum = [paths objectEnumerator];

					while (pathDict = [pEnum nextObject])
					{
				//		NSAutoreleasePool* pool2 = [[NSAutoreleasePool alloc] init];

						NSString* text = [pathDict objectForKey: @"path"];
						if (text != nil && [[text lowercaseString] rangeOfString: lowerSearch].location != NSNotFound)
						{
							test = TRUE;
							break;
						}

						text = [pathDict objectForKey: @"copyfrompath"];
						if (text != nil && [[text lowercaseString] rangeOfString: lowerSearch].location != NSNotFound)
						{
							test = TRUE;
							break;
						}

				//		[pool2 release];
					}
				}
			}
			else
			{
				NSString* text = [item objectForKey: @"msg"];
				if ([[text lowercaseString] rangeOfString: lowerSearch].location != NSNotFound)
					test = TRUE;
			}

			if (test)
				[matchedObjects addObject: item];

			[pool release];
		}

	    objects = matchedObjects;
	}

	return [super arrangeObjects: objects];
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
