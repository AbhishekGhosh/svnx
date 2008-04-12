/* Tasks */

#import <Cocoa/Cocoa.h>

@interface Tasks : NSObject
{
    IBOutlet NSArrayController *tasksAC;

    IBOutlet NSPanel *activityWindow;
	IBOutlet NSDrawer *logDrawer;
	
	IBOutlet NSTextView *logTextView;
	
	id currentTaskObj;
}

+ (id) sharedInstance;

- (IBAction) stopTask:       (id) sender;
- (IBAction) clearCompleted: (id) sender;

- (void) newTaskWithDictionary: (NSMutableDictionary*) taskObj;
- (void) taskDataAvailable: (NSNotification*) aNotification isError: (BOOL) isError;
- (void) cancelCallbacksOnTarget: (id) target;

@end
