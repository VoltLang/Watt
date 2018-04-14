// Copyright 2015, David Herberth.
// Copyright 2015, Bernard Helyer.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Modules for parsing [JSON](http://json.org/).
 *
 * For small and simple jobs, the @ref watt.json.dom parser is best.
 *
 * If your JSON files are large, or your needs are more complex, you can use
 * the @ref watt.json.sax parser. The DOM parser is built upon this also.
 */
module watt.json;

public import watt.json.util;
public import watt.json.sax;
public import watt.json.dom;
