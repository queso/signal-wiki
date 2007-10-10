require File.expand_path(File.dirname(__FILE__) + "/test_helper")

class DummyDate
  @@dates = [Date.today, Date.today-30*365]
  def self.today
    @@dates.shift
  end
end

class DumbScoper
  @@names = %w{Harvard Yale}
  def self.name
    @@names.shift
  end
end

class Student < ActiveRecord::Base
  scope_out :freshmen,            :field => :level,   :value => 'Freshman'
  scope_out :eighteen_year_olds,  :field => :age,     :value => 18
  scope_out :active,              :field => :active,  :value => true
  scope_out :inactive,            :field => :active,  :value => false
  scope_out :one_active,          :field => :active,  :value => true, :limit => 1
  scope_out :anonymous,           :field => :name,    :value => nil
  combined_scope :active_freshmen, [:active, :freshmen]
  scope_out :freshmen_active,     :conditions => ["students.active = ? AND students.level = ?", true, 'Freshman']
  belongs_to :school
  combined_scope :sexually_active_freshmen, [:active, :freshmen], :conditions => "students.id = students.id"
  combined_scope :sexually_promiscuous, :active, :conditions => "students.id = students.id"
end

class School < ActiveRecord::Base
  has_many :students, :extend => Student::AssociationMethods
  scope_out :old do
    {:conditions => ["schools.founded < ?", DummyDate.today-125*365]}
  end
  scope_out :dumb_scope do
    {:conditions => ["schools.name = ?", DumbScoper.name]}
  end
  
  # defaults to :field => :ivy_league, :value => true
  scope_out :ivy_league
  scope_out :bool_one, :value => true
  scope_out :bool_two, :field => :bool_two
end

class Student < ActiveRecord::Base
  scope_out :old, :conditions => "students.id = students.id"
end

