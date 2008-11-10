//----------------------------------------------------------------------------------------
//	SvnInterface.m - Interface to Subversion libraries
//
//	Copyright © Chris, 2003 - 2008.  All rights reserved.
//----------------------------------------------------------------------------------------

#include "SvnInterface.h"
#include "svn_config.h"
#include "svn_fs.h"
#include "svn_auth.h"
#include "NSString+MyAdditions.h"


#define	SvnPush(array, obj)		((*(typeof(obj)*) apr_array_push(array)) = (obj))


//----------------------------------------------------------------------------------------

@implementation SvnException

- (id) init: (SvnError) err
{
	self = [super init];
	if (self)
	{
		fError = err;
	}

	return self;
}


//----------------------------------------------------------------------------------------

- (void) dealloc
{
	svn_error_clear(fError);
	[super dealloc];
}


//----------------------------------------------------------------------------------------

- (SvnError) error
{
	return fError;
}


//----------------------------------------------------------------------------------------

- (NSString*) message
{
	return fError ? UTF8(fError->message) : @"";
}

@end	// SvnException


//----------------------------------------------------------------------------------------

void
SvnDoThrow (SvnError err)
{
	@throw [[SvnException alloc] init: err];
}


//----------------------------------------------------------------------------------------

void
SvnDoReport (SvnError err)
{
	// TO_DO: Show alert
#if qDebug
	DbgSvnPrint(err);
#elif 0
	svn_handle_error2(err, stderr, FALSE, kAppName);
#endif
}


//----------------------------------------------------------------------------------------
#pragma mark -
//----------------------------------------------------------------------------------------
// Returns TRUE if the Subversion lib was initialized successfully.

BOOL
SvnInitialize ()
{
#ifndef SVN_LIBS
	#define	SVN_LIBS	/opt/subversion/lib
#endif
#define	STR_STR(s)			#s
#define	APR_LIB_PATH(dir)	(@"" STR_STR(dir) "/libapr-1.0.dylib")
	NSString* const apr_lib_path = APR_LIB_PATH(SVN_LIBS);
#undef	APR_LIB_PATH
#undef	STR_STR
	static BOOL inited = FALSE, exists = FALSE;

	if (!inited)
	{
		inited = TRUE;
		const intptr_t fn1 = (intptr_t) svn_fs_initialize,
					   fn2 = (intptr_t) apr_initialize,
					   fn3 = (intptr_t) svn_ver_check_list;

	#if qDebug
		if (![[NSFileManager defaultManager] fileExistsAtPath: apr_lib_path])
			dprintf("missing lib '%s'", [apr_lib_path UTF8String]);
	#endif
		// Initialize the APR & SVN libraries.
		if (fn1 != 0 && fn2 != 0 && fn3 != 0 &&
			[[NSFileManager defaultManager] fileExistsAtPath: apr_lib_path])
		{
		#if 0
			setenv("LC_ALL", "en_GB.UTF-8", 1);
			exists = (svn_cmdline_init(kAppName, qDebug ? stderr : NULL) == EXIT_SUCCESS);
		#elif 1
			NSLocale* locale = [NSLocale currentLocale];
			char buf[32];
			if (ToUTF8([NSString stringWithFormat: @"%@_%@.UTF-8",
							[locale objectForKey: NSLocaleLanguageCode],
							[locale objectForKey: NSLocaleCountryCode]],
						buf, sizeof(buf)))
			{
			//	dprintf("locale='%s'", buf);
				setlocale(LC_ALL, buf);
				if (apr_initialize() == APR_SUCCESS)
				{
					static const svn_version_checklist_t checklist[] = {
					//	{ "apr",        apr_version        },
						{ "svn_client", svn_client_version },
						{ "svn_fs",     svn_fs_version     },
						{ "svn_subr",   svn_subr_version   },
						{ NULL, NULL }
					};

					SVN_VERSION_DEFINE(my_version);

					SvnError err = svn_ver_check_list(&my_version, checklist);
					exists = (err == NULL);
				#if qDebug
					if (err)
						DbgSvnPrint(err);
				#endif
				}
				else
					dprintf("lapr_initialize() != APR_SUCCESS", 0);
			}
		#endif
		}
		if (!exists)
			dprintf("svn_fs_initialize=0x%X apr_initialize=0x%X", fn1, fn2);
	}

	return exists;
}


//----------------------------------------------------------------------------------------

NSString*
SvnRevNumToString (SvnRevNum rev)
{
	return SVN_IS_VALID_REVNUM(rev) ? [NSString stringWithFormat: @"%d", rev] : @"";
}


//----------------------------------------------------------------------------------------

NSString*
SvnStatusToString (SvnWCStatusKind kind)
{
	switch (kind)
	{
		case svn_wc_status_none:		return @" ";
		case svn_wc_status_unversioned:	return @"?";
		case svn_wc_status_normal:		return @" ";
		case svn_wc_status_added:		return @"A";
		case svn_wc_status_missing:		return @"!";
		case svn_wc_status_deleted:		return @"D";
		case svn_wc_status_replaced:	return @"R";
		case svn_wc_status_modified:	return @"M";
		case svn_wc_status_merged:		return @"G";
		case svn_wc_status_conflicted:	return @"C";
		case svn_wc_status_ignored:		return @"I";
		case svn_wc_status_obstructed:	return @"~";
		case svn_wc_status_external:	return @"X";
		case svn_wc_status_incomplete:	return @"!";
	}

	return @"?";	// ???
}


