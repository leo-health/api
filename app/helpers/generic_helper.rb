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

  def self.generate_token(token_name)
    loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless User.exists?(Hash[token_name, random_token])
    end
  end

  def self.try_nested_value_for_key_path(hash, keys)
    key_enum = keys.to_enum
    cur_hash = hash
    while cur_hash
      begin
        key = key_enum.next
      rescue StopIteration
        return cur_hash
      end
      cur_hash = cur_hash.try(:[], key)
    end
  end
end
