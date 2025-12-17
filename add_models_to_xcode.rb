#!/usr/bin/env ruby
require 'xcodeproj'

project_path = 'Consigliary/Consigliary.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.first

# Get or create the Models group
consigliary_group = project.main_group.find_subpath('Consigliary/Consigliary', true)
models_group = consigliary_group.find_subpath('Models', true)

# Add the model files
['Contributor.swift', 'SplitSheet.swift'].each do |filename|
  file_path = "Consigliary/Consigliary/Models/#{filename}"
  
  # Check if file already exists in project
  existing_file = models_group.files.find { |f| f.path == filename }
  
  unless existing_file
    # Add file reference
    file_ref = models_group.new_reference(file_path)
    
    # Add to target
    target.add_file_references([file_ref])
    
    puts "Added #{filename} to project"
  else
    puts "#{filename} already in project"
  end
end

project.save
puts "Project saved successfully"
