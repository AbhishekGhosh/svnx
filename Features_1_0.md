# Introduction #

### _SvnX_ is a _Free_, open source, _Subversion_ client for _Mac OS X_. ###

<table border='none'><tr>
<td><img src='http://svnx.googlecode.com/svn/wiki/svnX-icon.png' /></td>
<td>SvnX 1.0 runs on Mac OS X 10.4.x & 10.5.x.<br />
SvnX 1.0 is compatible with Subversion 1.4.6, 1.5.6 & 1.6.1.<br />
SvnX 1.0 is provided as a universal binary packaged in a disc image.</td>
</tr></table>

### <font color='green'><a href='http://svnx.googlecode.com/files/svnX%201.0.dmg'>►►►  Download svnX 1.0  ◀◀◀</a></font> ###

![![](http://svnx.googlecode.com/svn/wiki/svnX-1.0-tiny.png)](http://svnx.googlecode.com/svn/wiki/svnX-1.0-big.png)


# Details #

Here is the list of **new** features and changes in **svnX 1.0**.

#### Repositories & Working Copies windows: ####
  * Hide/Show edit fields.  `[`When hidden - editing is disabled. Toggling is via a disclosure button or Cmd-E.  The state is saved/restored to/from the preferences.`]`
  * Pressing return or enter when the list is focused opens the highlighted item.
  * Pressing an alpha-numeric key when the list is focused jumps to the next name beginning with that character.
  * Double-click in list activates existing window if possible.
  * Alt-double-click always opens new window. `[`Old double-click behaviour.`]`
  * Optionally abbreviate Working Copy paths.

#### Working Copy window: ####
  * Updated layout, toolbar, Commit Message sheet & Update alert.  `[`Users of older versions may be need to reset the toolbar.`]`
  * Pressing return or enter when the file list is focused & a single file is highlighted opens that file.
  * Pressing an alpha-numeric key when the file list is focused highlights the next name beginning with that character.
  * Added keyboard support for toolbar items: cmd-shift-F ⇨ Reveal in Finder, cmd-R ⇨ Refresh, cmd-alt-R ⇨ Refresh with updates, cmd-U ⇨ Update, cmd-D ⇨ Diff, cmd-shift-D ⇨ Diff with sheet, cmd-S ⇨ Repository.
  * Extended the Filter pop-up with Conflict & Changed (modified, added, deleted, replaced, conflict, missing or wrong kind) items & added command keys.
  * Replaced Flat Mode & Smart Mode toolbar check-boxes with new View segmented toolbar control.  Maps cmd-ctrl-T ⇨ Tree View, cmd-ctrl-F ⇨ Flat View & cmd-ctrl-S ⇨ Smart View.
  * Improved the look of the tree list and fixed the keyboard focus when it's hidden (also hides the splitter bar).
  * Save & restore each window's frame, view & filter modes.
  * Improvements, corrections & optimisations to file list's help tags.
  * Refresh is up to 5-10 times as fast.  Uses less memory.
  * Fixed commit failure due to mixed end-of-line characters in commit message. `[`Maps all `EoLs` to \n.`]`
  * Fixed dragging of non-selected items in Flat & Smart modes.
  * Maintain file selection after refresh or view mode change.  Also maintain tree state.
  * New recent items menu in search field.
  * Added auto-refresh option (with preference checkbox).  Refreshes Working Copy window each time it’s focused.
  * Added new svn update options sheet.  `[`Alt-click Update action button or toolbar icon to see options for updating selection or entire WC.  Supports updating to any file to any revision & most svn update options.`]`

#### Repository window: ####
  * Updated layout & toolbar.
  * Added new Report toolbar item.  Displays an HTML formatted, printable, log report of any item in the browser.  `[`Alt-click excludes path lists from report. Report window has toolbar with buttons for smaller/bigger text & printing.  Long reports span multiple HTML pages.`]`
  * For all commands normalise end-of-line characters & strip control-characters in commit messages.
  * Faster & better caching of log & repository browser lists.
  * Improved drag feedback (transparent icons).
  * Improved help tags (folders don't have size info).
  * New recent items menu in search field.
  * Correctly browse files with names that start or end with white-space.
  * Replace Advanced/Simple tabbed view with an ‘Advanced’ toggle button.
  * Added new Blame toolbar item.  `[`Supports multiple files & alt-click ⇨ verbose.`]`
  * Search messages and/or paths in Advanced mode.
  * Added initial support for peg revisions (currently Diff & Blame only).  Allows use of commands on deleted files.
  * Replaced 'Browse as a sub-repository' directory items' contextual pop-up menu with double-clicking any item in the browser switches to its log view.
  * Added key equivalents for toolbar items: cmd-D ⇨ Diff, cmd-B & cmd-alt-B ⇨ Blame, cmd-R & cmd-alt-R ⇨ Report, cmd-K ⇨ Checkout, cmd-S ⇨ Export & cmd-O ⇨ Output.

#### Review and Commit window: <font color='red'>  NEW</font> ####
  * Opened by clicking ‘Review…’ button in a Working Copy window.
  * Initially adds all committable items to the Available Items list and marks them as ‘will commit’ (checked).
  * Refreshing the Available Items list adds new items as ‘don’t commit’ (unchecked).
  * The Available Items list responds to cmd-shift-A ⇨ check all, cmd-shift-N ⇨ check none, cmd-R ⇨ refresh.
  * The selected item responds to cmd-D ⇨ Diff, cmd-O or double click ⇨ Open, cmd-T ⇨ toggle commit status & cmd-shift-F ⇨ reveal file in Finder.
  * Drag items to Finder to copy them or to an application’s icon to open them.
  * Items display same help tags as in WC.
  * Displays formatted or raw diff of selected file.  User switchable by clicking ‘Tabular’ or ‘Unified’.
  * Saves & restores window size & splits.
  * Lists, and allows reuse of, the 50 most recent commit messages.
  * Custom commit message templates with keyword substitution & embed-able shell scripts.
> > Keywords are: `<MACHINE>`, `<USER>`, `<DATE>`, `<FILES>`…`</FILES>`, `<FILES>` & `<SCRIPT>`…`</SCRIPT>`.

#### Other: ####
  * Replace Advanced/Simple tabbed view in Diff sheets with an ‘Advanced’ toggle button.
  * Added support for finding in messages & paths in log views.
  * New look Preferences dialog with new 'Abbreviate Working Copy path' option.
  * Improved diff feedback by better preserving file extensions & including revision numbers in temporary file names.
  * Leopard compatible icons.
  * Many bug fixes & optimisations.
  * Updated for compatibility with Subversion 1.5/1.6.
  * Updated help documentation & added commit message template examples.
  * Prompt the user to accept or reject un-trusted SSL server certificates.  `[`Requires ‘Use old parsing method’ preference to be off.`]`
  * Faster caching (no PHP script & only 1 folder) and cache files are ~50% smaller.  `[`User may safely delete any folders in ~/Library/Caches/com.lachoseinteractive.svnX/.`]`
  * Source & project now builds in Xcode 2.3 through 3.1, contains Debug & Release targets, and builds with NO warnings.  `[`It also automatically downloads necessary SVN & APR headers & builds stub libraries.`]`

# Screen Shots #

### Repository Window: ###
![http://svnx.googlecode.com/svn/wiki/NewRepository.png](http://svnx.googlecode.com/svn/wiki/NewRepository.png)

### Working Copy Window: ###
![http://svnx.googlecode.com/svn/wiki/NewWorkingCopy.png](http://svnx.googlecode.com/svn/wiki/NewWorkingCopy.png)

### Update Working Copy Sheet: ###
![http://svnx.googlecode.com/svn/wiki/NewUpdate.png](http://svnx.googlecode.com/svn/wiki/NewUpdate.png)

### Review and Commit Window: ###
![http://svnx.googlecode.com/svn/wiki/ReviewAndCommit.png](http://svnx.googlecode.com/svn/wiki/ReviewAndCommit.png)