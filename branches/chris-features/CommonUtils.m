//----------------------------------------------------------------------------------------
//	CommonUtils.m - Common Cocoa utilities
//
//	Copyright © Chris, 2003 - 2008.  All rights reserved.
//----------------------------------------------------------------------------------------

#include <Cocoa/Cocoa.h>
#include "CommonUtils.h"
#include "DbgUtils.h"


//----------------------------------------------------------------------------------------

id
GetPreference (NSString* prefKey)
{
	return [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey: prefKey];
}


//----------------------------------------------------------------------------------------

BOOL
GetPreferenceBool (NSString* prefKey)
{
	return [GetPreference(prefKey) boolValue];
}


//----------------------------------------------------------------------------------------

int
GetPreferenceInt (NSString* prefKey)
{
	return [GetPreference(prefKey) intValue];
}


//----------------------------------------------------------------------------------------

void
SetPreference (NSString* prefKey, id prefValue)
{
	[[NSUserDefaults standardUserDefaults] setObject: prefValue forKey: prefKey];
}


//----------------------------------------------------------------------------------------

NSInvocation*
MakeCallbackInvocation (id target, SEL selector)
{
#if qDebug
	NSMethodSignature* methodSig = [[target class] instanceMethodSignatureForSelector: selector];
	if (methodSig == nil)
		dprintf("(%@ '@%s'): ERROR: no method found", target, sel_getName(selector));
	Assert(methodSig != nil);
	NSInvocation* callback = [NSInvocation invocationWithMethodSignature: methodSig];
#else
	NSInvocation* callback = [NSInvocation invocationWithMethodSignature:
									[[target class] instanceMethodSignatureForSelector: selector]];
#endif
	[callback setSelector: selector];
	[callback setTarget:   target];

	return callback;
}


//----------------------------------------------------------------------------------------

bool
AltOrShiftPressed ()
{
	return ([[NSApp currentEvent] modifierFlags] & (NSAlternateKeyMask | NSShiftKeyMask)) != 0;
}


//----------------------------------------------------------------------------------------
#pragma mark	-
//----------------------------------------------------------------------------------------

@interface NSSavePanel (ShouldBeAvailableInOSX10_4)
	- (void) _setIncludeNewFolderButton: (BOOL) flag;
@end


//----------------------------------------------------------------------------------------

@implementation NSSavePanel (MakeAvailable)

- (void) setIncludeNewFolderButton: (BOOL) flag
{
	if ([self respondsToSelector: @selector(_setIncludeNewFolderButton:)])
		[self _setIncludeNewFolderButton: flag];
}


@end


//----------------------------------------------------------------------------------------

@interface CTableView : NSTableView
@end

@implementation CTableView
@end


//----------------------------------------------------------------------------------------
// End of CommonUtils.m
