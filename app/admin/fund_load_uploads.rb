ActiveAdmin.register_page "Fund Load Uploads" do
  content do
    panel "Upload input.txt" do
      para "Upload a file where each line is a JSON object: {\"id\":\"15887\",\"customer_id\":\"528\",\"load_amount\":\"$3318.47\",\"time\":\"2000-01-01T00:00:00Z\"}"
      active_admin_form_for :fund_load_uploads, url: admin_fund_load_uploads_upload_path, html: { multipart: true } do |f|
        f.inputs do
          f.input :file, as: :file, required: true, label: "input.txt or input.json"
        end
        f.actions do
          f.action :submit, label: "Process"
        end
      end
    end

    # Show processed output.txt contents if available
    panel "Processed " do
      pre do
        results = FundLoadRestrictions::Submission.submission_with_velocity_limit_results.limit(100).to_a
        JSON.pretty_generate(results.map { |r| r.attributes.slice("id", "ext_customer_id", "accepted", "decline_reason") })
      end
    end
  end

  page_action :upload, method: :post do
    if params[:fund_load_uploads].present? && params[:fund_load_uploads][:file].present?
      #clear customers and submissions and submission results and submission sanction results
      #TODO: remove it from production , this is just for Demo.
      ActiveRecord::Base.transaction do
        FundLoadRestrictions::Submission.destroy_all
        FundLoadRestrictions::SubmissionVelocityLimitResult.destroy_all
        FundLoadRestrictions::SubmissionSanctionResult.destroy_all
        FundLoadRestrictions::Customer.destroy_all
      end
      io = params[:fund_load_uploads][:file].tempfile
      enq = FundLoadRestrictions::ProcessInputFile.new(io, chunk_size: (ENV["FUND_LOAD_CHUNK_SIZE"] || 1000)).call
      redirect_to admin_fund_load_uploads_path, notice: "Enqueued #{enq[:enqueued_chunks]} chunk jobs (#{enq[:total_lines]} lines). File stored at #{enq[:file_path]}. If available, the latest output.txt is displayed below."
    else
      redirect_to admin_fund_load_uploads_path, alert: "Please choose a file."
    end
  end
end


