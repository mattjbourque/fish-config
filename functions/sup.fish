function sup


    argparse h/help q/quiet r/rcloneconfig= -- $argv
    or return

    if set -q _flag_help
	echo \
"
sup - Sakai upload

Use this to upload course documents to Sakai.

For each specified directory in the course directory, the script will update a directory of symbolic links and then use rclone to sync these directories with Sakai.
For example, the local file 
     course/Classwork/01introduction/questions.pdf
is uploaded to
     course_remote:Classwork/01introduction-questions.pdf.

course_remote must be set up with rclone.
This script will attempt to make (e.g.) course-remote:Classwork if it doesn't exist.

"
	return 0
    end

    if  set -q _flag_rcloneconfig
	set rclone_config $_flag_rcloneconfig
    else
	# Use the default rcone config file, which should be set in a sup config.
	set rclone_config /home/mbourque/Dropbox/Teaching/Utilities/rclone.conf
    end


    if test -z "$argv" 
	echo You must specify a course.
    else
	for course in $argv
	    if test -O ~/Dropbox/Teaching/$course # This is a real course, update its files.

		if contains $course (string replace ':' '' (rclone --config $rclone_config listremotes))

		    # Determine the directories that will be uploaded for each course.
		    # This should probably be configurable.


		    set directories \
			/home/mbourque/Dropbox/Teaching/$course/Classwork/ \
			/home/mbourque/Dropbox/Teaching/$course/Slides/ \
			/home/mbourque/Dropbox/Teaching/$course/Quizzes/ \
			/home/mbourque/Dropbox/Teaching/$course/Exams/

		    # Determine the filenames that will be uploaded for each course in the directories.
		    # This should probably be configurable for now it is hardcoded as up_solutions.pdf, questions.pdf, and slides.pdf

		    for dir in $directories
			if test -e $dir
			   cd $dir
			   for file in */up_solutions.pdf */questions.pdf */slides.pdf
			       set linkname $(path dirname $file)-$(path basename $file)
			       if test ! -L ~/Dropbox/Teaching/$course/.Sakai/$(path basename $dir)/$linkname
				   ln -s $(path resolve $file) ~/Dropbox/Teaching/$course/.Sakai/$(path basename $dir)/$linkname
			       end
			   end
			end
		    end #We've updated the links
		    # Syncing with Sakai 

		    # Delete orphaned links
		    find ~/Dropbox/Teaching/$course/.Sakai -xtype l -delete
		    rclone --config $rclone_config sync -L ~/Dropbox/Teaching/$course/.Sakai $course:
		else
		    echo Use rclone config to set up the remote.
		end
	    else
		echo $argv is not a course found in the Teaching directory.
	    end
	end
    end
end
