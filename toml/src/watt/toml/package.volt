// Copyright © 2017, Bernard Helyer.
// See copyright notice in src/watt/licence.volt (BOOST ver 1.0).
/*!
 * Package module for Watt's [TOML](https://github.com/toml-lang/toml) parser.
 *
 * The Watt TOML parser is mostly compliant with 0.4, except for the intentional
 * exclusion of date support. The presence of a date string in a document given
 * to this TOML parser will result in an error being generated.
 */
module watt.toml;

public import watt.toml.event;
public import watt.toml.tree;
public import watt.toml.util : TomlException;
