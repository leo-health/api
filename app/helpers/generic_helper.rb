module GenericHelper
  def self.merge_sorted(left, right)
    result = []
    until left.empty? || right.empty?
      if left.first < right.first
        result << left.shift
      else
        result << right.shift
      end
    end
    result + left + right
  end

  def self.generate_vendor_id
    loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless Enrollment.exists?(vendor_id: random_token)
    end
  end
end
