module FundLoadRestrictions
  class ProcessInputFile
    DEFAULT_CHUNK_SIZE = 100

    def initialize(io, chunk_size: DEFAULT_CHUNK_SIZE)
      @io = io
      @chunk_size = (chunk_size || DEFAULT_CHUNK_SIZE).to_i
      @chunk_size = DEFAULT_CHUNK_SIZE if @chunk_size <= 0
    end

    def call
      path = persist_upload(@io)
      total_lines = count_lines(path)
      Rails.logger.info "Total lines: #{total_lines}"
      puts "total_lines: #{total_lines}"
      
      total_chunks = (total_lines.to_f / @chunk_size).ceil
      Rails.logger.info "Enqueuing #{total_chunks} chunks for file #{path}"
      enqueue_chunks(path, total_chunks)
      { file_path: path, total_lines: total_lines, chunk_size: @chunk_size, enqueued_chunks: total_chunks }
    end

    private

    def persist_upload(io)
      dir = Rails.root.join("tmp", "fund_loads")
      FileUtils.mkdir_p(dir)
      path = dir.join("input_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{$$}.txt").to_s
      File.open(path, "wb") { |f| IO.copy_stream(io, f) }
      path
    end

    def count_lines(path)
      count = 0
      File.foreach(path) { |_line| count += 1 }
      count
    end

    def enqueue_chunks(path, total_chunks)
      total_chunks.times do |chunk_index|
        FundLoadRestrictions::ProcessInputChunkJob.perform_now(path, chunk_index, @chunk_size) #TODO change to perform_later in production
      end
    end
  end
end
