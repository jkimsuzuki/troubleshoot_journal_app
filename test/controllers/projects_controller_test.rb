require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @project = projects(:one)
    @user = users(:one)
    sign_in_as @user
  end

  test "should get index" do
    get projects_url
    assert_response :success
  end

  test "should get new" do
    get new_project_url
    assert_response :success
  end

  test "should create project" do
    assert_difference("Project.count") do
      post projects_url, params: { project: { description: @project.description, name: @project.name, status: @project.status } }
    end

    assert_redirected_to project_url(Project.last)
  end

  test "should show project" do
    get project_url(@project)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_url(@project)
    assert_response :success
  end

  test "should update project" do
    patch project_url(@project), params: { project: { description: @project.description, name: @project.name, status: @project.status } }
    assert_redirected_to project_url(@project)
  end

  test "should destroy project" do
    assert_difference("Project.count", -1) do
      delete project_url(@project)
    end

    assert_redirected_to projects_url
  end

  test "demo account cannot create, update, or destroy projects" do
    sign_in_as users(:demo)
    demo_project = projects(:demo)

    assert_no_difference("Project.count") do
      post projects_url, params: { project: { name: "New", description: "New", status: "Active" } }
    end

    patch project_url(demo_project), params: { project: { name: "Changed" } }
    assert_not_equal "Changed", demo_project.reload.name

    assert_no_difference("Project.count") do
      delete project_url(demo_project)
    end
  end
end
