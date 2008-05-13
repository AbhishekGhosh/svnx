#!/bin/bash
#
# review.sh <svn-tool> <options> <destination> <urls...>
#

svn="$1";			shift
options="$1";		shift
destination="$1";	shift


{
	cat "${0%/*}/Review.html";

	until [ -z "$1" ]
	do
		url="$1"
		shift
		echo '<textarea style="display:none">'
		"$svn" diff $options "$url"
		echo '</textarea>'
	done

	echo '</body>
</html>'

} > "$destination"

