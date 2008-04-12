//----------------------------------------------------------------------------------------
//	CommonUtils.h - Common Cocoa utilities & definitions
//
//	Copyright © Chris, 2003 - 2008.  All rights reserved.
//----------------------------------------------------------------------------------------

#pragma once

#include <Foundation/Foundation.h>


typedef const char*			ConstCStr;
#if __LP64__
	typedef double			GCoord;
#elif 1
	typedef float			GCoord;
#endif

#define	kNSTrue		((id) kCFBooleanTrue)
#define	kNSFalse	((id) kCFBooleanFalse)
#define	NSBool(f)	((f) ? kNSTrue : kNSFalse)


id		GetPreference (NSString* prefKey);


//----------------------------------------------------------------------------------------
// End of CommonUtils.h
