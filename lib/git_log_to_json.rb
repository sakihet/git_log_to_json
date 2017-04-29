require "git_log_to_json/version"
require 'json'
require 'optparse'

module GitLogToJson
  option = {}
  OptionParser.new do |opt|
    opt.on('--version', 'show version') { |v| option[:version] = v }
    opt.on('-n', '--number [NUM]', Integer, '') { |v| option[:number] = v }
    # TODO
    # opt.on('--hash') { |v| option[:hash] = v }
    # opt.on('--name') { |v| option[:name] = v }
    # opt.on('--date') { |v| option[:date] = v }
    # opt.on('--subject') { |v| option[:subject] = v }
    opt.parse!(ARGV)
  end

  def self.version
    puts GitLogToJson::VERSION
  end

  def self.print_json(dir, option)
    Dir.chdir(dir) do
      format_opts = ['%H', '%an', '%ad', '%s']
      format = format_opts.join('%x0b') + '%x07'
      cmd_base = 'git log '
      cmd_opts = ''
      if option[:number]
        cmd_opts += "-n #{option[:number]} "
      end
      cmd_opts += "--pretty=format:\"#{format}\""
      cmd = cmd_base + cmd_opts
      git_log = `#{cmd}`
      ary = []
      keys = [:hash, :author_name, :author_date, :subject]
      git_log.split("\a").each do |line|
        h = {}
        values = line.split("\v")
        values[0].gsub!(/\n/, '')
        raise Exception.new('size error') if values.size != 4
        begin
          tr  = [keys, values].transpose
          h = Hash[*tr.flatten]
          ary.push(h)
        rescue => e
          puts e
        end
      end
      puts ary.to_json
    end
  end

  if option[:version]
    version
  else
    print_json(ARGV[0], option)
  end
end
