module Nm
  class InvalidError < RuntimeError
  end
end

class ::Hash
  def __nm_add_call_data__(call_name, data)
    if data.is_a?(::Array)
      raise Nm::InvalidError, "invalid `#{call_name}` call"
    end
    self.merge(data || {})
  end
end

class ::Array
  def __nm_add_call_data__(call_name, data)
    if data.is_a?(::Hash)
      raise Nm::InvalidError, "invalid `#{call_name}` call"
    end
    self.concat(data || [])
  end
end

def nil.__nm_add_call_data__(call_name, data)
  data
end
