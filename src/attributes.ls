## Module attributes ###################################################
#
# Inspects the attributes of a file system Node.
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
{lift-node} = require 'pinky-for-fun'


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
is-file = (path) -> (status path).then (.is-file!)


#### λ is-directory
# Checks if a Node is a directory node.
#
# :: String -> Promise Bool
is-directory = (path) -> (status path).then (.is-directory!)




### -- Exports ---------------------------------------------------------
module.exports = {
  status, link-status
  is-file, is-directory
}
