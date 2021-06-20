# frozen_string_literal: true

module Nm
  class InvalidError < RuntimeError
  end
end

class ::Hash
  def __nm_add_partial_data__(data)
    raise Nm::InvalidError, "invalid partial call" if data.is_a?(::Array)
    merge(data || {})
  end
end

class ::Array
  def __nm_add_partial_data__(data)
    raise Nm::InvalidError, "invalid partial call" if data.is_a?(::Hash)
    concat(data || [])
  end
end

def nil.__nm_add_partial_data__(data)
  data
end
