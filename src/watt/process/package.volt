// Copyright 2016-2018, Jakob Bornecrantz.
// SPDX-License-Identifier: BSL-1.0
/*!
 * Modules for spawning new processes, reading environmental variables,
 * running and capturing the output of a command.
 */
module watt.process;

public import watt.process.cmd;
public import watt.process.pipe;
public import watt.process.spawn;
public import watt.process.group;
public import watt.process.environment;
public import watt.process.util;
