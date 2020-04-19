require 'logger'
require_relative 'config'

$log = Logger.new(STDOUT)
$log.level = Kernel.const_get($log_level)