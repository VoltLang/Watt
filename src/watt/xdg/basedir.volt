// Copyright 2017, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Retrieve paths to XDG standard directories.
 *
 * The [XDG Specification](https://specifications.freedesktop.org/basedir-spec/latest/) specifies
 * where files should be located on a system. This module retrieves those paths.
 */
module watt.xdg.basedir;

version (Linux):

import watt.path;
import watt.process.environment;
import watt.text.string;
import watt.text.format;
import watt.text.path;
import watt.io.file;

/*!
 * Get the config dirs values.
 *
 * The config dirs are a "preference-ordered set of base directories
 * to search for configuration files in addition to the $XDG_CONFIG_HOME base directory.
 *
 * If `$XDG_CONFIG_DIRS` is set, it is returned.  
 * Otherwise, the XDG default is returned.
 */
fn getConfigDirs() string[]
{
	return xdgGetList("XDG_CONFIG_DIRS", "/etc/xdg");
}

/*!
 * Get the configuration home value.
 *
 * The config home is a "base directory relative to which user
 * specific configuration files should be stored".
 *
 * If `$XDG_CONFIG_HOME` is set, it is returned.  
 * Otherwise, the XDG default is returned. If the environment
 * does not have `$HOME` set, or it is invalid, an empty string is returned.
 */
fn getConfigHome() string
{
	return xdgGetHome("XDG_CONFIG_HOME", "/.config");
}

/*!
 * Get the data dirs values.
 *
 * The data dirs are a "preference-ordered set of base directories to
 * search for data files in addition to the `$XDG_DATA_HOME` base directory"
 *
 * If `$XDG_DATA_DIRS` is set, it is returned.  
 * Otherwise, the XDG default is returned.
 */
fn getDataDirs() string[]
{
	return xdgGetList("XDG_DATA_DIRS", "/usr/local/share/:/usr/share/");
}

/*!
 * Get the data home value.
 *
 * The data home is a "base directory relative to which user specific
 * data files should be stored".
 *
 * If `$XDG_DATA_HOME` is set, it is returned.
 * Otherwise, the XDG default is returned.
 */
fn getDataHome() string
{
	return xdgGetHome("XDG_DATA_HOME", "/.local/share");
}

/*!
 * Find a configuration file.
 *
 * Uses the paths returned by `getConfigHome` and `getConfigDirs` to find
 * all matching files. The personal files (from `getConfigHome` will be first,
 * followed by the config dirs.
 *
 * @Returns A list of full paths to files that match.
 */
fn findConfigFile(tail: string) string[]
{
	files: string[];

	home := getConfigHome();
	configDirs := getConfigDirs();

	fn check(base: string)
	{
		fp := fullPath(concatenatePath(base, tail));
		if (exists(fp)) {
			files ~= fp;
		}
	}

	check(home);
	foreach (configDir; configDirs) {
		check(configDir);
	}

	return files;
}

private:

// Returns true if `path` is a valid XDG variable value.
fn valid(path: string) bool
{
	return !(path == "" || path[0] != '/');
}

// Get the value of XDG variable var, or $HOME+child.
fn xdgGetHome(var: string, child: string) string
{
	env := retrieveEnvironment();
	val := env.getOrNull(var);
	if (valid(val)) {
		return val;
	}
	home := env.getOrNull("HOME");
	if (!valid(home)) {
		return "";
	}
	return format("%s%s", home, child);
}

// Get the value of an XDG list (colon separated) `var`, or `def` if invalid.
fn xdgGetList(var: string, def: string) string[]
{
	env := retrieveEnvironment();
	val := env.getOrNull(var);
	if (!valid(val)) {
		val = def;
	}
	if (val.indexOf(':') < 0) {
		return [val];
	} else {
		return val.split(':');
	}
}
