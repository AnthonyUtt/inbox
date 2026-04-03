class IdeasController < ApplicationController
  def new
  end

  def create
    idea_params = params.require(:idea).permit(:title, :content)
    title = idea_params[:title].to_s.strip
    content = idea_params[:content].to_s.strip

    if title.blank? && content.blank?
      return render_toast("Please enter an idea.", :error)
    end

    timestamp = Time.current.strftime("%Y-%m-%d-%H%M%S")
    slug = content.present? ? content.split(/\s+/).first(5).join(" ").parameterize(separator: "_") : timestamp
    filename = "#{slug}_#{timestamp}.md"
    dir = ENV.fetch("INBOX_WORKING_DIR", "/inbox")
    filepath = File.join(dir, filename)

    quoted_content = content.lines.map { |line| "> #{line.chomp}" }.join("\n")
    quoted_content = "> " if quoted_content.empty?

    title_line = title.present? ? "\ntitle: \"#{title.gsub('"', '\\"')}\"" : ""

    file_content = <<~MD
      ---
      up:#{title_line}
      tags:
        - fleeting
      ---


      # References

      > [!QUOTE] Original Capture
      #{quoted_content}
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
