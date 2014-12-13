module AuditHelper
  include Lipstick::Helpers::LayoutHelper

  def audit_table(audits)
    content_tag('table', class: 'ui very basic compact audit table') do
      concat(audit_header)
      concat(audit_body(audits.sort_by { |a| -1 * a.created_at.to_i }))
    end
  end

  private

  def audit_header
    content_tag('thead') do
      content_tag('tr') do
        concat(content_tag('th', 'Record'))
        concat(content_tag('th', 'Subject'))
        concat(content_tag('th', 'Action'))
        concat(content_tag('th', 'Changes'))
      end
    end
  end

  def audit_body(audits)
    content_tag('tbody') do
      audits.each { |audit| concat(audit_row(audit)) }
    end
  end

  def audit_row(audit)
    content_tag('tr') do
      concat(audit_record_name_cell(audit))
      concat(audit_user_cell(audit))
      concat(audit_comment_cell(audit))
      concat(audit_changes_cell(audit))
    end
  end

  def audit_record_name_cell(audit)
    name = "#{audit.auditable_type.underscore.titleize} ##{audit.auditable_id}"
    content_tag('td') { audit_record_link(audit, name) }
  end

  def audit_record_link(audit, name)
    return audit_record_deleted_icon(name) if audit.auditable.nil?
    link_to(name, audit.auditable)
  end

  def audit_record_deleted_icon(name)
    capture do
      concat("#{name} ")
      concat(icon_tag('red warning sign popup',
                      'data-content' => 'Record has been deleted'))
    end
  end

  def audit_user_cell(audit)
    content_tag('td') do
      if (user = audit.user)
        # TODO: Link to subject record, when we have a subjects controller
        concat(user.name)
      else
        concat(icon_tag('red warning sign'))
        concat(content_tag('em', ' No user recorded'))
      end
    end
  end

  def audit_comment_cell(audit)
    content_tag('td') do
      concat(audit.comment)
      concat('<br/>'.html_safe)
      ts = content_tag('time', datetime: audit.created_at.xmlschema) do
        "#{time_ago_in_words(audit.created_at)} ago"
      end
      concat(ts)
    end
  end

  def audit_changes_cell(audit)
    case audit.action
    when 'create'
      audit_creation_cell(audit)
    when 'destroy'
      audit_deletion_cell(audit)
    else
      audit_update_cell(audit)
    end
  end

  def audit_creation_cell(audit)
    audit_full_attributes_cell(audit, 'positive')
  end

  def audit_deletion_cell(audit)
    audit_full_attributes_cell(audit, 'negative')
  end

  def audit_full_attributes_cell(audit, css_class)
    content_tag('td', class: css_class) do
      audit.audited_changes.each do |k, v|
        div = content_tag('div') do
          concat(content_tag('strong', "#{k.titleize}: "))
          concat(v)
        end
        concat(div)
      end
    end
  end

  def audit_update_cell(audit)
    content_tag('td') do
      audit.audited_changes.each do |k, v|
        old, new = v

        concat(content_tag('strong', "Old #{k.titleize}: "))
        concat(old)

        concat('<br/>'.html_safe)

        concat(content_tag('strong', "New #{k.titleize}: "))
        concat(new)
      end
    end
  end
end
