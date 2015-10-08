class Member < User
  default_scope { where(email: nil) }
  has_many :patients

end
