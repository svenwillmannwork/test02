#! /bin/bash

##############################################################################
# this is to make sure that everything fits together
##############################################################################


# file which contains the version number
versionFile="version.info"

# if there is no version info file, moan and refuse
if [ ! -f $versionFile ]; then
    echo "Version file $versionFile not found, unable to create the release"
    exit 1
fi

# read version info from file
source $versionFile
echo "Try to create release for $latestrc"


# check if tag for previous release exist otherwise us master for branch
# new release release-v1.0.0, release-v1.5.2, etc.
releaseBranchLabel="release-$latestrc"
if git rev-parse -q --verify "refs/heads/$releaseBranchLabel" >/dev/null; then
    echo "Try to checkout branch: $releaseBranchLabel"
    # try to checkout tag for previous version

	git checkout $releaseBranchLabel
	git pull
else
    echo "Can not locate the branch $releaseBranchLabel, make sure it exists"
fi


##############################################################################
# now lets merge into master and tag
##############################################################################

git checkout master
git pull
git merge --no-ff --no-commit $releaseBranchLabel
echo "Try to merge $releaseBranchLabel into master"
if [[ $# -eq 0 ]]; then
	echo "Merged went well, commiting now"
	git commit -m "Merged $releaseBranchLabel into master and create the tag $latestrc for the release"
	git tag -a $latestrc -m "Tag release version $latestrc"	
	git push --tags origin master
	exit 0
else 
	echo "Merged failed and I can not create the release, going to revert"
	git merge --abort
	exit 1
fi
