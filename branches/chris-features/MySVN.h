/* MySVN */

#import <Cocoa/Cocoa.h>

@interface MySvn : NSObject
{

}

+ (NSMutableDictionary*) fileMergeItems: (NSArray*)      itemsPaths
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) genericCommand: (NSString*)     command
						 arguments:      (NSArray*)      args
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) moveMultiple:   (NSArray*)      files
						 destination:    (NSString*)     destinationPath
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) copyMultiple:   (NSArray*)      files
						 destination:    (NSString*)     destinationPath
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) log:            (NSString*)     path
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) list:           (NSString*)     path
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) checkout:       (NSString*)     file
						 destination:    (NSString*)     destinationPath
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) extractItems:   (NSArray*)     items
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) import:         (NSString*)     file
						 destination:    (NSString*)     destinationPath
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) copy:           (NSString*)     file
						 destination:    (NSString*)     destinationPath
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) move:           (NSString*)     file
						 destination:    (NSString*)     destinationPath
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) mkdir:          (NSArray*)      files
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) delete:         (NSArray*)      files
						 generalOptions: (NSInvocation*) generalOptions
						 options:        (NSArray*)      options
						 callback:       (NSInvocation*) callback
						 callbackInfo:   (id)            callbackInfo
						 taskInfo:       (id)            taskInfo;

+ (NSMutableDictionary*) statusAtWorkingCopyPath: (NSString*)     path
						 generalOptions:          (NSInvocation*) generalOptions
						 options:                 (NSArray*)      options
						 callback:                (NSInvocation*) callback
						 callbackInfo:            (id)            callbackInfo
						 taskInfo:                (id)            taskInfo;

+ (NSMutableDictionary*) updateAtWorkingCopyPath: (NSString*)     path
						 generalOptions:          (NSInvocation*) generalOptions
						 options:                 (NSArray*)      options
						 callback:                (NSInvocation*) callback
						 callbackInfo:            (id)            callbackInfo
						 taskInfo:                (id)            taskInfo;

+ (NSArray*) optionsFromSvnOptionsInvocation: (NSInvocation*) invocation;

+ (NSString*) joinedOptions: (NSArray*) options1
			  andOptions:    (NSArray*) options2;

+ (NSMutableDictionary*) launchTask:         (NSString*)     taskLaunchPath
						 arguments:          (NSArray*)      arguments
						 callback:           (NSInvocation*) callback
						 callbackInfo:       (id)            callbackInfo
						 taskInfo:           (id)            taskInfo
						 additionalTaskInfo: (id)            additionalTaskInfo;

+ (void) killProcess: (int) pid;

+ (NSString*) cachePathForUrl: (NSURL*) url;

+ (NSString*) cachePathForUrl: (NSURL*)    url
			  revision:        (NSString*) revision;

// CLASS VARIABLES ACCESSORS
+ (NSString *) svnPath;
+ (void) setSvnPath: (NSString *) aSvnPath;
+ (NSString *)bundleScriptPath:(NSString *)script;

@end
