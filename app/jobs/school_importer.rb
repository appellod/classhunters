class SchoolImporter
  @queue = :import_schools

  def self.perform(uploaded_file)
  	file = uploaded_file
    tempfile = Tempfile.new('file')
    tempfile.binmode
    tempfile.write(Base64.decode64(file['tempfile']))
    file = ActionDispatch::Http::UploadedFile.new(tempfile: tempfile, filename: file['original_filename'], type: file['content_type'], head: file['headers'])
    School.import(file)
  end
end