/* Tasks */

#import <Cocoa/Cocoa.h>

@class MySvn;

@interface Tasks : NSObject
{
    IBOutlet NSArrayController *tasksAC;

    IBOutlet NSPanel *activityWindow;
	IBOutlet NSDrawer *logDrawer;
	
	IBOutlet NSTextView *logTextView;
	
	id currentTaskObj;
}

+ (id) sharedInstance;

- (IBAction)stopTask:(id)sender;
- (IBAction)clearCompleted:(id)sender;

- (void) cancelCallbacksOnTarget: (id) target;
- (void) invokeCallBackForTask: (id) taskObj;
- (NSMutableAttributedString*) appendString:       (NSString*)                  string
							   toAttributedString: (NSMutableAttributedString*) otherString
							   errorStyle:         (BOOL)                       isError;

@end