class ScopeOutTest < Test::Unit::TestCase
  fixtures :students, :schools
  
  def setup
    @scopes = %w{freshmen eighteen_year_olds active freshmen_active inactive one_active anonymous active_freshmen sexually_active_freshmen sexually_promiscuous}
  end
  
  def test_method_added_to_student_class
    @scopes.each do |field| 
      assert Student.methods.include?("find_#{field}")
      assert Student.protected_methods.include?("with_#{field}")
      assert Student.methods.include?("calculate_#{field}")
    end
  end
  
  def test_defaults_to_boolean_true
    assert_equal( School.find(:all, :conditions => ["ivy_league = ?", true]),
                  School.find_ivy_league(:all))
  end
  
  def test_value_false
    assert Student.find_inactive(:all).all? { |s| !s.active? }
  end
  
  def test_other_ways_to_define_boolean
    assert_equal(School.find_bool_one(:all), School.find_bool_two(:all))
  end
  
  def test_string_finder
    freshmen_boring = Student.find_all_by_level('Freshman')
    freshmen_awesome = Student.find_freshmen(:all)
    assert_equal(freshmen_boring.length, freshmen_awesome.length)
    freshmen_boring.each { |bore| assert(freshmen_awesome.include?(bore)) }
    freshmen_boring.each { |awesome| assert(freshmen_boring.include?(awesome)) }
    
    using_public_scopes(Student) do
      assert_equal( Student.find_all_by_level_and_age('Freshman', 16), 
                    Student.with_freshmen{Student.find(:all, :conditions => "age = 16")})
    end
  end
  
  def test_integer_finder
    assert_equal(Student.find_all_by_age(18), Student.find_eighteen_year_olds(:all))
  end
  
  def test_boolean_finder
    assert_equal(Student.find_all_by_active(true, :order => 'age'), Student.find_active(:all, :order => 'age'))
  end
  
  def test_combined_scopes_with_additional_options
    assert_equal Student.find_sexually_active_freshmen(:all), Student.find_active_freshmen(:all)
  end
  
  def test_single_combined_scope_with_additional_options
    assert_equal Student.find_sexually_promiscuous(:all), Student.find_active(:all)
  end
  
  def test_should_allow_nil_scope
    assert_equal(Student.find(:all, :conditions => {:name => nil}), 
                  Student.find_anonymous(:all))
  end
  
  def test_should_allow_include_with_same_name_fields_in_conditions
    assert_equal(Student.find(:all, :conditions => {:name => nil}, :include => :school), 
                  Student.find_anonymous(:all, :include => :school))
  end
  
  def test_combined_scopes
    using_public_scopes(Student) do
      Student.with_freshmen do
        Student.with_eighteen_year_olds do
          Student.with_active do
            t = Student.find :all
            assert_equal([students(:jack)], t)
          end
        end
      end
    end
  end
  
  def test_combined_scope_method
    # for the duration of this test, make protected methods public
    using_public_scopes(Student) do
      s = []
      Student.with_active do
        Student.with_freshmen do
          s = Student.find :all
        end
      end
      assert_equal(s, Student.with_active_freshmen{ Student.find :all })
    end
  end
  
  def test_combined_scope_adds_find_and_calculate
    [:with_active_freshmen, :find_active_freshmen, :calculate_active_freshmen].each { |s| assert Student.respond_to?(s) }
  end
  
  def test_combined_scope_adds_scope_to_association_methods
    assert Student::AssociationMethods.instance_methods.include?("active_freshmen")
  end
  
  def test_should_not_be_in_super_class
    assert (Student.methods - ActiveRecord::Base.methods).include?("find_" + @scopes.first)
  end
  
  def test_should_accept_explicit_conditions
    normal_find = Student.find(:all, :conditions => ["students.active = ? AND students.level = ?", true, 'Freshman'])
    using_public_scopes(Student) do
      Student.with_freshmen_active do
        assert_equal(normal_find, Student.find(:all))
      end
    end
    assert_equal(normal_find, Student.find_freshmen_active(:all))
  end
  
  def test_calculate_methods
    assert_equal(Student.calculate(:count, :all, :conditions => "level = 'Freshman'"),
                 Student.calculate_freshmen(:count, :all))
    assert_equal(Student.calculate(:count, :all, :conditions => "age = 18"),
                 Student.calculate_eighteen_year_olds(:count, :all))
    assert_equal(Student.calculate(:count, :all, :conditions => ["active = ?", true]),
                 Student.calculate_active(:count, :all))
    assert_equal(Student.calculate(:count, :all, :conditions => ["active = ? and level = ?", true, 'Freshman']),
                 Student.calculate_freshmen_active(:count, :all))
  end
  
  def test_passes_limit_option_to_with_scope
    assert_equal(Student.find_all_by_active(true, :limit => 1), Student.find_one_active(:all))
  end
  
  def test_should_define_module
    assert(defined? Student::AssociationMethods)
  end
    
  def test_should_put_finders_in_module
    @scopes.each do |scope|
      assert(Student::AssociationMethods.method_defined?(scope),
             "method '#{scope}' not defined on Student::AssociationMethods")      
    end
  end
  
  def test_association_responds_to_finders
    school = schools(:yale)
    @scopes.each { |scope| assert(school.students.respond_to?(scope)) }
  end
  
  def test_school_should_find_students
    school = schools(:ou)
    assert_equal(Student.find_all_by_active_and_school_id(true, school.id), school.students.active)
  end
  
  def test_base_should_not_contain_student_methods
    @scopes.each do |scope|
      %w{with_ find_ calculate_}.each do |meth|
        assert(!ActiveRecord::Base.methods.include?(meth+scope), "ActiveRecord::Base contains #{meth+scope} method")
      end
    end
  end
  
  def test_association_memoization
    school = schools(:ou)
    students_initial = school.students.active
    students_initial_count = students_initial.length
    new_student = Student.create(:school_id => school.id, :active => true)
    stale_students = school.students.active
    assert_equal(students_initial, stale_students)
    refreshed_students = school.students.active(:reload)
    assert_equal(students_initial_count+1, refreshed_students.length)
  end
  
  def test_should_scope_out_old_schools_dynamically
    old_schools = School.find_old(:all)
    assert old_schools.include?(schools(:ou))
    assert old_schools.include?(schools(:yale))
    assert !old_schools.include?(schools(:harvard))
    
    #2nd call should return the older date, i.e. it's dynamic
    old_schools_again = School.find_old(:all)
    assert old_schools_again.include?(schools(:ou))
    assert !old_schools_again.include?(schools(:yale))
    assert !old_schools_again.include?(schools(:harvard))
    
    #should support more than one dynamic scope per model
    assert_equal schools(:harvard), School.find_dumb_scope(:first)
    assert_equal schools(:yale), School.find_dumb_scope(:first)
  end
  
  def test_block_stored_in_school_class
    assert School.instance_variables.include?('@scope_out_blocks')
    School.ancestors.each do |klass|
      next if klass == School
      assert(!klass.instance_variables.include?('@scope_out_blocks'), "@scope_out_blocks present in #{klass}")
    end
  end
  
  def test_association_methods_per_class
    assert Student::AssociationMethods.instance_methods != School::AssociationMethods.instance_methods
  end
  
  def test_method_missing_hack_does_not_mess_with_activerecord_hack
    assert_equal students(:holly), Student.find_by_name('holly')
  end
  
  def test_method_missing_hack_works_for_find_by
    assert_equal students(:jack), Student.find_active_by_name("jack")
  end
  
  def test_method_missing_hack_works_for_find_by_all
    assert_equal [students(:jack)], Student.find_all_eighteen_year_olds_by_active(true)
  end
  
  def test_method_missing_should_still_raise_method_missing_where_appropriate
    assert_raises(NoMethodError){Student.find_non_existant_scope_by_id(1)}
  end
  
  def using_public_scopes(klass)
    raise "must pass a block" unless block_given?
    $with_methods = (klass.methods-['with_scope']).grep(/^with_.*$/)
    class << klass
      public *$with_methods
    end
    yield
    class << klass
      protected *$with_methods
    end
  end
end
