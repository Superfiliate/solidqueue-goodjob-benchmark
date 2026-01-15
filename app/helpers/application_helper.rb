module ApplicationHelper
  def duration_or_pending(duration, run: nil, show_progress: false)
    if duration.blank?
      if run&.scheduling_started_at.present?
        if show_progress
          # Show progress when scheduling is in progress (only for Scheduling column)
          progress = run.scheduling_progress || 0
          total = run.jobs_count
          return tag.span("#{progress}/#{total}", class: "badge badge-neutral badge-sm")
        else
          # Show "Working..." for Run column when scheduling is in progress
          return tag.span("Working...", class: "badge badge-neutral badge-sm")
        end
      else
        return tag.span("Enqueued", class: "badge badge-neutral badge-sm")
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

  def compact_datetime(datetime)
    return "" if datetime.nil?
    datetime.strftime("%m/%d %H:%M")
  end

  def compact_mode(mode)
    case mode
    when "in_bulk"
      "Bulk"
    when "one_by_one"
      "1-by-1"
    else
      mode.humanize
    end
  end
end
