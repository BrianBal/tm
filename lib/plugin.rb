class Plugin

  def plugin_tag
    nil
  end

  def test(project)
    nil
  end

  def test?
    false
  end

  def build(project)
    nil
  end

  def build?
    false
  end

  def scm?
    false
  end

  def has_changes(project)
    nil
  end

  def update_from_remote(project)
    nil
  end

  def checkout_from_remote(project)
    nil
  end

  def before_test(project)
  end

  def after_test(project)
  end

  def before_build(project)
  end

  def after_build(project)
  end

end
