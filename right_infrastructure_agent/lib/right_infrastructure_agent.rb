# Copyright (c) 2009-2011 RightScale, Inc, All Rights Reserved Worldwide.
#
# THIS PROGRAM IS CONFIDENTIAL AND PROPRIETARY TO RIGHTSCALE
# AND CONSTITUTES A VALUABLE TRADE SECRET.  Any unauthorized use,
# reproduction, modification, or disclosure of this program is
# strictly prohibited.  Any use of this program by an authorized
# licensee is strictly subject to the terms and conditions,
# including confidentiality obligations, set forth in the applicable
# License Agreement between RightScale.com, Inc. and the licensee.

require 'rubygems'
require 'right_agent'

unless defined?(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR)
  RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR =
    File.normalize_path(File.join(File.dirname(__FILE__), 'right_infrastructure_agent'))
end

require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'rest_client'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'models_helper'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'login_policy_factory'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'exception_mailer'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'agent_config'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'packets'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'infrastructure_agent'))
require File.normalize_path(File.join(RIGHT_INFRASTRUCTURE_AGENT_BASE_DIR, 'rainbows_agent_controller'))
