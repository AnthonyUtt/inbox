require "test_helper"
require "tmpdir"

class IdeasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dir = Dir.mktmpdir
    ENV["INBOX_WORKING_DIR"] = @dir
  end

  teardown do
    FileUtils.remove_entry(@dir) if @dir && Dir.exist?(@dir)
    ENV.delete("INBOX_WORKING_DIR")
  end

  test "GET / renders the form" do
    get root_path
    assert_response :success
    assert_select "input[type=text]"
    assert_select "textarea"
    assert_select "input[type=submit]"
  end

  test "POST /ideas with title and content writes a markdown file" do
    freeze_time do
      post ideas_path, params: { idea: { title: "My Great Idea", content: "Some details here" } },
        as: :turbo_stream

      assert_response :success

      files = Dir.glob("#{@dir}/*.md")
      assert_equal 1, files.length

      content = File.read(files.first)
      assert_match(/^---$/, content)
      assert_match(/^title: "My Great Idea"$/, content)
      assert_match(/^tags:$/, content)
      assert_match(/fleeting/, content)
      assert_match(/^# References$/, content)
      assert_match(/\[!QUOTE\] Original Capture/, content)
      assert_match(/^> Some details here$/, content)

      timestamp = Time.current.strftime("%Y-%m-%d-%H%M%S")
      assert_equal "some_details_here_#{timestamp}.md", File.basename(files.first)
    end
  end

  test "POST /ideas with blank title and content returns error toast" do
    post ideas_path, params: { idea: { title: "", content: "" } }, as: :turbo_stream

    assert_response :success
    assert_match(/Please enter an idea/, response.body)
  end

  test "POST /ideas with title only uses timestamp as filename slug" do
    freeze_time do
      post ideas_path, params: { idea: { title: "Just A Title", content: "" } }, as: :turbo_stream

      assert_response :success

      files = Dir.glob("#{@dir}/*.md")
      assert_equal 1, files.length

      timestamp = Time.current.strftime("%Y-%m-%d-%H%M%S")
      assert_equal "#{timestamp}_#{timestamp}.md", File.basename(files.first)

      content = File.read(files.first)
      assert_match(/^title: "Just A Title"$/, content)
    end
  end

  test "POST /ideas without title uses content words in filename" do
    freeze_time do
      post ideas_path, params: { idea: { title: "", content: "Some content without a title" } },
        as: :turbo_stream

      assert_response :success

      files = Dir.glob("#{@dir}/*.md")
      assert_equal 1, files.length

      timestamp = Time.current.strftime("%Y-%m-%d-%H%M%S")
      assert_equal "some_content_without_a_title_#{timestamp}.md", File.basename(files.first)

      content = File.read(files.first)
      assert_match(/Some content without a title/, content)
      refute_match(/^title:/, content)
    end
  end

  test "POST /ideas with missing directory returns error toast" do
    ENV["INBOX_WORKING_DIR"] = "/nonexistent/path"

    post ideas_path, params: { idea: { title: "Test", content: "Content" } }, as: :turbo_stream

    assert_response :success
    assert_match(/does not exist/, response.body)
  end
end
