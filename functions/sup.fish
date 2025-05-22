function sup

  set uploads questions up_solutions slides
  set directories /home/mbourque/Dropbox/Teaching/118math_Su25/Classwork/ /home/mbourque/Dropbox/Teaching/118math_Su25/Slides/ /home/mbourque/Dropbox/Teaching/118math_Su25/Quizzes/

  for dir in $directories
    rclone --config /home/mbourque/Dropbox/Teaching/Utilities/rclone.conf mkdir 118math_Su25:(basename $dir)
    for subdir in (find $dir -type d)
      for file in $uploads
	if test -e $subdir/$file.pdf
	  echo $subdir/$file.pdf -\> 118math_Su25:(basename $dir)/(basename $subdir)-$file.pdf
	  rclone --quiet --config /home/mbourque/Dropbox/Teaching/Utilities/rclone.conf copyto $subdir/$file.pdf 118math_Su25:(basename $dir)/(basename $subdir)-$file.pdf
	end
      end
    end
  end
end
