--
-- Add-on package description utilities
--
-- codename Naia - Project Ethea phase 1 campaigns shared library
-- Copyright (C) 2018 by Iris Morelle <shadowm@wesnoth.org>
--
-- See COPYING for usage terms.
--

local default_package = {
	global_id    = "project_ethea.Naia",
	name         = "",
	version      = "0.0.0",
	abbreviation = "Naia",
	tracker_url  = "https://github.com/project-ethea/Naia/issues",
	forum_thread = "",
	naia_version = PROJECT_ETHEA_NAIA_VERSION,
	registered   = false,
}

local package = default_package

--[[

Registers a Naia add-on, filling in the internal info table with attributes
used by certain functionality.

Usage:

naia_register_package {
    -- The add-on's global id, used e.g. for persistent WML variables.
    global_id    = "project_ethea.After_the_Storm",

    -- The user-visible name for the add-on.
    name         = "After the Storm",

    -- The add-on version.
    version      = "0.10.0",

    -- The user-visible abbreviation for the add-on.
    abbreviation = "AtS",

    -- The issue tracker URL for the add-on.
    tracker_url  = "http://localhost/",

    -- The forum thread URL for the add-on.
    forum_thread = "http://localhost/",
}

]]
function naia_register_package(p)
	if package.registered then
		wput(W_WARN, "multiple calls to naia_register_package() detected!")
		return
	end

	package.global_id = p.global_id or default_package.global_id
	package.name = p.name or default_package.name
	package.version = p.version or default_package.version
	package.abbreviation = p.abbreviation or default_package.abbreviation
	package.tracker_url = p.tracker_url or default_package.tracker_url
	package.forum_thread = p.forum_thread or default_package.forum_thread

	package.registered = true

	wprintf(W_INFO, "%s (%s) version %s (Naia %s)", package.name, package.global_id, package.version, package.naia_version)
	_wsetlogprefix(package.abbreviation)
end

function naia_get_package_name()
	return package.name
end

function naia_get_package_name_abbrev()
	return package.abbreviation
end

function naia_get_package_version()
	return { package.version, package.naia_version }
end

function naia_get_package_url()
	return { package.forum_thread, package.tracker_url }
end

function naia_get_package_id()
	return package.global_id
end