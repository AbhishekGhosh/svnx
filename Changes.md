<a href='Hidden comment: ..............................  1.3.4  ..............................'></a>
# 1.3.4 — <font color='#0B0'>RELEASE</font>    <font size='3'>2012–09–04    <a href='http://code.google.com/p/svnx/wiki/Features_1_3'>View Detailed Features and Changes</a></font> #

#### General ####
  * Improved compatibility with OSX 10.8 (Mountain Lion) & Xcode 4.4.
  * Fixed a problem where a stopped task could truncate its output.
  * Clearing the field ‘Path to svn binaries folder’ in Preferences causes svnX to re-check the default paths & reset the field to a suitable default.
  * Some small updates to content of the Help book.

#### Working Copy windows ####
  * Fixed a refresh problem resulting from Subversion providing incorrectly escaped URLs.

#### Repository windows ####
  * Improved inter-view tabbing.
  * Trim leading new-lines from Message column.
  * Enabled Find panel for current message text view.
  * Fixed a problem where browsing a repository would sometimes fail.
  * Correctly calculate the the real column widths in the repository browser.
  * When a checkout is automatically added to the Working Copies window it is now named by combining the working copy folder name & the repository name.

**NOTE:** Users who experienced svnX crashing on launch when using Subversion binaries from WANdisco on OSX 10.8 should download & install new binaries from them, as they have fixed the problem.
<p /><br />



---

<a href='Hidden comment: ..............................  1.3.3  ..............................'></a>
# 1.3.3 — <font color='#0B0'>RELEASE</font>    <font size='3'>2012–04–09    <a href='http://code.google.com/p/svnx/wiki/Features_1_3'>View Detailed Features and Changes</a></font> #

