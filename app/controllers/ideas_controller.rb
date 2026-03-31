class IdeasController < ApplicationController
  def new
  end

  def create
    body = params.require(:idea).permit(:body)[:body].to_s.strip

    if body.blank?
      return render_toast("Please enter an idea.", :error)
    end

    lines = body.lines.map(&:chomp)
    title = lines.first.strip
    content = lines.drop(1).join("\n").strip

    filename = "#{title.underscore.parameterize(separator: '_')}.md"
    dir = ENV.fetch("INBOX_WORKING_DIR", "/inbox")
    filepath = File.join(dir, filename)

    file_content = <<~MD
      ---
      created-at: #{Time.current.iso8601}
      ---

      # #{title}

      #{content}
    MD

    begin
      File.write(filepath, file_content.gsub(/^      /, ""))
    rescue Errno::ENOENT
      return render_toast("Inbox directory does not exist: #{dir}", :error)
    rescue Errno::EACCES
      return render_toast("No write permission to inbox directory: #{dir}", :error)
    rescue => e
      return render_toast("Could not save idea: #{e.message}", :error)
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("idea_form", partial: "ideas/form"),
          turbo_stream.append("toasts", partial: "ideas/toast",
            locals: { message: "Idea saved!", type: "success" })
        ]
      end
    end
  end

  private

  def render_toast(message, type)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("toasts", partial: "ideas/toast",
          locals: { message: message, type: type })
      end
    end
  end
end
