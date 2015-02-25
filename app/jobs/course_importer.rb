class CourseImporter
  @queue = :import_courses

  def self.perform(uploaded_file, school_id, semester, type)
  	file = uploaded_file
    tempfile = Tempfile.new('file')
    tempfile.binmode
    tempfile.write(Base64.decode64(file['tempfile']))
    file = ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: file['original_filename'], type: file['content_type'], head: file['headers'])
    if type == 'Schedule'
    	Course.import(file, school_id, semester)
    else
    	Course.import_descriptions(file, school_id)
    end
  end
end