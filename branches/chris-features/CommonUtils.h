//----------------------------------------------------------------------------------------
//	CommonUtils.h - Common Cocoa utilities & definitions
//
//	Copyright © Chris, 2003 - 2008.  All rights reserved.
//----------------------------------------------------------------------------------------

#pragma once

#include <Foundation/Foundation.h>

#ifndef Assert
#define	Assert(expr)	/*(expr)*/
#endif
#ifndef WarnIf
#define	WarnIf(expr)	(expr)
#endif


typedef const char*			ConstCStr;
#if __LP64__
	typedef double			GCoord;
#elif 1
	typedef float			GCoord;
#endif

#define	kNSTrue		((id) kCFBooleanTrue)
#define	kNSFalse	((id) kCFBooleanFalse)
#define	NSBool(f)	((f) ? kNSTrue : kNSFalse)


id				GetPreference			(NSString* prefKey);
BOOL			GetPreferenceBool		(NSString* prefKey);
int				GetPreferenceInt		(NSString* prefKey);
void			SetPreference			(NSString* prefKey, id prefValue);

NSInvocation*	MakeCallbackInvocation	(id target, SEL selector);

bool			AltOrShiftPressed		();


//----------------------------------------------------------------------------------------

@interface NSSavePanel (MakeAvailable)
	- (void) setIncludeNewFolderButton: (BOOL) flag;
@end


//----------------------------------------------------------------------------------------
// End of CommonUtils.h
