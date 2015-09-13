#
# Cookbook Name:: icinga2
# Recipe:: default
#
# Copyright (C) 2014 Karol@Pasternak.pro
#
# All rights reserved - Do Not Redistribute
#
include_recipe "#{cookbook_name}::server"
include_recipe "#{cookbook_name}::web"
