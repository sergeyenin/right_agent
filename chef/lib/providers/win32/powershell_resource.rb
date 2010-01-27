#
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

require 'fileutils'

class Chef

  class Resource

    # Powershell chef resource.
    # Allows defining recipes which wrap Powershell v1.0 scripts.
    #
    # === Example
    # powershell "My Powershell Script" do
    #   source "write-output \"Running powershell v1.0 script\""
    # end
    class Powershell < Chef::Resource

      # Initialize Powershell resource with default values
      #
      # === Parameters
      # name<String>:: Nickname of Powershell
      # collection<Array>:: Collection of included recipes
      # node<Chef::Node>:: Node where resource will be used
      def initialize(name, collection=nil, node=nil)
        super(name, collection, node)
        @resource_name = :powershell
        @parameters = {}
        @source = nil
        @source_path = nil
        @action = :run
        @allowed_actions.push(:run)
      end

      # <String> Powershell nickname
      def nickname(arg=nil)
        set_or_return(
          :nickname,
          arg,
          :kind_of => [ String ]
        )
      end

      # <String> text of Powershell source code if inline
      def source(arg=nil)
        set_or_return(
          :source,
          arg,
          :kind_of => [ String ]
        )
      end

      # <String> local path for external Powershell source file if not inline
      def source_path(arg=nil)
        set_or_return(
          :source_path,
          arg,
          :kind_of => [ String ]
        )
      end

      # <Hash> Powershell parameters values keyed by names
      def parameters(arg=nil)
        set_or_return(
          :parameters,
          arg,
          #:kind_of => [ Hash ]
          :kind_of => [ Chef::Node::Attribute ] # Change back to Hash when Chef is fixed
        )
      end

    end
  end
end