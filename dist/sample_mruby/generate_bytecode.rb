require "fileutils"
require_relative "delete_extern"

ETROBO_MRUBY_ROOT = ENV["ETROBO_MRUBY_ROOT"]
MRBC_CMD = "#{ETROBO_MRUBY_ROOT}/bin/mrbc"

# ビルドに失敗した場合に古いファイルが利用されることを防ぐために削除しておく
FileUtils.rm_f "main_task.h"
FileUtils.rm_f "tracer_task.h"

system MRBC_CMD, "-g",  "-v", "-Bbcode",  "-omain_task.h", "main_task.rb"
system MRBC_CMD, "-g",  "-v", "-Bbcode",  "-otracer_task.h", "tracer_task.rb"

# mruby 2.0.1 に含まれている不具合の対処
# 実機で使用していた最新バージョンであるため、動作実績を重視してこのバージョンを使用している
delete_extern
