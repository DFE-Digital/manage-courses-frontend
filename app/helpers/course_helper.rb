module CourseHelper
  def course_has_unpublished_changes(course)
    course.attributes[:content_status] == "published_with_unpublished_changes"
  end

  def course_content_tag_content(course)
    {
      "published" => "Published",
      "empty" => "Empty",
      "draft" => "Draft",
      "published_with_unpublished_changes" => "Published&nbsp;*"
    }[course.attributes[:content_status]]
  end

  def course_content_tag_css_class(course)
    {
      "published" => "phase-tag--published",
      "empty" => "phase-tag--no-content",
      "draft" => "phase-tag--draft",
      "published_with_unpublished_changes" => "phase-tag--published"
    }[course.attributes[:content_status]]
  end

  def course_ucas_status(course)
    {
      "running" => "Running",
      "new" => "New – not yet running",
      "not_running" => "Not running"
    }[course.attributes[:ucas_status]]
  end

  def course_outcome(course)
    course.qualifications.sort.map(&:upcase).join(' with ')
  end

  def course_study_mode(course)
    course.study_mode.humanize
  end

  def course_start_date(course)
    course.start_date.to_date.strftime("%B %Y")
  end

  def course_apprenticeship(course)
    course.attributes[:funding] == 'apprenticeship' ? 'Yes' : 'No'
  end

  def course_funding(course)
    case course.attributes[:funding]
    when 'salary'
      'Salaried'
    when 'apprenticeship'
      'Teaching apprenticeship (with salary)'
    when 'fee'
      'Fee paying (no salary)'
    end
  end

  def course_applications_open(course)
    course.attributes[:applications_open_from]&.to_date&.strftime("%-d %B %Y")
  end

  def course_send(course)
    course.attributes[:is_send?] == true ? 'Yes' : 'No'
  end
end
