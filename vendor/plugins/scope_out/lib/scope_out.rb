module ScopeOut
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    ASSOC_MODULE_NAME = "AssociationMethods"
    # given a name such as 'active', scope_out creates 3 methods
    #   with_active creates a scope 
    #   find_active uses the with_active scope to call find
    #   calculate_active uses the with_active scope to call calculate
    def scope_out(name, options = {}, &block)
      @scope_out_blocks ||= {}
      if block_given?
        puts "WARNING: scope_out :options ignored if block given" unless options.empty?
        @scope_out_blocks[name] = block
      else
        opts = prepare_scope_out_options(name, options)
      end
      
      # create new class methods
      instance_eval <<-DEFINE_METHODS 
        protected
        def with_#{name}
          with_scope :find => #{@scope_out_blocks[name] ? "@scope_out_blocks[#{name.inspect}].call" : opts.inspect} do
            yield
          end
        end
      DEFINE_METHODS
      
      # create find_x and calculate_x methods
      add_scoped_finders name
      # create a memoized association finder
      add_association_method name
    end
    
    # use previously defined with_scopes to define a new, composite scope and finders
    def combined_scope(name, scopes, options = nil)
      return if (scopes = Array(scopes)).blank?
      new_scope = options ? "with_scope(:find => #{options.inspect}) {yield}" : 'yield'
      scope_string = scopes.inject(new_scope) do |str, scope|
        str.sub('yield', "with_#{scope} {yield}")
      end
      instance_eval "def with_#{name}() #{scope_string}; end"
      add_scoped_finders name
      add_association_method name
    end
    
    # allow scope_out users to be able to do cool stuff like
    # Student.find_all_active_by_age(18)
    # this will use the with_active scope and then pass :find_all_by_age up the method_missing chain
    def method_missing_with_scope_out(method_called, *args, &block)
      method_str = method_called.to_s
      match = method_str.match(/^(find_)(all_)?(\w+)(_by_)(\w+)$/)
      if match && match[3] != 'all'
        # our scope name should be in $3
        scope_str = match[3]
        method_str = match.captures
        # delete scope name (match is omitted from captures)
        method_str.delete_at(2)
        method_str = method_str.compact.join.gsub('__', '_')
        scope_sym = "with_#{scope_str}".to_sym
        # call ActiveRecord method missing to do the real work,
        # after wrapping it in our scope
        send scope_sym do
          send method_str.to_sym, *args, &block
        end
      else
        # doesn't match our string. pass it on to ActiveRecord.method_missing
        method_missing_without_scope_out(method_called, *args, &block)
      end
    end    
    alias_method_chain :method_missing, :scope_out
    
    private
    
    # allows scope_out to be defined in any of the following ways (all equivalent)
    # scope_out :active, :field => :active, :value => true
    # scope_out :active, :value => true
    # scope_out :active, :field => :active
    # scope_out :active
    # scope_out :active, :conditions => ["active = ?", true]
    # scope_out :active do
    #   {:conditions => ["active = ?", true]}
    # end
    def prepare_scope_out_options(name, opts)
      returning opts.dup do |options|
        if options[:conditions]
          raise "Contradictory options to scope_out" if options.has_key?(:value) || options.has_key?(:field)
        else
          # field defaults to name, and value defaults to true
          options[:value] = true unless options.has_key?(:value)
          options[:conditions] ||= { (options[:field] || name).to_sym => options[:value] }
        end
        options.delete :field
        options.delete :value
      end
    end
    
    def add_association_method(name)
      # create a memoized association finder
      association_module.class_eval <<-DEF_ASSOC
        def #{name}(reload = false)
          @#{name}_memoized = nil if reload
          @#{name}_memoized ||= find_#{name}(:all)
        end
      DEF_ASSOC
    end
    
    def add_scoped_finders(name)
      instance_eval <<-DEF_FINDERS
        def find_#{name}(*args)
          with_#{name} {find(*args)}
        end
      
        def calculate_#{name}(*args)
          with_#{name} {calculate(*args)}
        end
      DEF_FINDERS
    end
    
    # create a new anonymous module inside of our class
    # store a reference to it in a constant
    def association_module(module_name = ASSOC_MODULE_NAME)
      unless const_defined?(module_name)
        class_eval do
          const_set(module_name, Module.new)
        end
      end
      const_get module_name
    end

  end
end
