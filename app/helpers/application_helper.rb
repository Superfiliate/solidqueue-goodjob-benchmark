module ApplicationHelper
  def duration_or_pending(duration, run: nil)
    if duration.blank?
      if run&.scheduling_started_at.present?
        # Show progress when scheduling is in progress
        progress = run.scheduling_progress || 0
        total = run.jobs_count
        return tag.span("#{progress} / #{total}", class: "badge badge-neutral")
      else
        return tag.span("Enqueued", class: "badge badge-neutral")
      end
    end

    duration_seconds = duration.to_i
    if duration_seconds < 60
      "#{duration_seconds}s"
    elsif duration_seconds < 3600
      minutes = duration_seconds / 60
      seconds = duration_seconds % 60
      "#{minutes}m #{seconds}s"
    else
      hours = duration_seconds / 3600
      minutes = (duration_seconds % 3600) / 60
      seconds = duration_seconds % 60
      "#{hours}h #{minutes}m #{seconds}s"
    end
  end

  def jobs_count_label(count)
    return "" if count.nil?

    if count >= 1_000_000 && (count % 1_000_000).zero?
      "#{count / 1_000_000}M"
    elsif count >= 1_000 && (count % 1_000).zero?
      "#{count / 1_000}k"
    else
      count.to_s
    end
  end
end
