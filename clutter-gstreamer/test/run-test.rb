#!/usr/bin/env ruby
#
# Copyright (C) 2013-2015  Ruby-GNOME2 Project Team
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

have_make = system("which make > /dev/null")

ruby_gnome2_base = File.join(File.dirname(__FILE__), "..", "..")
ruby_gnome2_base = File.expand_path(ruby_gnome2_base)

glib_base = File.join(ruby_gnome2_base, "glib2")
cairo_gobject_base = File.join(ruby_gnome2_base, "cairo-gobject")
gobject_introspection_base = File.join(ruby_gnome2_base, "gobject-introspection")
gdk_pixbuf2_base = File.join(ruby_gnome2_base, "gdk_pixbuf2")
clutter_base = File.join(ruby_gnome2_base, "clutter")
gstreamer_base = File.join(ruby_gnome2_base, "gstreamer")
clutter_gstreamer_base = File.join(ruby_gnome2_base, "clutter-gstreamer")

modules = [
  [glib_base, "glib2"],
  [cairo_gobject_base, "cairo-gobject"],
  [gobject_introspection_base, "gobject-introspection"],
  [gdk_pixbuf2_base, "gdk_pixbuf2"],
  [clutter_base, "clutter"],
  [gstreamer_base, "gstreamer"],
  [clutter_gstreamer_base, "clutter-gst"],
]
modules.each do |target, module_name|
  if File.exist?(File.join(target, "Makefile")) and have_make
    `make -C #{target.dump} > /dev/null` or exit(false)
  end
  $LOAD_PATH.unshift(File.join(target, "ext", module_name))
  $LOAD_PATH.unshift(File.join(target, "lib"))
end

$LOAD_PATH.unshift(File.join(glib_base, "test"))
require "glib-test-init"

$LOAD_PATH.unshift(File.join(gobject_introspection_base, "test"))
require "gobject-introspection-test-utils"

$LOAD_PATH.unshift(File.join(clutter_base, "test"))
require "clutter-test-utils"

$LOAD_PATH.unshift(File.join(clutter_gstreamer_base, "test"))
require "clutter-gstreamer-test-utils"

require "clutter-gst"

repository = GObjectIntrospection::Repository.default
begin
  repository.require(ClutterGst::Loader::NAMESPACE)
rescue GLib::Error
  puts("Omit because typelib file doesn't exist: #{$!.message}")
  exit(true)
end

begin
  Clutter.init
rescue Clutter::InitError
  puts("Omit because initialization is failed: #{$!.message}")
  exit(true)
end

exit Test::Unit::AutoRunner.run(true, File.join(clutter_gstreamer_base, "test"))
