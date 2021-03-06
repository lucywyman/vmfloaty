# frozen_string_literal: true

class Ssh
  def self.which(cmd)
    # Gets path of executable for given command

    exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exts.each do |ext|
        exe = File.join(path, "#{cmd}#{ext}")
        return exe if File.executable?(exe) && !File.directory?(exe)
      end
    end
    nil
  end

  def self.ssh(verbose, host_os, token, url)
    ssh_path = which('ssh')
    raise 'Could not determine path to ssh' unless ssh_path

    os_types = {}
    os_types[host_os] = 1

    response = Pooler.retrieve(verbose, os_types, token, url)
    raise "Could not get vm from vmpooler:\n #{response}" unless response['ok']

    user = /win/.match?(host_os) ? 'Administrator' : 'root'

    hostname = "#{response[host_os]['hostname']}.#{response['domain']}"
    cmd = "#{ssh_path} #{user}@#{hostname}"

    # TODO: Should this respect more ssh settings? Can it be configured
    #       by users ssh config and does this respect those settings?
    Kernel.exec(cmd)
    nil
  end
end
