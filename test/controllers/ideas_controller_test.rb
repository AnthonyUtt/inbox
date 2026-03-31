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
    assert_select "textarea"
    assert_select "input[type=submit]"
  end

  test "POST /ideas with valid body writes a markdown file" do
    post ideas_path, params: { idea: { body: "My Great Idea\n\nSome details here" } },
      as: :turbo_stream

    assert_response :success

    files = Dir.glob("#{@dir}/*.md")
    assert_equal 1, files.length

    content = File.read(files.first)
    assert_match(/^---$/, content)
    assert_match(/^created-at: /, content)
    assert_match(/^# My Great Idea$/, content)
    assert_match(/Some details here/, content)

    assert_equal "my_great_idea.md", File.basename(files.first)
  end

  test "POST /ideas with blank body returns error toast" do
    post ideas_path, params: { idea: { body: "" } }, as: :turbo_stream

    assert_response :success
    assert_match(/Please enter an idea/, response.body)
  end

  test "POST /ideas with title only writes file with empty content" do
    post ideas_path, params: { idea: { body: "Just A Title" } }, as: :turbo_stream

    assert_response :success

    files = Dir.glob("#{@dir}/*.md")
    assert_equal 1, files.length
    assert_equal "just_a_title.md", File.basename(files.first)
  end

  test "POST /ideas with missing directory returns error toast" do
    ENV["INBOX_WORKING_DIR"] = "/nonexistent/path"

    post ideas_path, params: { idea: { body: "Test\n\nContent" } }, as: :turbo_stream

    assert_response :success
    assert_match(/does not exist/, response.body)
  end
end
