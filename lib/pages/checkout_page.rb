require_relative "../shared/base_page"

module Pages
  class CheckoutPage < BasePage
    FIRST_NAME = [:id, "first-name"].freeze
    LAST_NAME = [:id, "last-name"].freeze
    POSTAL_CODE = [:id, "postal-code"].freeze
    CONTINUE_BUTTON = [:id, "continue"].freeze
    ERROR_MESSAGE = [:css, "[data-test='error']"].freeze

    FINISH_BUTTON = [:id, "finish"].freeze
    SUMMARY_TOTAL = [:class, "summary_total_label"].freeze

    COMPLETE_HEADER = [:class, "complete-header"].freeze

    def fill_information(first_name:, last_name:, postal_code:)
      type_text(FIRST_NAME, first_name)
      type_text(LAST_NAME, last_name)
      type_text(POSTAL_CODE, postal_code)
      click(CONTINUE_BUTTON)
      self
    end

    def error_message
      text_of(ERROR_MESSAGE)
    end

    def summary_total
      text_of(SUMMARY_TOTAL)
    end

    def finish
      click(FINISH_BUTTON)
      self
    end

    def completion_header
      text_of(COMPLETE_HEADER)
    end
  end
end
