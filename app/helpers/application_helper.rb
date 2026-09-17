module ApplicationHelper
  # Renders a Bootstrap Icons glyph from the vendored sprite (app/assets/images/bootstrap-icons.svg).
  # Names match https://icons.getbootstrap.com/ exactly, e.g. icon("trash"), icon("pencil-square").
  def icon(name, size: 16, **options)
    options[:class] = ["bi", options[:class]].compact.join(" ")

    content_tag(:svg, width: size, height: size, fill: "currentColor", **options) do
      tag(:use, href: "#{image_path('bootstrap-icons.svg')}##{name}")
    end
  end
end
