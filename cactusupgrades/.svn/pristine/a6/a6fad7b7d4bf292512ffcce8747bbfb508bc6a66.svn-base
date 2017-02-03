#!/bin/bash
set -x #echo on
set -e #quit on first error

# Make sure there are no local changes to the revision numbering file
svn revert Revision.txt

# Make sure the commit is up to date 
svn commit . 

# Fetch the commit number of the last tag
LastTagCommit=$(svnversion -c Revision.txt)

# Update the revision numbering file
RevisionFile="Revision.txt"
Revision=$(cat "${RevisionFile}")    # Get the last revision number
Revision=$(( ${Revision} + 1 ))      # Increment the revision number
echo ${Revision} > "${RevisionFile}" # Save it back to the file

# Update the revision number in the VHDL
RevisionHex=$(printf 'X"%x"' $(( ${Revision} + 0x10010000 )) ) # Format the revision number as we need it for the top_decl files
sed -i "s/CONSTANT ALGO_REV.*/CONSTANT ALGO_REV : STD_LOGIC_VECTOR( 31 downto 0 ) := ${RevisionHex};/g" $(find . -iname "top_decl*.vhd") # Update the revision numbers in top_decl.*.vhd

# Create a release notes file
echo                                                               >  ReleaseNotes.txt
echo "###########################################################" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo " RELEASE NOTES: Calo-L2 Payload tag ${Revision}"             >> ReleaseNotes.txt
echo -n " Generated at "                                           >> ReleaseNotes.txt
date                                                               >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo "###########################################################" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo "###########################################################" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo "AUTHOR'S RELEASE NOTES:"                                     >> ReleaseNotes.txt
echo ">>>>>>> AUTHOR'S RELEASE NOTES TO BE FILLED IN HERE <<<<<<<" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo "###########################################################" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo "###########################################################" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo " SVN log messages since last tag"                            >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
svn log -r ${LastTagCommit}:HEAD algorithm_components/             >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt
echo "###########################################################" >> ReleaseNotes.txt
echo                                                               >> ReleaseNotes.txt

nano ReleaseNotes.txt


# Commit the updated revision numbering file, VHDL and Release Notes
svn commit -m "Update the algorithm revision numbers to ${Revision} (${RevisionHex}) and create Release Notes"

# Create the tag
Tag="calol2_$(date +"%y%m%d")_${Revision}"
svn mkdir  -m   "Creating tag for algorithm revision ${Revision} (${RevisionHex})" ^/tags/calol2/firmware/unstable/${Tag}                                        # Create the tag
svn cp     -m "Populating tag for algorithm revision ${Revision} (${RevisionHex})" ^/trunk/cactusupgrades/projects/calol2 ^/tags/calol2/firmware/unstable/${Tag} # Populate the tag

# Update the revision numbering file again
Revision=$(( ${Revision} + 1 ))      # Increment the revision number
echo ${Revision} > "${RevisionFile}" # Save it back to the file

# Update the revision number in the VHDL
RevisionHex=$(printf 'X"%x"' $(( ${Revision} + 0x10010000 )) ) # Format the revision number as we need it for the top_decl files
sed -i "s/CONSTANT ALGO_REV.*/CONSTANT ALGO_REV : STD_LOGIC_VECTOR( 31 downto 0 ) := ${RevisionHex};/g" $(find . -iname "top_decl*.vhd") # Update the revision numbers in top_decl.*.vhd

# Create a release notes file
echo > ReleaseNotes.txt

# Commit the updated revision numbering file, VHDL and Release Notes
svn commit -m "Update the algorithm revision numbers to ${Revision} (${RevisionHex}) and delete Release Notes"
