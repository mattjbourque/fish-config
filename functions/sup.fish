function sup


    argparse h/help q/quiet r/rcloneconfig= -- $argv
    or return

    if set -q _flag_help
	echo \
"
sup - Sakai upload

Use this to upload course documents to Sakai.

The script will upload specified files in specified directories.
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
		    # This should probably be configurable.
		    # Now we assume all the files to be uploaded are PDFs and add the .pdf later.

		    set uploads questions up_solutions slides

		    for dir in $directories
			# TODO: test and only make the directory if it doesn't exist <01-07-25, mattjbourque@gmail.com> #
			rclone --config /home/mbourque/Dropbox/Teaching/Utilities/rclone.conf mkdir 118math_Su25:(basename $dir)
			for subdir in (find $dir -type d)
			    for file in $uploads
				if test -e $subdir/$file.pdf
				    # TODO test for quiet flag here
				    # TODO set up a flag for dry run and test here
				    echo $subdir/$file.pdf -\> 118math_Su25:(basename $dir)/(basename $subdir)-$file.pdf
				    # rclone $rclone_quiet_arg --config $rclone_config copyto $subdir/$file.pdf 118math_Su25:(basename $dir)/(basename $subdir)-$file.pdf
				end
			    end
			end
		    end
		end
	    end
	end
    end
end
