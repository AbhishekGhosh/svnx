//
// SvnLogReport.h
//

#import <Cocoa/Cocoa.h>

@class WebView, MySvnView;

@interface SvnLogReport : NSResponder
{
	IBOutlet NSWindow*	fWindow;
	IBOutlet WebView*	fLogView;

@private
	NSString*	fFileURL;
	NSString*	fRevision;
}


- (SvnLogReport*) initWithURL: (NSString*) fileURL
				  revision:    (NSString*) revision;
- (NSTask*) launchTask: (NSString*) taskLaunchPath
			 arguments: (NSArray*) arguments
			 stdOutput: (NSString*) stdOutput;
- (void) begin:   (MySvnView*) svnView
		 verbose: (BOOL)       verbose;
- (void) textSmaller: (id) sender;
- (void) textBigger: (id) sender;
- (void) printDocument: (id) sender;
- (BOOL) validateToolbarItem: (NSToolbarItem*) toolbarItem;
- (NSWindow*) window;

@end

