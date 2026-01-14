module ApplicationHelper
  def duration_or_pending(duration)
    return tag.span("Pending", class: "badge badge-neutral") if duration.blank?

    duration_seconds = duration.to_i
    if duration_seconds < 60
      "#{duration_seconds}s"
    elsif duration_seconds < 3600
      minutes = duration_seconds / 60
      seconds = duration_seconds % 60
      "#{minutes}m #{seconds}s"
    else
      distance_of_time_in_words(0, duration_seconds, include_seconds: true)
    end
  end
end
