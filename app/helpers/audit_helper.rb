# frozen_string_literal: true

module AuditHelper
  include Lipstick::Helpers::LayoutHelper

  def audit_table(audits)
    content_tag('table', class: 'ui striped compact audit table') do
      concat(audit_header)
      concat(audit_body(audits.sort_by { |a| -1 * a.created_at.to_i }))
    end
  end

  private

  def audit_header
    tr = content_tag('tr') do
      headings = %w(Record Subject Action Changes)
      headings.each { |h| concat(content_tag('th', h)) }
    end

    content_tag('thead', tr)
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
        concat(content_tag('em', ' No subject was recorded'))
      end
    end
  end

  def audit_comment_cell(audit)
    content_tag('td') do
      concat(audit.comment)
      concat(tag('br'))
      ts = content_tag('time', datetime: audit.created_at.xmlschema) do
        "#{time_ago_in_words(audit.created_at)} ago"
      end
      concat(ts)
    end
  end

  def audit_changes_cell(audit)
    return audit_creation_cell(audit) if audit.action == 'create'
    return audit_deletion_cell(audit) if audit.action == 'destroy'
    audit_update_cell(audit)
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
        v.zip(%w(Old New)).each do |(value, caption)|
          concat(audit_update_line(k, value, caption))
        end
      end
    end
  end

  def audit_update_line(field, value, caption)
    content_tag('div') do
      concat(content_tag('strong', "#{caption} #{field.titleize}: "))
      concat(value)
    end
  end
end
