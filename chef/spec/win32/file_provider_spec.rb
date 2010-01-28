# Copyright (c) 2010 RightScale Inc
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

# FIX: rake spec should check parent directory name?
if RightScale::RightLinkConfig[:platform].windows?

  require 'fileutils'
  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'mock_auditor_proxy'))
  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'chef_runner'))

  module FileProviderSpec
    # unique directory for temporary files.
    # note that Chef fails if backslashes appear in cookbook paths.
    TEST_TEMP_PATH = File.expand_path(File.join(Dir.tmpdir, "file-provider-spec-0C1CE753-0089-4ac7-B689-FB74F31E90F5")).gsub("\\", "/")
    TEST_COOKBOOKS_PATH = File.join(TEST_TEMP_PATH, 'cookbooks')
    TEST_FILE_PATH = File.join(TEST_TEMP_PATH, 'data', 'test_file.txt')

    def create_test_cookbook
      test_cookbook_path = File.join(TEST_COOKBOOKS_PATH, 'test')
      test_recipes_path = File.join(test_cookbook_path, 'recipes')
      FileUtils.mkdir_p(test_recipes_path)

      # create (empty) file using file provider.
      create_file_recipe =
<<EOF
file "#{TEST_FILE_PATH}" do
  mode 0644
end
EOF
      create_file_recipe_path = File.join(test_recipes_path, 'create_file_recipe.rb')
      File.open(create_file_recipe_path, "w") { |f| f.write(create_file_recipe) }

      # fail to create file due to unsupported owner (or group) attribute.
      fail_owner_create_file_recipe =
<<EOF
file "#{TEST_FILE_PATH}" do
  owner "Administrator"
  group "Administrators"
end
EOF
      fail_owner_create_file_recipe_path = File.join(test_recipes_path, 'fail_owner_create_file_recipe.rb')
      File.open(fail_owner_create_file_recipe_path, "w") { |f| f.write(fail_owner_create_file_recipe) }

      # touch file using file provider.
      touch_file_recipe =
<<EOF
file "#{TEST_FILE_PATH}" do
  action :touch
end
EOF
      touch_file_recipe_path = File.join(test_recipes_path, 'touch_file_recipe.rb')
      File.open(touch_file_recipe_path, "w") { |f| f.write(touch_file_recipe) }

      # delete file using file provider.
      delete_file_recipe =
<<EOF
file "#{TEST_FILE_PATH}" do
  backup 2
  action :delete
end
EOF
      delete_file_recipe_path = File.join(test_recipes_path, 'delete_file_recipe.rb')
      File.open(delete_file_recipe_path, "w") { |f| f.write(delete_file_recipe) }

      # metadata
      metadata =
<<EOF
maintainer "RightScale, Inc."
version    "0.1"
recipe     "test::create_file_recipe", "Creates a file"
recipe     "test::fail_owner_create_file_recipe", "Fails to creates a file due to owner attribute"
recipe     "test::touch_file_recipe", "Touches a file"
recipe     "test::delete_file_recipe", "Deletes a file"
EOF
      metadata_path = test_recipes_path = File.join(test_cookbook_path, 'metadata.rb')
      File.open(metadata_path, "w") { |f| f.write(metadata) }
    end

    def cleanup
      (FileUtils.rm_rf(TEST_TEMP_PATH) rescue nil) if File.directory?(TEST_TEMP_PATH)
    end

    module_function :create_test_cookbook, :cleanup
  end

  describe Chef::Provider::File do

    before(:all) do
      @old_logger = Chef::Log.logger
      FileProviderSpec.create_test_cookbook
      FileUtils.mkdir_p(File.dirname(FileProviderSpec::TEST_FILE_PATH))
    end

    before(:each) do
      Chef::Log.logger = RightScale::Test::MockAuditorProxy.new
    end

    after(:all) do
      Chef::Log.logger = @old_logger
      FileProviderSpec.cleanup
    end

    it "should create files on windows" do
      runner = lambda {
        RightScale::Test::ChefRunner.run_chef(
          FileProviderSpec::TEST_COOKBOOKS_PATH,
          'test::create_file_recipe') }
      runner.call.should == true
      File.file?(FileProviderSpec::TEST_FILE_PATH).should == true
      File.delete(FileProviderSpec::TEST_FILE_PATH)
    end

    it "should fail to create files when owner or group attribute is used on windows" do
      runner = lambda {
        RightScale::Test::ChefRunner.run_chef(
          FileProviderSpec::TEST_COOKBOOKS_PATH,
          'test::fail_owner_create_file_recipe') }
      result = false
      begin
        # note that should raise_error() does not handle NoMethodError for some reason.
        runner.call
      rescue NoMethodError
        result = true
      end
      result.should == true
    end

    it "should touch files on windows" do
      File.open(FileProviderSpec::TEST_FILE_PATH, "w") { |f| f.puts("stuff") }
      sleep 1.1  # ensure touch changes measurable time
      old_time = File.mtime(FileProviderSpec::TEST_FILE_PATH)
      runner = lambda {
        RightScale::Test::ChefRunner.run_chef(
          FileProviderSpec::TEST_COOKBOOKS_PATH,
          'test::touch_file_recipe') }
      runner.call.should == true
      touch_time = File.mtime(FileProviderSpec::TEST_FILE_PATH)
      (old_time < touch_time).should == true
      File.delete(FileProviderSpec::TEST_FILE_PATH)
    end

    it "should delete files on windows" do
      run_list = []
      2.times { run_list << 'test::delete_file_recipe' }
      File.open(FileProviderSpec::TEST_FILE_PATH, "w") { |f| f.puts("stuff") }
      runner = lambda {
        RightScale::Test::ChefRunner.run_chef(
          FileProviderSpec::TEST_COOKBOOKS_PATH,
          run_list) }
      runner.call.should == true
      File.exists?(FileProviderSpec::TEST_FILE_PATH).should == false

      # check that backup file was created.
      backups = Dir[FileProviderSpec::TEST_FILE_PATH + '*']
      backups.length.should == 1
      backups.each { |path| File.delete(path) }
    end

  end

end # if windows?