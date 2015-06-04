class Mailer < ActionMailer::Base
  default from: "no-reply@classhunters.com"

  # Sends the contact form submission to jobs@placecodes.com
  def contact_email(name, email, school, message)
  	@name = name
  	@email = email
  	@school = school
  	@message = message
  	mail(to: 'info@classhunters.com', subject: 'Contact Form Submission')
  end

  def reset_password_email(email, hash)
  	@hash = hash
  	mail(to: email, subject: 'Reset Password')
  end
end
