## Module attributes ###################################################
#
# Inspects/mutates the attributes of a file system Node.
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
fs = require 'fs'
path = require 'path'
{lift-node} = require 'pinky-for-fun'
{pipeline, all} = require 'pinky-combinators'
{walk-tree} = require './utils'

### -- Attributes ------------------------------------------------------

#### λ status
# Returns information about a file.
#
# No permissions are required in the file itself, but `search/execute`
# permission is required on all the directories in the path that leads
# to the file.
#
# See also: `stat(2)`.
#
# :: String -> Promise Stats FileError
status = lift-node fs.stat


#### λ link-status
# Returns information about a path, without dereferencing symlinks.
#
# Otherwise, this works the same way as `status`.
#
# See also: `lstat(2)`.
#
# :: String -> Promise Stats FileError
link-status = lift-node fs.lstat


### -- File predicates -------------------------------------------------
#
# For one-off type checking on files, these provide a convenient to
# that, rather than stating and then transforming the resulting promise
# by calling the right thing on the `Stats` object.


#### λ is-file
# Checks if a Node is a file node.
#
# :: String -> Promise Bool
is-file = (path-name) -> (status path-name).then (.is-file!)


#### λ is-directory
# Checks if a Node is a directory node.
#
# :: String -> Promise Bool
is-directory = (path-name) -> (status path-name).then (.is-directory!)


### -- File ownership --------------------------------------------------

#### λ change-owner
# Changes the ownership of a single node.
#
# See also: `chown(2)`
#
# :: UserID -> GroupID -> String -> Promise String
chown = lift-node fs.chown
change-owner = (user-id, group-id, path-name) -->
  promise = pinky!
  (chown path-name, user-id, group-id).then do
                                            * -> promise.fulfill path-name
                                            * promise.reject
  return promise


#### λ change-link-owner
# Changes the ownership of a single node, without dereferencing symbolic
# links.
#
# See also: `lchown(2)`, `change-owner`
#
# :: UserID -> GroupID -> String -> Promise String
lchown = lift-node fs.lchown
change-link-owner = (user-id, group-id, path-name) -->
  promise = pinky!
  (chown path-name, user-id, group-id).then do
                                            * -> promise.fulfill path-name
                                            * promise.reject
  return promise                                       


#### λ change-owner-recursive
# Like `change-owner`, but also changes the ownership of
# sub-directories/files.
#
# :: UserID -> GroupID -> String -> Promise String
change-owner-recursive = (user-id, group-id, path-name) -->
  (path-name |> walk-tree (change-owner user-id, group-id)) .then do
    * -> promise.fulfill path-name



### -- File modes ------------------------------------------------------

#### λ change-mode
# Changes the mode of a single file node.
#
# See also: `chmod(2)`
#
# :: FileMode -> String -> Promise String
chmod = lift-node fs.chmod
change-mode = (mode, path-name) -->
  promise = pinky!
  (chmod path-name, mode).then do
                               * -> promise.fulfill path-name
                               * promise.reject
  return promise

#### λ change-link-mode
# Changes the mode of a single file node, without dereferencing symbolic
# links.
#
# See also: `lchmod(2)`
#
# :: FileMode -> String -> Promise String
lchmod = lift-node fs.lchmod
change-link-mode = (mode, path-name) -->
  promise = pinky!
  (lchmod path-name, mode).then do
                                * -> promise.fulfill path-name
                                * promise.reject
  return promise


#### λ change-mode-recursive
# Changes the mode of all files within the given path.
#
# :: FileMode -> String -> Promise String
change-mode-recursive = (mode, path-name) -->
  (path-name |> walk-tree (change-mode mode)).then do
    * -> promise.fulfill path-name
  



### -- Exports ---------------------------------------------------------
module.exports = {
  status, link-status
  is-file, is-directory
  change-owner, change-link-owner, change-owner-recursive  
  change-mode, change-link-mode, change-mode-recursive
}
