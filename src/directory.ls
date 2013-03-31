## Module directory ####################################################
#
# Directory handling utilities.
#
#
# Copyright (c) 2013 Quildreen "Sorella" Motta <quildreen@gmail.com>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
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

### -- Dependencies ----------------------------------------------------
path  = require 'path'
fs    = require 'fs'

pinky = require 'pinky'
{lift-node} = require 'pinky-for-fun'
{pipeline, all} = require 'pinky-combinators'
{walk-tree} = require './utils'


### -- Helpers ---------------------------------------------------------

#### λ parent
# Returns the absolute parent path of the given path.
#
# :: String -> String
parent = (p) -> path.resolve p, '..'


### -- Creating directories --------------------------------------------

#### λ make
# Creates the directory defined by `path`.
#
# This fails if any of the parents of such directory are not present, or
# if the directory itself already exists. To recursively create all
# directories in a given `path`, use `make-recursive`.
#
# :: Mode -> String -> Promise String FileError
mkdir = lift-node fs.mkdir
make = (mode, path) -->
  promise = pinky!
  (mkdir path, mode).then do
                          * -> promise.fulfill path
                          * promise.reject
  return promise


#### λ make-recursive
# Creates the directory defined by `path`, and all of its pernt
# directories.
#
# :: Mode -> String -> Promise String FileError
make-recursive = (mode, path) -->
  promise = pinky!
  (make mode, path).then do
    * (_)     -> promise.fulfill path
    * (error) ->
              | already-exists error => promise.fulfill path
              | doesnt-exist error   => do
                                        p = pipeline [ (-> make mode, parent path)
                                                       (-> make mode, path) ]
                                        p.then do
                                               * -> promise.fulfill path
                                               * promise.reject
  return promise


### -- Inspecting directories ------------------------------------------

#### λ list
# Lists the contents of a directory.
#
# :: String -> Promise [String] Error
list = lift-node fs.readdir


#### λ list-recursive
# Lists the contents of a directory and all its subdirectories.
#
# :: String -> Promise [String] Error
list-recursive = (dir) ->
  return (list dir).then (files) ->
            all (files.map maybe-list . (-> path.join dir, it)) .then flatten


  function flatten(xs) => switch
    | xs.length is 0 => []
    | otherwise      => xs.reduce (++)

  function maybe-list(x) => (lift-node fs.stat) x .then (stats) ->
    | stats.is-directory x => list-recursive x
    | stats.is-file x      => pinky [x]



### -- Exports ---------------------------------------------------------
module.exports = {
  make, make-recursive
  list, list-recursive
}
