if RUBY_VERSION == '1.8.7'
  class Hash
    def default_proc=(proc)
      initialize(&proc)
    end
  end
end