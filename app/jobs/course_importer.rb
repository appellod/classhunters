class CourseImporter
  @queue = :import_courses

  def self.perform(uploaded_file, school_id)
  	file = uploaded_file
    tempfile = Tempfile.new('file')
    tempfile.binmode
    tempfile.write(Base64.decode64(file['tempfile']))
    file = ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: file['original_filename'], type: file['content_type'], head: file['headers'])
    Course.import(file, school_id)
  end
end