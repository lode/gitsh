require 'shellwords'
require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class GitCommand
      def initialize(env, command, args)
        @env = env
        @command = command
        @args = args
      end

      def execute
        ShellCommandRunner.new(command_with_arguments, env).run
      end

      private

      attr_reader :env, :command, :args

      def command_with_arguments
        [git_command, config_arguments, command, arg_values].flatten
      end

      def git_command
        Shellwords.split(env.git_command)
      end

      def config_arguments
        env.config_variables.map { |k, v| ['-c', "#{k}=#{v}"] }
      end

      def arg_values
        args.values(env)
      end
    end
  end
end
