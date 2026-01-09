module FundLoadRestrictions
  class ProcessInputChunkJob < ApplicationJob
    queue_as :default #TODO change to a more appropriate queue in production

    # @param file_path [String] path to persisted input file
    # @param chunk_index [Integer] zero-based chunk index
    # @param chunk_size [Integer] number of lines per chunk
    def perform(file_path, chunk_index, chunk_size)
      start_index = chunk_index.to_i * chunk_size.to_i
      end_index_exclusive = start_index + chunk_size.to_i
      line_index = -1

      File.open(file_path, "r") do |f|
        f.each_line do |line|
          line_index += 1
          next if line_index < start_index
          break if line_index >= end_index_exclusive

          line = line.strip
          next if line.empty?

          payload = JSON.parse(line) rescue nil
          next unless payload.is_a?(Hash)

          FundLoadRestrictions::ValidateSubmission.new(payload).call
        end
      end
    end
  end
end


