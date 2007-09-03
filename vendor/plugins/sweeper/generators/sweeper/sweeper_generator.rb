
class SweeperGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, "#{class_name}Sweeper"

      # Create the directory if missing. Which is pretty unlikely.
      m.directory File.join('app/models', class_path)

      # Copy files with data filled in.
      m.template 'sweeper.rb', File.join('app/models', class_path, "#{file_name}_sweeper.rb")
    end
  end
end

