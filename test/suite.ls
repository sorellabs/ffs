(require 'mocha-as-promised')!

path = require 'path'
chai = require 'chai'
chai.use (require 'chai-as-promised')

global.o      = it
global.expect = chai.expect
process.chdir (path.resolve __dirname, 'fixtures')

require './unit/attributes'
require './unit/directory'
require './unit/file'
require './unit/path'