# Introduction — <font color='#0B0'>RELEASE</font> #

### _SvnX_ is a _Free_ graphical user interface (GUI) _Subversion_ client for _Mac OS X_. ###

<table border='none'><tr>
<td><img src='http://svnx.googlecode.com/svn/wiki/svnX-icon.png' /></td>
<td>SvnX 1.2 runs on Mac OS X 10.4.11, 10.5.8 & 10.6.<br />
SvnX 1.2 is compatible with Subversion 1.4.6, 1.5.7 & 1.6.11.<br />
SvnX 1.2 is provided as a universal binary packaged in a disc image.</td>
</tr></table>

## <a href='http://svnx.googlecode.com/files/svnX%201.2.dmg'><font color='green'>►►► Download svnX 1.2 ◀◀◀</font></a> ##

![![](http://svnx.googlecode.com/svn/wiki/svnX-1.2-tiny.png)](http://svnx.googlecode.com/svn/wiki/svnX-1.2-big.png)


# Details #

Here is the list of **new** features and changes in **svnX 1.2**.

#### Working Copy windows ####
  * Subversion properties browser & editor panel.  <font color='#F70'><b>NEW</b></font>
    * View, add, edit & delete multiple text (UTF-8) & binary (hexadecimal) properties on multiple items.
    * Works with the svn tool or direct svn library calls for best performance.
    * Both standard (svn:`*`) & custom properties are supported.
    * Provides custom editors for different value types.
    * Understands implicit valued properties & enforces file only & directory only properties.
  * Interactively resolve file conflicts using FileMerge, Araxis Merge, DiffMerge, Guiffy or KDiff3.  <font color='#F70'><b>NEW</b></font>
  * An improved Merge sheet now provides the following new features:
    * The ability to perform a dry-run of a merge.
    * Reintegrate merges.  `[`svn 1.6+`]`
    * File hierarchy depth-limit control (empty, files, immediate & infinity).  `[`svn 1.6+`]`
    * Automatic conflict resolution actions (postpone, base, mine conflict, theirs conflict, mine full & theirs full).  `[`svn 1.6+`]`
    * Record only - mark revisions as merged.
    * Force operation to run.
  * Support for Subversion 1.6 features has also been added to the Update sheet:
    * Force operation to run.
    * File hierarchy depth-limit control.
    * Automatic conflict resolution actions.
  * Diff any items against their PREV revisions with a single click or key press.  <font color='#F70'><b>NEW</b></font><br />`[`Shift-click the Diff tool or type cmd–shift–D.`]`
  * New item list contextual menu provides access to several commands including new ‘svn info’ commands.  <font color='#F70'><b>NEW</b></font><br />`[`Commands also include Cleanup, Rename…, Copy…, Lock & Unlock.`]`
  * Rename or copy items in flat-view & smart-view modes.
  * Support for ‘`svn cleanup`’ command.  <font color='#F70'><b>NEW</b></font><br />`[`Cleanup the selected folders, the current folder or the entire working copy.`]`
  * The ‘Working Copy Path’ toolbar item has been removed.
  * Improved save & restore of window settings & state.
  * Working copy toolbars will be reset to their defaults the first time svnX 1.2 is used.

#### Repository windows ####
  * Drag & drop a repository log entry to a working copy window to request a reverse merge of that change.  <font color='#F70'><b>NEW</b></font>
  * Drag & drop a repository log entry’s path item to a working copy window to request a reverse merge of that change of that file/directory.  <font color='#F70'><b>NEW</b></font><br />`[`Also drag either of the above to a text editor or the Finder.`]`
  * Diff repository items, log entries (changes) & log entry paths against their PREV revisions with a single click or key press.  <font color='#F70'><b>NEW</b></font><br />`[`Select the target & click the Diff tool or type cmd–D. Open the Diff/log sheet by _alt_ clicking the Diff tool or typing cmd–L.`]`
  * Blame & its verbose option now also supports log entry path items.
  * Directly open files & directories from there log entry path items.
  * Browse the log of any repository log entry paths (like you can for repository items).
  * Added support to Import sheet for enable/disable automatic properties, disregard ignore settings, force operation to run & file hierarchy depth-limit control (last 2 require svn 1.6+).
  * Improved import, export & checkout file selection sheets with better prompts & custom button titles.
  * Improved save & restore of window settings & state.
  * Repository toolbars will be reset to their defaults the first time svnX 1.2 is used.

#### Review & Commit windows ####
  * Display side-by-side diffs.  <font color='#F70'><b>NEW</b></font>
  * Diff pane settings pop-up menu to customise & control many aspects of the diff display.  <font color='#F70'><b>NEW</b></font>
    * Make text bigger or smaller.
    * Select default view: side-by-side, inline or unified.
    * Enable/disable showing of function names.
    * Enable/disable highlighting of changed characters within a diff.
    * Specify the number of lines of context around each diff.
  * Protect user from accidental closure/loss of un-commited message.<br />`[`Displays an alert if user tries to close a Review & Commit window or quit svnX with checked items & a message.`]`

#### Other changes ####
  * New global icon cache for improved display, performance & resource usage.
  * Various bug fixes & code improvements.
  * Added several new & updated other keyboard short-cuts.
  * Added support for Guiffy & KDiff3 diff applications.
  * Improved naming of temporary diff files, repository files & blame files.
  * Added ‘resolve’ command to `svnx` shell-script/tool.
  * Updated & extended documentation.
  * Fully compatible with Subversion 1.6.11 (& 1.6.9).<br />`[`Installs missing links to enable ‘Call Subversion libraries directly’ preference.`]`


### [See what was new in svnX 1.1](http://code.google.com/p/svnx/wiki/Features_1_1) ###
### [See what was new in svnX 1.0](http://code.google.com/p/svnx/wiki/Features_1_0) ###
<br />


# Screen Shots #

<table width='100%' align='center'>
<tr>
<th>Working Copy & Properties</th>
<th>Update Working Copy</th>
<th>Merge into Working Copy</th>
</tr>
<tr align='center' valign='top'>
<td><a href='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BProps-1.2.png'>
<img src='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BProps-1.2t.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BUpdate-1.2.png'>
<img src='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BUpdate-1.2t.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BMerge-1.2.png'>
<img src='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BMerge-1.2t.png' /></a></td>
</tr>
<tr height='12px' />
<tr>
<th>Repository</th>
<th>Review and Commit</th>
<th>Import into Repository</th>
</tr>
<tr align='center' valign='top'>
<td><a href='http://svnx.googlecode.com/svn/wiki/Repository-1.1.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/Repository-1.1.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/Review%26Commit-1.2.png'>
<img src='http://svnx.googlecode.com/svn/wiki/Review%26Commit-1.2t.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/Repository%2BImport-1.2.png'>
<img src='http://svnx.googlecode.com/svn/wiki/Repository%2BImport-1.2t.png' /></a></td>
</tr>
<tr height='12px' />
<tr>
<th>Preferences</th>
<th>Working Copies</th>
<th>Repositories</th>
</tr>
<tr align='center' valign='top'>
<td><a href='http://svnx.googlecode.com/svn/wiki/Preferences-1.1.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/Preferences-1.1.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/WorkingCopies-1.0.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/WorkingCopies-1.0.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/Repositories-1.0.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/Repositories-1.0.png' /></a></td>
</tr>
</table>
