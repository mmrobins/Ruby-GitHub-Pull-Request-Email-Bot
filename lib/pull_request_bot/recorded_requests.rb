require 'fileutils'

class PullRequestBot
  class RecordedRequests
    def initialize(state_dir, repository_name)
      state_dir = File.join(File.expand_path(state_dir), repository_name)

      @open_state_file = File.join(state_dir, 'open_requests')
      @closed_state_file = File.join(state_dir, 'closed_requests')

      [@open_state_file, @closed_state_file].each do |file|
        next if File.file?(file)

        FileUtils.mkdir_p(File.dirname(file))
        FileUtils.touch(file)
      end

      @open_requests   = read_contents_from_file(@open_state_file)   || []
      @closed_requests = read_contents_from_file(@closed_state_file) || []
    end

    def open(*request_numbers)
      request_numbers.each do |request|
        @open_requests << request.to_i
        @closed_requests.delete(request)
      end

      @open_requests.compact!
      @open_requests.sort!
      @open_requests.uniq!

      flush_files
    end

    def close(*request_numbers)
      request_numbers.each do |request|
        @closed_requests << request.to_i
        @open_requests.delete(request)
      end

      @closed_requests.compact!
      @closed_requests.sort!
      @closed_requests.uniq!

      flush_files
    end

    def open?(request_number)
      @open_requests.include?(request_number)
    end

    def closed?(request_number)
      @closed_requests.include?(request_number)
    end

    private

    def flush_files
      write_contents_to_file(@open_state_file, @open_requests)
      write_contents_to_file(@closed_state_file, @closed_requests)
    end

    def write_contents_to_file(file, contents)
      File.open(file, 'w') do |f|
        f.puts contents.join("\n")
      end
    end

    def read_contents_from_file(file)
      File.readlines(file).map(&:chomp).reject(&:empty?).map(&:to_i)
    end
  end
end