//----------------------------------------------------------------------------------------
// An authentication callback function of type 'svn_auth_simple_prompt_func_t'.

SvnError
SvnAuthenticate (svn_auth_cred_simple_t** cred,
				 void*                    baton,
				 const char*              realm,
				 const char*              username,
				 SvnBool                  may_save,
				 SvnPool                  pool)
{
	#pragma unused(realm, may_save)
	id delegate = (id) baton;
	svn_auth_cred_simple_t* ret = apr_pcalloc(pool, sizeof(*ret));
	char answerbuf[100];

/*	if (realm)
	{
		printf("Authentication realm: %s\n", realm);
	}*/

	if (username)
	{
		ret->username = apr_pstrdup(pool, username);
	}
	else if (ToUTF8([delegate user], answerbuf, sizeof(answerbuf)))
	{
		ret->username = apr_pstrdup(pool, answerbuf);
	}

	if (ToUTF8([delegate pass], answerbuf, sizeof(answerbuf)))
		ret->password = apr_pstrdup(pool, answerbuf);

//	NSLog(@"SvnAuthenticate username='%s' password='%s'", ret->username, ret->password);
	*cred = ret;
	return SVN_NO_ERROR;
}


//----------------------------------------------------------------------------------------
// An authentication callback function of type 'svn_auth_username_prompt_func_t'.

SvnError
SvnAuthUsername (svn_auth_cred_username_t** cred,
				 void*                    baton,
				 const char*              realm,
				 SvnBool                  may_save,
				 SvnPool                  pool)
{
	#pragma unused(realm, may_save)
	id delegate = (id) baton;
	svn_auth_cred_username_t* ret = apr_pcalloc(pool, sizeof(*ret));
	char answerbuf[100];

	if (ToUTF8([delegate user], answerbuf, sizeof(answerbuf)))
	{
		ret->username = apr_pstrdup(pool, answerbuf);
	}

//	NSLog(@"SvnAuthUsername username='%s'", ret->username);
	*cred = ret;
	return SVN_NO_ERROR;
}


//----------------------------------------------------------------------------------------

SvnAuth
SvnSetupAuthentication (SvnInterface* delegate, SvnPool pool)
{
	apr_array_header_t* providers = apr_array_make(pool, 4, sizeof(SvnAuthProvider));

	SvnAuthProvider provider = NULL;
	void* const baton = delegate;

	svn_auth_get_simple_prompt_provider(&provider, SvnAuthenticate,
										baton, kSvnRetryLimit, pool);
	SvnPush(providers, provider);

	svn_auth_get_username_prompt_provider(&provider, SvnAuthUsername,
										  baton, kSvnRetryLimit, pool);
	SvnPush(providers, provider);

	svn_auth_get_keychain_simple_provider(&provider, pool);
	SvnPush(providers, provider);

	SvnAuth auth_baton = NULL;
	svn_auth_open(&auth_baton, providers, pool);

	return auth_baton;
}


//----------------------------------------------------------------------------------------

SvnClient
SvnSetupClient (SvnInterface* delegate, SvnPool pool)
{
	// Initialize the FS library.
	SvnThrowIf(svn_fs_initialize(pool));

	// Make sure the ~/.subversion run-time config files exist
	SvnThrowIf(svn_config_ensure(NULL, pool));

	// Initialize and allocate the client_ctx object.
	SvnClient ctx = NULL;
	SvnThrowIf(svn_client_create_context(&ctx, pool));

	// Load the run-time config file into a hash
	SvnThrowIf(svn_config_get_config(&ctx->config, NULL, pool));

	ctx->auth_baton = SvnSetupAuthentication(delegate, pool);

	return ctx;
}


#if 0
//----------------------------------------------------------------------------------------

void
SvnDoStatus (SvnInterface* interface)
{	
//	NSLog(@"svn status - begin");
	NSAutoreleasePool* autoPool = [[NSAutoreleasePool alloc] init];
	// Create top-level memory pool.
	SvnPool pool = svn_pool_create(NULL);
	@try
	{
	//	[interface svnBeginStatus];
		[interface svnDoStatus: pool];
	}
	@catch (SvnException* err)
	{
		ReportCatch(err);
		svn_handle_error2([err error], stderr, FALSE, kAppName ": ");
	}
	@finally
	{
		svn_pool_destroy(pool);
		[autoPool release];
//		NSLog(@"svn status - end");
	}
	[interface svnEndStatus];
}


//----------------------------------------------------------------------------------------
// svn info <workingCopyPath>

- (void) svnInfo_new: (SvnPool) pool
{
	SvnClient ctx = [self setupSvn: pool];

	// Set revision to always be the HEAD revision.
	svn_opt_revision_t revision_opt;
	revision_opt.kind = svn_opt_revision_head;

	char path[2048];
	[workingCopyPath getCString: path maxLength: sizeof(path) encoding: NSUTF8StringEncoding];
	SvnThrowIf(svn_client_info(path, &revision_opt, &revision_opt,
							   SvnInfoReceiver, self, !kSvnRecurse, ctx, pool));
}
#endif


//----------------------------------------------------------------------------------------
// End of SvnInterface.m
