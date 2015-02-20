require 'gitsh/shell_command_runner'

module Gitsh
  module Commands
    class ShellCommand
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
        [command, arg_values].flatten
      end

      def arg_values
        args.values(env)
      end
    end
  end
end
