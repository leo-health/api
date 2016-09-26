require 'csv'

module GenericHelper
  # params: [{header_0: row_0_col_0},{header_1: row_1_col_1},{header_2: row_2_col_2}, ...]
  # returns: ????:
  # side effects: writes to a file
  # TODO: write to any stream (file, network, log, string, etc...)
  # require 'csv'
  def hashes_to_csv(hashes: , csv_out_filename:)
    CSV.open("data.csv", "wb") do |csv|
      csv.add_row(hashes.first.keys) # adds the attributes name on the first line
      hashes.each do |hash|
        csv.add_row(hash.values)
      end
    end
  end

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

  # @param array - assumes a sorted, homogeneous array of comparable types
  # @param value - assumes to be comparable with array elements
  # @return item in `array` with min distance to `value`
  # @return larger item in the equidistant case
  # @return nil if `value` is nil
  def self.closest_item(value, array)

    return array.first if array.count <= 1
    return nil if value == nil

    left = array[0...array.count/2]
    right = array[array.count/2...array.count]

    if value < left.last
      closest_item(value,left)
    elsif value > right.first
      closest_item(value,right)
    else
      distanceFromLeft = (value - left.last).abs
      distanceFromRight = (value - right.first).abs
      distanceFromLeft < distanceFromRight ? left.last : right.first
    end
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
