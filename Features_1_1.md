# Introduction — <font color='#0B0'>RELEASE</font> #

### _SvnX_ is a _Free_, open source, _Subversion_ client for _Mac OS X_. ###

<table border='none'><tr>
<td><img src='http://svnx.googlecode.com/svn/wiki/svnX-icon.png' /></td>
<td>SvnX 1.1 runs on Mac OS X 10.4.11, 10.5 & 10.6.<br />
SvnX 1.1 is compatible with Subversion 1.4.6, 1.5.7 & 1.6.6.<br />
SvnX 1.1 is provided as a universal binary packaged in a disc image.</td>
</tr></table>

## <a href='http://svnx.googlecode.com/files/svnX%201.1.dmg'><font color='green'>►►► Download svnX 1.1 ◀◀◀</font></a> ##

![![](http://svnx.googlecode.com/svn/wiki/svnX-1.1-tiny.png)](http://svnx.googlecode.com/svn/wiki/svnX-1.1-big.png)


# Details #

Here is the list of **new** features and changes in **svnX 1.1**.

#### Repository windows ####
  * The selected repository items may now be opened directly (in an appropriate application).  <font color='#F70'><b>NEW</b></font> <br />`[`Click the Open toolbar icon or type cmd-O or enter.`]`
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
  * A Recursive option (checkbox) has been added (& given an appropriate default value) for add, remove, update, revert & resolved commands.
  * Re-enabled the ability to remove un-versioned items and extended this to added & replaced items.  Allow obstructed items to be reverted.  Improved the text of the alert sheet & added a warning when removing (deleting) un-versioned or modified items.
  * Svn switch now correctly uses the prevailing revision number & not that of the last change.
  * The ‘Review…’ button now only opens additional Review & Commit windows if _alt_ is pressed.  Otherwise it activates an extant R&C window.
  * Automatically refresh all related Review & Commit file lists after refreshing the working copy’s file list.

#### Review & Commit windows ####
  * Always display the working copy relative paths of items - regardless of Working Copy window’s view mode.
  * Refreshing the list should now always work correctly when the ‘Call Subversion libraries directly’ preference is off.

#### Preferences window ####
  * Gets & displays the version number from the svn tool and validates the binaries folder path.  <font color='#F70'><b>NEW</b></font>
  * Prevents use of svnX until the svn tool’s path is valid.
  * Improved error messages if svn tool not found.
  * Disables the ‘Call Subversion libraries directly’ option if the specified svn tool’s version is not compatible with the libraries.
  * Added support for DiffMerge as a diff application.
  * Added support for Changes as a diff application.
  * Added colour swatch for Conflicted files in working copies.  <font color='#F70'><b>NEW</b></font>
  * Fixed a problem with Sparkle that prevented the ‘Check for updates at startup’ preference from working.

#### Other changes ####
  * New `svnx` shell-script/tool that allows access to svnX features from a terminal window (a link is installed at `~/bin/svnx`).  <font color='#F70'><b>NEW</b></font> <br />Available commands are: <br />`    log <file-path>        `- open a log sheet. <br />`    wc [working-copy-path] `- open a working copy window. <br />`    rep [wc-path-or-URL]   `- open a repository window. <br />`    diff <file-path…>      `- compare files with their base revisions. <br />`    open <file-path…>      `- open files in appropriate applications. <br />`    help                   `- display some help text.
  * The opening of files (in appropriate applications) from Working Copy windows, Review & Commit windows, Repository windows (directly or via Blame) and via AppleScript or `svnx open` is determined by a customisable script.  <font color='#F70'><b>NEW</b></font>
  * Improved drag & drop support in Working Copies & Repositories windows. <br />Allows copying of Working Copy items, dropping of URLs, `*.webloc` files & folders in Repositories window.
  * Various small improvements to Review & Commit windows.
  * Fixed a crash when updating the Repository URL (with old parsing).
  * Some improvements to management of sub-tasks.
  * Some memory leaks have been fixed.
  * Smaller & prettier disc image.


### [See what was new in svnX 1.0](http://code.google.com/p/svnx/wiki/Features_1_0) ###
<br />


# Screen Shots #

<table width='100%' align='center'>
<tr>
<th>Working Copy</th>
<th>Update Working Copy</th>
<th>Merge into Working Copy</th>
</tr>
<tr align='center' valign='top'>
<td><a href='http://svnx.googlecode.com/svn/wiki/NewWorkingCopy.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/NewWorkingCopy.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/NewUpdate.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/NewUpdate.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/NewMergeSheet-1.1.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/NewMergeSheet-1.1.png' /></a></td>
</tr>
<tr height='12px' />
<tr>
<th>Repository</th>
<th>Review and Commit</th>
<th>Log Report Setup</th>
</tr>
<tr align='center' valign='top'>
<td><a href='http://svnx.googlecode.com/svn/wiki/Repository-1.1.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/Repository-1.1.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/ReviewAndCommit.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/ReviewAndCommit.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/LogReportSetup-1.1.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/LogReportSetup-1.1.png' /></a></td>
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
