class Mailer < ActionMailer::Base
  default from: "dan.appello@classhunters.com"

  # Sends the contact form submission to jobs@placecodes.com
  def contact_email(name, email, school, message)
  	@name = name
  	@email = email
  	@school = school
  	@message = message
  	mail(to: 'dan.appello@classhunters.com', subject: 'Contact Form Submission')
  end
end
