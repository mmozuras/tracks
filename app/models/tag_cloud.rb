class TagCloud
  attr_reader :user, :cut_off

  def initialize(user, cut_off = nil)
    @user = user
    @cut_off = cut_off
  end

  def tags
    @tags ||= Tag.find_by_sql(sql).sort_by { |tag| tag.name.downcase }
  end

  def divisor
    levels = 10
    @divisor ||= ((tag_counts.max) / levels) + 1
  end

  private

  def tag_counts
    @tags.map { |tag| tag.count.to_i }
  end

  def sql
    cut_off ? [sql_tags, cut_off, cut_off] : sql_tags
  end

  def sql_tags
    query = "SELECT tags.id, tags.name, count(*) AS count"
    query << " FROM taggings, tags, todos"
    query << " WHERE tags.id = tag_id"
    query << " AND taggings.taggable_id = todos.id"
    query << " AND todos.user_id = " + user.id.to_s + " "
    query << " AND taggings.taggable_type='Todo' "
    query << cut_off_predicate if cut_off
    query << " GROUP BY tags.id, tags.name"
    query << " ORDER BY count DESC, name"
    query << " LIMIT 100"
    query
  end

  def cut_off_predicate
    " AND (todos.created_at > ? OR todos.completed_at > ?) "
  end
end
