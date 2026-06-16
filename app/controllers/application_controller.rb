class ApplicationController < ActionController::Base
  include Authentication

  around_action :track_response_time

  private

    def track_response_time
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

      yield

      duration =
        (
          Process.clock_gettime(Process::CLOCK_MONOTONIC) -
          start_time
        ) * 1000

      Rails.cache.write(
        "response_time_ms",
        duration.round(2)
      )
    end
end
