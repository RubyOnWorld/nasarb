# Define a method to find and run all tests

require 'funit/compiler'
require 'funit/functions'
require 'funit/fortran_deps'
require 'funit/assertions'
require 'funit/testsuite'

module Funit
  VERSION = '0.1.3'

  def run_tests
    Compiler.new# a test for compiler env set (remove this later)
    writeTestRunner(testSuites = parseCommandLine)
    # convert each *.fun file into a Fortran file:
    testSuites.each{ |ts| TestSuite.new(ts) }
    compileTests testSuites
    raise "Failed to execute TestRunner" unless system("./TestRunner")
  end
end

#--
# Copyright 2006 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++