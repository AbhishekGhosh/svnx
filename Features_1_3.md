# Introduction — <font color='#0B0'>RELEASE</font> #

### _SvnX_ is a _Free_ graphical user interface (GUI) _Subversion_ client for _Mac OS X_. ###

<table border='none'><tr>
<td><img src='http://svnx.googlecode.com/svn/wiki/svnX-icon.png' /></td>
<td>SvnX 1.3.4 runs on Mac OS X 10.4.11 through 10.8.x.<br />
SvnX 1.3.4 is compatible with Subversion 1.4.6 through 1.7.x.<br />
SvnX 1.3.4 is provided as a universal binary packaged in a disc image.</td>
</tr></table>

## <a href='http://svnx.googlecode.com/files/svnX%201.3.4.dmg'><font color='green'>►►► Download svnX 1.3.4 ◀◀◀</font></a> ##

![![](http://svnx.googlecode.com/svn/wiki/svnX-1.3-tiny.png)](http://svnx.googlecode.com/svn/wiki/svnX-1.3-big.png)


# Details #

Here is the list of **new** features and changes in **svnX 1.3**.

#### General ####
  * Added comprehensive support for ‘@’ in file names.  <font color='#F70'><b>NEW</b></font><br />`[`Only enabled for Subversion 1.6+.  Works for all commands except Merge.`]`
  * If app has to fix-up ‘`/opt/subversion/lib`’ then request authorisation & report success to user with option to re-launch.
  * New Apple Help help document.  <font color='#F70'><b>NEW</b></font><br />`[`Includes some additional information, this change log & the license.`]`
  * On first launch of new version of app the change log is displayed.
  * Improved support for & compatibility with Subversion 1.7.x.
  * [Growl](http://growl.info) support.  <font color='#F70'><b>NEW</b></font><br />`[`Notifies Growl on completion of checkout, commit, update, merge, etc.  Each may be enabled/disabled independently.<br />  To enable this functionality Growl must be obtained & installed separately.`]`
  * Improved diff application support including better compatibility with FileMerge & Xcode 4.3.x.<br />Now runs pre-flight checks before executing a Diff command to determine availability of chosen diff application.  <font color='#F70'><b>NEW</b></font><br />`[`Any failure is reported along with Help & Open Preferences buttons.`]`
  * Support for ECMerge as a Diff and Resolve application.
  * Overly long error messages are truncated to prevent Cocoa from creating alerts taller than your screen.
  * Improved checking for new svnX releases.

#### Working Copy windows ####
  * Added new WC ‘Blame’ & ‘Blame Verbose’ contextual menu commands.  <font color='#F70'><b>NEW</b></font>
  * Added new WC ‘Ignore’ contextual menu command.  <font color='#F70'><b>NEW</b></font><br />`[`Ignore multiple items in multiple folders.  Recognises & offers to use suffix patterns.`]`
  * When opening WC window (that uses https) ask user to interactively validate any invalid/unknown SSL certificate.  <font color='#F70'><b>NEW</b></font><br />`[`Accepting the cert ensures that any subsequent commit etc. will not fail due to auth status.`]`
  * Fixed `svn cleanup` for selected folders when in flat-view mode & not using svn libs.
  * Merged WC column 8 into column 2.
  * Added helpful tool-tips to the command buttons & the first 7 column titles (OSX 10.5+).
  * Don’t show expansion tool-tip for first 7 columns.
  * Block contextual menu if window has an open sheet.
  * Fixed problem with window not opening at previous position.
  * The ‘Repository’ toolbar item is now better at choosing a Repository window.
  * Fixed a problem where minimising a window while a Refresh was underway would abnormally terminate the refresh.
  * Display tree conflicts as a ‘C’ in the 4th column (requires Subversion 1.6.x).<br />`[`Tree conflict items will now be included in the Conflict filter & may be reverted or marked as resolved.`]`
  * Opening a Working Copy window that is using Subversion 1.6 format (or earlier) when you are using Subversion 1.7 will allow you to upgrade it to Subversion 1.7 format.
  * Basic Quick Look support.  <font color='#F70'><b>NEW</b></font><br />`[`Press the spacebar to show or hide a Quick Look panel of the currently selected items.<br />  This feature is only available on Mac OS X 10.5+.`]`
  * Reveal in Finder will now reveal all selected items.<br />`[`If no items are selected then the current tree folder or working copy root folder is revealed.<br />  If no selected items exist on disc then svnX will just beep.`]`

#### Review & Commit window ####
  * The diff pane settings pop-up menu’s ‘Highlight Characters’ (on/off) option has been replaced with a new ‘Character Diffs:’ group with 5 levels (‘Best’, ‘Medium’, ‘Fast’, ‘Fastest’ & ‘Off’).<br />`[`The level represents the amount of time to spend calculating character diffs.  From ‘Best’ which spends the most time down to ‘Off’ which spends no time.`]`
  * Display some informative & friendly feedback, in the diffs pane, following a successful or failed commit.  <font color='#F70'><b>NEW</b></font>
  * Improved display of Subversion properties, especially multiple properties.

#### Repository windows ####
  * When opening Repo window (that uses https) ask user to interactively validate any invalid/unknown SSL certificate.  <font color='#F70'><b>NEW</b></font><br />`[`New when using svn tool.  Already exists if ‘Call Subversion libraries directly’ was active.`]`
  * Disable Checkout & Import toolbar items when a file is selected.
  * For Report, Checkout, Export & Import commands: display consistent repo paths.
  * Allow ‘[’, ‘:’ & ‘]’ characters in new names for Copy, Move & Make Dir commands.

#### Activity window ####
  * The Stop button now only tries to stop the selected tasks.
  * Fixed problem where last output/error line in log was sometimes duplicated.


### [See what was new in svnX 1.2](http://code.google.com/p/svnx/wiki/Features_1_2) ###
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
<td><a href='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BProps-1.3.png'>
<img src='http://svnx.googlecode.com/svn/wiki/WorkingCopy%2BProps-1.3t.png' /></a></td>
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
<td><a href='http://svnx.googlecode.com/svn/wiki/Review%26Commit-1.3.png'>
<img src='http://svnx.googlecode.com/svn/wiki/Review%26Commit-1.3t.png' /></a></td>
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
<td><a href='http://svnx.googlecode.com/svn/wiki/WorkingCopies-1.3.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/WorkingCopies-1.3.png' /></a></td>
<td><a href='http://svnx.googlecode.com/svn/wiki/Repositories-1.3.png'>
<img width='75%' src='http://svnx.googlecode.com/svn/wiki/Repositories-1.3.png' /></a></td>
</tr>
</table>
