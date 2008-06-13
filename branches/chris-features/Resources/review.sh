#! /usr/bin/perl -w
#
# review.sh <svn-tool> <options> <ctx-lines> <show-func> <show-chars> <dest-html> <paths...>
#

my ($svn, $options, $ctx_lines, $show_func, $show_chars, $dest_html)
	= ($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5]);
for (1..6) { shift; }

my $diff = "-U $ctx_lines";
if ("$show_func" ne '') {
	$diff .= ' -p --show-function-line=[[:blank:]]*[-+][[:blank:]]*([[:alpha:]_]';
}

open(STDOUT, ">$dest_html") || die "Can't redirect stdout";

$0 =~ s/\/[^\/]+$//g;
system('cat', "$0/Review.html");
if ($show_chars ne '') { system('cat', "$0/Review.js"); }

my ($path, $str);
foreach $path (@ARGV)
{
	$str = `$svn diff $options --non-interactive --diff-cmd /usr/bin/diff -x '$diff' '$path'`;
	$str =~ s/\\/\\\\/g;
	$str =~ s/\'/\\\'/g;
	$str =~ s/\r/\\r/g;
	$str =~ s/]]>/]\\]>/g;
	$str =~ s/<\/script>/<\\\/script>/g;
	$str =~ s/\n$//;
	$str =~ s/\n/',\n '/g;
	print("diff1([\n '$str'\n]);\n\n");
}

print("//]]></script>\n</body>\n</html>\n");

