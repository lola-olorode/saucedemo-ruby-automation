require "httparty"

# Minimal API client wrapper around HTTParty.
#
# Keeps HTTP calls and base-URL/header setup in one place, same rationale
# as the Page Object Model on the UI side -- specs describe *what* they're
# checking, not how the request is built.
module ApiTests
  class ApiClient
    API_BASE_URL = "https://reqres.in/api".freeze

    ApiResponse = Struct.new(:status, :body, :raw_body, :headers, :elapsed_seconds, keyword_init: true)

    def initialize(base_url: API_BASE_URL)
      @base_url = base_url
      @default_headers = { "x-api-key" => "reqres-free-v1" }
    end

    def get(path, headers: {}, query: nil)
      request(:get, path, headers: @default_headers.merge(headers), query: query)
    end

    def post(path, body:, headers: {})
      request(:post, path, headers: json_headers(headers), body: body.to_json)
    end

    def put(path, body:, headers: {})
      request(:put, path, headers: json_headers(headers), body: body.to_json)
    end

    def delete(path, headers: {})
      request(:delete, path, headers: @default_headers.merge(headers))
    end

    private

    def json_headers(extra)
      @default_headers.merge({ "Content-Type" => "application/json" }, extra)
    end

    def request(method, path, headers:, body: nil, query: nil)
      started_at = Time.now
      response = HTTParty.send(method, "#{@base_url}#{path}", headers: headers, body: body, query: query)

      ApiResponse.new(
        status: response.code,
        body: response.parsed_response,
        raw_body: response.body,
        headers: response.headers,
        elapsed_seconds: Time.now - started_at
      )
    end
  end
end
