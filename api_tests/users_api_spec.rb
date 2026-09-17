require_relative "../spec/spec_helper"
require_relative "api_client"

# API-layer test suite.
RSpec.describe "Users API" do
  let(:api) { ApiTests::ApiClient.new }
  let(:max_acceptable_response_time_seconds) { 2.0 }

  it "returns the expected shape for a single user", :smoke do
    response = api.get("/users/2")

    expect(response.status).to eq(200)
    expect(response.body["data"]).to include("first_name", "last_name", "avatar",
                                             "id" => 2, "email" => a_string_including("@"))
    expect(response.headers["Content-Type"]).to include("application/json")
    expect(response.elapsed_seconds).to be < max_acceptable_response_time_seconds
  end

  it "paginates the user list" do
    response = api.get("/users", query: { page: 1 })

    expect(response.status).to eq(200)
    body = response.body
    expect(body).to include("total", "total_pages", "page" => 1)
    expect(body["data"].length).to eq(body["per_page"])
    expect(response.elapsed_seconds).to be < max_acceptable_response_time_seconds
  end

  it "returns 404 for a nonexistent user" do
    response = api.get("/users/999")

    expect(response.status).to eq(404)
    expect(response.elapsed_seconds).to be < max_acceptable_response_time_seconds
  end

  it "returns 201 when creating a user" do
    payload = { name: "Funmilola Olorode", job: "QA Engineer" }
    response = api.post("/users", body: payload)

    expect(response.status).to eq(201)
    expect(response.body).to include("id", "createdAt", "name" => payload[:name], "job" => payload[:job])
    expect(response.headers["Content-Type"]).to include("application/json")
  end

  it "returns 200 when updating a user" do
    response = api.put("/users/2", body: { job: "Senior QA Engineer" })

    expect(response.status).to eq(200)
    expect(response.body).to include("updatedAt", "job" => "Senior QA Engineer")
  end

  it "returns 204 with an empty body when deleting a user" do
    response = api.delete("/users/2")

    expect(response.status).to eq(204)
    expect(response.raw_body).to be_nil.or eq("")
  end


  it "succeeds on a single-user lookup with no API key" do
    response = api.get("/users/2", headers: { "x-api-key" => "" })

    expect(response.status).to eq(200)
    expect(response.body["data"]["id"]).to eq(2)
  end
end
