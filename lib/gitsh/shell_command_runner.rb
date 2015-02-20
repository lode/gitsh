module Gitsh
  class ShellCommandRunner
    def initialize(command_with_arguments, env)
      @command_with_arguments = command_with_arguments
      @env = env
    end

    def run
      pid = Process.spawn(
        *command_with_arguments,
        out: env.output_stream.to_i,
        err: env.error_stream.to_i
      )
      wait_for_process(pid)
      $? && $?.success?
    rescue SystemCallError => e
      env.puts_error e.message
      false
    end

    private

    attr_reader :command_with_arguments, :env

    def wait_for_process(pid)
      Process.wait(pid)
    rescue Interrupt
      Process.kill('INT', pid)
      retry
    end
  end
end
