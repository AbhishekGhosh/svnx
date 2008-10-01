/*
 * apr_svn.c - apr & svn .dylib stubs for functions used by svnX
 */

#include "apr.h"
#include "apr_general.h"
#include "apr_pools.h"
#include "apr_tables.h"


/*----------------------------------------------------------------------*/

#ifdef LIB_svn_client
#include "svn_client.h"

svn_error_t *
svn_client_info(const char *path_or_url,
                const svn_opt_revision_t *peg_revision,
                const svn_opt_revision_t *revision,
                svn_info_receiver_t receiver,
                void *receiver_baton,
                svn_boolean_t recurse,
                svn_client_ctx_t *ctx,
                apr_pool_t *pool)
{
	return 0;
}


svn_error_t *
svn_client_status2(svn_revnum_t *result_rev,
                   const char *path,
                   const svn_opt_revision_t *revision,
                   svn_wc_status_func2_t status_func,
                   void *status_baton,
                   svn_boolean_t recurse,
                   svn_boolean_t get_all,
                   svn_boolean_t update,
                   svn_boolean_t no_ignore,
                   svn_boolean_t ignore_externals,
                   svn_client_ctx_t *ctx,
                   apr_pool_t *pool)
{
	return 0;
}


svn_error_t *
svn_client_create_context(svn_client_ctx_t **ctx,
                          apr_pool_t *pool)
{
	return 0;
}

#endif	// LIB_svn_client


/*----------------------------------------------------------------------*/

#ifdef LIB_svn_subr
#include "svn_error.h"
#include "svn_auth.h"

apr_pool_t *svn_pool_create_ex(apr_pool_t *parent_pool,
                               apr_allocator_t *allocator)
{
	return 0;
}


svn_error_t *svn_config_ensure(const char *config_dir, apr_pool_t *pool)
{
	return 0;
}


svn_error_t *svn_config_get_config(apr_hash_t **cfg_hash,
                                   const char *config_dir,
                                   apr_pool_t *pool)
{
	return 0;
}


void svn_handle_error2(svn_error_t *error,
                       FILE *stream,
                       svn_boolean_t fatal,
                       const char *prefix)
{
}


void svn_error_clear(svn_error_t *error)
{
}


void
svn_auth_get_keychain_simple_provider(svn_auth_provider_object_t **provider,
                                      apr_pool_t *pool)
{
}


void
svn_auth_get_simple_prompt_provider(svn_auth_provider_object_t **provider,
                                    svn_auth_simple_prompt_func_t prompt_func,
                                    void *prompt_baton,
                                    int retry_limit,
                                    apr_pool_t *pool)
{
}


void svn_auth_get_username_prompt_provider
  (svn_auth_provider_object_t **provider,
   svn_auth_username_prompt_func_t prompt_func,
   void *prompt_baton,
   int retry_limit,
   apr_pool_t *pool)
{
}


void svn_auth_open(svn_auth_baton_t **auth_baton,
                   apr_array_header_t *providers,
                   apr_pool_t *pool)
{
}

#endif	// LIB_svn_subr


/*----------------------------------------------------------------------*/

#ifdef LIB_svn_fs
#include "svn_fs.h"


svn_error_t *svn_fs_initialize(apr_pool_t *pool)
{
	return 0;
}


#endif	// LIB_svn_fs


/*----------------------------------------------------------------------*/

#ifdef LIB_apr

APR_DECLARE(apr_status_t) apr_initialize(void)
{
	return 0;
}


APR_DECLARE(void *) apr_palloc(apr_pool_t *p, apr_size_t size)
{
	return 0;
}


APR_DECLARE(char *) apr_pstrdup(apr_pool_t *p, const char *s)
{
	return 0;
}


APR_DECLARE(void) apr_pool_destroy(apr_pool_t *p)
{
}


APR_DECLARE(apr_array_header_t *) apr_array_make(apr_pool_t *p,
                                                 int nelts, int elt_size)
{
	return 0;
}


APR_DECLARE(void *) apr_array_push(apr_array_header_t *arr)
{
	return 0;
}

#endif	// LIB_apr


/*
----------------------------------------------------------------------
LIBS="svn_client svn_subr svn_fs apr"
OTHER_LDFLAGS = -weak_library $APR_SVN/libsvn_client.dylib -weak_library $APR_SVN/libsvn_subr.dylib -weak_library $APR_SVN/libsvn_fs.dylib -weak_library $APR_SVN/libapr.dylib
SVN_LIBS = /opt/subversion/lib

----------------------------------------------------------------------
libsvn_client
	_svn_client_info
	_svn_client_status2
	_svn_client_create_context
libsvn_subr
	_svn_pool_create_ex
	_svn_auth_get_keychain_simple_provider
	_svn_auth_get_simple_prompt_provider
	_svn_auth_get_username_prompt_provider
	_svn_auth_open
	_svn_config_ensure
	_svn_config_get_config
	_svn_error_clear
libsvn_fs
	_svn_fs_initialize
libapr
	_apr_pool_destroy
	_apr_array_make
	_apr_array_push
	_apr_initialize
	_apr_palloc
	_apr_pstrdup
----------------------------------------------------------------------
*/

