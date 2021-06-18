# frozen_string_literal: true

module Nm
  class InvalidError < RuntimeError
  end
end

class ::Hash
  def __nm_add_call_data__(call_name, data)
    raise Nm::InvalidError, "invalid `#{call_name}` call" if data.is_a?(::Array)
    merge(data || {})
  end
end

class ::Array
  def __nm_add_call_data__(call_name, data)
    raise Nm::InvalidError, "invalid `#{call_name}` call" if data.is_a?(::Hash)
    concat(data || [])
  end
end

def nil.__nm_add_call_data__(_call_name, data)
  data
end