#### General ####
  * Added [Growl](http://growl.info) support.  <font color='#F70'><b>NEW</b></font><br />`[`Notifies Growl on completion of checkout, commit, update, merge, etc.  Each may be enabled/disabled independently.<br />  To enable this functionality Growl must be obtained & installed separately.`]`
  * Improved compatibility with FileMerge and Xcode 4.3.x.
  * The Preferences window’s Diff application menu is now build from DiffApps.plist.  This also adds some handy tool-tips to the menu.
  * Now runs pre-flight checks before executing a Diff command to determine availability of chosen diff application.  <font color='#F70'><b>NEW</b></font><br />`[`Any failure is reported along with Help & Open Preferences buttons.`]`
  * When using FileMerge as the diff application, any error output is no longer suppressed.
  * Progress & any output from ‘`svn diff`’ commands is now displayed in the Output drawers of Working Copy or Repository windows.
  * Fixed a problem using kdiff3 as the diff application.
  * Improved checking for new svnX releases.

#### Working Copy windows ####
  * Added helpful tool-tips to the command buttons.
  * Added basic Quick Look support.  <font color='#F70'><b>NEW</b></font><br />`[`Press the spacebar to show or hide a Quick Look panel of the currently selected items.<br />  This feature is only available on Mac OS X 10.5+.`]`
  * Reveal in Finder will now reveal all selected items.<br />`[`If no items are selected then the current tree folder or working copy root folder is revealed.<br />  If no selected items exist on disc then svnX will just beep.`]`

#### Repository windows ####
  * Fixed a problem (possibly a bug in Subversion) when exporting items with names that contain ‘@’.

#### Activity window ####
  * The Stop button now only tries to stop the selected tasks.
  * Fixed problem where last output/error line in log was sometimes duplicated.
<br />



---

<a href='Hidden comment: ..............................  1.3.2  ..............................'></a>
# 1.3.2 — <font color='#0B0'>RELEASE</font>    <font size='3'>2012–01–01    <a href='http://code.google.com/p/svnx/wiki/Features_1_3'>View Detailed Features and Changes</a></font> #

#### General ####
  * SvnX may now request authorisation to write to /opt/subversion/lib if it needs to add some missing symbolic links there.<br />`[`Once done you should not be bothered again until you upgrade your Subversion installation.`]`
  * Overly long error messages are now truncated to prevent Cocoa from creating alerts taller than your screen.
  * Added support for ECMerge as a Diff and Resolve application.

#### Working Copy windows ####
  * Opening a Working Copy window that is using Subversion 1.6 format (or earlier) when you are using Subversion 1.7 will allow you to upgrade it to Subversion 1.7 format.
  * Fixed the Working Copy’s interactive Resolve command when using Subversion 1.7.
  * If setting or deleting Subversion properties via the Properties panel fails then an alert is displayed.<br />`[`Deleting a property that does not exist on all selected files may fail with Subversion 1.6.  This appears to be fixed in Subversion 1.7.`]`

#### Review & Commit windows ####
  * Correctly displays diffs for file paths that contain ‘'’, ‘"’ & ‘$’.
  * Improved display of Subversion properties, especially multiple properties.
  * Now parses & displays Subversion property diffs from Subversion 1.7.<br />`[`Also works around Subversion 1.7 inserting empty diff blocks.`]`
<br />



---

<a href='Hidden comment: ..............................  1.3.1  ..............................'></a>
# 1.3.1 — <font color='#0B0'>RELEASE</font>    <font size='3'>2011–08–01    <a href='http://code.google.com/p/svnx/wiki/Features_1_3'>View Detailed Features and Changes</a></font> #

**NOTE:** SvnX 1.3.x will probably be the last verison to support Mac OS X 10.4.x & Subverison 1.4.x.<br />(If this is an issue for you then please bring it up on the svnX discussion group.)

#### General ####
  * Fixed a problem with the Diff command and Subversion 1.6.17 using a temporary file.<br />`[`Only affects files that have Subversion property `svn:eol-style=…` or similar.`]`
  * Some small improvements to the `svnx` CLI tool.<br />`[`Including better relative-path support.`]`

#### Repository windows ####
  * Fixed a problem with highlighting/selecting items in the repository browser.

#### Working Copy windows ####
  * Display tree conflicts as a ‘C’ in the 4th column (requires Subversion 1.6.x).<br />`[`Tree conflict items will now be included in the Conflict filter & may be reverted or marked as resolved.`]`
<br />



---

<a href='Hidden comment: ..............................  1.3  ..............................'></a>
# 1.3 — <font color='#0B0'>RELEASE</font>    <font size='3'>2010–11–02    <a href='http://code.google.com/p/svnx/wiki/Features_1_3'>View Detailed Features and Changes</a></font> #

**NOTE:** Also includes all changes listed under 1.3b1.

#### General ####
  * Some minor changes to support for ‘@’ in file names.

#### Working Copies & Repositories windows ####
  * Some small improvements to the list views.

#### Working Copy windows ####
  * Further improved the ‘Repository’ toolbar item’s Repository matching.
  * Fixed a problem where minimising a window while a Refresh was underway would abnormally terminate the refresh.
<br />



---

<a href='Hidden comment: ..............................  1.3b1  ..............................'></a>
# 1.3b1 — <font color='#D00'>BETA</font>    <font size='3'>2010–09–15    <a href='http://code.google.com/p/svnx/wiki/Features_1_3'>View Detailed Features and Changes</a></font> #

#### General ####
  * Added support for ‘@’ in file names.  <font color='#F70'><b>NEW</b></font>
  * If app had to fix-up ‘`/opt/subversion/lib`’ then report success to user with option to re-launch.
  * New Apple Help help document.  <font color='#F70'><b>NEW</b></font><br />`[`Includes Change Log & license.`]`
  * On first launch of new version of app the Change Log is displayed.

#### Working Copy windows ####
  * Added new WC ‘Blame’ & ‘Blame Verbose’ contextual menu commands.  <font color='#F70'><b>NEW</b></font>
  * Added new WC ‘Ignore’ contextual menu command.  <font color='#F70'><b>NEW</b></font>
  * When opening WC window (that uses https) ask user to interactively validate any invalid/unknown SSL cert.  <font color='#F70'><b>NEW</b></font><br />`[`Accepting the cert ensures that any subsequent commit etc. will not fail due to auth status.`]`
  * Fixed ‘`svn cleanup`’ for selected folders when in flat-view mode & not using svn libs.
  * Merged WC column 8 into column 2.
  * Added tool-tips for the first 7 column titles (OSX 10.5+).
  * Don’t show expansion tool-tip for first 7 columns.
  * Block contextual menu if window has an open sheet.
  * Fixed problem with window not opening at previous position.
  * The ‘Repository’ toolbar item is now better at choosing a Repository window.

#### Review & Commit windows ####
  * The diff pane settings pop-up menu’s ‘Highlight Characters’ (on/off) option has been replaced with a new ‘Character Diffs:’ group with 5 levels (‘Best’, ‘Medium’, ‘Fast’, ‘Fastest’ & ‘Off’).
  * Display some informative & friendly feedback, in the diffs pane, following a successful or failed commit.  <font color='#F70'><b>NEW</b></font>

#### Repository windows ####
  * When opening Repo window (that uses https) ask user to interactively validate any invalid/unknown SSL cert.  <font color='#F70'><b>NEW</b></font>
  * Disable Checkout & Import toolbar items when a file is selected.
  * For Report, Checkout, Export & Import commands: display consistent repo paths.
  * Allow ‘[’, ‘:’ & ‘]’ characters in new names for Copy, Move & Make Dir commands.
<br />



---

<a href='Hidden comment: ....................  1.2  ....................'></a>
# 1.2 — <font color='#0B0'>RELEASE</font>    <font size='3'>2010–06–01    <a href='http://code.google.com/p/svnx/wiki/Features_1_2'>View Detailed Features and Changes</a></font> #

**NOTE:** Also includes all changes listed under 1.2b1.

#### Working Copy windows ####
  * Support property values starting with ‘-’ when not using direct library calls.
  * Added support for DiffMerge diff application to Resolve command.
  * Truncate Name column in middle when necessary.
  * Fixed problem with ‘Cleanup entire working copy’ command.
  * Fixed crash with ‘`svnx resolve …`’ if window was not open.

#### Repository windows ####
  * Improved support for empty/new repositories.
  * Copy username & password when creating a working copy entry from a repository checkout.
  * Fixed crash if user closed a repository window immediately after initiating a log refresh.

#### Review & Commit window ####
  * Allow long lines to wrap in diff panel.

#### General ####
  * Improved support for KDiff3 diff application.
  * Fixed some compatibility issues with Mac OS X 10.4.
<br />



---

<a href='Hidden comment: ....................  1.2b1  ....................'></a>
# 1.2b1 — <font color='#D00'>BETA</font>    <font size='3'>2010–04–23    <a href='http://code.google.com/p/svnx/wiki/Features_1_2'>View Detailed Features and Changes</a></font> #

#### Working Copy windows ####
  * Subversion properties browser & editor panel.  <font color='#F70'><b>NEW</b></font><br />`[`View, add, edit & delete multiple text & binary properties on multiple items.`]`
  * Interactively resolve file conflicts.  <font color='#F70'><b>NEW</b></font>
  * Merge sheet now provides dry-run & Subversion 1.6 feature support including reintegrate, depth control, automatic conflict resolution & record only.
  * Support for Subversion 1.6 features has also been added to the Update sheet including force operation, depth control & automatic conflict resolution.
  * Diff any items against their PREV revisions with a single click or key press.  <font color='#F70'><b>NEW</b></font>
  * New item list contextual menu provides access to several commands including new ‘svn info’ commands.  <font color='#F70'><b>NEW</b></font>
  * Rename or copy items in flat-view & smart-view modes.
  * Support for ‘`svn cleanup`’ command.  <font color='#F70'><b>NEW</b></font>
  * Removed ‘Working Copy Path’ toolbar item.
  * Improved save & restore of window settings & state.

#### Review & Commit windows ####
  * Display side-by-side diffs.  <font color='#F70'><b>NEW</b></font>
  * Diff pane settings pop-up menu to customise & control many aspects of the diff display.  <font color='#F70'><b>NEW</b></font>
  * Protect user from accidental closure/loss of un-commited message.

#### Repository windows ####
  * Drag & drop a repository log entry to a working copy window to request a reverse merge of that change.  <font color='#F70'><b>NEW</b></font>
  * Drag & drop a repository log entry’s path item to a working copy window to request a reverse merge of that change of that file/directory.  <font color='#F70'><b>NEW</b></font><br />`[`Also drag either of the above to a text editor or the Finder.`]`
  * Diff repository items, log entries (changes) & log entry paths against their PREV revisions with a single click or key press.  <font color='#F70'><b>NEW</b></font>
  * Blame & its verbose option now also supports log entry path items.
  * Directly open files & directories from there log entry path items.
  * Browse the log of any repository log entry paths (like you can for repository items).
  * Added support to Import sheet for enable/disable automatic properties, disregard ignore settings, force operation & depth control (last 2 require svn 1.6+).
  * Improved import, export & checkout file selection sheets with better prompts & custom button titles.
  * Improved save & restore of window settings & state.

#### General ####
  * New global icon cache for improved display, performance & resource usage.
  * Various bug fixes & code improvements.
  * Added several new & updated other keyboard short-cuts.
  * Added support for Guiffy & KDiff3 diff applications.
  * Improved naming of temporary diff files, repository files & blame files.
  * Added ‘resolve’ command to `svnx` shell-script/tool.
  * Updated & extended documentation.
<br />



---

<a href='Hidden comment: ....................  1.1  ....................'></a>
# 1.1 — <font color='#0B0'>RELEASE</font>    <font size='3'>2009–10–28    <a href='http://code.google.com/p/svnx/wiki/Features_1_1'>View Detailed Features and Changes</a></font> #

**NOTE:** Also includes all changes listed under 1.1b1, 1.1b2 & 1.1b3.

#### Working Copy windows ####
  * The ‘Review…’ button now only opens additional Review & Commit windows if _alt_ is pressed.  Otherwise it activates an extant R&C window.
  * Automatically refresh all related Review & Commit file lists after refreshing the working copy’s file list.
  * Fixed an occasional crash when refreshing the file list and ‘Call Subversion libraries directly’ preference is on.
  * Improved diff compatibility with Subversion 1.6.x.

#### Review & Commit windows ####
  * Always display the working copy relative paths of items - regardless of Working Copy window’s view mode.
  * Refreshing the list should now always work correctly when the ‘Call Subversion libraries directly’ preference is off.

#### Preferences window ####
  * Fixed a problem with Sparkle that prevented the ‘Check for updates at startup’ preference from working.

#### General ####
  * Allow opening of diff sheet for a path that doesn’t exist at HEAD.
  * Smaller & prettier disc image.
  * Fixed some memory leaks.
<br />



---

<a href='Hidden comment: ....................  1.1b3  ....................'></a>
# 1.1b3 — <font color='#D00'>BETA</font>    <font size='3'>2009–05–30    <a href='http://code.google.com/p/svnx/wiki/Features_1_1'>View Detailed Features and Changes</a></font> #

#### General ####
  * Fixed a crash on launch, on Intel only, if the Subversion libraries aren’t found.  (Ouch!)
<br />



---

<a href='Hidden comment: ....................  1.1b2  ....................'></a>
# 1.1b2 — <font color='#D00'>BETA</font>    <font size='3'>2009–05–27    <a href='http://code.google.com/p/svnx/wiki/Features_1_1'>View Detailed Features and Changes</a></font> #

#### Repository windows ####
  * Fixed an irrelevant error message when using Blame.

#### Working Copy windows ####
  * Prevent launching multiple concurrent `svn info/status` tasks to refresh the list.
  * Don’t log the standard output of `svn status` tasks in Activity.  `[`Saves memory & is ~30% faster.`]`
  * Correctly save & restore the selected files when in Tree view mode.
  * Fixed a crash when changing View mode and ‘Call Subversion libraries directly’ preference is off.
  * Reduced memory usage & fixed a leak when parsing the output of `svn status`.

#### Preferences window ####
  * Changed the enabling of the ‘Call Subversion libraries directly’ preference and its affect.<br />`[`The tool & library versions must now match exactly.`]`
<br />



---

<a href='Hidden comment: ....................  1.1b1  ....................'></a>
# 1.1b1 — <font color='#D00'>BETA</font>    <font size='3'>2009–05–22    <a href='http://code.google.com/p/svnx/wiki/Features_1_1'>View Detailed Features and Changes</a></font> #

#### Repository windows ####
  * The selected repository items may now be opened directly (in an appropriate application).  <font color='#F70'><b>NEW</b></font>
  * Drag one or more items onto a Docked application’s icon to open them with that app.
  * Drag them into an application’s document window to insert them.
  * The ‘Name opened repository items with rev’ preference allows the adding of the revision number to an opened item’s file name.
  * Exporting/extracting a directory item by dragging it to the Finder now presents an alert with a Cancel button.
  * Import a file or folder by clicking the Import toolbar icon and choosing the file or folder.  With improved import sheet.
  * Double clicking a path of a log item will display the log of that path.
  * Repository directory lists are sorted alpha-numerically & case-insensitively.
  * Repository directory lists are faster.
  * Copy, Move, Make Dir, Delete & Import now, on completion, update the log & switch the browser to the latest revision.
  * Improved user interface when the log is that of a file.
  * Dragging an item into a Working Copy window now opens an svn Merge sheet.  `[`The old svn Switch support is still also available.`]`
  * Clicking the Report toolbar icon now opens an options sheet.  <font color='#F70'><b>NEW</b></font> <br />`[`Report on the selected repository item or the currently displayed log items, include changed paths, continue past copies, revision dates or relative ages, reverse order & limit length.`]`
  * Action codes in log paths tables & reports are colorised.
  * Added alpha-numeric & case-insensitive sorting to log paths tables.

#### Working Copy windows ####
  * Subversion merge support is now available via dragging a file or folder from a Repository window into a Working Copy window.  <font color='#F70'><b>NEW</b></font> <br />`[`Merge a single change, a range of revisions, the difference between 2 URLs, reverse changes and recursively merge a directory.`]`
  * Files are now sorted alpha-numerically & case-insensitively.
  * Current & Last changed columns are now sorted numerically.
  * Allows opening of multiple-file selections.
  * A Recursive option has been added for add, remove, update, revert & resolved commands along with several other improvements.
  * Svn switch now correctly uses the prevailing revision number & not that of the last change.

#### Preferences window ####
  * Gets & displays the version number from the svn tool and validates the binaries folder path.  <font color='#F70'><b>NEW</b></font>
  * Prevents use of svnX until the svn tool’s path is valid.
  * Improved error messages if svn tool not found.
  * Disables the ‘Call Subversion libraries directly’ option if the specified svn tool’s version is not compatible with the libraries.
  * Added support for DiffMerge as a diff application.
  * Added support for Changes as a diff application.
  * Added colour swatch for Conflicted files in working copies.  <font color='#F70'><b>NEW</b></font>

#### Other changes ####
  * New `svnx` shell-script/tool that allows access to svnX features from a terminal window (a link is installed at `~/bin/svnx`).  <font color='#F70'><b>NEW</b></font> <br />Available commands are: <br />`    log <file-path>        `- open a log sheet. <br />`    wc [working-copy-path] `- open a working copy window. <br />`    rep [wc-path-or-URL]   `- open a repository window. <br />`    diff <file-path…>      `- compare files with their base revisions. <br />`    open <file-path…>      `- open files in appropriate applications. <br />`    help                   `- display some help text.
  * The opening of files (in appropriate applications) from Working Copy windows, Review & Commit windows, Repository windows (directly or via Blame) and via AppleScript or `svnx open` is determined by a customisable script.  <font color='#F70'><b>NEW</b></font>
  * Improved drag & drop support in Working Copies & Repositories windows. <br />Allows copying of Working Copy items, dropping of URLs, `*.webloc` files & folders in Repositories window.
  * Various small improvements to Review & Commit windows.
  * Fixed a crash when updating the Repository URL (with old parsing).
  * Some improvements to management of sub-tasks.
  * Some memory leaks have been fixed.
<br />



---

<a href='Hidden comment: ....................  1.0  ....................'></a>
# 1.0 — <font color='#0B0'>RELEASE</font>    <font size='3'>2009–04–14    <a href='http://code.google.com/p/svnx/wiki/Features_1_0'>View Detailed Features and Changes</a></font> #

#### Repositories & Working Copies windows: ####
  * Hide/Show edit fields.  `[`When hidden - editing is disabled. Toggling is via a disclosure button or cmd–E.  The state is saved/restored to/from the preferences.`]`
  * Pressing return or enter when the list is focused opens the highlighted item.
  * Pressing an alpha-numeric key when the list is focused jumps to the next name beginning with that character.
  * Double-click in list activates existing window if possible.
  * Alt-double-click always opens new window. `[`Old double-click behaviour.`]`
  * Optionally abbreviate Working Copy paths.

#### Working Copy window ####
  * Updated layout, toolbar, Commit Message sheet & Update alert.  `[`Users of older versions may be need to reset the toolbar.`]`
  * Pressing return or enter when the file list is focused & a single file is highlighted opens that file.
  * Pressing an alpha-numeric key when the file list is focused highlights the next name beginning with that character.
  * Added keyboard support for toolbar items: cmd–shift–F ⇨ Reveal in Finder, cmd–R ⇨ Refresh, cmd–alt–R ⇨ Refresh with updates, cmd–U ⇨ Update, cmd–D ⇨ Diff, cmd–shift–D ⇨ Diff with sheet, cmd–S ⇨ Repository.
  * Extended the Filter pop-up with Conflict & Changed (modified, added, deleted, replaced, conflict, missing or wrong kind) items & added command keys.
  * Replaced Flat Mode & Smart Mode toolbar check-boxes with new View segmented toolbar control.  Maps cmd–ctrl–T ⇨ Tree View, cmd–ctrl–F ⇨ Flat View & cmd–ctrl–S ⇨ Smart View.
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

#### Repository window ####
  * Updated layout & toolbar.
  * Added new Report toolbar item.  Displays an HTML formatted, printable, log report of any item in the browser.  `[`Alt-click excludes path lists from report. Report window has toolbar with buttons for smaller/bigger text & printing.  Long reports span multiple HTML pages.`]`
  * For all commands normalise end-of-line characters & strip control-characters in commit messages.
  * Faster & better caching of log & repository browser lists.
  * Improved drag feedback (transparent icons).
  * Improved help tags (folders don't have size info).
  * New recent items menu in search field.
  * Correctly browse files with names that start or end with white-space.
  * Replace Advanced/Simple tabbed view with an ‘Advanced’ toggle button.
  * Added new Blame toolbar item.  `[`Supports multiple files & alt–click ⇨ verbose.`]`
  * Search messages and/or paths in Advanced mode.
  * Added initial support for peg revisions (currently Diff & Blame only).  Allows use of commands on deleted files.
  * Replaced 'Browse as a sub-repository' directory items' contextual pop-up menu with double-clicking any item in the browser switches to its log view.
  * Added key equivalents for toolbar items: cmd–D ⇨ Diff, cmd–B & cmd–alt–B ⇨ Blame, cmd–R & cmd–alt–R ⇨ Report, cmd–K ⇨ Checkout, cmd–S ⇨ Export & cmd–O ⇨ Output.

#### Review and Commit window  <font color='#F70'><b>NEW</b></font> ####
  * Opened by clicking ‘Review…’ button in a Working Copy window.
  * Initially adds all committable items to the Available Items list and marks them as ‘will commit’ (checked).
  * Refreshing the Available Items list adds new items as ‘don’t commit’ (unchecked).
  * The Available Items list responds to cmd–shift–A ⇨ check all, cmd–shift–N ⇨ check none, cmd–R ⇨ refresh.
  * The selected item responds to cmd–D ⇨ Diff, cmd–O or double click ⇨ Open, cmd–T ⇨ toggle commit status & cmd–shift–F ⇨ reveal file in Finder.
  * Drag items to Finder to copy them or to an application’s icon to open them.
  * Items display same help tags as in WC.
  * Displays formatted or raw diff of selected file.  User switchable by clicking ‘Tabular’ or ‘Unified’.
  * Saves & restores window size & splits.
  * Lists, and allows reuse of, the 50 most recent commit messages.
  * Custom commit message templates with keyword substitution & embeddable shell scripts. <br />Keywords are: `<MACHINE>`, `<USER>`, `<DATE>`, `<FILES>`…`</FILES>`, `<FILES>` & `<SCRIPT>`…`</SCRIPT>`.

#### Other changes ####
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
  * Source & project now builds in Xcode 2.3 through 3.1, contains Debug & Release targets, and builds with NO warnings. <br />`[`It also automatically downloads necessary SVN & APR headers & builds stub libraries.`]`
<br />



---

<a href='Hidden comment: ....................  0.9.x  ....................'></a>
<a href='Hidden comment: 2007-10-26'></a>
#### 0.9.13 ####
  * Improves stability on Leopard.

#### 0.9.12 ####
  * Fixed wrong status bug for conflicted items.

#### 0.9.11 ####
  * Added Araxis Merge support (Thanks Doug Anderson & Tommy Krul). It expects araxissvndiff to be in /usr/local/bin.
  * Updated Sparkle Plus to version 96.
  * Fixed : reverted the ability to rename (renamable!) files in hierarchical mode.

<a href='Hidden comment: 2007-08-05'></a>
#### 0.9.10 ####
  * New bullet-proof parsing method for svn status that uses --xml output. Requires a subversion 1.4 client. Can be disabled in the preferences.
  * Added a tooltip that explains the meaning of the columns’ characters.
  * Added a thin vertical separator in working copy browser.
  * Added a basic warning if svn is not found in the path that it set in preferences. (Thanks vskbros).
  * Applied <a href='http://svnx.lachoseinteractive.net/ticket/84'>patch</a> by robbie from prelab.net to fix diff issue.

<a href='Hidden comment: v0.9.9 - 2006-11-11'></a>

<a href='Hidden comment: 2006-07-29'></a>
#### 0.9.8 ####
  * Rewrote the broken file history panel AppleScript invocation from scratch. It now tries to find a known working copy the file belongs to, then opens this working copy window and displays the sheet for the file. <br />See “Invoking svnX’s file history panel from AppleScript” from the Help menu for usage.
  * Support for BBEdit diff.
  * Implemented auto-update with Sparkle Plus.
  * “Reveal In Finder” now opens the root directory of the local repository if no file/folder is selected in the Working copy list.

<a href='Hidden comment: 2006-04-23'></a>
#### 0.9.7 ####
  * Now compiled as Universal Binary.
  * In the repository window, the url is now clickable : you can now click a segment of the url to browse an upper level of the repository.
  * Also, you can now “browse a folder as a sub-repository” using the contextual menu in the bottom column view.
  * When the hierarchical list in the working copies inspector is reloaded, the first selected item is now brought into view.
  * Added a checkbox in preferences to choose whether an item is added to the working copies list when a folder is checked out. When active, after check-out an item is added to list with correct path and the working copies window is brought to front and the Name field is selected.
  * Added a Reveal In Finder toolbar item.
  * Fixed : in old revisions, could not browse paths that had been moved or deleted. Now use path@revision syntax in svn list, svn checkout & svn export.
  * Fixed : svnX now properly closes the pipes it opens.

<a href='Hidden comment: 2006-01-07'></a>
#### 0.9.6.4 ####
  * Fixed status bar of the working copy window which displayed the repository UUID instead of the current revision when using subversion 1.3.

<a href='Hidden comment: 2006-01-05'></a>
#### 0.9.6.3 ####
  * Subversion 1.3.0 compatibility.
  * Working Copies and Repositories lists should now properly be saved.

<a href='Hidden comment: 2005-12-01'></a>
#### 0.9.6.2 ####
  * Passwords are now hidden in text fields.

<a href='Hidden comment: 2005-07-19'></a>
#### 0.9.6.1 ####
  * Fixed issue introduced in 0.9.6 when trying to FileMerge a file with no extension.

#### 0.9.6 ####
  * Added lock/unlock support for subversion 1.2.
  * Integrates a patch by Yuichi Fujishige that should provide better support for UTF-16 strings. Should fix the log file stall issue.
  * Diff comparisons should no longer be messed up when launched several at time (thanks James Dessart).
  * The temp file diff compares against is now given the same extension, so FileMerge coloring (from XCode 2.1) is right.
  * Fixed “svn resolved” issue.

<a href='Hidden comment: 2005-05-22'></a>
#### 0.9.5 ####
  * Fixed export of a single non-directory item by drag&drop that was broken in 0.9.4.

#### 0.9.4 ####
  * Preliminary support for diff applications other than FileMerge. Added TextWrangler and CodeWarrior as possible choice in general preferences. <br />(thanks to <a href='http://www.rogue-research.com'>Sean McBride</a> for the modified script!).
  * Fixed broken nib file that affected svn switch in v.0.9.3.

#### 0.9.3 ####
  * Fixed issue when cancelling a rename in the working copy window
  * Fixed several possible crash situations.

#### 0.9.2 ####
  * Implemented **svn switch** by drag&drop between the repository and the working copy !
  * Now warns if svn binary is not accessible.

#### 0.9.1 ####
  * Implemented **svn import by drag&drop** from the Finder to the repository browser !
  * Fixed : checkout output missing from drawer when triggered by drag&drop.
  * Fixed issue where empty user/password could be sent instead of none.

#### 0.9 ####
  * Preliminary svn authentication support.
  * Task management is now totally revamped
    * Each task is now displayed in the activity window.
    * Main tasks output (checkout & export in the repository window, update & commits in the working copy window) is also displayed in a drawer.
    * Dramatically improved log display performance.

  * Working copy outline view improvement (“non flat” view):
    * Optimized outline view calculation.
    * Now keeps the selected folder in the outline view after a copy/move.
    * If a single file is copied or moved using the outliner in the working copy window, an intermediate sheet now lets the user rename it.

<a href='Hidden comment: 2005-04-16'></a>
#### 0.83 ####
  * Fixed out-of-sync issue between the revision and the browser after a svn copy/move/delete in advanced mode.

#### 0.82 ####
  * Fixed problem introduced in 0.81 where svn log would be called twice when a new repository window was open in “advanced” log view mode.

#### 0.81 ####
  * BUG FIX : Fixed problem introduced in v.0.8 that could result in incomplete data in the working copy window.
  * NEW : The default log view mode for new repository windows (advanced or simple) can now be set in the preferences.

#### 0.8 ####
  * NEW : you can now search into repository paths.
  * NEW : implemented drag & drop from the repository file browser (export or checkout). (check this out!!)
  * NEW : new task management architecture. Most important operations are accessible in the Activity window. <br />Note : Not all operations have moved to this new system yet.
  * Added svn export to toolbar.
  * Bug fixes:
    * No longer crashes when a working window is closed during a refresh.
    * Fixed a glitch that made the author name sometimes disappear from the log view.
    * Many minor fixes

#### 0.7 ####
  * Bug fix : you should now be able to use any utf8 char in your commit messages, provided you’re using the latest version of subversion binaries.
  * You can invoke svnX from TextMate (or any AppleScript-capable editor) and be presented with a window with the different revisions of the edited file. (see the help file from the Help menu).

#### 0.6 ####
  * Added svn move support to the repository inspector
  * Pressing the Alt key while clicking Refresh in the working copy browser now performs a svn status --show-updates.
  * Turned “metal” buttons into aqua ones.
  * The working copy’s root (“.”) is now shown.
  * Added drag & drop support in favorite working copies and favorite repositories windows.
  * Fixed crash when working copy is an “aggregate” of externals.

#### 0.5 ####
  * NEW: Repository inspector.
  * Working copy:
    * Fixed move, copy and rename.
    * Fixed inconsistencies between flat mode and smart mode.
    * FileMerge integration.
    * Many other bug fixes and improvements.

#### 0.12 ####
  * Changed the behavior of the split view so it can’t no longer be out of sync with toggle view mode.
  * Double-click in an empty favorite working copies row no longer opens a broken document.
  * New Transformer to clean-up the path of the favorite working copy (solves the trailing slash bug).

#### 0.11 ####
  * No longer embeds the svn binary inside the package. Uses a path to the user’s binaries instead.
  * Slight change in the interface.
  * Now uses NSAlert to display svn error messages.

#### 0.1 ####
  * Initial release.
