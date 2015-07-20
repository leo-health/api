class Patient < User
  def email_required?
    new_record? ? false : super
  end

  def password_required?
    new_record? ? false : super
  end
end
